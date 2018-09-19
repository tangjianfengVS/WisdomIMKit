//========================================================================
// Mac OS X and iOS BigInteger Library
// Copyright (c) 2012 - 2014, Aequans
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//========================================================================

#ifndef BIG_INTEGER_H
#define BIG_INTEGER_H

//--------------------------------------------------------------
// Version number.
//--------------------------------------------------------------

#define BIGINT_VERSION			"1.1"
#define BIGINT_VERNUM				0x0101

//--------------------------------------------------------------
// On 32 bits architectures, a digit is represented by a 16-bit
// value and therefore bigints are expressed in base 65536. On
// 64 bits architectures, a digit is represented by a 32-bit
// value and therefore bigints are expressed in base 4294967296.
//--------------------------------------------------------------

#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64

#define SIZEOF_DIGIT		4			// A convenient definition used in the library for conditional compilation.
typedef uint32_t	bn_digit;		// A digit on a 64 bits architecture.
typedef uint64_t	bn_word;		// A double digit on a 64 bits architecture.

#else

#define SIZEOF_DIGIT		2			// A convenient definition used in the library for conditional compilation.
typedef uint16_t	bn_digit;		// A digit on a 32 bits architecture.
typedef uint32_t	bn_word;		// A double digit on a 32 bits architecture.

#endif

//--------------------------------------------------------------
// A big integer. This structure may vary as the library evolves.
// You should not directly access its members nor rely on their
// type or existence.
//--------------------------------------------------------------

typedef struct _BIGINT
{
	BOOL				sign;						// Sign (NO = positive, YES = negative)
	int					length;					// Number of digits actually used (i.e. log(n))
	int					alloc;					// Number of digits allocated.
	bn_digit	* digits;					// Digits.
}
	BIGINT;

//--------------------------------------------------------------
// The BigInteger class.
//--------------------------------------------------------------

@interface BigInteger : NSObject <NSCopying, NSCoding>
{
	BIGINT	bn;
}

- (id)initWithInt32:(int32_t)x;
- (id)initWithUnsignedInt32:(uint32_t)x;
- (id)initWithBigInteger:(BigInteger *)bigint;
- (id)initWithString:(NSString *)num radix:(int)radix;
- (id)initWithRandomNumberOfSize:(int)bitcount exact:(BOOL)exact;

+ (BigInteger *)bigintWithInt32:(int32_t)x;
+ (BigInteger *)bigintWithUnsignedInt32:(uint32_t)x;
+ (BigInteger *)bigintWithBigInteger:(BigInteger *)bigint;
+ (BigInteger *)bigintWithString:(NSString *)num radix:(int)radix;
+ (BigInteger *)bigintWithRandomNumberOfSize:(int)bitcount exact:(BOOL)exact;

- (NSString *)description;
- (NSString *)toRadix:(int)radix;
- (void)getBytes:(uint8_t *)bytes length:(int)length;
- (int32_t)intValue;
- (int64_t)longValue;

- (NSComparisonResult)compare:(BigInteger *)bigint;
- (BOOL)isEqualToBigInteger:(BigInteger *)bigint;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

- (int)sign;
- (BigInteger *)abs;
- (BigInteger *)negate;
- (BOOL)isEven;
- (BOOL)isOdd;
- (BOOL)isZero;

- (BigInteger *)add:(BigInteger *)x;
- (BigInteger *)sub:(BigInteger *)x;
- (BigInteger *)multiply:(BigInteger *)mul;
- (BigInteger *)multiply:(BigInteger *)mul modulo:(BigInteger *)mod;
- (BigInteger *)divide:(BigInteger *)div;
- (BigInteger *)divide:(BigInteger *)div remainder:(BigInteger **)rem;
- (BigInteger *)exp:(uint32_t)exp;
- (BigInteger *)exp:(BigInteger *)exp modulo:(BigInteger *)mod;

- (BigInteger *)shiftLeft:(int)count;
- (BigInteger *)shiftRight:(int)count;

- (int)bitCount;
- (BigInteger *)bitwiseNotUsingWidth:(int)count;
- (BigInteger *)bitwiseAnd:(BigInteger *)x;
- (BigInteger *)bitwiseOr:(BigInteger *)x;
- (BigInteger *)bitwiseXor:(BigInteger *)x;

- (BigInteger *)greatestCommonDivisor:(BigInteger *)bigint;
- (BigInteger *)inverseModulo:(BigInteger *)mod;

- (BOOL)isProbablePrime;
- (BigInteger *)nextProbablePrime;

@end

//--------------------------------------------------------------

#endif

//========================================================================
