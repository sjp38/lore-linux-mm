Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C1E2C3A5A5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:53:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0105E2087E
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:53:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tjQlQ2Ex"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0105E2087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B6B76B0543; Mon, 26 Aug 2019 03:53:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 866ED6B0545; Mon, 26 Aug 2019 03:53:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 755A36B0546; Mon, 26 Aug 2019 03:53:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0161.hostedemail.com [216.40.44.161])
	by kanga.kvack.org (Postfix) with ESMTP id 569546B0543
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 03:53:04 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id EB3F84405
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:53:03 +0000 (UTC)
X-FDA: 75863813046.21.dog37_8f1e926b95f54
X-HE-Tag: dog37_8f1e926b95f54
X-Filterd-Recvd-Size: 5781
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:53:03 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id 196so11266440pfz.8
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 00:53:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=efgN+vHmbZbtfSnoe2tJDrmfT0GUhJplIH0aIIOgUwk=;
        b=tjQlQ2ExrfoO855NFAVsXPV0e4T1NSJLC/o6pniiADGzTexVhfkjnj7HMQKTfDabp9
         2VrpOmtAMlfxBTcV5oq3/ef4R19zGKjOvrYi28ZeEgTDLMFABrCXbnBl/A3fkl0pCdHY
         vv4hfU59E5lc5B7WQxqMi2WmlAsIBjDAguGQ1a6wJy4fHD7zvKZMZXdVkmymfrDkwTn5
         By0P8Yfc2fhDL0KAmp1Y24MU1f0mZgM6u3TJAKVyzOAYzckNWVHBe6KXAeZvyUWH4vOf
         CnPTqp67rX2vTBJ8bxYsYiY2uLj2Dqk3bcbw6KN8UbgqtndFk9klGKHWdKr1YQmAVjxp
         iRww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=efgN+vHmbZbtfSnoe2tJDrmfT0GUhJplIH0aIIOgUwk=;
        b=K/qjetKSJ0oknpTCDFvdhWSCQRgGaZSWQr6mxTNLP8xcpodhksbzBYrs0XvTuhPA9F
         WuoxI5otxxyz/6lIukKB9A/ubdxRTOzdXe02+d2T9jQ1rMBqjDxF9UT0rs7wgR7UElvr
         sd+2yfWlV52OQEpcBjo7XUnoVThDh5Cnx7g93u1UDMpAFhvvLLsdRdzBKRdA1NHad2wL
         fYj6t68qXks9FkMvXMBs9Ju8Ze3zocK2jJ36PvTd7vZ/YjZDNYGnnq16jkXqiSG2LcUr
         Nu6xMN7PYupjFic7mv3vi4ae0yxDFTAvEIIMftD9Ba5dnF+TcPOqB6MQwkP3YcwRAbGN
         4uzQ==
X-Gm-Message-State: APjAAAVjlnbOfsUe9DONeuvaZbgQoSzOVTi4tVQlOZS20nw8onryQdAH
	0ZKVUk+rKTWLw5wtykM/yQ==
X-Google-Smtp-Source: APXvYqyxRtF788S9SAurc3XEByUeMhHgAoa/qAhAeLHGf5p/zj9RyDaDK4+HzzxGKEADZkX1N9VkTQ==
X-Received: by 2002:a63:ff65:: with SMTP id s37mr14929040pgk.102.1566805982049;
        Mon, 26 Aug 2019 00:53:02 -0700 (PDT)
Received: from mypc ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id r75sm14966984pfc.18.2019.08.26.00.52.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Aug 2019 00:53:01 -0700 (PDT)
Date: Mon, 26 Aug 2019 15:52:51 +0800
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
Message-ID: <20190826075251.GA7486@mypc>
References: <1565078411-27082-1-git-send-email-kernelfans@gmail.com>
 <1565078411-27082-2-git-send-email-kernelfans@gmail.com>
 <20190815172222.GD30916@redhat.com>
 <20190816150222.GA10855@mypc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816150222.GA10855@mypc>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 11:02:22PM +0800, Pingfan Liu wrote:
> On Thu, Aug 15, 2019 at 01:22:22PM -0400, Jerome Glisse wrote:
> > On Tue, Aug 06, 2019 at 04:00:10PM +0800, Pingfan Liu wrote:
> > > MIGRATE_PFN_MIGRATE marks a valid pfn, further more, suitable to migrate.
> > > As for hole, there is no valid pfn, not to mention migration.
> > > 
> > > Before this patch, hole has already relied on the following code to be
> > > filtered out. Hence it is more reasonable to see hole as invalid source
> > > page.
> > > migrate_vma_prepare()
> > > {
> > > 		struct page *page = migrate_pfn_to_page(migrate->src[i]);
> > > 
> > > 		if (!page || (migrate->src[i] & MIGRATE_PFN_MIGRATE))
> > > 		     \_ this condition
> > > }
> > 
> > NAK you break the API, MIGRATE_PFN_MIGRATE is use for 2 things,
> > first it allow the collection code to mark entry that can be
> > migrated, then it use by driver to allow driver to skip migration
> > for some entry (for whatever reason the driver might have), we
> > still need to keep the entry and not clear it so that we can
> > cleanup thing (ie remove migration pte entry).
> Thanks for your kindly review.
> 
> I read the code again. Maybe I miss something. But as my understanding,
> for hole, there is no pte.
> As the current code migrate_vma_collect_pmd()
> {
> 	if (pmd_none(*pmdp))
> 		return migrate_vma_collect_hole(start, end, walk);
> ...
> 	make_migration_entry()
> }
> 
> We do not install migration entry for hole, then no need to remove
> migration pte entry.
> 
> And on the driver side, there is way to migrate a hole. The driver just
> skip it by
> drivers/gpu/drm/nouveau/nouveau_dmem.c: if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE))
>                                              ^^^^
> Finally, in migrate_vma_finalize(), for a hole,
> 		if (!page) {
> 			if (newpage) {
> 				unlock_page(newpage);
> 				put_page(newpage);
> 			}
> 			continue;
> 		}
> And we do not rely on remove_migration_ptes(page, newpage, false); to
> restore the orignal pte (and it is impossible).
> 
Hello, do you have any comment?

I think most of important, hole does not use the 'MIGRATE_PFN_MIGRATE'
API. Hole has not pte, and there is no way to 'remove migration pte
entry'. Further more, we can know the failure on the source side, no
need to defer it to driver side.

By this way, [3/3] can unify the code.

Thanks,
	Pingfan

