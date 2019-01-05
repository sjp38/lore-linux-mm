Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4ABFCC43387
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 15:35:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0002020868
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 15:35:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="S4xtRcFO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0002020868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB4978E011E; Sat,  5 Jan 2019 10:35:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C63498E00F9; Sat,  5 Jan 2019 10:35:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B79228E011E; Sat,  5 Jan 2019 10:35:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9608E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 10:35:03 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a18so31881619pga.16
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 07:35:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:from:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Io6QIiHDLZsdMZDQJoEWtF7YYQTGjo7EiY5kTtsRaGw=;
        b=gHX7HGTOQ3SkOPFquL+oBAHmQCYN/+FLdL9XrzPEPL995eArchbcILCpJnRj1SeJ5V
         ooGa4eTKlt0p1BLmGrnvdrqzHKJBqXBEcP8nY4s85oQCC3oeUYjUYFpwRvtrpobe2bLt
         pD6QNRAmdiFv3UNNdt9d3QuSP4YYhqUHslYlUKmgTI+4r2joqPq152dKRKSjYbwQvw4u
         41lHdxH5MwvcZS2etg12+tw6mmchjYGGb/XZx5DuoWE4ef5p33d7fDsXJ0QaZx2dX3ei
         Zj98dshmMxHk6Nsw1V5Rg5hOl8SdQZn4IhTpwGoJ8t8I1fUKNxC28NYvIMs0phYaUHBy
         wyhQ==
X-Gm-Message-State: AJcUukfHKYC9jjdZYoobdNbMGfL83LV9Gt/eM4JSKQRtV1AuLDcQ5tWp
	/0xWiBkqcsh9IBh4jIVpRbuLAnK7tjSCx6f53t6s1iieYtv6BEgR7O7+/1za29ojSS4pQ4wAXN9
	1/vM0x2fWyrEHHwUzoThbfm4+lxeMsHZe61qrtw7QE23b0Ik3olER6OOqN7O47vo=
X-Received: by 2002:a63:e74b:: with SMTP id j11mr5211488pgk.397.1546702502976;
        Sat, 05 Jan 2019 07:35:02 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7apnOWn5cdsGTC4MWJJ2yg50XBIZ2siERqYXOsg/c8CWtVi9CygXMw1NteY3CmtXs1BO+N
