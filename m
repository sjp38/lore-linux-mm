Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E701C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 16:55:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4A1920823
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 16:55:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4A1920823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F8328E0004; Wed, 27 Feb 2019 11:55:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47E368E0001; Wed, 27 Feb 2019 11:55:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 320348E0004; Wed, 27 Feb 2019 11:55:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C40758E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 11:55:41 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id a21so7308114eda.3
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 08:55:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8KovG0avRcIIprAIuQHqV0QfBQSOIesQgR50XG+Olys=;
        b=st9taTON26TSor4t6LfnHExYOOidDY+DyuvRW3KcOvCGhI2zgeWPAPWNRIuAkL2NbV
         DfCxFc8/Tc55tYITZH77McC6AkhnAjuOpvNTq73MGCcAAgCaUwnSl8qnw8LzlF3KWMKI
         /8KlE4cNxF8tNtrvJsfdhOkTwqsTtCYAnEWk22+THYSnpdxFxnlVSPxZO/NgtS/MrkH+
         nOCHZVkqeMFRmmwaAAZCf9KHKhjsTlQCRr083aL+UF1qm61La3HM63dtzq5E4DbIvmRP
         6BINHMhKtqdCod3ep1kMdR4wrTL1RkbNzJZc+0fDxYLtMe3bzLSjR4B6DEbyC4QHqlE8
         Vcew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuYpJFd6x0UIl7MyvRsbqhN8P6LRf6In0lqGkvPUwHDae/wCerYy
	boqVRELkiX2dUQe6GMGjkliTbSDe5UHlFKNxiAclstVwj+P7rHO3LTfLyhAcDpTPlInV7MLIfpz
	bC7GIADc6XA71/aNDQkmElQccWUEdFfI7LeJbpa6Lesx2EC3R/lvMUbKkLSayRU9dFg==
X-Received: by 2002:a50:ac55:: with SMTP id w21mr3187636edc.121.1551286541204;
        Wed, 27 Feb 2019 08:55:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYKImioI5FnBiZ3Hd5S7M1CQqCgEXhTM3SBm35joluVPqruV7eIvnRWgVZgnhHK+TRJTk5F
X-Received: by 2002:a50:ac55:: with SMTP id w21mr3187544edc.121.1551286539767;
        Wed, 27 Feb 2019 08:55:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551286539; cv=none;
        d=google.com; s=arc-20160816;
        b=RHccSy8V25hs9dPWVFIM0cf3LDFovl1CJ+omllEPBXsGa5wip7o8s26ya0nZLgqfhF
         Lq+iS4au2nbnOPLYSleTrBGOtE7x7AwmwqgV4JPk68I9l5iDAPjq1zQwDlheTxu1At3J
         TNfTZ3utpAMe3byzDDTAx5kMbj8Zu3UjPdUDR4PP72dlvQRapMW6Xqt2dhU5sQz7TA29
         +BKr/JRkcp3IULP5EUvPKhss8rYO2tSL2FRG4VldPrzTYTnvGTarLX5QOveA6jhqSSRA
         KXnitXEgbJzNhOV/dcieAEZ9CBpTPbLWBChZ8bIELMCIDmBYGs75Hcr+uZkWQVLXQGkZ
         KXgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8KovG0avRcIIprAIuQHqV0QfBQSOIesQgR50XG+Olys=;
        b=jV9qp2ps8pTsdvTrICTu5mlle/ISXOGAmg4KeEJ0RCGOe696ZjMxUooA2t/7ybLVSd
         X360qFUuKW7yZsZoVWCZBFso6NioyvM0wj4bHfiNjm77CBXhoqvxZFSMqQv9/Z3bfeEq
         wMT3DaVBLqZ84n2vvHiKNQFKPNC3bOr64zzjN9AM9vMr2vJOYZWuNva+YKKSI4ugnX+1
         nnHgafhPwU4ykGOtonsA13Yhv7UX8oKdMuzbUrPkn5T0JsqjvcySdH5KB5i84jhAjdDY
         o98BS3oJ1Wl9Z4Jyzu8rpbrNjM4MLgbwJrVY3sHMjTodCzTkAquTaNagIHiFU+OEXoJU
         33RQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v19si2989071eja.285.2019.02.27.08.55.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 08:55:39 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 32B6BAF5F;
	Wed, 27 Feb 2019 16:55:39 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id CEB1E1E426A; Wed, 27 Feb 2019 17:55:38 +0100 (CET)
