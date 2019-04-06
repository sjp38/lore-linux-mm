Return-Path: <SRS0=nlaJ=SI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B41C282DC
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 05:59:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB22821855
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 05:59:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XzdkRPNx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB22821855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B8106B026C; Sat,  6 Apr 2019 01:59:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 369A96B026D; Sat,  6 Apr 2019 01:59:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2579F6B026E; Sat,  6 Apr 2019 01:59:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 050466B026C
	for <linux-mm@kvack.org>; Sat,  6 Apr 2019 01:59:34 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id 81so3694801vkn.19
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 22:59:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=uLtgzl+y47IAFLBMiAJzXtmdzwQQQv6bFkF049bGo8Q=;
        b=OdSzWtMNmeAd0IDo5AlSUU4i/b+RgdQIMguovTOdPGqX4Nn866HYTzjFztE72oERXu
         JYPhIvqeFWPufYiCZzErKDIZoRuyDl8jyiVpghy9x17jegTIMcLmRAC4QYAEebAI+Tng
         yXFZTk+ZgzUOT9Zp3ktuVOK7LBG7YZX0OMVFCaIFMmc7wkJ0fW9++y751IGrD+9SI8xR
         HSh+q/nUQi8SPt/UK9Fe7V14Uj4G9rZVzXWpwrZmLT+synbiKfhPkWhObVSqFkaSEHyK
         wDSwA5ExXNN+x3GberuOc9IQSPaH2skvJz9FMooyMoDjuw84YmmIQ3x+4iyMV2PjB8fs
         vczg==
X-Gm-Message-State: APjAAAUNQirA8hk3pIquraGBRCqOeHFlG/y4uKERYz/0ClCxmbakvTNf
	4cDwAPRLo2P5dWmQoYzCA8Gf5mPz5Ov1Uk81j7Eei6a93TszLDhG/oU2Brx/exTWjY3R1b9D5Dj
	huzFUcO6yEbJ2Ht4UH3+26XJlfSbOi1ikhCu9uGBHgA4Huk5Ah/mgTeS0iBELO3ZxUA==
X-Received: by 2002:a67:83c5:: with SMTP id f188mr10113600vsd.163.1554530373614;
        Fri, 05 Apr 2019 22:59:33 -0700 (PDT)
X-Received: by 2002:a67:83c5:: with SMTP id f188mr10113561vsd.163.1554530372246;
        Fri, 05 Apr 2019 22:59:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554530372; cv=none;
        d=google.com; s=arc-20160816;
        b=v/+PP+DDOTJHTJx9Yxs0OreDP2CTb36eNsNgrMGYOB54WWUz1LtCAqcToOP/2Gp4Wz
         7a0s30SaXl2b/fqQUunznTqQDEMMBC+iEdOA8pKn1NudWJR9f7cQa9H3C8uni9/hlSXG
         fiZffwKIhJ6bWKmVbQPVVAZrn+f22syQ9RQ0aBrdfFaShF5gfJrSv1d05eKVxDQJ8qfl
         OMFtD379+PBwpeMFg9VHEoka6rbCQJoLLuK5msahu6J9JwiCa4OsHcmilPJQvq+wtqLU
         wTF/jY7xEei2iQpotRvrnEbDXV3q7TlvB8No9U2ycOt5ZlPywbczaRbUK7TH/5ABJAHU
         hB8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=uLtgzl+y47IAFLBMiAJzXtmdzwQQQv6bFkF049bGo8Q=;
        b=DdH6BMjQhyfycstjJa7YTrYGqsAuqa27Uc+HCpiTJlYIqgyTaC2JILN9pEpGpXF8Kv
         Rd3C82NYfeTC1A2ewjxGgA0ozUyjFJJLc8C/68dzIaJEK1AeoCaIkkUN8TkMeAUjEtnB
         Cu6Z6BaBNsxV6gHJfFaFu31kIvGKVZzv8aNzZGNK37UkQM74pIj7z/uUt4FZ2Qyhi7Pv
         AViaSd06AXXRjubub6vPqSKYKR2aaLjeqFo/f6GDm7fV//gX+NLfV4F+HDBCYoKd/uYI
         OolX+N8m0TgiFIerpL4WsXxGXGljIVvIPxkNLAcVOQh5/UNO5nviA0ymOGo3DiumR33z
         mM+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XzdkRPNx;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r6sor15172184vsp.109.2019.04.05.22.59.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 22:59:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XzdkRPNx;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=uLtgzl+y47IAFLBMiAJzXtmdzwQQQv6bFkF049bGo8Q=;
        b=XzdkRPNxN+E5x7cMA147ngi9PqZF1Uulpanlf8yImKQjWpEefMF/L3UhwvU79Zhyf3
         Cu6yM8QemSeOF3qjWl+fctVrVwo1VHt/XtLMUUlJIdATsTQgmQhQDbye5HdROlrw41oj
         pdw2W4+rvE4xd3uXdVhH1OAKh1XfEtTtrh6CDQQw4qJ7L7I4It+rrnKTrvXC/ZNH7m0J
         UUlzRAo1/zEA7hKwMCEWN6t670kPKS6Wu12VTeLtSkaVUyUH4kCTzPVZuMXC9jie3uOD
         JZnAVzT7KyNrCS6zUEN5BltudarfyIWHCZeEo8L34OzjJzZQbLtkexTW0oH56hS+nf29
         A5WA==
