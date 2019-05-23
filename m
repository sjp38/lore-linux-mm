Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 046D7C04AAC
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 05:48:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A4452175B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 05:48:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="BtiFCan1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A4452175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E597D6B0003; Thu, 23 May 2019 01:48:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0B1D6B0006; Thu, 23 May 2019 01:48:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF9AD6B0007; Thu, 23 May 2019 01:48:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9790D6B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 01:48:35 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i8so3371702pfo.21
        for <linux-mm@kvack.org>; Wed, 22 May 2019 22:48:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:from:date
         :message-id:mime-version:content-transfer-encoding;
        bh=WW7bQ2HiznpUZnA8pCVDOOs99BzhAbIgChVUnh2F/zE=;
        b=T1GG8ewvkGOP9/0n6RiSbo0xPLbCKgk5hv/AlhA4/PlMHlWTO5dFO633ZN8leazNz4
         UqzwjN4988E3UTJDBsExp4IfJP8QBHdRImcLgDU8tb84Eg6o9uDr2ap5sBn8o+DjdWaq
         DhN0miWs3xJ0xKlb2mkQ5vqfzaU+RcyEqQXREYBN4xDz3PhuhHaMx6a+eeX0jyqmTiHo
         eNcFp9pMwzuJqb9YaUBLZN7zny78/xoeXtEE12BVJGhb63hGgOfGOpn/NYAexs4aPsQf
         eDiuD1/i6jlv7WOP5rVCOqMhacRS3SFkCrQSxYJv3K8/aLLH+KUYMhkChewGcSlEHYIa
         EHww==
X-Gm-Message-State: APjAAAXyevIAzbi2gdvQ2VK4Q7BcN2+nWIWmNz/OGSjH8Yed0EfffyL6
	StSc7I9qeZhvpQztxsg/SghDbGatrSMr3+AqhdfBI2GfHYyQmROm9HJxPjUcTm9kp7S1vicZJlo
	2Q1mFxsyTBqSGLFp5Q4MJ09AEurr8lNPmntvGCdGoH4oqdFx/xnDooP4mdy1WGmWKnQ==
X-Received: by 2002:a63:dc09:: with SMTP id s9mr54303236pgg.425.1558590515086;
        Wed, 22 May 2019 22:48:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/xtOY6hi6wm7zD/y/PZ9KjyCHGIV2GGGT13JjwSY9RbJuw4YUZUUr6WwQB75zRj8OmtC2
X-Received: by 2002:a63:dc09:: with SMTP id s9mr54303166pgg.425.1558590514329;
        Wed, 22 May 2019 22:48:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558590514; cv=none;
        d=google.com; s=arc-20160816;
        b=Kka+WllMXBurRHay4LE4qyzBjO4FEpCYP/ElAUCLrmXfYfi7MiI7RyR5us1ZnKwdOg
         M1s0nagEh3n0BDqIb9hiGxCr7+mv5IptMfC7xtMIkNEN+DaHlv/YKjN630NF5cqSP8Eb
         wsZeVKiYQN/ZJhV37YOOaiq9r2JVXEyCJoJqb5Jgy2fdhQvb/MbCeAMCdQ/9ko7voJbF
         3ziu5oqTJuERHfPbmX+kH8iJG2Vh+n3hPAlFR9itG7/DUPs463bc3jSdTlZ7hD+vkY82
         21t3+RE1dB5oE1dmfO+uqZ56EbFY0ifOriQ1kmHXcfR8w7Ct4jZa1otKcFfgapyRBAzr
         Aulg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:from:cc:to
         :subject:dkim-signature;
        bh=WW7bQ2HiznpUZnA8pCVDOOs99BzhAbIgChVUnh2F/zE=;
        b=qfSwqGIgxIw+zh3kYa3GORcIY8ks5jp341qeD0x31spJHj0a5m4jC4Q5HeImqkVBuJ
         LpQJZHXDr49UWPuixCrvmxgTsD77vg7WMPJbBSojSv4kdm32yerjowfw+NiC+wzk+AGv
         yodVu3nl5WQC/Ku5dUlnJ480w8Hpa7uJ6cMrkYYubAiJoeeMNSUfThNILgJoMC9pL6KP
         umNb2b//28z8MygqUT0Nfuu4W2PNoL1cVfhu4UcpiKdND2y7yBN7z5X3fGVaYoTCNuB5
         6MAv3JzQiLZi2H7yMUAfr7twNV0lhYi1zDwn6NzgmHyJKITKksh/5ObfM4ltLuAwn6b3
         8bKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BtiFCan1;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y9si29495571pgj.57.2019.05.22.22.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 22:48:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BtiFCan1;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 380AB21019;
	Thu, 23 May 2019 05:48:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558590513;
	bh=AqqZ+h/nX28a1Z7QWDOUfDueXx9PWYLYzMDsnAoj350=;
	h=Subject:To:Cc:From:Date:From;
	b=BtiFCan1hK7d78s1BFuJMzp6dVdSwtVTbsmPlAFfHvmASr57zElCMAqPG8U2gJXTi
	 Whjg9/7Ap3RIWgR0GU7iE/BYxF5LXefzN25JhRPV+Fy70PvDnpeqwtNC5wRP6RuIeX
	 m3zibFz86dd5sa24fJSYi1gwJZ/w298XLN07tJjk=
