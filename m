Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 534A3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 12:24:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E33072087C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 12:24:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cjKA91tL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E33072087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4135D8E0003; Wed, 27 Feb 2019 07:24:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39CB68E0001; Wed, 27 Feb 2019 07:24:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23AAE8E0003; Wed, 27 Feb 2019 07:24:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2CC98E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 07:24:54 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h70so13094052pfd.11
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 04:24:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=R0BkAjbufpb2k9PEj6vKmkHn6B6MS+KyUi/AaeClImw=;
        b=gtHPMP/LEgPouGH6YnPeICd4mJGXVEgzd5R7KSSPZ5bXL4LZf9/yG2sKA53vP9yuif
         NAtxoaufiIO2NVynfzDuz0PieIqRt30dEJsn4Wpc47Sry3HpgYNc1VzHN5uEJOJjyyWq
         MCA1uGsc94skAiu6bLvRNFvKuUvwOj96lm2NbCiou+GhIT6NPUhJROs4sryNvWOV9FBu
         kkDHZDxU0aXZvJMOafkm2TGxzsl0tagt5PMW056ls/yBXboA9QzU1MK86BR6LoXqL9SM
         s4Q2BwSeI9m0QBGsxM/rNwpQpmcypy1ZvYeynyN6vtS/Wpry8ohL8FlbR7oDah6UoBUI
         xezA==
X-Gm-Message-State: AHQUAua7f5kWVwgLSafScoGXYYAOHgmCI5XLKBo5QvELR5o+psCbivsA
	Jio3FE9KaJGI3UI26mN9JzYgUqR1+5foq4PIdGc6GLyGxfhAYYpWdm8r2bGya/klte7AXOyJs9L
	M15hs5bg8mgrKgVVC2MJZNdHHKCfOqtO/4tNHm+/6DeH723bp8woQMLLYywrotg3a5A==
X-Received: by 2002:a17:902:8344:: with SMTP id z4mr1898715pln.77.1551270294188;
        Wed, 27 Feb 2019 04:24:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbValJ1o+3Eun/JZbD/gk2reVZnhAU45q9W45OaxOATwQmJCgAYIs2rN3X1ii3yyXVJqSh3
X-Received: by 2002:a17:902:8344:: with SMTP id z4mr1898614pln.77.1551270292553;
        Wed, 27 Feb 2019 04:24:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551270292; cv=none;
        d=google.com; s=arc-20160816;
        b=Jq2oeuHrhCjLm9Bk6cBVLTeR8sAkc2RpTMd5o7DOmXsyyAiAB5hSGFI3ce6Nn5sl+g
         viS0rcFJtUdMnTgDImr5QmVwnpbGt+66lPhigjgXV2Fkunpq9xIp6QthqfUvE5erNkV5
         b4nebvNn7h1iSU717Wac2eAVieiJZR8RgEIEoHAF/Uyc4wjln+VKhSKFq9/rCpFvbarj
         e1embzYRFx1CoQtqOWv4Pxo24gyKv81i02SKfoe9ue9CpOk2d7jcXWPASP9yvTUSobKI
         uIWPoPqiCByvu2cMYVwGfSkVEVt1psDIVEe8Gkahu8CCrArzfDCzwVaCUdeqkFTOT/S2
         Q5UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=R0BkAjbufpb2k9PEj6vKmkHn6B6MS+KyUi/AaeClImw=;
        b=UDL8fur+Wl5UeJuR5sN1Yrm95xoXON6rFTYV3UqEn/6X934sY1P50XgKqNPs8zIqv3
         Uw0jUHjVhQ792DsPXwLeMiqtbC659hpqPRew1BhtQHbFf6oK+g+pr0FPkIkmqEQY0jQ/
         kwsEh8udr/SaDX9MYtT1HI6KPPO4Gq1HJRcghgL74B7gYQbbYnd2nIf5XExVoP6yLLIK
         Fyvwk5goiK3Ml1noL6cbnJ25C9rFC3TXngrfTMsp54jO9L94xR5xKMuSgFZfdOlmZYe1
         mdztmHvyrJbuflV1z412wOWmW414H4mVwHcCNzOzvVxG4UmUDQ2kEGM181ZOGbU2LO6m
         wfsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cjKA91tL;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d5si10250848pfh.138.2019.02.27.04.24.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Feb 2019 04:24:52 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cjKA91tL;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=R0BkAjbufpb2k9PEj6vKmkHn6B6MS+KyUi/AaeClImw=; b=cjKA91tLGH4YObxPTlRDebFqm
	afTcGNFS2uV1Rku4ZcCsX54VHAtA0K/meLGpvRhQfMTV8mK1gT/iyan7Pb7LcoansxHN3aFIVAJcR
	Q3cL2VEZOMnzXRlU8U5CU6i1ip5UXf2g8jTfoemb9B4/AUpp9WHvM2hIVw+Oc54XS55Koanfr/vIk
	b+r9r0WDeDSDJsiaSjBWV0GEPKUGdVaoeRi+8QIFaTf01nVRwWCrrB1Skj+SiEed3DRqhvHAuO8ZM
	aP0p4pLFrbDmK4DtVUBv5OZ/zt2l4jAYS/kqdz/er0fuEpMAyBUqd+eTH/mhoSTI3F1kM/XutVJHr
	Esn79LkBw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gyyGZ-0002qM-Kv; Wed, 27 Feb 2019 12:24:51 +0000
