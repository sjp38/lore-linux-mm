Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B971C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:41:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4E622133D
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:41:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4E622133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A69F6B0003; Tue, 19 Mar 2019 10:41:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72FD16B0006; Tue, 19 Mar 2019 10:41:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F6846B0007; Tue, 19 Mar 2019 10:41:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 03ACD6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:41:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x13so8250900edq.11
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 07:41:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NgNZg5cItkviasegCBnbi1TmtqI9zVNi9ojPjk+qzho=;
        b=DILBUNRPKfNlYOD4QvaVSQLTdBpe1n7hBKSBi5DAy3LXkkOEmi8UfvUUoCRVlx2U/V
         wK/c6c1TEhiG8JIlqaaoyQ3rUGh29b3NiC4H4iolPxs0KB9sxLNF/a5JQMcQjntZxOhh
         LeibJraqJkRSzvSNrJJTBmGd8OtNBER2IpSW9dt0f/Z2OkJ7PIGkYb7XZG7uVMc9U2aG
         D/vk/h+8UJUacl05vvlOn3CGTg6nYrdsbmsaRpNz7U9osMm6FK1ZgGpcV9b9iJzke66W
         DaOB93UmoxnOh8Fu0epFT5X1wPNj57/Roc2M20BED61wHoPQjNjk02wCR9ve0GbWnnjJ
         4mDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVYf/BxJHSfEHh/+ctNCRbJCdAh3Zqc9UyfAF6JwAYGXpiqfhPy
	M/7fGvvDrmesjgvfddK4P6twTLGN+vbgLz7aaTVyipe2aSo8NW8rrAqvGNwAClKUFJxdhjeM8jr
	2bEB+q8NvFMBBdBLXR9MRMpOIpOFE5628Fi26hiLOMO9R2rIw1NK9u8280MoEthabzg==
X-Received: by 2002:a17:906:4a48:: with SMTP id a8mr5686907ejv.57.1553006496534;
        Tue, 19 Mar 2019 07:41:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyiW8xjpFxlt9WyZQKw3u3E4rXPIp0yGIA8yn3RoOqcc3OHCZDAtL7SF8DsYs5NzAPmeyE1
X-Received: by 2002:a17:906:4a48:: with SMTP id a8mr5686883ejv.57.1553006495707;
        Tue, 19 Mar 2019 07:41:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553006495; cv=none;
        d=google.com; s=arc-20160816;
        b=aI+d4xbXbvSr3+oL8qJhq2am8xQvo6chIYMoG98gDADpg6ZCms7zdwrvgrUr4L5IGW
         7a4PglEEK4HpKyHTlNooC11vigWJeEad7VqLsjlY/Feur52ZAwgju9aynYbteFgR+RsZ
         uRC14T8sAZ7zADl/2nhWB+KZIz85JYq2LaGKHIG86fzJWikgJxq0ijZC32BK+I0dSjmz
         ImdPwiCu/ANy0H7RJ64bzrIaK8vnMobWT+trBpyr4ziHs20OQcPk/anBipxw39mzgl/D
         GjOoCMj+wxZ5tU/SSkWHYaQVef1uQfm/w6UZbjP4bclBg9y51L99UvSkuxR+V0FnlVJs
         0hnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NgNZg5cItkviasegCBnbi1TmtqI9zVNi9ojPjk+qzho=;
        b=NIyQixjrEEgdSPUA99HO4y8xlFa39LOD145RNilhFbd+jB3CTwsNQA0EDy/DEnNCsp
         jEuDiMTMYSwR/t9MJYd62bM97HPykp+RaLNF9jeSJy3JgPoUX5IxMOduncAvwqJIFNan
         quyp1q5mbGvj+y9s0U/MzA0Y25XsbZnGa9zzPVJsZJ1a5YPRl4CsKUgsM2pQte70SZo5
         fM+ZIB0ZjmClf8nkDFDL8l/d8/Te38zeaefz2ZAqGOAds5oOjMGFFomGK8ItuvROnklP
         T8mXjr+ZhsWJDKBEgSnmFMcwse8FeOiW7wbvIVB7C3RFALYS2MjkFxIkOsRpLAtuMBpR
         0R+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id a48si2516523edd.336.2019.03.19.07.41.35
        for <linux-mm@kvack.org>;
        Tue, 19 Mar 2019 07:41:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id EC8C24605; Tue, 19 Mar 2019 15:41:33 +0100 (CET)
Date: Tue, 19 Mar 2019 15:41:33 +0100
From: Oscar Salvador <osalvador@suse.de>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Yang Shi <shy828301@gmail.com>, Cyril Hrubis <chrubis@suse.cz>,
	Linux MM <linux-mm@kvack.org>, linux-api@vger.kernel.org,
	ltp@lists.linux.it, Vlastimil Babka <vbabka@suse.cz>,
	kirill.shutemov@linux.intel.com
Subject: Re: mbind() fails to fail with EIO
Message-ID: <20190319144130.lidqtrkfl75n2haj@d104.suse.de>
References: <20190315160142.GA8921@rei>
 <CAHbLzkqvQ2SW4soYHOOhWG0ShkdUhaiNK0_y+ULaYYHo62O0fQ@mail.gmail.com>
 <20190319132729.s42t3evt6d65sz6f@d104.suse.de>
 <20190319142639.wbind5smqcji264l@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319142639.wbind5smqcji264l@kshutemo-mobl1>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 05:26:39PM +0300, Kirill A. Shutemov wrote:
> That's all sounds reasonable.
> 
> We only need to make sure the bug fixed by 77bf45e78050 will not be
> re-introduced.

I gave it a spin with the below patch.
Your testcase works (so the bug is not re-introduced), and we get -EIO
when running the ltp test [1].
So unless I am missing something, it should be enough.

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index af171ccb56a2..b192b13460f0 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -502,11 +508,16 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
                        continue;
                if (!queue_pages_required(page, qp))
                        continue;
-               migrate_page_add(page, qp->pagelist, flags);
+               if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+                       migrate_page_add(page, qp->pagelist, flags);
+               else
+                       break;
        }
        pte_unmap_unlock(pte - 1, ptl);
        cond_resched();
-       return 0;
+       return addr != end ? -EIO : 0;
 }

 static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
@@ -603,7 +614,8 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
        }

        /* queue pages from current vma */
-       if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+       if ((flags & MPOL_MF_STRICT) ||
+               (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
                return 0;
  

[1] https://github.com/metan-ucw/ltp/blob/master/testcases/kernel/syscalls/mbind/mbind02.c

-- 
Oscar Salvador
SUSE L3