Subject: Patch "mm/gup: Remove the 'write' parameter from gup_fast_permitted()" has been added to the 5.0-stable tree
To: 20190210223424.13934-1-ira.weiny@intel.com,akpm@linux-foundation.org,bp@alien8.de,dan.j.williams@intel.com,dave.hansen@intel.com,gregkh@linuxfoundation.org,ira.weiny@intel.com,jmforbes@linuxtx.org,kirill.shutemov@linux.intel.com,linux-mm@kvack.org,mingo@kernel.org,peterz@infradead.org,tglx@linutronix.de,torvalds@linux-foundation.org
Cc: <stable-commits@vger.kernel.org>
From: <gregkh@linuxfoundation.org>
Date: Thu, 23 May 2019 07:48:31 +0200
Message-ID: <1558590511976@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
X-stable: commit
X-Patchwork-Hint: ignore 
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


This is a note to let you know that I've just added the patch titled

    mm/gup: Remove the 'write' parameter from gup_fast_permitted()

to the 5.0-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     mm-gup-remove-the-write-parameter-from-gup_fast_permitted.patch
and it can be found in the queue-5.0 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


From ad8cfb9c42ef83ecf4079bc7d77e6557648e952b Mon Sep 17 00:00:00 2001
From: Ira Weiny <ira.weiny@intel.com>
Date: Sun, 10 Feb 2019 14:34:24 -0800
Subject: mm/gup: Remove the 'write' parameter from gup_fast_permitted()

From: Ira Weiny <ira.weiny@intel.com>

commit ad8cfb9c42ef83ecf4079bc7d77e6557648e952b upstream.

The 'write' parameter is unused in gup_fast_permitted() so remove it.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20190210223424.13934-1-ira.weiny@intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Cc: Justin Forbes <jmforbes@linuxtx.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/pgtable_64.h |    3 +--
 mm/gup.c                          |    6 +++---
 2 files changed, 4 insertions(+), 5 deletions(-)

--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -259,8 +259,7 @@ extern void init_extra_mapping_uc(unsign
 extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
 
 #define gup_fast_permitted gup_fast_permitted
-static inline bool gup_fast_permitted(unsigned long start, int nr_pages,
-		int write)
+static inline bool gup_fast_permitted(unsigned long start, int nr_pages)
 {
 	unsigned long len, end;
 
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1811,7 +1811,7 @@ static void gup_pgd_range(unsigned long
  * Check if it's allowed to use __get_user_pages_fast() for the range, or
  * we need to fall back to the slow version:
  */
-bool gup_fast_permitted(unsigned long start, int nr_pages, int write)
+bool gup_fast_permitted(unsigned long start, int nr_pages)
 {
 	unsigned long len, end;
 
@@ -1853,7 +1853,7 @@ int __get_user_pages_fast(unsigned long
 	 * block IPIs that come from THPs splitting.
 	 */
 
-	if (gup_fast_permitted(start, nr_pages, write)) {
+	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_save(flags);
 		gup_pgd_range(start, end, write, pages, &nr);
 		local_irq_restore(flags);
@@ -1895,7 +1895,7 @@ int get_user_pages_fast(unsigned long st
 	if (unlikely(!access_ok((void __user *)start, len)))
 		return -EFAULT;
 
-	if (gup_fast_permitted(start, nr_pages, write)) {
+	if (gup_fast_permitted(start, nr_pages)) {
 		local_irq_disable();
 		gup_pgd_range(addr, end, write, pages, &nr);
 		local_irq_enable();


Patches currently in stable-queue which might be from ira.weiny@intel.com are

queue-5.0/mm-gup-remove-the-write-parameter-from-gup_fast_permitted.patch

