Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2494C43387
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 15:38:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81E1A20874
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 15:38:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2fcG53Q1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81E1A20874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33CF48E0120; Sat,  5 Jan 2019 10:38:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2ED668E00F9; Sat,  5 Jan 2019 10:38:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18EB38E0120; Sat,  5 Jan 2019 10:38:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C18AC8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 10:38:03 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id l9so28897303plt.7
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 07:38:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:from:date
         :message-id:mime-version:content-transfer-encoding;
        bh=fU6vft3hVVQEZCRQOV3YAEscJw+f6svb4ufOnAIl02E=;
        b=MPXIM+x2N6CIPqXZW+SNQ7iDPIALyO5zIYq4LywDZhDr4750uN0FmulgUaCHkDaaTQ
         5VM4E1R6UOpCdnCOfuzG3c5Ul9tgBxeLkB8NoZe5HCB5gOjv4vZhYe6wocshR7RObYpi
         klaeTTDlajJMIaxcy+pmsmu957ZQJ/A8rc8kVJNIkrX5pHbFYd12xdvM/cnk+afKZhtH
         EFwUehb4MEOlpDvoj+45mdCxAbC6goNabl+ybrz/mwpcTn/z3Z0uK5R+WuYm6zkoGBry
         18VoH5EOsuqsbPv+4IUShWVIGxFpiiTawbJIX5ORdzwAAyAtGJdduwdvCVHxgz0Ynu5P
         uHjw==
X-Gm-Message-State: AA+aEWbfXzBRMY08FVgozwsZXTFUV6c4e/A84q6c0k3vlb9t+vKlM/40
	/LO3+2prOkbCPPXB8qU42lvjZpRwDyQGn1l9ar9hn6/g6xpnXCMtLv+gNfXVaU+iTE00z2o+UXe
	btCpf6sYO2iUyjILR3sa4JbzJFlUAn5qNZLc1yZ5KYguYnA9qiIewMSJHBlZVGlM=
X-Received: by 2002:a62:e044:: with SMTP id f65mr55976916pfh.208.1546702683326;
        Sat, 05 Jan 2019 07:38:03 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6cKA2dLp8emxgFHWyl+OE71r0tyy1eLFmNYNHjhqlRPGHj+iUDcQpXKYqu8IzNzYIcCCkJ
X-Received: by 2002:a62:e044:: with SMTP id f65mr55976889pfh.208.1546702682537;
        Sat, 05 Jan 2019 07:38:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546702682; cv=none;
        d=google.com; s=arc-20160816;
        b=Z6aq/fHTFTTN6nm2769yDlxnl9ijow5ZS4Y4WNwPgenXcp3iR03hErMqKXa2JqKpUj
         OOKUiiidqbzBFdv+KXKCPcYvTVn9DrB02TRMyAjjBXpNliv09cnHgIw3zl+89q2otCv7
         6JMDolGl+xWefVqkCXtu4Ihg7/YCsos8UEumqYqchzV1kD4p4QRBZmct3483m8LkryXy
         CR/x2RNrvq5gM4jzUilzGQs8MpCo5oiKKu/1kbc3cR4yzEBHV+LUybKwDRtZw5t68hmo
         IV9oTkyd61A5mOyXklmZEwS+ZHdSRHlwbNwNMuReV/Lk/htYeN1UVr7pyjdbYkC8ugV7
         rJLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:from:cc:to
         :subject:dkim-signature;
        bh=fU6vft3hVVQEZCRQOV3YAEscJw+f6svb4ufOnAIl02E=;
        b=pWeSesayUISHxprloEnZHZpFpJRjv5ryIq39/Rg3HO5BdqxPWFzMGeiILeniD5gC1b
         3qoumkRfy/SvORteGhc8LW+k4nJ/itvQV7/7ap5dVpgIRAnilsNsqyMYg1ebHwI1FP25
         zvurgTChNLub8d5mfSMcc+UNNfuo7rL/QfyjfdVtqPlOif4JM8Ci/yHNYQSU2XuLF2oc
         g76RS+jcwn0nQ+6CZB1K5sPQrFBp0I5Qc9y+Lomhs5rWv2oTGlveVa9XSrqENHoVs9ni
         NWUuf4mA+3exsFEYFigknSWPF43bJ2SQPgM+W9n23SIseCOISwJ/2hxUppTdY9q4Kwl+
         LfyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2fcG53Q1;
       spf=pass (google.com: domain of srs0=bkkl=pn=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=bKkL=PN=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r17si56369955pgh.299.2019.01.05.07.38.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 07:38:02 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=bkkl=pn=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2fcG53Q1;
       spf=pass (google.com: domain of srs0=bkkl=pn=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=bKkL=PN=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (unknown [188.89.135.87])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8CDDA20868;
	Sat,  5 Jan 2019 15:38:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1546702682;
	bh=BEfANQWyt2ctzMeU0Ze/b0yH33JYnS7q1r5V+nuRhKY=;
	h=Subject:To:Cc:From:Date:From;
	b=2fcG53Q1czEZPrFb6h+s+Odzf6B8lYsaP2+4uw3SQicouVQyIir0g28sloz1DnpDm
	 wj/uPVVhdG6n5hpn6p3VMtbx0av3wdcdyhHnmMNuEs10WLEJtOHZltdSzOSCHcGqsO
	 /gXUjoTFfrGA432U8hYNVS9hbIJsEWFa7nwOzUUY=
Subject: Patch "x86/speculation/l1tf: Drop the swap storage limit restriction when l1tf=off" has been added to the 4.20-stable tree
To: ak@linux.intel.com,bp@suse.de,dave.hansen@intel.com,gregkh@linuxfoundation.org,jkosina@suse.cz,linux-mm@kvack.org,mhocko@suse.com,pasha.tatashin@soleen.com,tglx@linutronix.de,torvalds@linux-foundation.org
Cc: <stable-commits@vger.kernel.org>
From: <gregkh@linuxfoundation.org>
Date: Sat, 05 Jan 2019 16:32:07 +0100
Message-ID: <1546702327210248@kroah.com>
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
Message-ID: <20190105153207.WAjvjLa0j9__JxCmfi9wlTkbwmwxARZHRP0CnTfb6EI@z>


This is a note to let you know that I've just added the patch titled

    x86/speculation/l1tf: Drop the swap storage limit restriction when l1tf=off

to the 4.20-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-speculation-l1tf-drop-the-swap-storage-limit-restriction-when-l1tf-off.patch
and it can be found in the queue-4.20 subdirectory.

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
@@ -2096,6 +2096,9 @@
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
@@ -1002,7 +1002,8 @@ static void __init l1tf_select_mitigatio
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
@@ -931,7 +931,7 @@ unsigned long max_swapfile_size(void)
 
 	pages = generic_max_swapfile_size();
 
-	if (boot_cpu_has_bug(X86_BUG_L1TF)) {
+	if (boot_cpu_has_bug(X86_BUG_L1TF) && l1tf_mitigation != L1TF_MITIGATION_OFF) {
 		/* Limit the swap file size to MAX_PA/2 for L1TF workaround */
 		unsigned long long l1tf_limit = l1tf_pfn_limit();
 		/*


Patches currently in stable-queue which might be from mhocko@suse.com are

queue-4.20/x86-speculation-l1tf-drop-the-swap-storage-limit-restriction-when-l1tf-off.patch