Date: Wed, 27 Feb 2019 04:24:51 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mgorman@suse.de
Subject: Re: Truncate regression due to commit 69b6c1319b6
Message-ID: <20190227122451.GJ11592@bombadil.infradead.org>
References: <20190226165628.GB24711@quack2.suse.cz>
 <20190226172744.GH11592@bombadil.infradead.org>
 <20190227112721.GB27119@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190227112721.GB27119@quack2.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 12:27:21PM +0100, Jan Kara wrote:
> On Tue 26-02-19 09:27:44, Matthew Wilcox wrote:
> > On Tue, Feb 26, 2019 at 05:56:28PM +0100, Jan Kara wrote:
> > > after some peripeties, I was able to bisect down to a regression in
> > > truncate performance caused by commit 69b6c1319b6 "mm: Convert truncate to
> > > XArray".
> > 
> > [...]
> > 
> > > I've gathered also perf profiles but from the first look they don't show
> > > anything surprising besides xas_load() and xas_store() taking up more time
> > > than original counterparts did. I'll try to dig more into this but any idea
> > > is appreciated.
> > 
> > Well, that's a short and sweet little commit.  Stripped of comment
> > changes, it's just:
> > 
> > -       struct radix_tree_node *node;
> > -       void **slot;
> > +       XA_STATE(xas, &mapping->i_pages, index);
> >  
> > -       if (!__radix_tree_lookup(&mapping->i_pages, index, &node, &slot))
> > +       xas_set_update(&xas, workingset_update_node);
> > +       if (xas_load(&xas) != entry)
> >                 return;
> > -       if (*slot != entry)
> > -               return;
> > -       __radix_tree_replace(&mapping->i_pages, node, slot, NULL,
> > -                            workingset_update_node);
> > +       xas_store(&xas, NULL);
> 
> Yes, the code change is small. Thanks to you splitting the changes, the
> regression is easier to analyze so thanks for that :)

That was why I split the patches so small.  I'm kind of glad it paid off ...
not glad to have caused a performance regression!

> > I have a few reactions to this:
> > 
> > 1. I'm concerned that the XArray may generally be slower than the radix
> > tree was.  I didn't notice that in my testing, but maybe I didn't do
> > the right tests.
> 
> So one difference I've noticed when staring into the code and annotated
> perf traces is that xas_store() will call xas_init_marks() when stored
> entry is 0. __radix_tree_replace() didn't do this. And the cache misses we
> take from checking tags do add up. After hacking the code in xas_store() so
> that __clear_shadow_entry() does not touch tags, I get around half of the
> regression back. For now I didn't think how to do this so that the API
> remains reasonably clean. So now we are at:
> 
> COMMIT      AVG            STDDEV
> a97e7904c0  1431256.500000 1489.361759
> 69b6c1319b  1566944.000000 2252.692877
> notaginit   1483740.700000 7680.583455

Well, that seems worth doing.  For the page cache case, we know that
shadow entries have no tags set (at least right now), so it seems
reasonable to move the xas_init_marks() from xas_store() to its various
callers.

> > 2. The setup overhead of the XA_STATE might be a problem.
> > If so, we can do some batching in order to improve things.
> > I suspect your test is calling __clear_shadow_entry through the
> > truncate_exceptional_pvec_entries() path, which is already a batch.
> > Maybe something like patch [1] at the end of this mail.
> 
> So this apparently contributes as well but not too much. With your patch
> applied on top of 'notaginit' kernel above I've got to:
> 
> batched-xas 1473900.300000 950.439377

Fascinating that it reduces the stddev so much.  We can probably take this
further (getting into the realm of #3 below) -- the call to xas_set() will
restart the walk from the top of the tree each time.  Clearly this usecase
(many thousands of shadow entries) is going to construct a very deep tree,
and we're effectively doing a linear scan over the bottom of the tree, so
starting from the top each time is O(n.log n) instead of O(n).  I think
you said the file was 64GB, which is 16 million 4k entries, or 24 bits of
tree index.  That's 4 levels deep so it'll add up.

> > 3. Perhaps we can actually get rid of truncate_exceptional_pvec_entries().
> > It seems a little daft for page_cache_delete_batch() to skip value
> > entries, only for truncate_exceptional_pvec_entries() to erase them in
> > a second pass.  Truncation is truncation, and perhaps we can handle all
> > of it in one place?
> > 
> > 4. Now that calling through a function pointer is expensive, thanks to
> > Spectre/Meltdown/..., I've been considering removing the general-purpose
> > update function, which is only used by the page cache.  Instead move parts
> > of workingset.c into the XArray code and use a bit in the xa_flags to
> > indicate that the node should be tracked on an LRU if it contains only
> > value entries.
> 
> I agree these two are good ideas to improve the speed. But old radix tree
> code has these issues as well so they are not the reason of this
> regression. So I'd like to track down where Xarray code is slower first.
> 
> I'm going to dig more into annotated profiles...

Thanks!  I'll work on a patch to remove the xas_init_marks() from xas_store().