Date: Wed, 27 Feb 2019 17:55:38 +0100
From: Jan Kara <jack@suse.cz>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mgorman@suse.de
Subject: Re: Truncate regression due to commit 69b6c1319b6
Message-ID: <20190227165538.GD27119@quack2.suse.cz>
References: <20190226165628.GB24711@quack2.suse.cz>
 <20190226172744.GH11592@bombadil.infradead.org>
 <20190227112721.GB27119@quack2.suse.cz>
 <20190227122451.GJ11592@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190227122451.GJ11592@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 27-02-19 04:24:51, Matthew Wilcox wrote:
> On Wed, Feb 27, 2019 at 12:27:21PM +0100, Jan Kara wrote:
> > On Tue 26-02-19 09:27:44, Matthew Wilcox wrote:
> > > On Tue, Feb 26, 2019 at 05:56:28PM +0100, Jan Kara wrote:
> > > > after some peripeties, I was able to bisect down to a regression in
> > > > truncate performance caused by commit 69b6c1319b6 "mm: Convert truncate to
> > > > XArray".
> > > 
> > > [...]
> > > 
> > > > I've gathered also perf profiles but from the first look they don't show
> > > > anything surprising besides xas_load() and xas_store() taking up more time
> > > > than original counterparts did. I'll try to dig more into this but any idea
> > > > is appreciated.
> > > 
> > > Well, that's a short and sweet little commit.  Stripped of comment
> > > changes, it's just:
> > > 
> > > -       struct radix_tree_node *node;
> > > -       void **slot;
> > > +       XA_STATE(xas, &mapping->i_pages, index);
> > >  
> > > -       if (!__radix_tree_lookup(&mapping->i_pages, index, &node, &slot))
> > > +       xas_set_update(&xas, workingset_update_node);
> > > +       if (xas_load(&xas) != entry)
> > >                 return;
> > > -       if (*slot != entry)
> > > -               return;
> > > -       __radix_tree_replace(&mapping->i_pages, node, slot, NULL,
> > > -                            workingset_update_node);
> > > +       xas_store(&xas, NULL);
> > 
> > Yes, the code change is small. Thanks to you splitting the changes, the
> > regression is easier to analyze so thanks for that :)
> 
> That was why I split the patches so small.  I'm kind of glad it paid off ...
> not glad to have caused a performance regression!
> 
> > > I have a few reactions to this:
> > > 
> > > 1. I'm concerned that the XArray may generally be slower than the radix
> > > tree was.  I didn't notice that in my testing, but maybe I didn't do
> > > the right tests.
> > 
> > So one difference I've noticed when staring into the code and annotated
> > perf traces is that xas_store() will call xas_init_marks() when stored
> > entry is 0. __radix_tree_replace() didn't do this. And the cache misses we
> > take from checking tags do add up. After hacking the code in xas_store() so
> > that __clear_shadow_entry() does not touch tags, I get around half of the
> > regression back. For now I didn't think how to do this so that the API
> > remains reasonably clean. So now we are at:
> > 
> > COMMIT      AVG            STDDEV
> > a97e7904c0  1431256.500000 1489.361759
> > 69b6c1319b  1566944.000000 2252.692877
> > notaginit   1483740.700000 7680.583455
> 
> Well, that seems worth doing.  For the page cache case, we know that
> shadow entries have no tags set (at least right now), so it seems
> reasonable to move the xas_init_marks() from xas_store() to its various
> callers.
> 
> > > 2. The setup overhead of the XA_STATE might be a problem.
> > > If so, we can do some batching in order to improve things.
> > > I suspect your test is calling __clear_shadow_entry through the
> > > truncate_exceptional_pvec_entries() path, which is already a batch.
> > > Maybe something like patch [1] at the end of this mail.
> > 
> > So this apparently contributes as well but not too much. With your patch
> > applied on top of 'notaginit' kernel above I've got to:
> > 
> > batched-xas 1473900.300000 950.439377
> 
> Fascinating that it reduces the stddev so much.  We can probably take this

