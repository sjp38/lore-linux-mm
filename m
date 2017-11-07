Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9CEFE6B0261
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 20:31:48 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id 2so4035089qkg.5
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 17:31:48 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s3si83161qkd.22.2017.11.06.17.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 17:31:47 -0800 (PST)
Subject: Re: [PATCH v2 7/9] memfd-test: add 'memfd-hugetlb:' prefix when
 testing hugetlbfs
References: <20171106143944.13821-1-marcandre.lureau@redhat.com>
 <20171106143944.13821-8-marcandre.lureau@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a020e971-e84d-42aa-7523-86bbbb7244ba@oracle.com>
Date: Mon, 6 Nov 2017 17:31:39 -0800
MIME-Version: 1.0
In-Reply-To: <20171106143944.13821-8-marcandre.lureau@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

On 11/06/2017 06:39 AM, Marc-AndrA(C) Lureau wrote:
> Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

> ---
>  tools/testing/selftests/memfd/memfd_test.c | 26 ++++++++++++++++----------
>  1 file changed, 16 insertions(+), 10 deletions(-)
> 
> diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
> index cca957a06525..955d09ee16ca 100644
> --- a/tools/testing/selftests/memfd/memfd_test.c
> +++ b/tools/testing/selftests/memfd/memfd_test.c
> @@ -20,6 +20,7 @@
>  #include <unistd.h>
>  
>  #define MEMFD_STR	"memfd:"
> +#define MEMFD_HUGE_STR	"memfd-hugetlb:"
>  #define SHARED_FT_STR	"(shared file-table)"
>  
>  #define MFD_DEF_SIZE 8192
> @@ -30,6 +31,7 @@
>   */
>  static int hugetlbfs_test;
>  static size_t mfd_def_size = MFD_DEF_SIZE;
> +static const char *memfd_str = MEMFD_STR;
>  
>  /*
>   * Copied from mlock2-tests.c
> @@ -606,7 +608,7 @@ static void test_create(void)
>  	char buf[2048];
>  	int fd;
>  
> -	printf("%s CREATE\n", MEMFD_STR);
> +	printf("%s CREATE\n", memfd_str);
>  
>  	/* test NULL name */
>  	mfd_fail_new(NULL, 0);
> @@ -652,7 +654,7 @@ static void test_basic(void)
>  {
>  	int fd;
>  
> -	printf("%s BASIC\n", MEMFD_STR);
> +	printf("%s BASIC\n", memfd_str);
>  
>  	fd = mfd_assert_new("kern_memfd_basic",
>  			    mfd_def_size,
> @@ -704,7 +706,7 @@ static void test_seal_write(void)
>  {
>  	int fd;
>  
> -	printf("%s SEAL-WRITE\n", MEMFD_STR);
> +	printf("%s SEAL-WRITE\n", memfd_str);
>  
>  	fd = mfd_assert_new("kern_memfd_seal_write",
>  			    mfd_def_size,
> @@ -730,7 +732,7 @@ static void test_seal_shrink(void)
>  {
>  	int fd;
>  
> -	printf("%s SEAL-SHRINK\n", MEMFD_STR);
> +	printf("%s SEAL-SHRINK\n", memfd_str);
>  
>  	fd = mfd_assert_new("kern_memfd_seal_shrink",
>  			    mfd_def_size,
> @@ -756,7 +758,7 @@ static void test_seal_grow(void)
>  {
>  	int fd;
>  
> -	printf("%s SEAL-GROW\n", MEMFD_STR);
> +	printf("%s SEAL-GROW\n", memfd_str);
>  
>  	fd = mfd_assert_new("kern_memfd_seal_grow",
>  			    mfd_def_size,
> @@ -782,7 +784,7 @@ static void test_seal_resize(void)
>  {
>  	int fd;
>  
> -	printf("%s SEAL-RESIZE\n", MEMFD_STR);
> +	printf("%s SEAL-RESIZE\n", memfd_str);
>  
>  	fd = mfd_assert_new("kern_memfd_seal_resize",
>  			    mfd_def_size,
> @@ -808,7 +810,7 @@ static void test_share_dup(char *banner, char *b_suffix)
>  {
>  	int fd, fd2;
>  
> -	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
> +	printf("%s %s %s\n", memfd_str, banner, b_suffix);
>  
>  	fd = mfd_assert_new("kern_memfd_share_dup",
>  			    mfd_def_size,
> @@ -850,7 +852,7 @@ static void test_share_mmap(char *banner, char *b_suffix)
>  	int fd;
>  	void *p;
>  
> -	printf("%s %s %s\n", MEMFD_STR,  banner, b_suffix);
> +	printf("%s %s %s\n", memfd_str,  banner, b_suffix);
>  
>  	fd = mfd_assert_new("kern_memfd_share_mmap",
>  			    mfd_def_size,
> @@ -884,7 +886,7 @@ static void test_share_open(char *banner, char *b_suffix)
>  {
>  	int fd, fd2;
>  
> -	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
> +	printf("%s %s %s\n", memfd_str, banner, b_suffix);
>  
>  	fd = mfd_assert_new("kern_memfd_share_open",
>  			    mfd_def_size,
> @@ -927,7 +929,7 @@ static void test_share_fork(char *banner, char *b_suffix)
>  	int fd;
>  	pid_t pid;
>  
> -	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
> +	printf("%s %s %s\n", memfd_str, banner, b_suffix);
>  
>  	fd = mfd_assert_new("kern_memfd_share_fork",
>  			    mfd_def_size,
> @@ -963,7 +965,11 @@ int main(int argc, char **argv)
>  			}
>  
>  			hugetlbfs_test = 1;
> +			memfd_str = MEMFD_HUGE_STR;
>  			mfd_def_size = hpage_size * 2;
> +		} else {
> +			printf("Unknown option: %s\n", argv[1]);
> +			abort();
>  		}
>  	}
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
