Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F5E8C43387
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 15:38:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AABD20868
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 15:38:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="iZwdnjdG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AABD20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFF468E011F; Sat,  5 Jan 2019 10:38:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C87A18E00F9; Sat,  5 Jan 2019 10:38:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B29C98E011F; Sat,  5 Jan 2019 10:38:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE758E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 10:38:00 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 68so39406927pfr.6
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 07:38:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:from:date
         :message-id:mime-version:content-transfer-encoding;
        bh=lx6Qw67kc6uRoLvcAtEc/QuHh6WBkdk6mXjCI3BU0JA=;
        b=oxoR2n4kCpEHXKV0P8qK+yG5ke/sxNynfAPe1lDMbC5Z78oP+raDvmw66dylZH+hde
         9jf1HLp1zsa42YG6SkQgTLHcxFSzL7709VN7C61+pnhyBQFs0/gKDy3CQSILeEoujQz5
         ftZU/wjSXef7lhpdqi/LRhry+i9/d54LhKuqy6q9E4IhLUjAaNp5KcWYmPZpHKmYCeAU
         0a5Zz15cLOp6RQa4JEC62mY8KutzW4Ga18p1yUXAXX4eY483QIQ/6+RpxMi5mvGiLx2s
         QMgIE2mRQ1kCi+Bptpzz37wl5DxDzydSiTe3kWO/oNxmxRk+mQgF0XQUM11vgGC7b+/X
         Ec2Q==
X-Gm-Message-State: AJcUukcTtHi1OZoZVl1thYVNHQbeq0GgUrfTnN3jLmbhW1034ufspp0u
	d0w1lSOvKr5ICSmis5+dEQ90R1GKMHzXpKe63aRYOLY6oRlXSv/rEwqNCnzo3zMKL3Exmu00QNE
	Smnj0+i25N9gPqPYtp3iAXGDfI/CAspJFVehh3/qD+D7862hOD0nC5kxi5RvGmWs=
X-Received: by 2002:a17:902:503:: with SMTP id 3mr55489325plf.233.1546702680076;
        Sat, 05 Jan 2019 07:38:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN503x53nhBlz97LwEsrfcWzj7ANn/3Fy7t50shyXYARTWcjaFF43s41tXieJGvdnuc03khE
X-Received: by 2002:a17:902:503:: with SMTP id 3mr55489303plf.233.1546702679309;
        Sat, 05 Jan 2019 07:37:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546702679; cv=none;
        d=google.com; s=arc-20160816;
        b=pHLWhVo07pnvozYOVJaulJ70Id1dWExogElOXgTE1VEd3bcCMi/SyfuyZ87SG2HfZe
         hak5U8mDvtGrzIZ6Iw7CcckEVXikBZj9psHpYuGHR0JnQBLtDfSWt9ovtIYOOwBQ8tXq
         njHbdVLjkAP3gGmR69ssdhVqvtRvimBxlg9v2ZqJe4tMc+1sbY4n1UlG9MBX1qP1Wlki
         s3hOap1KkeegVSOAlqohI2XhorAYvEvur7mn0XqbFs9QqFDtJ3wGI5fkE2dOYSNe98V/
         zcb3+9HbXKu3x//2VGNxKSyW885WUxkTd2A636PI/Lr9/4LnClFvH8fA/FNnrrRVpCgm
         5PiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:from:cc:to
         :subject:dkim-signature;
        bh=lx6Qw67kc6uRoLvcAtEc/QuHh6WBkdk6mXjCI3BU0JA=;
        b=RrK6w78uTHzRnGwwtxuRzAzB+8a6Mix4Mn68znyWR9vq43gDn33WxFJ5o4gA+G4kIj
         lOMtXOEZU3hwhGmtmvlWCKI4A25HackN8DAk1G8tF8B+DblzZh7k+HE7pVfE43JBHJzA
         ElB1VC/2pPFeQVT1r1dlB2aFYWVCmukbtaTHdKH2FE6IR7M1roIH04moUtfFHey0khCy
         Q8sumsS+/H2wzSowILrhA8EsdZcJNF0iyVdnhmQFhhDpelCzXseo1dLut4Am9Xqt2FZa
         kxGmaxDjnx6NHT8VgJHkdYZH+nS1MyGy/UiYOBfkXDVFAREE/IHvt8himBXPCnNcs5dm
         CcFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iZwdnjdG;
       spf=pass (google.com: domain of srs0=bkkl=pn=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=bKkL=PN=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n1si6581700pfh.96.2019.01.05.07.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 07:37:59 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=bkkl=pn=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iZwdnjdG;
       spf=pass (google.com: domain of srs0=bkkl=pn=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=bKkL=PN=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (unknown [188.89.135.87])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0EC762070B;
	Sat,  5 Jan 2019 15:37:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1546702678;
	bh=058a+YvDR8K5MX20P0gmXrJmsM5c1xE9fSa8Aq1dHqA=;
	h=Subject:To:Cc:From:Date:From;
	b=iZwdnjdGxTyR+nzmFMy2MCad0zH9z++RS+sLbO65ZJgPOzStKA7/+ZKitoxOfslvV
	 hgZQ/GI9xiOgEq2LuY9vshn3PQI+77+0vQRef4FxW2qOEEzFjn20MJUZIt7YGup3Le
	 riR2VRuS29wMSsUNYCDaVz8U5z6olTh0LYleXHXo=
Subject: Patch "x86/speculation/l1tf: Drop the swap storage limit restriction when l1tf=off" has been added to the 4.14-stable tree
To: ak@linux.intel.com,bp@suse.de,dave.hansen@intel.com,gregkh@linuxfoundation.org,jkosina@suse.cz,linux-mm@kvack.org,mhocko@suse.com,pasha.tatashin@soleen.com,tglx@linutronix.de,torvalds@linux-foundation.org
Cc: <stable-commits@vger.kernel.org>
From: <gregkh@linuxfoundation.org>
Date: Sat, 05 Jan 2019 16:31:21 +0100
Message-ID: <1546702281204220@kroah.com>
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
Message-ID: <20190105153121.w7HcqEkLzY9tauug3QYNv-BMM9cKR--gmdjyzXpWZ4o@z>


This is a note to let you know that I've just added the patch titled

    x86/speculation/l1tf: Drop the swap storage limit restriction when l1tf=off

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-speculation-l1tf-drop-the-swap-storage-limit-restriction-when-l1tf-off.patch
and it can be found in the queue-4.14 subdirectory.

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
@@ -1965,6 +1965,9 @@
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
@@ -999,7 +999,8 @@ static void __init l1tf_select_mitigatio
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
@@ -890,7 +890,7 @@ unsigned long max_swapfile_size(void)
 
 	pages = generic_max_swapfile_size();
 
-	if (boot_cpu_has_bug(X86_BUG_L1TF)) {
+	if (boot_cpu_has_bug(X86_BUG_L1TF) && l1tf_mitigation != L1TF_MITIGATION_OFF) {
 		/* Limit the swap file size to MAX_PA/2 for L1TF workaround */
 		unsigned long long l1tf_limit = l1tf_pfn_limit();
 		/*


Patches currently in stable-queue which might be from mhocko@suse.com are

queue-4.14/x86-speculation-l1tf-drop-the-swap-storage-limit-restriction-when-l1tf-off.patch

