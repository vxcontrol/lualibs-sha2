--sha256/384/512 hash and digest
local ffi = require'ffi'
local C = ffi.load'sha2'

if not ... then
	require'sha2_test'
	require'sha2_hmac_test'
	return
end

ffi.cdef[[
enum {
	SHA256_BLOCK_LENGTH  = 64,
	SHA256_DIGEST_LENGTH = 32,
	SHA384_BLOCK_LENGTH = 128,
	SHA384_DIGEST_LENGTH = 48,
	SHA512_BLOCK_LENGTH = 128,
	SHA512_DIGEST_LENGTH = 64,
};
typedef struct _SHA256_CTX {
	uint32_t	state[8];
	uint64_t	bitcount;
	uint8_t	buffer[SHA256_BLOCK_LENGTH];
} SHA256_CTX;
typedef struct _SHA512_CTX {
	uint64_t	state[8];
	uint64_t	bitcount[2];
	uint8_t	buffer[SHA512_BLOCK_LENGTH];
} SHA512_CTX;
typedef SHA512_CTX SHA384_CTX;

void SHA256_Init_n(SHA256_CTX *);
void SHA256_Update_n(SHA256_CTX*, const uint8_t*, size_t);
void SHA256_Final_n(uint8_t[SHA256_DIGEST_LENGTH], SHA256_CTX*);

void SHA384_Init_n(SHA384_CTX*);
void SHA384_Update_n(SHA384_CTX*, const uint8_t*, size_t);
void SHA384_Final_n(uint8_t[SHA384_DIGEST_LENGTH], SHA384_CTX*);

void SHA512_Init_n(SHA512_CTX*);
void SHA512_Update_n(SHA512_CTX*, const uint8_t*, size_t);
void SHA512_Final_n(uint8_t[SHA512_DIGEST_LENGTH], SHA512_CTX*);
]]

local function digest_function(Context, Init, Update, Final, DIGEST_LENGTH)
	return function()
		local ctx = ffi.new(Context)
		local result = ffi.new('uint8_t[?]', DIGEST_LENGTH)
		Init(ctx)
		return function(data, size)
			if data then
				Update(ctx, data, size or #data)
			else
				Final(result, ctx)
				return ffi.string(result, ffi.sizeof(result))
			end
		end
	end
end

local function hash_function(digest_function)
	return function(data, size)
		local d = digest_function(); d(data, size); return d()
	end
end

local M = {C = C}

M.sha256_digest = digest_function(ffi.typeof'SHA256_CTX', C.SHA256_Init_n, C.SHA256_Update_n, C.SHA256_Final_n, C.SHA256_DIGEST_LENGTH)
M.sha384_digest = digest_function(ffi.typeof'SHA384_CTX', C.SHA384_Init_n, C.SHA384_Update_n, C.SHA384_Final_n, C.SHA384_DIGEST_LENGTH)
M.sha512_digest = digest_function(ffi.typeof'SHA512_CTX', C.SHA512_Init_n, C.SHA512_Update_n, C.SHA512_Final_n, C.SHA512_DIGEST_LENGTH)
M.sha256 = hash_function(M.sha256_digest)
M.sha384 = hash_function(M.sha384_digest)
M.sha512 = hash_function(M.sha512_digest)

local function mkhmac(SHA, keysize)
	local HMAC = SHA..'_hmac'
	local SHA = M[SHA]
	M[HMAC] = function(message, key)
		local hmac = require'hmac'
		M[HMAC] = hmac.new(SHA, keysize)
		return M[HMAC](message, key)
	end
end
mkhmac('sha256',  64)
mkhmac('sha384', 128)
mkhmac('sha512', 128)

return M
