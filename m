Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B50CC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 19:47:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7DCE2081B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 19:47:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7DCE2081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F1FC8E00A9; Thu, 21 Feb 2019 14:47:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A11B8E009E; Thu, 21 Feb 2019 14:47:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B6348E00A9; Thu, 21 Feb 2019 14:47:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7888E009E
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 14:47:17 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 17so12974290pgw.12
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 11:47:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2Bd3yzDftsxFwBxfrvgbnKXass4MT1o7R2tEYBN9pRo=;
        b=g/NphweYanZeUWtyJkJ8h5Xajg49kSzAK1rcxbVMP0iT9yUpeHXGAH3NPlQ9pGjWEX
         DjAo0mKntV4l49FMw0KRmycYZHV1plznNa3/Is+9/w1j1uBKERncEcSC9umPZaL6elNv
         FlLqKY7ZAIQtQiY2FvgrnYGIiCaQHhAM4b12jqTS+ByMQcCqUxoPWv7KDchKX3uQ+6sD
         vRL3WkmBAPiVN9ukC2V+ji0xCqca+Ppf4ojB0Lhhy461/cKIGjaRkF1XpmBr03Z8Ygq2
         d1oah6iMotqdQ9jAbfWkeiP6pwcxHzDmKgdfvNlCTHxgU/BX+J5fiR/3p8CNU7Zg3bt8
         MfnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuYzKpfBfSur6FH16m9r9o0IXAOGPJGNM/StTBthOi3LEh7dfHEY
	RaUi+Ql5M9UGDcVGlc1WL6VnckM+gfMKMRXadeGBz4v2gvcgGW4XXNhIBDf9XoW8jfRvu99Yhki
	Fwco9zsRamu2OAt44MbNJw2YGQV0S9TxzEJsquxZRoGuEfiDHh+3Pvln5lFbRdUbgJQ==
X-Received: by 2002:a17:902:9a09:: with SMTP id v9mr187644plp.225.1550778436835;
        Thu, 21 Feb 2019 11:47:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iacvs1pD1uoGllDtBXLE1Kv/nwwD7HSJUihlg3dNsZpjr2vUWgowTq4EepqN7VJ0sQB/fvI
X-Received: by 2002:a17:902:9a09:: with SMTP id v9mr187583plp.225.1550778435844;
        Thu, 21 Feb 2019 11:47:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550778435; cv=none;
        d=google.com; s=arc-20160816;
        b=D5Rq6XlwFKAY04Mqrvaufn8plJuZXAk2REk8kjMdGSqKEHLUjv1j4LgfLIdpw+dxXg
         O2OoVcJGODqC7fRC2U5cO6wQELr9QanVOZgsbA2Wod9sXd7S0jrybNHKEADZg+d4M0T3
         uxMggBUeJq56iNvLcS9G3wfJbETKEFEHs9VkNr0osP9gTR984A8LWda4aOt9qSHVs2O4
         y4Ur8ac05UOGHyNK3pYNBOOYeqLd2yUkrQ6379R1w5vQuSh4QDPb8p1ahLpXbs4X2lIT
         kyxkRTnPWeZv9qAXQscr71Elvg8JbvuH2CSEDaH/zP22/J6/QpeTomD1HqXCvXPbBXtC
         /amw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=2Bd3yzDftsxFwBxfrvgbnKXass4MT1o7R2tEYBN9pRo=;
        b=WbZYMAY3Bk+6aNVqITpCBTWj9hlQcGDkpgnCVT1FU1TtOVBUiX4TjOAcR0MO4kdHsB
         LT0vvNq0E7qVJSohpaF1WTMA7xSclWKR79n0NWlQ71HltYts6v9rkifGbErfA6kDQo7v
         CAci8vLcA1OdDrvkU4+NnzfMdUG8X1BNLJ/J7KsnfeuSCM/vldYeVSNmyBD5iA3/IwQQ
         U3OOX4/+fTDCh5uCT2u/JgYxLMIo0839AwwIbU6zRCIilo29//C29sy7mZOu++B5FTUR
         NTGSMpKiHKZiQMuLAz4w/Lgwf7lIBoVZBjubYyf0NdJ3WUiaMcGcEHdLd5vqg1L5SN3G
         0DZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k19si20991058pfi.258.2019.02.21.11.47.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 11:47:15 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 0E0D93BD2;
	Thu, 21 Feb 2019 19:47:15 +0000 (UTC)
