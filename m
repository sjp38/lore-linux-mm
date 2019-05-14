Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33E72C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 17:14:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBA042084A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 17:14:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2v16+IEg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBA042084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F7D76B0007; Tue, 14 May 2019 13:14:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 681586B0008; Tue, 14 May 2019 13:14:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 548716B000A; Tue, 14 May 2019 13:14:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 18D1D6B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 13:14:58 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id h12so10940494pll.20
        for <linux-mm@kvack.org>; Tue, 14 May 2019 10:14:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:from:date
         :message-id:mime-version:content-transfer-encoding;
        bh=DDOiBSjOKCXsAs56zFjAJ5JgNPUOb6Za8ZOiAU/hQyY=;
        b=Px7lmVmvDAnXNBjABJA2rCbJsXAUBMy9RB5knjOPHjdOHO/N+y1JKJP8lnSSfaEhW+
         FgZ0Kbte/sveBEtozFwjxOt87LfdYw127/rL2QJx35wIFxs2upi0SwqCyAz+GGrsxT3B
         oV5se97QxYwyzE0fR0UH7iDz1xCu49kbPRAzQqM23acPektFNeD7y/RMvYUM1IXtoKsC
         wjVdCPqncdE6lg5YmMyFLlt8r6qm41QOBaSCQTUGEjuMjAXIoI0GPbdT3DqqL6Iu88mC
         sUAP4ax+GE3QYOgRBmSvXaYNFwJ07PThoq8Vzh9Iwzk2OcsAoNrsTkBwPf3/GA/VN2mr
         NGwg==
X-Gm-Message-State: APjAAAWjO8hc5tqcIYLt8e0YI+XN1gA5yMKsqjYKW6ySQcZHB/6VOrih
	SDafNZ8719DnTyRMMn3lNtp04zhSh78F6AU5kDWBjIv5Gzrouv49pquSTh7LoiENOP0xha81mWw
	O1xrscl5XOKWJjVB1rso+KA/Pyz34OGiNX6kAjZhOI9jbZ4glSRFrImygs1IOdfQ3/A==
X-Received: by 2002:a63:4621:: with SMTP id t33mr38679098pga.246.1557854097428;
        Tue, 14 May 2019 10:14:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYuWtMRAw3PuDS6zW9m4AIci97dq08hi0RgfAUmuhmXTldSKu9XP7b4RL6nfGnKSvri4fg
X-Received: by 2002:a63:4621:: with SMTP id t33mr38679010pga.246.1557854096426;
        Tue, 14 May 2019 10:14:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557854096; cv=none;
        d=google.com; s=arc-20160816;
        b=kDj6ClqDfIrNtoz9GYzYGOPLiKnhczBQC/Ee+T+z0jnZR52Zy2gLjtm8lq9I/A4ET6
         6x2sosUKPhuBl/dD3aU5Z8BgTKxANAB4joV6AvmwSwY2t7b4hmbc2G+GFwM32rtSBqf5
         VEin7WCRG3qAXq7Xi2OWw9ptiEEzbZAOHS1ZRs7nH6ijkSc+HRw9RzMbFMSXHMmg/7Kw
         d3to2b+pbcK9P/SKtOisgNGpiVtGgS6m4glwkeUUsw1ULD4E2TI93TECqkEJoVLPY5R6
         GeCTwReonnscBeYVrqY7m18Z6iQScQk/NfyT5N76djDhl7YOPHCAup1TGI2pTfEfcFQn
         e1wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:from:cc:to
         :subject:dkim-signature;
        bh=DDOiBSjOKCXsAs56zFjAJ5JgNPUOb6Za8ZOiAU/hQyY=;
        b=nw9xG45KXdZrLANL6V7Sz8vxpCf05VzA1Bfhbk1h3ZR5kQaupVjoIm7t3VXUDNxYSZ
         EbmhyFvK0fr+RxpvPkmpQjyYzJvamvVi6tWQK5crP+nLz5wIrjb/2/EArwoHOqS8Rj1M
         0bKciChcVS2l+v5+y/30yMNNb7uxp+ebSmkeLH3JTEf57RkNaIqG1uHVw5/unUxzAtg7
         KlFPe0IsDa8yQtpIZJRtbZMtVUdQI1b0RokimnBOE80tae7Gtu6G5x7Zm//RuCAxyg0O
         zmwcNTduCSsmqPBvHvRHgXkx01LvEOqE/vyddD6zJQs6A7YWhT5AUeqN4TGkjwud3W4T
         uydw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2v16+IEg;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c27si2159209pfp.65.2019.05.14.10.14.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 10:14:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2v16+IEg;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 94D6120578;
	Tue, 14 May 2019 17:14:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557854096;
	bh=k5tIXMBacQ6bf0YAzV6e3q5yJtd2hJptWqrY+AY+Rcc=;
	h=Subject:To:Cc:From:Date:From;
	b=2v16+IEg/hGZJlxs+FKpZcHl4LytarYnjbu1Am/yPJGUJHU8Utbccg7/d+LuGndLN
	 YC54458nvsqPStJbcTrXdoPMyFBxbAy3uR9puTALzXMt+7yRus2OXwAnDzuc9FZ4a9
	 XH1WfttSEEULCeU8LRhGikerQ7w0PEEpmQ5K0KcM=