X-Google-Smtp-Source: APXvYqy4UKsunqxI/fOpkTdAf8nulfxruUmZd2oXxfHy79RjFPK3mjgLdImOcFpEPP4V3Z1y7Dg04kwZfrCS0jpr630=
X-Received: by 2002:a67:f582:: with SMTP id i2mr11133517vso.33.1554530371758;
 Fri, 05 Apr 2019 22:59:31 -0700 (PDT)
MIME-Version: 1.0
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Sat, 6 Apr 2019 11:29:27 +0530
Message-ID: <CACDBo57pEVRjOBf0yLMQ+KuGPeOuFcMufGVzjPJVnwfLFjzFSA@mail.gmail.com>
Subject: vmscan.c: Reclaim unevictable pages.
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	kernelnewbies@kernelnewbies.org, vbabka@suse.cz, mhocko@kernel.org, 
	minchan@kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello ,

shrink_page_list() returns , number of pages reclaimed, when pages is
unevictable it returns VM_BUG_ON_PAGE(PageLRU(page) ||
PageUnevicatble(page),page);

We can add the unevictable pages in reclaim list in
shrink_page_list(), return total number of reclaim pages including
unevictable pages, let the caller handle unevictable pages.

I think the problem is shrink_page_list is awkard. If page is
unevictable it goto activate_locked->keep_locked->keep lables, keep
lable list_add the unevictable pages and throw the VM_BUG instead of
passing it to caller while it relies on caller for
non-reclaimed-non-unevictable  page's putback.
I think we can make it consistent so that shrink_page_list could
return non-reclaimed pages via page_list and caller can handle it. As
an advance, it could try to migrate mlocked pages without retrial.


Below is the issue i observed of CMA_ALLOC of large size buffer :
(Kernel version - 4.14.65 With Android Pie.

[   24.718792] page dumped because: VM_BUG_ON_PAGE(PageLRU(page) ||
PageUnevictable(page))
[   24.726949] page->mem_cgroup:bd008c00
[   24.730693] ------------[ cut here ]------------
[   24.735304] kernel BUG at mm/vmscan.c:1350!
[   24.739478] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM


Below is the patch which solved this issue :

diff --git a/mm/vmscan.c b/mm/vmscan.c
index be56e2e..12ac353 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -998,7 +998,7 @@ static unsigned long shrink_page_list(struct
list_head *page_list,
                sc->nr_scanned++;

                if (unlikely(!page_evictable(page)))
-                       goto activate_locked;
+                      goto cull_mlocked;

                if (!sc->may_unmap && page_mapped(page))
                        goto keep_locked;
@@ -1331,7 +1331,12 @@ static unsigned long shrink_page_list(struct
list_head *page_list,
                } else
                        list_add(&page->lru, &free_pages);
                continue;
-
+cull_mlocked:
+                if (PageSwapCache(page))
+                        try_to_free_swap(page);
+                unlock_page(page);
+                list_add(&page->lru, &ret_pages);
+                continue;
 activate_locked:
                /* Not a candidate for swapping, so reclaim swap space. */
                if (PageSwapCache(page) && (mem_cgroup_swap_full(page) ||




It fixes the below issue.

1. Large size buffer allocation using cma_alloc successful with
unevictable pages.

cma_alloc of current kernel will fail due to unevictable page

Please let me know if anything i am missing.

Regards,
Pankaj