Date: Thu, 21 Feb 2019 11:47:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko
 <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea
 Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov"
 <kirill.shutemov@linux.intel.com>, Mel Gorman
 <mgorman@techsingularity.net>, Davidlohr Bueso <dave@stgolabs.net>,
 stable@vger.kernel.org
Subject: Re: [PATCH] huegtlbfs: fix races and page leaks during migration
Message-Id: <20190221114713.ee2a38267f75ef1a2fd6de44@linux-foundation.org>
In-Reply-To: <7534d322-d782-8ac6-1c8d-a8dc380eb3ab@oracle.com>
References: <803d2349-8911-0b47-bc5b-4f2c6cc3f928@oracle.com>
	<20190212221400.3512-1-mike.kravetz@oracle.com>
	<20190220220910.265bff9a7695540ee4121b80@linux-foundation.org>
	<7534d322-d782-8ac6-1c8d-a8dc380eb3ab@oracle.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Feb 2019 11:11:06 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> 
> Sorry for the churn.  As I find and fix one issue I seem to discover another.
> There is still at least one more issue with private pages when COW comes into
> play.  I continue to work that.  I wanted to send this patch earlier as it
> is pretty easy to hit the bugs if you try.  If you would prefer another
> approach, let me know.
> 

No probs, the bug doesn't seem to be causing a lot of bother out there
and it's cc:stable; there's time to get this right ;)

Here's the delta I queued:

--- a/mm/hugetlb.c~huegtlbfs-fix-races-and-page-leaks-during-migration-update
+++ a/mm/hugetlb.c
@@ -3729,6 +3729,7 @@ static vm_fault_t hugetlb_no_page(struct
 	pte_t new_pte;
 	spinlock_t *ptl;
 	unsigned long haddr = address & huge_page_mask(h);
+	bool new_page = false;
 
 	/*
 	 * Currently, we are forced to kill the process in the event the
@@ -3790,6 +3791,7 @@ retry:
 		}
 		clear_huge_page(page, address, pages_per_huge_page(h));
 		__SetPageUptodate(page);
+		new_page = true;
 
 		if (vma->vm_flags & VM_MAYSHARE) {
 			int err = huge_add_to_page_cache(page, mapping, idx);
@@ -3861,8 +3863,9 @@ retry:
 
 	spin_unlock(ptl);
 
-	/* May already be set if not newly allocated page */
-	set_page_huge_active(page);
+	/* Make newly allocated pages active */
+	if (new_page)
+		set_page_huge_active(page);
 
 	unlock_page(page);
 out:
--- a/mm/migrate.c~huegtlbfs-fix-races-and-page-leaks-during-migration-update
+++ a/mm/migrate.c
@@ -1315,6 +1315,16 @@ static int unmap_and_move_huge_page(new_
 		lock_page(hpage);
 	}
 
+	/*
+	 * Check for pages which are in the process of being freed.  Without
+	 * page_mapping() set, hugetlbfs specific move page routine will not
+	 * be called and we could leak usage counts for subpools.
+	 */
+	if (page_private(hpage) && !page_mapping(hpage)) {
+		rc = -EBUSY;
+		goto out_unlock;
+	}
+
 	if (PageAnon(hpage))
 		anon_vma = page_get_anon_vma(hpage);
 
@@ -1345,6 +1355,7 @@ put_anon:
 		put_new_page = NULL;
 	}
 
+out_unlock:
 	unlock_page(hpage);
 out:
 	if (rc != -EAGAIN)
_


