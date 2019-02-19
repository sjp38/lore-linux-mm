Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1359C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 05:26:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 565772173C
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 05:26:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IFdYJ03B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 565772173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5C1B8E0003; Tue, 19 Feb 2019 00:26:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E5308E0002; Tue, 19 Feb 2019 00:26:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 886D78E0003; Tue, 19 Feb 2019 00:26:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 596A18E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 00:26:57 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id f15so16671648otl.17
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 21:26:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:user-agent:mime-version;
        bh=Nn7jvN56Aij59rB16XbFytNtDnwP8hvfDgxfVmhsN+4=;
        b=cAYN2QqGdnvravZNI0aDQMq10JokGoaiMGFUW64dnOvs3iyCanq7LuPld21VJDYVzB
         0Y5sUZAx104FeNpNRCgWh4anoo5FSDXxCKjIAUZM6zhqURc34ZhZpMLAkOwMEVI7NpY9
         6OF1eAckPvEgV8xxnzN3KIjbxLFzPV0LbEaVH/2Zy3XkjUBUdFHwqL40T9XEVUkaxsNR
         7fIUvNhjmt4Nd02F2vrQEhPtBVoF9fja+VhlZ1dZd/vPruNi/8aVGhYjChM+z/VbGvsk
         i++xTgpG5QsDXle56wpl6TNdYjx+NdhuoNVJ8+/IFEypdAquhHwvfuMblSpaZyZef1HG
         US8A==
X-Gm-Message-State: AHQUAuYfKGJAqFaaNwgFxzMA24HbOnwPKwkKW1IQEwLMXDuOkvYf8m6H
	Ie7CSFw+kcryGUIcIdtcuS15ZEE/glimwTryCmb7OUGovBn5WsedvxsPy5tHggLKPbEv9itXP4b
	grgXXhAc/NgToRfw+gxJMOnhb1qHHlFJkQ8IKjylS2gyNPyKF26gK1LbK9BRPdkQFPwpxrVsyVr
	HFH7sdukn+JioDK2pFMUgaj5Sek9v9BdvGcNVSl9CMoV9Sy0gtYV4OBdB3iI8du6CBqCKe0Q6PL
	PQYbxWJOZRxZx5Au+URnHuj4g/QPrOX1PtF5zlzkQIIRytsEsJPim6RrYp6Y54X2h1Uc9STcXH+
	j0sVyUE2qakV0dVUE1VGl/Zb1ozAxnSgVNjbbp8OsnobE5UaSRthC4Ac/FLExp5k+Vl+VpZRdn3
	c
X-Received: by 2002:a9d:64cb:: with SMTP id n11mr17734294otl.314.1550554017023;
        Mon, 18 Feb 2019 21:26:57 -0800 (PST)
X-Received: by 2002:a9d:64cb:: with SMTP id n11mr17734272otl.314.1550554016222;
        Mon, 18 Feb 2019 21:26:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550554016; cv=none;
        d=google.com; s=arc-20160816;
        b=zBKyXkZ5K1BVuZJzHlEiPXKWSUoW4Z2bMWl1nEU7DOafKBEW9dTHW3k6OUF7vIPuI3
         V8xuAbCNbS1JvAIICoQKTOZ5ZuZkJZeN+m9CYYWAWK/ZePyuFdOhXkLgou6azgCMLqiX
         hkrRZKFRHktztOD41r+lvAYAQdahTTFufReK5Z21ToIMEdpovSoUm+K8ermlOozUGSrZ
         H1SX6FTQ8r9w2kI5ABXhqkhDCruZ0E2epe56kkbupNfo7elZ3GaTG/kF/LczPpW1Ptou
         2KKWOaWXAIjV1XswpxPujmDNOcCgR2kO7B3TJ9lcFXpn4hlUoEE5Qb0evWK+DSGsfONq
         DDag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:subject:cc:to:from:date
         :dkim-signature;
        bh=Nn7jvN56Aij59rB16XbFytNtDnwP8hvfDgxfVmhsN+4=;
        b=b+TElnFF62eVk1PMZoz/z/xx59tfcuqtm8WCE8PCI4xTvI9mui6jw5aXiUP2cBPf9F
         XSPMTdt2TABlOrqXwZUJba1WMT3G/cm7seOyMuOyyI2k10y9gJWVqHKjDsdTtUsOboRj
         c7ssVXnlOAuo9I6GldZi2WY/gqozyRx0ZRsZ/d32WlSmVV09K7he4GgbTkQZCapfzQGv
         50+Mu0rm60cA9HWPWVoMCpoHd4O4Yw5jZ1kbhyyvePnEnVcJQs1huuw/kBQqisT1KOrx
         fpcs53BMrSZYUxlhbXIikYxmjtFyCMB/WraoW1iOUSBmDnX+/7ntM17aWyeP5i77ARA2
         7dqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IFdYJ03B;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e17sor6808974oih.145.2019.02.18.21.26.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 21:26:56 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IFdYJ03B;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:user-agent:mime-version;
        bh=Nn7jvN56Aij59rB16XbFytNtDnwP8hvfDgxfVmhsN+4=;
        b=IFdYJ03BUDOzKwP2gwBMlbooLzhGcLWZDVHmjwf9ZDSeSb+YuYEGtkaLmxWFwwlZPR
         zwVwFZ+IOC7/n4lzvQakHGbrUJk89//jhxZ0sQaWVSlZhVBNAOhSG6DECh90OQzP4/eC
         XCIE1bIk3WjqwBojZ+FBcre0vLgYdYQgXFbYLXYDQICZM1QP+f1Q+H7FIqmERzIYSZfP
         lahbNq61TkIsedWlXZ5jxkvapFFvMNzxamYa/bvUX8WDx1GEObw32T4lymRSlWFSGNno
         cz2TeQ4ajPJDc3Mi91VFPnu5xz6A8FY1AY0DY0TRCpexK5I0DDXZXvwIKPLM9/Fk6+i4
         8GOA==
