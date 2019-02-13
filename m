Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2650C282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:41:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E0D220700
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:41:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E0D220700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1ACDC8E0002; Wed, 13 Feb 2019 10:41:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 165F98E0001; Wed, 13 Feb 2019 10:41:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04B4F8E0002; Wed, 13 Feb 2019 10:41:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4A18E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 10:41:18 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id p52so1148259eda.18
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:41:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=FX2ES1Vuf0yhSbhrj7p50+8NzL0l3pf1KGAVwkV1zgk=;
        b=lnUOLUAcNSlJUaqQhpnmfQvgAl0NdKmMhPsMpbN9MW930OHpRAILk6Z/Q0t+1G1j6f
         DX5eyEsqyM1RKlnhjD/WZyaxmKTZ6NeEQd0LnFXCZ8dkwIuwp+Ldcv2OwaBqgnsjSrat
         mqEu/2TiLNwIW8AxxWfANMXLZp6cTSVxFVEQgnaTtg7SJDW8V8MXOvb8NPC8mgzOzViD
         7dYpTXtA8rSeGc1SZtpCWl5cHG1fbtU7oFIUdrnzDRafcSXa8UQTbj0gcc/RGVOjA4Px
         uvbqE5lU42rsb8QWvNIenkAoOt3dA3i5wwe1a1nIAP7uoEm4+YiiQ8ZxKv98fI8MiYod
         ABXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: AHQUAuZwz54gvglOrwrT6gCJyLSEyJFd/6+pMgUxaq8b5LBnmn32srFY
	VdF2bRD/F2BkRUX7/bp90iCeyRcdKzEGSQcbDWFcfdUWd2TMZovnPLcL+w6RvdySpN5xGf3C1EE
	k72yhjn0aRoeyR47dgr0XYBRvLFRGOu8H2bp2mPO9EI9y0XDZWv93DCkiWVLXkgdI4Q==
X-Received: by 2002:a50:9f6b:: with SMTP id b98mr399472edf.290.1550072478088;
        Wed, 13 Feb 2019 07:41:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ3p992Q0qkCgK+VrAR1ubh8HFQWTb6I1yKak6z5UYRcfCaq7FZLIYnEDt9hqBwpo9EGVun
X-Received: by 2002:a50:9f6b:: with SMTP id b98mr399394edf.290.1550072476916;
        Wed, 13 Feb 2019 07:41:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550072476; cv=none;
        d=google.com; s=arc-20160816;
        b=pFKTiql6Wx1v5DXStYYIJ+P0saC3tfOU8qrIuSQeVJEHUF+aKsLHY6vzCCLUQP7vSl
         BVvu1DtAb3/oMDRckNcK7OLeJoLcDK+lvvTUI0DRz68fQ7do4Xb9AJ6JUgbp5ahFPhsQ
         NeB3TvQcEyNJxXkaXfX1xoNCLHR+V8/IjAPbcKhd0OvkOWbZnb+6Iu9INRW9pHL+3Do9
         ta8rs6k+V/fDUDlAhLem6vjUWavdXEAEmrCRoUS+DA8YWhISHNCS2yxnAevUrJccpHMW
         NuwmLJM7OZ7yonDTNtl2cjaTL36jTFCltzPZQYsPQK3cAJ93njnDDyQlZfwE58j8j+He
         OwSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=FX2ES1Vuf0yhSbhrj7p50+8NzL0l3pf1KGAVwkV1zgk=;
        b=OyR9mcenGdbus+vi7XcaiSzzV0e4HOYBS4bLhDbof8eSZKbk51VrdiWvrOR5nv2xyW
         MlKTVZR/ALSfX3UdzK/tiMTkjNx5fQmtCRH6BU+3rGBxfKyZ2RxcNM18MZn6xeJNLw3V
         yNeNasMCwUw/+d4gi+anWwacsC5VvbvNennibwajVn8uKmVAs6q1jfDJKx8iXERen7Py
         ZbNGwyKsN+bPAN3VjjKs2qNS/at0RUxO24Jivk01m0PC32PBWLBUge8eJDuxYkY8NxST
         rm4S3w4yP1pyOPLnvaEl1fXQ2+RX/wIXJDWWG4mlSg3Frbg5Ot5QNRaPpH7zANSIyd5E
         uD9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m17si516040eje.78.2019.02.13.07.41.16
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 07:41:16 -0800 (PST)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BA079A78;
	Wed, 13 Feb 2019 07:41:15 -0800 (PST)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id CD6FD3F575;
	Wed, 13 Feb 2019 07:41:14 -0800 (PST)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: mhocko@suse.com,
	akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2] mm: Fix __dump_page() for poisoned pages
Date: Wed, 13 Feb 2019 15:41:04 +0000
Message-Id: <03b53ee9d7e76cda4b9b5e1e31eea080db033396.1550071778.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.20.1.dirty
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Evaluating page_mapping() on a poisoned page ends up dereferencing junk
and making PF_POISONED_CHECK() considerably crashier than intended:

[  107.147056] Unable to handle kernel NULL pointer dereference at virtual address 0000000000000006
[  107.155774] Mem abort info:
[  107.158546]   ESR = 0x96000005
[  107.161572]   Exception class = DABT (current EL), IL = 32 bits
[  107.167437]   SET = 0, FnV = 0
[  107.170460]   EA = 0, S1PTW = 0
[  107.173568] Data abort info:
[  107.176419]   ISV = 0, ISS = 0x00000005
[  107.180218]   CM = 0, WnR = 0
[  107.183151] user pgtable: 4k pages, 39-bit VAs, pgdp = 00000000c2f6ac38
[  107.189702] [0000000000000006] pgd=0000000000000000, pud=0000000000000000
[  107.196430] Internal error: Oops: 96000005 [#1] PREEMPT SMP
[  107.201942] Modules linked in:
[  107.204962] CPU: 2 PID: 491 Comm: bash Not tainted 5.0.0-rc1+ #1
[  107.210903] Hardware name: ARM LTD ARM Juno Development Platform/ARM Juno Development Platform, BIOS EDK II Dec 17 2018
[  107.221576] pstate: 00000005 (nzcv daif -PAN -UAO)
[  107.226321] pc : page_mapping+0x18/0x118
[  107.230200] lr : __dump_page+0x1c/0x398
[  107.233990] sp : ffffff8011a53c30
[  107.237265] x29: ffffff8011a53c30 x28: ffffffc039b6ec00
[  107.242520] x27: 0000000000000000 x26: 0000000000000000
[  107.247775] x25: 0000000056000000 x24: 0000000000000015
[  107.253029] x23: ffffff80114d8b18 x22: 0000000000000022
[  107.258283] x21: ffffffc03538ec38 x20: ffffff8011082e78
[  107.263537] x19: ffffffbf20000000 x18: 0000000000000000
[  107.268790] x17: 0000000000000000 x16: 0000000000000000
[  107.274044] x15: 0000000000000000 x14: 0000000000000000
[  107.279297] x13: 0000000000000000 x12: 0000000000000030
[  107.284550] x11: 0000000000000030 x10: 0101010101010101
[  107.289804] x9 : ff7274615e68726c x8 : 7f7f7f7f7f7f7f7f
[  107.295057] x7 : feff64756e6c6471 x6 : 0000000000008080
[  107.300310] x5 : 0000000000000000 x4 : 0000000000000000
[  107.305564] x3 : ffffffc039b6ec00 x2 : fffffffffffffffe
[  107.310817] x1 : ffffffffffffffff x0 : fffffffffffffffe
[  107.316072] Process bash (pid: 491, stack limit = 0x000000004ebd4ecd)
[  107.322442] Call trace:
[  107.324858]  page_mapping+0x18/0x118
[  107.328392]  __dump_page+0x1c/0x398
[  107.331840]  dump_page+0xc/0x18
[  107.334945]  remove_store+0xbc/0x120
[  107.338479]  dev_attr_store+0x18/0x28
[  107.342103]  sysfs_kf_write+0x40/0x50
[  107.345722]  kernfs_fop_write+0x130/0x1d8
[  107.349687]  __vfs_write+0x30/0x180
[  107.353134]  vfs_write+0xb4/0x1a0
[  107.356410]  ksys_write+0x60/0xd0
[  107.359686]  __arm64_sys_write+0x18/0x20
[  107.363565]  el0_svc_common+0x94/0xf8
[  107.367184]  el0_svc_handler+0x68/0x70
[  107.370890]  el0_svc+0x8/0xc
[  107.373737] Code: f9400401 d1000422 f240003f 9a801040 (f9400402)
[  107.379766] ---[ end trace cdb5eb5bf435cecb ]---

Fix that by not inspecting the mapping until we've determined that it's
likely to be valid. Now the above condition still ends up stopping the
kernel, but in the correct manner:

[   46.835963] page:ffffffbf20000000 is uninitialized and poisoned
[   46.835970] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
[   46.849520] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
[   46.857194] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
[   46.863170] ------------[ cut here ]------------
[   46.867736] kernel BUG at ./include/linux/mm.h:1006!
[   46.872646] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
[   46.878071] Modules linked in:
[   46.881092] CPU: 1 PID: 483 Comm: bash Not tainted 5.0.0-rc1+ #3
[   46.887032] Hardware name: ARM LTD ARM Juno Development Platform/ARM Juno Development Platform, BIOS EDK II Dec 17 2018
[   46.897704] pstate: 40000005 (nZcv daif -PAN -UAO)
[   46.902449] pc : remove_store+0xbc/0x120
[   46.906327] lr : remove_store+0xbc/0x120
...

Fixes: 1c6fb1d89e73 ("mm: print more information about mapping in __dump_page")
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---

v2: Expand commit message with logs, add Michal's ack

 mm/debug.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/debug.c b/mm/debug.c
index 0abb987dad9b..1611cf00a137 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -44,7 +44,7 @@ const struct trace_print_flags vmaflag_names[] = {
 
 void __dump_page(struct page *page, const char *reason)
 {
-	struct address_space *mapping = page_mapping(page);
+	struct address_space *mapping;
 	bool page_poisoned = PagePoisoned(page);
 	int mapcount;
 
@@ -58,6 +58,8 @@ void __dump_page(struct page *page, const char *reason)
 		goto hex_only;
 	}
 
+	mapping = page_mapping(page);
+
 	/*
 	 * Avoid VM_BUG_ON() in page_mapcount().
 	 * page->_mapcount space in struct page is used by sl[aou]b pages to
-- 
2.20.1.dirty