X-Received: by 2002:a63:e74b:: with SMTP id j11mr5211453pgk.397.1546702502146;
        Sat, 05 Jan 2019 07:35:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546702502; cv=none;
        d=google.com; s=arc-20160816;
        b=Yua8alDks3voq5HuwOucZrPl34zfepvkVVs7oo6ZPLMrTRemvBfSp7xJTZWMgf5Bz1
         2wZ/XKPadLbKsFp9BZn9gO3NQPK9YggXVU2bcyMAbSxwcjg8/w1pAsjS6iqo8iTrlAZU
         sx03o6P+8u1SIQErAREu7vynr8PqzjC09Br+y2Z7PdJkFslFb6hwLo2hcYGiN/pBpH0b
         2IPdQ6n8D9pRQVdoZYoxDEG5nTfclJWwcWJJuN1NlkFXJCn3c9SvSsktG+Jc5q4ovMh4
         eAab8mdy/v3WZnmcnAYW6tzJmE5TNXWXOaibb7Hqrdb6AuNnRAL+LsbMeaKSVKq7CufA
         VzJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:from:cc:to
         :subject:dkim-signature;
        bh=Io6QIiHDLZsdMZDQJoEWtF7YYQTGjo7EiY5kTtsRaGw=;
        b=AmVAgPJa1wV66O5lyBLvK2p+RMvzoe0CGcyEz7/dGRj3srrZcxTCTF6TJgisMA3OBW
         ChY/vhV6JyLI+W9k8EFrizU0QsjAcNPZZtc3RBWL5Z7Hwix+AulU8h1Osx6GEqd54PHK
         x7GJ/C6OAGYxbwBRa+8vdNSf+vgsNX0//80sBy2G5dqmDJMOUCvWKN0tHBOjeK0gEFzN
         3X5Rrr53Hkbn2EV7FBwiaq+6H6dGlJlYsWIRhOcVRF28spfTN08l84Or6nK8wFs627PS
         SOcCuuXPjSmCmE7Sl1uKYPac0i3N/CF7Z+3t24pH0epR+qFHTXle2VDFwrm+YH6yFDnI
         qQBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=S4xtRcFO;
       spf=pass (google.com: domain of srs0=bkkl=pn=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=bKkL=PN=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 1si57025810plb.103.2019.01.05.07.35.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 07:35:02 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=bkkl=pn=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=S4xtRcFO;
       spf=pass (google.com: domain of srs0=bkkl=pn=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=bKkL=PN=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (unknown [188.89.135.87])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 144FF206B6;
	Sat,  5 Jan 2019 15:35:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1546702501;
	bh=bLFjfkvhXVBb7GZEE80YAkyV0jjczVOa1SLic+/i1Sg=;
	h=Subject:To:Cc:From:Date:From;
	b=S4xtRcFOkGZCAX5CkXP/JBnJDk8bRwpAowQxC00rkNNOm6j6cOWMDBLh6WCCm8vEr
	 BWSWYHFdmkcASqOCbGRiw9EyNWXcRiZ8YSnnE8iZ1nLbDB1eyD/G+Ffptsiop9bvvD
	 bePQ7h8n4p4xnCzzFk+67UIn0RXtvipYYHH+8778=
Subject: Patch "x86/speculation/l1tf: Drop the swap storage limit restriction when l1tf=off" has been added to the 4.19-stable tree
To: ak@linux.intel.com,bp@suse.de,dave.hansen@intel.com,gregkh@linuxfoundation.org,jkosina@suse.cz,linux-mm@kvack.org,mhocko@suse.com,pasha.tatashin@soleen.com,tglx@linutronix.de,torvalds@linux-foundation.org
Cc: <stable-commits@vger.kernel.org>
From: <gregkh@linuxfoundation.org>
Date: Sat, 05 Jan 2019 16:31:44 +0100
Message-ID: <154670230458199@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-stable: commit
X-Patchwork-Hint: ignore 
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105153144.Mi1W0BxrTnQ_EjADq3XBahszho8gWfBJfV1iR9zV97M@z>


This is a note to let you know that I've just added the patch titled

    x86/speculation/l1tf: Drop the swap storage limit restriction when l1tf=off

to the 4.19-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-speculation-l1tf-drop-the-swap-storage-limit-restriction-when-l1tf-off.patch
and it can be found in the queue-4.19 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


From 5b5e4d623ec8a34689df98e42d038a3b594d2ff9 Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.com>
Date: Tue, 13 Nov 2018 19:49:10 +0100
Subject: x86/speculation/l1tf: Drop the swap storage limit restriction when l1tf=off

From: Michal Hocko <mhocko@suse.com>

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
Cc: stable@vger.kernel.org
Link: https://lkml.kernel.org/r/20181113184910.26697-1-mhocko@kernel.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 Documentation/admin-guide/kernel-parameters.txt |    3 +++
 Documentation/admin-guide/l1tf.rst              |    6 +++++-
 arch/x86/kernel/cpu/bugs.c                      |    3 ++-
 arch/x86/mm/init.c                              |    2 +-
 4 files changed, 11 insertions(+), 3 deletions(-)

--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2073,6 +2073,9 @@
 			off
 				Disables hypervisor mitigations and doesn't
 				emit any warnings.
+				It also drops the swap size and available
+				RAM limit restriction on both hypervisor and
+				bare metal.
 
 			Default is 'flush'.
 
--- a/Documentation/admin-guide/l1tf.rst
+++ b/Documentation/admin-guide/l1tf.rst
@@ -405,6 +405,9 @@ time with the option "l1tf=". The valid
 
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
--- a/arch/x86/kernel/cpu/bugs.c
+++ b/arch/x86/kernel/cpu/bugs.c
@@ -1000,7 +1000,8 @@ static void __init l1tf_select_mitigatio
 #endif
 
 	half_pa = (u64)l1tf_pfn_limit() << PAGE_SHIFT;
-	if (e820__mapped_any(half_pa, ULLONG_MAX - half_pa, E820_TYPE_RAM)) {
+	if (l1tf_mitigation != L1TF_MITIGATION_OFF &&
+			e820__mapped_any(half_pa, ULLONG_MAX - half_pa, E820_TYPE_RAM)) {
 		pr_warn("System has more than MAX_PA/2 memory. L1TF mitigation not effective.\n");
 		pr_info("You may make it effective by booting the kernel with mem=%llu parameter.\n",
 				half_pa);
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -932,7 +932,7 @@ unsigned long max_swapfile_size(void)
 
 	pages = generic_max_swapfile_size();
 
-	if (boot_cpu_has_bug(X86_BUG_L1TF)) {
+	if (boot_cpu_has_bug(X86_BUG_L1TF) && l1tf_mitigation != L1TF_MITIGATION_OFF) {
 		/* Limit the swap file size to MAX_PA/2 for L1TF workaround */
 		unsigned long long l1tf_limit = l1tf_pfn_limit();
 		/*


Patches currently in stable-queue which might be from mhocko@suse.com are

queue-4.19/x86-speculation-l1tf-drop-the-swap-storage-limit-restriction-when-l1tf-off.patch

