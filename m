Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id E745D6B00DB
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 17:33:44 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id h11so6423889wiw.12
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 14:33:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id pl10si29510215wic.91.2014.11.12.14.33.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Nov 2014 14:33:44 -0800 (PST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 1/3] hugetlb: fix hugepages= entry in kernel-parameters.txt
Date: Wed, 12 Nov 2014 17:33:11 -0500
Message-Id: <1415831593-9020-2-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com>
References: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, rientjes@google.com, riel@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, davidlohr@hp.com

The hugepages= entry in kernel-parameters.txt states that
1GB pages can only be allocated at boot time and not
freed afterwards. This is not true since commit
944d9fec8d7aee, at least for x86_64.

Instead of adding arch-specifc observations to the
hugepages= entry, this commit just drops the out of date
information. Further information about arch-specific
support and available features can be obtained in the
hugetlb documentation.

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
---
 Documentation/kernel-parameters.txt | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 479f332..d919af0 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1228,9 +1228,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			multiple times interleaved with hugepages= to reserve
 			huge pages of different sizes. Valid pages sizes on
 			x86-64 are 2M (when the CPU supports "pse") and 1G
-			(when the CPU supports the "pdpe1gb" cpuinfo flag)
-			Note that 1GB pages can only be allocated at boot time
-			using hugepages= and not freed afterwards.
+			(when the CPU supports the "pdpe1gb" cpuinfo flag).
 
 	hvc_iucv=	[S390] Number of z/VM IUCV hypervisor console (HVC)
 			       terminal devices. Valid values: 0..8
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
