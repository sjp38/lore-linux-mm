Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB966B05F2
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 12:52:06 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c2so24365456qkb.10
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 09:52:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c23si29862966qtb.154.2017.08.02.09.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 09:52:05 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/6] userfaultfd: selftest: explicit failure if the SIGBUS test failed
Date: Wed,  2 Aug 2017 18:51:42 +0200
Message-Id: <20170802165145.22628-4-aarcange@redhat.com>
In-Reply-To: <20170802165145.22628-1-aarcange@redhat.com>
References: <20170802165145.22628-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Maxime Coquelin <maxime.coquelin@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Alexey Perevalov <a.perevalov@samsung.com>

Showing zero in the output isn't very self explanatory as a successful
result. Show a more explicit error output if the test fails.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index d07156de55e8..34838d5b33f3 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -986,7 +986,9 @@ static int userfaultfd_sig_test(void)
 		return 1;
 
 	printf("done.\n");
-	printf(" Signal test userfaults: %ld\n", userfaults);
+	if (userfaults)
+		fprintf(stderr, "Signal test failed, userfaults: %ld\n",
+			userfaults);
 	close(uffd);
 	return userfaults != 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
