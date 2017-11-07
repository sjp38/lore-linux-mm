Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 98E38280245
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 07:28:30 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id s144so12849378oih.5
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 04:28:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s109si513838otb.26.2017.11.07.04.28.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 04:28:29 -0800 (PST)
From: =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>
Subject: [PATCH v3 7/9] memfd-test: add 'memfd-hugetlb:' prefix when testing hugetlbfs
Date: Tue,  7 Nov 2017 13:27:58 +0100
Message-Id: <20171107122800.25517-8-marcandre.lureau@redhat.com>
In-Reply-To: <20171107122800.25517-1-marcandre.lureau@redhat.com>
References: <20171107122800.25517-1-marcandre.lureau@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com, mike.kravetz@oracle.com, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>

Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 tools/testing/selftests/memfd/memfd_test.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/tools/testing/selftests/memfd/memfd_test.c b/tools/testing/selftests/memfd/memfd_test.c
index cca957a06525..955d09ee16ca 100644
--- a/tools/testing/selftests/memfd/memfd_test.c
+++ b/tools/testing/selftests/memfd/memfd_test.c
@@ -20,6 +20,7 @@
 #include <unistd.h>
 
 #define MEMFD_STR	"memfd:"
+#define MEMFD_HUGE_STR	"memfd-hugetlb:"
 #define SHARED_FT_STR	"(shared file-table)"
 
 #define MFD_DEF_SIZE 8192
@@ -30,6 +31,7 @@
  */
 static int hugetlbfs_test;
 static size_t mfd_def_size = MFD_DEF_SIZE;
+static const char *memfd_str = MEMFD_STR;
 
 /*
  * Copied from mlock2-tests.c
@@ -606,7 +608,7 @@ static void test_create(void)
 	char buf[2048];
 	int fd;
 
-	printf("%s CREATE\n", MEMFD_STR);
+	printf("%s CREATE\n", memfd_str);
 
 	/* test NULL name */
 	mfd_fail_new(NULL, 0);
@@ -652,7 +654,7 @@ static void test_basic(void)
 {
 	int fd;
 
-	printf("%s BASIC\n", MEMFD_STR);
+	printf("%s BASIC\n", memfd_str);
 
 	fd = mfd_assert_new("kern_memfd_basic",
 			    mfd_def_size,
@@ -704,7 +706,7 @@ static void test_seal_write(void)
 {
 	int fd;
 
-	printf("%s SEAL-WRITE\n", MEMFD_STR);
+	printf("%s SEAL-WRITE\n", memfd_str);
 
 	fd = mfd_assert_new("kern_memfd_seal_write",
 			    mfd_def_size,
@@ -730,7 +732,7 @@ static void test_seal_shrink(void)
 {
 	int fd;
 
-	printf("%s SEAL-SHRINK\n", MEMFD_STR);
+	printf("%s SEAL-SHRINK\n", memfd_str);
 
 	fd = mfd_assert_new("kern_memfd_seal_shrink",
 			    mfd_def_size,
@@ -756,7 +758,7 @@ static void test_seal_grow(void)
 {
 	int fd;
 
-	printf("%s SEAL-GROW\n", MEMFD_STR);
+	printf("%s SEAL-GROW\n", memfd_str);
 
 	fd = mfd_assert_new("kern_memfd_seal_grow",
 			    mfd_def_size,
@@ -782,7 +784,7 @@ static void test_seal_resize(void)
 {
 	int fd;
 
-	printf("%s SEAL-RESIZE\n", MEMFD_STR);
+	printf("%s SEAL-RESIZE\n", memfd_str);
 
 	fd = mfd_assert_new("kern_memfd_seal_resize",
 			    mfd_def_size,
@@ -808,7 +810,7 @@ static void test_share_dup(char *banner, char *b_suffix)
 {
 	int fd, fd2;
 
-	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
+	printf("%s %s %s\n", memfd_str, banner, b_suffix);
 
 	fd = mfd_assert_new("kern_memfd_share_dup",
 			    mfd_def_size,
@@ -850,7 +852,7 @@ static void test_share_mmap(char *banner, char *b_suffix)
 	int fd;
 	void *p;
 
-	printf("%s %s %s\n", MEMFD_STR,  banner, b_suffix);
+	printf("%s %s %s\n", memfd_str,  banner, b_suffix);
 
 	fd = mfd_assert_new("kern_memfd_share_mmap",
 			    mfd_def_size,
@@ -884,7 +886,7 @@ static void test_share_open(char *banner, char *b_suffix)
 {
 	int fd, fd2;
 
-	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
+	printf("%s %s %s\n", memfd_str, banner, b_suffix);
 
 	fd = mfd_assert_new("kern_memfd_share_open",
 			    mfd_def_size,
@@ -927,7 +929,7 @@ static void test_share_fork(char *banner, char *b_suffix)
 	int fd;
 	pid_t pid;
 
-	printf("%s %s %s\n", MEMFD_STR, banner, b_suffix);
+	printf("%s %s %s\n", memfd_str, banner, b_suffix);
 
 	fd = mfd_assert_new("kern_memfd_share_fork",
 			    mfd_def_size,
@@ -963,7 +965,11 @@ int main(int argc, char **argv)
 			}
 
 			hugetlbfs_test = 1;
+			memfd_str = MEMFD_HUGE_STR;
 			mfd_def_size = hpage_size * 2;
+		} else {
+			printf("Unknown option: %s\n", argv[1]);
+			abort();
 		}
 	}
 
-- 
2.15.0.125.g8f49766d64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
