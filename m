Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91DE5C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 08:54:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57AFC20880
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 08:54:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57AFC20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C73988E0064; Thu, 21 Feb 2019 03:54:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C235F8E0002; Thu, 21 Feb 2019 03:54:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B13A48E0064; Thu, 21 Feb 2019 03:54:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A08A8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:54:29 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id 29so1712584eds.12
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 00:54:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=GSF9A7O4PI4AtpMVjfj40JgGzdBXY1OmFVOOn9kwGLE=;
        b=lbvbHKl9OWsaDqeOaXBu2xZPnUOh7DxD1YyFwV74hZp06SXdW/fGq8Dzuxp03rpewp
         zER/aGTw4xDng//pSKapM4bzG2j48O70JYKgJKUoi9jMCf9TxvBWM9pRdPDrZjY5+sos
         JtXBDVMh0reRrovbywjgvfP7NeJh5Vq4CIUrxAcSEqKc22faifxmCJwba6Q0K6JoeRmI
         82EWcdt37bMMMXt2SdpfTmLpBKkMdXWcnsAIbebDt2JvjiZZOiwGWJ7kKPaxcbp5j+Wh
         rKu//JgkwMjVPRjZ8K1sjuWVEwZCV0RRUpWghZrJjgkunIZ0/z2Z4XUYPxckDWO6wNo/
         uViA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuYRKehDAToUvBXZlbgXLg58GtcX8VvtKG7dm/iGptJIHvjMpAZf
	84y5rBHWT2fE5Z+BNs1bVWIVoHk5qWbFLkmWX+8O52Edw3pTC3Kw+VKmRz3fnN/HgRzsUAgSuoM
	og/2PVqsZh5qY4mmDYks0thV+KDs+Ag5V/nIRP+lj8RKeuCCQzB4aMUkQ3UfA2aNHjg==
X-Received: by 2002:a17:906:1fda:: with SMTP id e26mr12981471ejt.53.1550739268831;
        Thu, 21 Feb 2019 00:54:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYbe9+LZm16iVrF5CqEuntk9IVDVEUUmIm60SYqIp78bHRsIggusj23H/7GUc7YHf6CZNl2
X-Received: by 2002:a17:906:1fda:: with SMTP id e26mr12981422ejt.53.1550739267669;
        Thu, 21 Feb 2019 00:54:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550739267; cv=none;
        d=google.com; s=arc-20160816;
        b=psClLP8Y7qswwf5Qe+dPw6N63mxTGCKq7t9h8CuLS56aVoNOcuv7Na3RJVfHR1/lI3
         MwodKH/tavjWLPHbqpnJa373CT833dIQuRaXwGYbvNSsiTL8N0DSdIB3ZEzE2fyVQDYf
         WsY7wAxzuEbOd5abM4wteR6tWtNFYi/25O2YmVrQj3mJxaBJHSyem24GGyQS3btGp3KF
         6qUsw2GT+mDY/1lukEPXZgsiRRZmiCV/kn8a+Wm1ojpy+szkLtQdMHl8uduvDG9vfjD4
         S3VZDg6IoQqQKSgrxhtcLapQWRrmxg4L0EJA5agWxVW51QsK/Fs9Xd9QB5Zy/cjoWTbX
         7ARg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=GSF9A7O4PI4AtpMVjfj40JgGzdBXY1OmFVOOn9kwGLE=;
        b=uFBtfIcg11HI2Fd25ZAXw8xyog18817HgPaTrPHU5bm7CvoPl+IwFRkf4K+7KTRMbp
         IAAbAohVb6kE/r2ezyE6IsTHpArUNwCUIg2SG4WJopr8aJFepJyHZvG+pAAw6whKcaZq
         202o06mN6nF3Yp60xHWB9kA6i6EbZWwAnCc2wcUrDyQP2xbVPmHfVJEerJW1Q6tHmFPF
         3kQ+k+bFukCZ8/TVqPiYhaahrFg39aQOcpFkRv4z4vPc1PzvVlpvPI7CRy0nKz757/Pg
         bniXLGf9ubPUAFOBfdzoheorsbXNpEpBwi5D9BlY2pbEqIRa84XLFC/h2D8nOekynYW2
         xNqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id x7si5702482edh.93.2019.02.21.00.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 00:54:27 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 21 Feb 2019 09:54:26 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Thu, 21 Feb 2019 08:54:18 +0000
