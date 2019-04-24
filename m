Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 418B4C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:41:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91A9521906
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:41:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mEBl8tDK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91A9521906
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FEF86B026B; Wed, 24 Apr 2019 10:41:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D5A86B026C; Wed, 24 Apr 2019 10:41:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ED186B026D; Wed, 24 Apr 2019 10:41:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCF546B026B
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:41:04 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y2so11966974pfl.16
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:41:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=igX1xLL9nMeqo+NTRmI3R9aRPljyfwnjH88ffDsAxg4=;
        b=jHZHJUTSSV1kDv82FTHNS5762nxWTHpKe03YuEPx2u9l8qTOrwQ1YrIc6PpCcpDpIO
         97MGVnJ2LU+cy/aqAfSoR492sIPO6zfF5rwMRPOuyjd8l3SUtWbISNBrtfNmoLPlGEDb
         2srEw+iLyfW5hSbV/bVXRDO//P5IpaDFda4ahVNakYsAhXggI3us63U2singT9ixLuSu
         V1yPWzHZ6GTnF6TKwSdex272xElQ4IOBuqvmhtAQY0yjb1O9YpB3x6xqsuA8j9czoVT9
         mGBFRPDReMoHndEgu7r5WfvpNE2bebvQNLRKosF+Hr1ShnMuWPmAvn/zlDNmoAmBoG/g
         +1DA==
X-Gm-Message-State: APjAAAVK8T1hF9Oj45ED8xLmuoFr4Elj2/9Y3dVZdOxGlwguRuxLwXRB
	1jxCE2kH9eHUMlVCgp2iSqsc3UOy+oSdBJ1bGnxqfOJ6uBNkcH4JRqWDshdmQUp/ZNRm0lp4Fa+
	7uEYQG8fUodzleo4lWhT/EIccsgaZ576tbQu31eaqX3wyENuNc6uHwWVXqZCj4HkbKg==
X-Received: by 2002:a63:6ac1:: with SMTP id f184mr31640099pgc.25.1556116864542;
        Wed, 24 Apr 2019 07:41:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/NiMA1EsxTNIaTGlgP4TSFhLVBFr4wEXxVo4KDLHg0835koPpj7w1YqNA7iwrGeWaiW5w
X-Received: by 2002:a63:6ac1:: with SMTP id f184mr31640031pgc.25.1556116863564;
        Wed, 24 Apr 2019 07:41:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556116863; cv=none;
        d=google.com; s=arc-20160816;
        b=RqU2Ymel42w39oTTZ2gdfK7pewmXtQ/A1v9EjROqKRwSjAxewTYiyax6OkJ0hdcUIW
         AxZOWVWF1KhMtoG9dJr7hAHNYAumAxy8Tl8ac6Brb0oRBgmIQCa7TJSwOeT6n7cL3LoV
         cNDomApvJj0tRYR4Jww1xIwgoKnZKDtJZGuHbKTxV9X5eiTuw/i8oNAZAOKFDdoouAYd
         LjNTuHEigKRrl97/9fHvKd6v7lYnLcq6IRVeGU6eCl1B586Lz3xsy6AeOtzKIUaEfE4k
         XgbrNCl2oSv6Zr0QhwwNMNG2ivpik+rGAsyOyDb52OjptsFZSiWBShg8yFwtKgXnlP5Z
         SJUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=igX1xLL9nMeqo+NTRmI3R9aRPljyfwnjH88ffDsAxg4=;
        b=A55O67gMtzByh1Z+OBDjdJMBudtEk/7DQgjwsFcnaFmvM/g9vlnHP9u9cx9zrni8BF
         vc0U0qVD2M93Kyg/ClWBwZtc8QyeJDgECbbJcrGmQzZxmAPpCU/G3UMH66CbsqcHsLS0
         s94TIYgxB5RhOBrjLNosFy6f9snTM1PuzXTSyFVzCf5sHF6/Puc8RkIi988ALpSpVgMw
         fKSaI7FYD0FWVmMTjXHGXzUFfSXYN6DmCLx0fyMXKuslI0MQBnJrE3zVt1cAsHAcPeT8
         yDQTiWMteRcm11lTNSeddHj6Vh/MFnWjTwIUKCpf5KI5PYFspHO3TK8Rr2j0xZUZmh+k
         yuKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mEBl8tDK;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g92si11077649plg.380.2019.04.24.07.41.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:41:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mEBl8tDK;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5CF7121904;
	Wed, 24 Apr 2019 14:41:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556116863;
	bh=P54PgaAy6zckb/pxFSGEP87Ma5lcKrxq3aFFshAojtE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=mEBl8tDKcmSJkrh0PTy7wR9R392zj3xkez/Bdoggss0CFzX4vVZg7dS12Tn8A53Nl
	 Ke+pAcScZvSK0NNitq0FMB/vQdtw/+LxMq+sXHUQCmse2nzv8UsFe5QlHizp+6my+s
	 /y0dpg8hZrgzs9bx1+rtJuzM7HwrCNfSe70aEUok=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Paul Mackerras <paulus@samba.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Avi Kivity <avi@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim Krcmar <rkrcmar@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 44/52] kmemleak: powerpc: skip scanning holes in the .bss section
