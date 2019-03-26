Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BC01C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:34:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7629206DF
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:34:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7629206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F8986B0005; Tue, 26 Mar 2019 12:34:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A8CE6B028D; Tue, 26 Mar 2019 12:34:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 172916B028F; Tue, 26 Mar 2019 12:34:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B941C6B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:34:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p88so1593622edd.17
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:34:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=H+7OVsvEwhn5IgvoV7terYZ4TNjyjLp8FU/v4rcpkwM=;
        b=UlItTZV2XWnG8v5qgEGdA6pIPkLNrxwmfic++QPkReuPZS21L17ZQObgCJROP+R/9H
         Nj3rtTZlg08HfTL7kMgts1qCgrkJwGeiV8SBXKg3xzkjO2Fc5RGA1qyFqak/u7Vszcg2
         sNjMY3OnENqUY0t1/CTB9dgvcFm3G9hpI0ShHhNUFfJiFxcIyx762Alnkzby1UfboyIC
         JzEFGjw/b1MZ4ZMRcqoss+WHE3e8O7K/KYuv+ATrxXAwYALirLhEYUh65KhwewZxt0iI
         HuwXybCFc/H54Fr6cr+7wbnGsM4tu3gPZ4B1aH9OJ4O7mmTucgamEd4hRTLkxqZvuFhY
         lj1g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXrjpiTIkv7Vyl3x5vpr4Ba4WAww+kMzw8wRChBDJt0v9GxS32N
	k50cZ17tpTb/UBLeCw9OgRH1m5O/HFq7IZzZXVOlPq/ns6a/w24PKWB8knqOz5aowzIouNoq4Rd
	sA0d9DNfNt1K0ffzhDq9GJbK55LI/jMEFVnGz88/ncDl+Xtoz56DR0rClokTgPmo=
X-Received: by 2002:a17:906:bce9:: with SMTP id op9mr18106993ejb.65.1553618041305;
        Tue, 26 Mar 2019 09:34:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/g03e7cp5R8oza0PV13Bhfmw9TOTaHy7xrCTiClyy5VumaAhjhnp6BC7aR/5kBBvT6SqQ
X-Received: by 2002:a17:906:bce9:: with SMTP id op9mr18106965ejb.65.1553618040554;
        Tue, 26 Mar 2019 09:34:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553618040; cv=none;
        d=google.com; s=arc-20160816;
        b=ECdhbzIufQHDyUyakSETsyjAZkuqC0/7DbFsnSjxgCLpfmImAIJU62ouydWoXl9o2b
         84UQNDGYupOwrvbBcsWtFBGzvYepkJHJfAM7q126s3e/DJJ93tjODZwOYWO213tcOpZ9
         T0l31YC/kqwN9SzUXQ9gG8BRwYS/GKoLkhcP/WPh2b6Xbr2g6qkNusk7fyeyGoj2iDEQ
         dbjnGm5j9bB79TOl9VvO0K5VyGuN1bP/rkGLJfbPyQs3VwlIGWYcz2ypAjOaffvYRArR
         nNr0iijdQfqL5zIjNYiDsOlBt33Mo7J3Q22rk7Q7haWFyyU9fb9H99ZnIvoQEIVAcOf1
         xqxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=H+7OVsvEwhn5IgvoV7terYZ4TNjyjLp8FU/v4rcpkwM=;
        b=GnyATMPitD1WsgCJqCgr+u/8uytP0yQmPwthkGPpx1CjEXcREh4PS5KcQoZRpYo3sh
         HfLxhzrZyS9GigK2+3KQmmqJ8IjLRF8UI+ftqRcKi9/wzs3t6xmpXpSsTrSyAn3LHirt
         PRrSPAd3gLxlG1BwtNHaXzJiBK0HsNKyxsgNe754vaTvMMr0M+D+XuT8sZnRl33+iHZC
         7Do4oOXGCOfFcKTHEmYcfemFPTu9MHlpXd6jVnzGUtkevPTO/1gX+EIKmdwuifL5mqnp
         Gsf42pnmze5do4aw9gWdCRuxur66yyrVgUG/x2KvyzZxhkY9Y8fYM7de96dpV6dphCiw
         T9cA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si3180592eda.290.2019.03.26.09.34.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 09:34:00 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9CD33ABC1;
	Tue, 26 Mar 2019 16:33:59 +0000 (UTC)
Date: Tue, 26 Mar 2019 17:33:56 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>,
	akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org,
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] kmemleaak: survive in a low-memory situation
Message-ID: <20190326163356.GS28406@dhcp22.suse.cz>
References: <20190326154338.20594-1-cai@lca.pw>
 <20190326160536.GO10344@bombadil.infradead.org>
 <20190326162038.GH33308@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326162038.GH33308@arrakis.emea.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 16:20:41, Catalin Marinas wrote:
> On Tue, Mar 26, 2019 at 09:05:36AM -0700, Matthew Wilcox wrote:
> > On Tue, Mar 26, 2019 at 11:43:38AM -0400, Qian Cai wrote:
> > > Unless there is a brave soul to reimplement the kmemleak to embed it's
> > > metadata into the tracked memory itself in a foreseeable future, this
> > > provides a good balance between enabling kmemleak in a low-memory
> > > situation and not introducing too much hackiness into the existing
> > > code for now.
> > 
> > I don't understand kmemleak.  Kirill pointed me at this a few days ago:
> > 
> > https://gist.github.com/kiryl/3225e235fea390aa2e49bf625bbe83ec
> > 
> > It's caused by the XArray allocating memory using GFP_NOWAIT | __GFP_NOWARN.
> > kmemleak then decides it needs to allocate memory to track this memory.
> > So it calls kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
> > 
> > #define gfp_kmemleak_mask(gfp)  (((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
> >                                  __GFP_NORETRY | __GFP_NOMEMALLOC | \
> >                                  __GFP_NOWARN | __GFP_NOFAIL)
> > 
> > then the page allocator gets to see GFP_NOFAIL | GFP_NOWAIT and gets angry.
> > 
> > But I don't understand why kmemleak needs to mess with the GFP flags at
> > all.
> 
> Originally, it was just preserving GFP_KERNEL | GFP_ATOMIC. Starting
> with commit 6ae4bd1f0bc4 ("kmemleak: Allow kmemleak metadata allocations
> to fail"), this mask changed, aimed at making kmemleak allocation
> failures less verbose (i.e. just disable it since it's a debug tool).
> 
> Commit d9570ee3bd1d ("kmemleak: allow to coexist with fault injection")
> introduced __GFP_NOFAIL but this came with its own problems which have
> been previously reported (the warning you mentioned is another one of
> these). We didn't get to any clear conclusion on how best to allow
> allocations to fail with fault injection but not for the kmemleak
> metadata. Your suggestion below would probably do the trick.

I have objected to that on several occasions. An implicit __GFP_NOFAIL
is simply broken and __GFP_NOWAIT allocations are a shiny example of
that. You cannot loop inside the allocator for an unbound amount of time
potentially with locks held. I have heard that there are some plans to
deal with that but nothing has really materialized AFAIK. d9570ee3bd1d
should be reverted I believe.

The proper way around is to keep a pool objects and keep spare objects
for restrected allocation contexts.
-- 
Michal Hocko
SUSE Labs