Subject: Patch "[PATCH 21/76] x86/speculation/l1tf: Drop the swap storage limit" has been added to the 4.9-stable tree
To: ak@linux.intel.com,ben@decadent.org.uk,bp@suse.de,dave.hansen@intel.com,gregkh@linuxfoundation.org,jkosina@suse.cz,linux-mm@kvack.org,mhocko@suse.com,pasha.tatashin@soleen.com,tglx@linutronix.de,torvalds@linux-foundation.org
Cc: <stable-commits@vger.kernel.org>
From: <gregkh@linuxfoundation.org>
Date: Tue, 14 May 2019 19:05:44 +0200
Message-ID: <155785354418960@kroah.com>
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

    [PATCH 21/76] x86/speculation/l1tf: Drop the swap storage limit

to the 4.9-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     0021-x86-speculation-l1tf-Drop-the-swap-storage-limit-res.patch
and it can be found in the queue-4.9 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


From a8f8998be737e1e6967c29dc685ad170ebc62886 Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.com>
Date: Tue, 13 Nov 2018 19:49:10 +0100
Subject: [PATCH 21/76] x86/speculation/l1tf: Drop the swap storage limit
 restriction when l1tf=off

commit 5b5e4d623ec8a34689df98e42d038a3b594d2ff9 upstream.

Swap storage is restricted to max_swapfile_size (~16TB on x86_64) whenever
the system is deemed affected by L1TF vulnerability. Even though the limit
is quite high for most deployments it seems to be too restrictive for
deployments which are willing to live with the mitigation disabled.

We have a customer to deploy 8x 6,4TB PCIe/NVMe SSD swap devices which is
clearly out of the limit.

Drop the swap restriction when l1tf=off is specified. It also doesn't make
much sense to warn about too much memory for the l1tf mitigation when it is
forcefully disabled by the administrator.

[ tglx: Folded the documentation delta change ]

Fixes: 377eeaa8e11f ("x86/speculation/l1tf: Limit swap file size to MAX_PA/2")
Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Jiri Kosina <jkosina@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: <linux-mm@kvack.org>
Link: https://lkml.kernel.org/r/20181113184910.26697-1-mhocko@kernel.org
[bwh: Backported to 4.9: adjust filenames, context]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 Documentation/kernel-parameters.txt | 3 +++
 Documentation/l1tf.rst              | 6 +++++-
 arch/x86/kernel/cpu/bugs.c          | 3 ++-
 arch/x86/mm/init.c                  | 2 +-
 4 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index a1472b48ee22..18cfc4998481 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2076,6 +2076,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			off
 				Disables hypervisor mitigations and doesn't
 				emit any warnings.
+				It also drops the swap size and available
+				RAM limit restriction on both hypervisor and
+				bare metal.
 
 			Default is 'flush'.
 
diff --git a/Documentation/l1tf.rst b/Documentation/l1tf.rst
index b85dd80510b0..9af977384168 100644
--- a/Documentation/l1tf.rst
+++ b/Documentation/l1tf.rst
@@ -405,6 +405,9 @@ time with the option "l1tf=". The valid arguments for this option are:
 
   off		Disables hypervisor mitigations and doesn't emit any
 		warnings.
+		It also drops the swap size and available RAM limit restrictions
+		on both hypervisor and bare metal.
+
   ============  =============================================================
 
 The default is 'flush'. For details about L1D flushing see :ref:`l1d_flush`.
@@ -576,7 +579,8 @@ Default mitigations
   The kernel default mitigations for vulnerable processors are:
 
   - PTE inversion to protect against malicious user space. This is done
-    unconditionally and cannot be controlled.
+    unconditionally and cannot be controlled. The swap storage is limited
+    to ~16TB.
 
   - L1D conditional flushing on VMENTER when EPT is enabled for
     a guest.
diff --git a/arch/x86/kernel/cpu/bugs.c b/arch/x86/kernel/cpu/bugs.c
index 03ebc0adcd82..803234b1845f 100644
--- a/arch/x86/kernel/cpu/bugs.c
+++ b/arch/x86/kernel/cpu/bugs.c
@@ -775,7 +775,8 @@ static void __init l1tf_select_mitigation(void)
 #endif
 
 	half_pa = (u64)l1tf_pfn_limit() << PAGE_SHIFT;
-	if (e820_any_mapped(half_pa, ULLONG_MAX - half_pa, E820_RAM)) {
+	if (l1tf_mitigation != L1TF_MITIGATION_OFF &&
+			e820_any_mapped(half_pa, ULLONG_MAX - half_pa, E820_RAM)) {
 		pr_warn("System has more than MAX_PA/2 memory. L1TF mitigation not effective.\n");
 		pr_info("You may make it effective by booting the kernel with mem=%llu parameter.\n",
 				half_pa);
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 90801a8f19c9..ce092a62fc5d 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -790,7 +790,7 @@ unsigned long max_swapfile_size(void)
 
 	pages = generic_max_swapfile_size();
 
-	if (boot_cpu_has_bug(X86_BUG_L1TF)) {
+	if (boot_cpu_has_bug(X86_BUG_L1TF) && l1tf_mitigation != L1TF_MITIGATION_OFF) {
 		/* Limit the swap file size to MAX_PA/2 for L1TF workaround */
 		unsigned long long l1tf_limit = l1tf_pfn_limit();
 		/*
-- 
2.21.0



Patches currently in stable-queue which might be from mhocko@suse.com are

queue-4.9/0021-x86-speculation-l1tf-Drop-the-swap-storage-limit-res.patch
queue-4.9/0011-x86-mm-Use-WRITE_ONCE-when-setting-PTEs.patch