Date: Wed, 24 Apr 2019 10:39:02 -0400
Message-Id: <20190424143911.28890-44-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190424143911.28890-1-sashal@kernel.org>
References: <20190424143911.28890-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Catalin Marinas <catalin.marinas@arm.com>

[ Upstream commit 298a32b132087550d3fa80641ca58323c5dfd4d9 ]

Commit 2d4f567103ff ("KVM: PPC: Introduce kvm_tmp framework") adds
kvm_tmp[] into the .bss section and then free the rest of unused spaces
back to the page allocator.

kernel_init
  kvm_guest_init
    kvm_free_tmp
      free_reserved_area
        free_unref_page
          free_unref_page_prepare

With DEBUG_PAGEALLOC=y, it will unmap those pages from kernel.  As the
result, kmemleak scan will trigger a panic when it scans the .bss
section with unmapped pages.

This patch creates dedicated kmemleak objects for the .data, .bss and
potentially .data..ro_after_init sections to allow partial freeing via
the kmemleak_free_part() in the powerpc kvm_free_tmp() function.

Link: http://lkml.kernel.org/r/20190321171917.62049-1-catalin.marinas@arm.com
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Reported-by: Qian Cai <cai@lca.pw>
Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
Tested-by: Qian Cai <cai@lca.pw>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Avi Kivity <avi@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krcmar <rkrcmar@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/powerpc/kernel/kvm.c |  7 +++++++
 mm/kmemleak.c             | 16 +++++++++++-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/kernel/kvm.c b/arch/powerpc/kernel/kvm.c
index 683b5b3805bd..cd381e2291df 100644
--- a/arch/powerpc/kernel/kvm.c
+++ b/arch/powerpc/kernel/kvm.c
@@ -22,6 +22,7 @@
 #include <linux/kvm_host.h>
 #include <linux/init.h>
 #include <linux/export.h>
+#include <linux/kmemleak.h>
 #include <linux/kvm_para.h>
 #include <linux/slab.h>
 #include <linux/of.h>
@@ -712,6 +713,12 @@ static void kvm_use_magic_page(void)
 
 static __init void kvm_free_tmp(void)
 {
+	/*
+	 * Inform kmemleak about the hole in the .bss section since the
+	 * corresponding pages will be unmapped with DEBUG_PAGEALLOC=y.
+	 */
+	kmemleak_free_part(&kvm_tmp[kvm_tmp_index],
+			   ARRAY_SIZE(kvm_tmp) - kvm_tmp_index);
 	free_reserved_area(&kvm_tmp[kvm_tmp_index],
 			   &kvm_tmp[ARRAY_SIZE(kvm_tmp)], -1, NULL);
 }
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 17dd883198ae..5912a26e041c 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1501,11 +1501,6 @@ static void kmemleak_scan(void)
 	}
 	rcu_read_unlock();
 
-	/* data/bss scanning */
-	scan_large_block(_sdata, _edata);
-	scan_large_block(__bss_start, __bss_stop);
-	scan_large_block(__start_ro_after_init, __end_ro_after_init);
-
 #ifdef CONFIG_SMP
 	/* per-cpu sections scanning */
 	for_each_possible_cpu(i)
@@ -2036,6 +2031,17 @@ void __init kmemleak_init(void)
 	}
 	local_irq_restore(flags);
 
+	/* register the data/bss sections */
+	create_object((unsigned long)_sdata, _edata - _sdata,
+		      KMEMLEAK_GREY, GFP_ATOMIC);
+	create_object((unsigned long)__bss_start, __bss_stop - __bss_start,
+		      KMEMLEAK_GREY, GFP_ATOMIC);
+	/* only register .data..ro_after_init if not within .data */
+	if (__start_ro_after_init < _sdata || __end_ro_after_init > _edata)
+		create_object((unsigned long)__start_ro_after_init,
+			      __end_ro_after_init - __start_ro_after_init,
+			      KMEMLEAK_GREY, GFP_ATOMIC);
+
 	/*
 	 * This is the point where tracking allocations is safe. Automatic
 	 * scanning is started during the late initcall. Add the early logged
-- 
2.19.1