I would not concentrate on the reduction of stddev too much. The high
stddev for 'notaginit' is caused by one relatively big outlier (otherwise
we are at ~2200). But still the patch reduced stddev to about a half so
there is some improvement.

> further (getting into the realm of #3 below) -- the call to xas_set() will
> restart the walk from the top of the tree each time.  Clearly this usecase
> (many thousands of shadow entries) is going to construct a very deep tree,
> and we're effectively doing a linear scan over the bottom of the tree, so
> starting from the top each time is O(n.log n) instead of O(n).  I think
> you said the file was 64GB, which is 16 million 4k entries, or 24 bits of
> tree index.  That's 4 levels deep so it'll add up.

Actually the benchmark creates 64 files, 1GB each, so the depth of the tree
will be just 3. But yes, traversing from top of the tree each time only to
zero out one long there looks just wasteful. It seems we should be able to
have much more efficient truncate implementation which would just trim the
whole node worth of xarray - working set entries would be directly
destroyed, pages returned locked (provided they can be locked with
trylock).

Looking more into perf traces, I didn't notice any other obvious low
hanging fruit. There is one suboptimality in the fact that
__clear_shadow_entry() does xas_load() and the first thing xas_store() does
is xas_load() again. Removing this double tree traversal does bring
something back but since the traversals are so close together, everything
is cache hot and so the overall gain is small (but still):

COMMIT     AVG            STDDEV
singleiter 1467763.900000 1078.261049

So still 34 ms to go to the original time.

What profiles do show is there's slightly more time spent here and there
adding to overall larger xas_store() time (compared to
__radix_tree_replace()) mostly due to what I'd blame to cache misses
(xas_store() is responsible for ~3.4% of cache misses after the patch while
xas_store() + __radix_tree_replace() caused only 1.5% together before).

Some of the expensive loads seem to be from 'xas' structure (kind
of matches with what Nick said), other expensive loads seem to be loads from
xa_node. And I don't have a great explanation why e.g. a load of
xa_node->count is expensive when we looked at xa_node->shift before -
either the cache line fell out of cache or the byte accesses somehow
confuse the CPU. Also xas_store() has some new accesses compared to
__radix_tree_replace() - e.g. it did not previously touch node->shift.

So overall I don't see easy way how to speed up xarray code further so
maybe just batching truncate to make up for some of the losses and live
with them where we cannot batch will be as good as it gets...

								Honza

> > > 3. Perhaps we can actually get rid of truncate_exceptional_pvec_entries().
> > > It seems a little daft for page_cache_delete_batch() to skip value
> > > entries, only for truncate_exceptional_pvec_entries() to erase them in
> > > a second pass.  Truncation is truncation, and perhaps we can handle all
> > > of it in one place?
> > > 
> > > 4. Now that calling through a function pointer is expensive, thanks to
> > > Spectre/Meltdown/..., I've been considering removing the general-purpose
> > > update function, which is only used by the page cache.  Instead move parts
> > > of workingset.c into the XArray code and use a bit in the xa_flags to
> > > indicate that the node should be tracked on an LRU if it contains only
> > > value entries.
> > 
> > I agree these two are good ideas to improve the speed. But old radix tree
> > code has these issues as well so they are not the reason of this
> > regression. So I'd like to track down where Xarray code is slower first.
> > 
> > I'm going to dig more into annotated profiles...
> 
> Thanks!  I'll work on a patch to remove the xas_init_marks() from xas_store().
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