X-Google-Smtp-Source: AHgI3IZP4FYhFOb0TC+x7B0bKWbbezKsrPAqVG/zOjPc10LzdCDMZ0Y8xraBhpTywalhPMH/5SBlUg==
X-Received: by 2002:aca:33d5:: with SMTP id z204mr1399324oiz.61.1550554015453;
        Mon, 18 Feb 2019 21:26:55 -0800 (PST)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id y137sm2154861oia.9.2019.02.18.21.26.53
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Feb 2019 21:26:54 -0800 (PST)
Date: Mon, 18 Feb 2019 21:26:46 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Andrew Morton <akpm@linux-foundation.org>
cc: Yang Shi <yang.shi@linux.alibaba.com>, ktkhai@virtuozzo.com, 
    jhubbard@nvidia.com, hughd@google.com, aarcange@redhat.com, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [PATCH mmotm] mm: ksm: do not block on page lock when searching
 stable tree fix
Message-ID: <alpine.LSU.2.11.1902182122280.6914@eggly.anvils>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I hit the kernel BUG at mm/ksm.c:809! quite easily under KSM swapping
load.  That's the BUG_ON(age > 1) in remove_rmap_item_from_tree().

There is a comment above it, but explaining in more detail: KSM saves
effort by not fully maintaining the unstable tree like a proper RB
tree throughout, but at the start of each pass forgetting the old tree
and rebuilding anew from scratch. But that means that whenever it looks
like we need to remove an item from the unstable tree, we have to check
whether it has already been linked into the new tree this time around
(hence rb_erase needed), or it's just a free-floating leftover from the
previous tree.

"age" 0 or 1 says which: but if it's more than 1, then something has
gone wrong: cmp_and_merge_page() was forgetting to remove the item
in the new EBUSY case.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
Fix to fold into
mm-ksm-do-not-block-on-page-lock-when-searching-stable-tree.patch

I like that patch better now it has the mods suggested by John Hubbard;
but what I'd still really prefer to do is to make the patch unnecessary,
by reworking that window of KSM page migration so that there's just no
need for stable_tree_search() to take page lock.  We would all prefer
that.  However, each time I've gone to do so, it's turned out to need
more care than I expected, and I run out of time.  So, let's go with
what we have, and one day I might perhaps get back to it.

 mm/ksm.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

--- mmotm/mm/ksm.c	2019-02-14 15:16:13.000000000 -0800
+++ linux/mm/ksm.c	2019-02-18 20:36:44.707310427 -0800
@@ -2082,10 +2082,6 @@ static void cmp_and_merge_page(struct pa
 
 	/* We first start with searching the page inside the stable tree */
 	kpage = stable_tree_search(page);
-
-	if (PTR_ERR(kpage) == -EBUSY)
-		return;
-
 	if (kpage == page && rmap_item->head == stable_node) {
 		put_page(kpage);
 		return;
@@ -2094,6 +2090,9 @@ static void cmp_and_merge_page(struct pa
 	remove_rmap_item_from_tree(rmap_item);
 
 	if (kpage) {
+		if (PTR_ERR(kpage) == -EBUSY)
+			return;
+
 		err = try_to_merge_with_ksm_page(rmap_item, page, kpage);
 		if (!err) {
 			/*