From: Oscar Salvador <osalvador@suse.de>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org,
	hughd@google.com,
	kirill@shutemov.name,
	vbabka@suse.cz,
	joel@joelfernandes.org,
	jglisse@redhat.com,
	yang.shi@linux.alibaba.com,
	mgorman@techsingularity.net,
	Oscar Salvador <osalvador@suse.de>
Subject: [RFC PATCH] mm,mremap: Bail out earlier in mremap_to under map pressure
Date: Thu, 21 Feb 2019 09:54:06 +0100
Message-Id: <20190221085406.10852-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When using mremap() syscall in addition to MREMAP_FIXED flag,
mremap() calls mremap_to() which does the following:

1) unmaps the destination region where we are going to move the map
2) If the new region is going to be smaller, we unmap the last part
   of the old region

Then, we will eventually call move_vma() to do the actual move.

move_vma() checks whether we are at least 4 maps below max_map_count
before going further, otherwise it bails out with -ENOMEM.
The problem is that we might have already unmapped the vma's in steps
1) and 2), so it is not possible for userspace to figure out the state
of the vma's after it gets -ENOMEM, and it gets tricky for userspace
to clean up properly on error path.

While it is true that we can return -ENOMEM for more reasons
(e.g: see may_expand_vm() or move_page_tables()), I think that we can
avoid this scenario in concret if we check early in mremap_to() if the
operation has high chances to succeed map-wise.

Should not be that the case, we can bail out before we even try to unmap
anything, so we make sure the vma's are left untouched in case we are likely
to be short of maps.

The thumb-rule now is to rely on the worst-scenario case we can have.
That is when both vma's (old region and new region) are going to be split
in 3, so we get two more maps to the ones we already hold (one per each).
If current map count + 2 maps still leads us to 4 maps below the threshold,
we are going to pass the check in move_vma().

Of course, this is not free, as it might generate false positives when it is
true that we are tight map-wise, but the unmap operation can release several
vma's leading us to a good state.

Because of that I am sending this as a RFC.
Another approach was also investigated [1], but it may be too much hassle
for what it brings.

[1] https://lore.kernel.org/lkml/20190219155320.tkfkwvqk53tfdojt@d104.suse.de/

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/mremap.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/mm/mremap.c b/mm/mremap.c
index 3320616ed93f..e3edef6b7a12 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -516,6 +516,23 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (addr + old_len > new_addr && new_addr + new_len > addr)
 		goto out;
 
+	/*
+	 * move_vma() need us to stay 4 maps below the threshold, otherwise
+	 * it will bail out at the very beginning.
+	 * That is a problem if we have already unmaped the regions here
+	 * (new_addr, and old_addr), because userspace will not know the
+	 * state of the vma's after it gets -ENOMEM.
+	 * So, to avoid such scenario we can pre-compute if the whole
+	 * operation has high chances to success map-wise.
+	 * Worst-scenario case is when both vma's (new_addr and old_addr) get
+	 * split in 3 before unmaping it.
+	 * That means 2 more maps (1 for each) to the ones we already hold.
+	 * Check whether current map count plus 2 still leads us to 4 maps below
+	 * the threshold, otherwise return -ENOMEM here to be more safe.
+	 */
+	if ((mm->map_count + 2) >= sysctl_max_map_count - 3)
+		return -ENOMEM;
+
 	ret = do_munmap(mm, new_addr, new_len, uf_unmap_early);
 	if (ret)
 		goto out;
-- 
2.13.7

