Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0F19C3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:02:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ADE62086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:02:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="isXsm8F7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ADE62086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6E076B0007; Fri, 16 Aug 2019 11:02:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1ECD6B0008; Fri, 16 Aug 2019 11:02:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90C826B000A; Fri, 16 Aug 2019 11:02:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0047.hostedemail.com [216.40.44.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2476B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 11:02:37 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 036CF4820
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:02:37 +0000 (UTC)
X-FDA: 75828607554.10.sun37_6e11edf046148
X-HE-Tag: sun37_6e11edf046148
X-Filterd-Recvd-Size: 5267
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:02:36 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id w16so3261585pfn.7
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:02:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=80681125HOe1NksgS/XdMjl6WQzpX7RNekCUe4aCq/Y=;
        b=isXsm8F7NqAKGGb6PgZvvznUtwOOxSMgaDX8r1auxQi6T+0wWxvsKu4UQcEV7FvDTt
         /kmf9wFUT593QxhHVbPkM/7ZvZjp8zaFDhuhrjJ+2dg5VecyfRCTm6uVilNB1OMAxGYo
         N1lfcetsW5mFyCCoz5J48KjqJUImLeh/5uo3n9ZQYv3BfWPRiAUE5t5mBjNxh1Yd0VhN
         N8Nd3Prb9PbpWE0nzwWQl+oCkS0chyoW+Snfn4DQJiX813XuRnuAobYBX4dgIpvjjB6S
         Xrpz7AxrAEACdibYFHVh5Ic5UWw9FIRtqz6dQ2UnxYP/8Bl541fTpvkhBdrngiAd7303
         Qp7A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=80681125HOe1NksgS/XdMjl6WQzpX7RNekCUe4aCq/Y=;
        b=dMi77YeOKTt9o8oUsp1Nr5s+xMDlAkJNloH7i6QVpHq0yUwVQwbdx7J9A1CVCjP6qG
         Bs4zTGB+JeGoXKLQoKzxsjB5gYzKVD57KTlVIohONPhAkzGaqahtq/zc0Nf1b6UoMuaV
         y7LIcbAMuDsllEprkYfBZMQu6d52irqzl/SDEgfLbJSv8kFrfI7IbhfYL7zGgBWliC5q
         f5dz31iCrZi7/tNSpZ6KeWLYY8haMjVZQ6ZjItgzIRLQ9oj0u+1ywN2T8NW/+cEocRpy
         8SibI0wXe1w6kc79iLnta6L3vt6YaEZEeqUbAW7c4PhgSrFSt1szYTKhnfMJ2N/4/yqR
         OtIw==
X-Gm-Message-State: APjAAAVsi+M3CD8TT13JRl1zwU/YBt2q1GH0/MDeSIdhXsMXtnEYXoAD
	9ZdB9moCKR0HluEPwmzoOQ==
X-Google-Smtp-Source: APXvYqyYrWsBv+YFWGKWMSvAj/Y6YsQ7WRpo5y7EPvTeuwShnVq5fuYFBDU7SpfgE/kycdeUsjN79w==
X-Received: by 2002:a17:90a:5207:: with SMTP id v7mr7332463pjh.127.1565967755090;
        Fri, 16 Aug 2019 08:02:35 -0700 (PDT)
Received: from mypc ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id f12sm5339136pgq.52.2019.08.16.08.02.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 08:02:33 -0700 (PDT)
Date: Fri, 16 Aug 2019 23:02:22 +0800
From: Pingfan Liu <kernelfans@gmail.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3] mm/migrate: see hole as invalid source page
Message-ID: <20190816150222.GA10855@mypc>
References: <1565078411-27082-1-git-send-email-kernelfans@gmail.com>
 <1565078411-27082-2-git-send-email-kernelfans@gmail.com>
 <20190815172222.GD30916@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815172222.GD30916@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 01:22:22PM -0400, Jerome Glisse wrote:
> On Tue, Aug 06, 2019 at 04:00:10PM +0800, Pingfan Liu wrote:
> > MIGRATE_PFN_MIGRATE marks a valid pfn, further more, suitable to migrate.
> > As for hole, there is no valid pfn, not to mention migration.
> > 
> > Before this patch, hole has already relied on the following code to be
> > filtered out. Hence it is more reasonable to see hole as invalid source
> > page.
> > migrate_vma_prepare()
> > {
> > 		struct page *page = migrate_pfn_to_page(migrate->src[i]);
> > 
> > 		if (!page || (migrate->src[i] & MIGRATE_PFN_MIGRATE))
> > 		     \_ this condition
> > }
> 
> NAK you break the API, MIGRATE_PFN_MIGRATE is use for 2 things,
> first it allow the collection code to mark entry that can be
> migrated, then it use by driver to allow driver to skip migration
> for some entry (for whatever reason the driver might have), we
> still need to keep the entry and not clear it so that we can
> cleanup thing (ie remove migration pte entry).
Thanks for your kindly review.

I read the code again. Maybe I miss something. But as my understanding,
for hole, there is no pte.
As the current code migrate_vma_collect_pmd()
{
	if (pmd_none(*pmdp))
		return migrate_vma_collect_hole(start, end, walk);
...
	make_migration_entry()
}

We do not install migration entry for hole, then no need to remove
migration pte entry.

And on the driver side, there is way to migrate a hole. The driver just
skip it by
drivers/gpu/drm/nouveau/nouveau_dmem.c: if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE))
                                             ^^^^
Finally, in migrate_vma_finalize(), for a hole,
		if (!page) {
			if (newpage) {
				unlock_page(newpage);
				put_page(newpage);
			}
			continue;
		}
And we do not rely on remove_migration_ptes(page, newpage, false); to
restore the orignal pte (and it is impossible).

Thanks,
	Pingfan

