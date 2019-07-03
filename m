Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B644C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:19:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAC6E2184C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:19:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="a7Rj0jY2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAC6E2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61BB38E0009; Wed,  3 Jul 2019 13:19:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CE4B8E0001; Wed,  3 Jul 2019 13:19:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C32E8E0009; Wed,  3 Jul 2019 13:19:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2BACD8E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 13:19:15 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id n8so3264499ioo.21
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 10:19:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YGjByfD82DU0x9mX4FdRfeYlzBtivDKcJ0KQXu0Ie1I=;
        b=smUuvtQJ8Vp8kr1kxvVYhDhzD8zPmdUqWc1xfHkQclfgV6PQzVJ6WKa/khSyWRFGGs
         cC31Pc20hs5IJ/JTOJxdbYdoTRgJQ3n17HaJWLuP7WWHi2krlUjEPMIZ2RLl2O3mPLzi
         fa+zLvkSGIXFqs4FZgDBG/M9ef6QvZr8/YZ5Us92yd9mgO76aTVHwhoMq/v4sRdsXG9X
         lW2UZO9guVpHl/pZJVA05R3brrSXXUzBbXQ16d3MU6jhyO9JzTohxtH5nKEOi5xY1KX0
         GLjWk5lbudAbL9J5zXb29pF1RDsisrl8HrljNDFDb87M5GZf+lihGNyX8SlwWjLEgrdI
         vuVw==
X-Gm-Message-State: APjAAAVzO5Obg08OyRpGTyngX+mWG48UjMAuK3dNfFBkdWjqaMC9dwHi
	yxX7QKhoETGOzBqYzSAS80q08Akj/JqWsZuVs49bzpFPixUT15JlXcNFCHFu86NDEQJu9XKkVCv
	leUzkWD4wk+shjXPRUTjn3thM3pJiz/654xtq9TcGmFC1o5S1XTBoWnCVczPcPnv23A==
X-Received: by 2002:a02:ab83:: with SMTP id t3mr43910380jan.133.1562174354861;
        Wed, 03 Jul 2019 10:19:14 -0700 (PDT)
X-Received: by 2002:a02:ab83:: with SMTP id t3mr43910312jan.133.1562174354125;
        Wed, 03 Jul 2019 10:19:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562174354; cv=none;
        d=google.com; s=arc-20160816;
        b=UJu0qWFm4znYD7HPL2ZCwdOAo6GtHlNEtQlqEoOGCI7+xT6BXC8zIE7UFLMJlMQnvA
         qgeREsBBhFu5C/Vorq8TyMZ7xXmFIfkyWYSdCYUlaI4QCVUeW0yFysT0u3tw+aT1OEu5
         6jEKt9bHWpCh+K5bY/Qq+r1neIywdf5gOih7Oq2W2I7McKV5sawPCPLn1n8e3adBBTCW
         fBUlhV9FFXzOghIX+vl/47xVIPCA9ozptmENUnWfM6E63Z2Jl8i54P4mrf/owE7fo99Q
         BgHMBdt0khmqyNDijR5XmCzRy4Mgd6FGZGzimAfS5kUHZSV1xeRVD3Kk3p1d1a8nKVjV
         KcgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YGjByfD82DU0x9mX4FdRfeYlzBtivDKcJ0KQXu0Ie1I=;
        b=YNtIf/vURGFu13KNCwJl8Qlne6waqHKxbvfYapT7tFUTm7bkrC/hpnwznxlFnVexEV
         BPmYSvwkkOwitR0x1JSnsMlRLn+cR2SrPdIUJGyt0babOIrO5IyCLkKUA5xQyDX1uCfe
         uPhsFzyb7vgkTc5CD3kxarT8hmvTriLRW6bFKDWZrFabRk6I/PdAeKofqRwnQF9etvZn
         LkmHNa2LskgwgWKEby4fMh8/q4KRQlqas7dkKN0vWEwqapm/ufT615JxiOCGUuGTlQPf
         LhpQBd3UgD18VGxniNelk1nwsatYaxsYg2gErqZ+hrgvRTOqusgxH9/AG4w2ZfqoZXyn
         wJrw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=a7Rj0jY2;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j128sor2164721iof.121.2019.07.03.10.19.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 10:19:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=a7Rj0jY2;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YGjByfD82DU0x9mX4FdRfeYlzBtivDKcJ0KQXu0Ie1I=;
        b=a7Rj0jY2QBIfViPNFUm76trGe/bKUY7mCjPwJbiaJ50x6pJNRBkPu+R1MM8mw6sOOU
         4B3aEJKjRb3+e7bU3IP1jFdb1YFmzDwlsN4MXd++Uf2Fp2Nzel29i8J9XQ22NojddDZB
         +Ulzkl67GjTVkp41624QkEl0E/s8o3qkxFuABwKgTE6kJYqMZA8jNskfHCbQOBk6pnzR
         NOpvtVVjeuJiet55kmS0P+X09nZ3dUpGlSld4TNhSinRaDzB2lEIW0iwUqau3LNF+c3h
         39nW6JLRT+JrNz8eQ83heezlELAfEDy8iT1ms460iBM6Lt5wffeg7MZ2w0nk/P0WI2Ur
         Z3XQ==
X-Google-Smtp-Source: APXvYqyUr71sdXpi43QYYZjncftgBxdzVnH8D2CCeSrP2TVbacVB/SQkZJ/WcE7USxtw+O12qqHaCQkIyrNp/Rpqopk=
X-Received: by 2002:a5e:c207:: with SMTP id v7mr10360260iop.163.1562174353630;
 Wed, 03 Jul 2019 10:19:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190701173042.221453-1-henryburns@google.com>
 <CAMJBoFPbRcdZ+NnX17OQ-sOcCwe+ZAsxcDJoR0KDkgBY9WXvpg@mail.gmail.com>
 <CAGQXPTjX=7aD9MQAs2kJthFvPdd3x8Nh53oc=wZCXH_dvDJ=Vg@mail.gmail.com> <CAMJBoFMBLv9OpXtQkOAyZ-vw5Ktk1tYtvfT=GPPx8jnKBN01rg@mail.gmail.com>
In-Reply-To: <CAMJBoFMBLv9OpXtQkOAyZ-vw5Ktk1tYtvfT=GPPx8jnKBN01rg@mail.gmail.com>
From: Henry Burns <henryburns@google.com>
Date: Wed, 3 Jul 2019 10:18:37 -0700
Message-ID: <CAGQXPThUgPA2gZkOiuFph43Qq_zFohbMcn_70dtjQZ_HxD41fQ@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold: Fix z3fold_buddy_slots use after free
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vitaly Vul <vitaly.vul@sony.com>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Xidong Wang <wangxidong_97@163.com>, 
	Shakeel Butt <shakeelb@google.com>, Jonathan Adams <jwadams@google.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000006, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > On Tue, Jul 2, 2019 at 12:45 AM Vitaly Wool <vitalywool@gmail.com> wrote:
> > >
> > > Hi Henry,
> > >
> > > On Mon, Jul 1, 2019 at 8:31 PM Henry Burns <henryburns@google.com> wrote:
> > > >
> > > > Running z3fold stress testing with address sanitization
> > > > showed zhdr->slots was being used after it was freed.
> > > >
> > > > z3fold_free(z3fold_pool, handle)
> > > >   free_handle(handle)
> > > >     kmem_cache_free(pool->c_handle, zhdr->slots)
> > > >   release_z3fold_page_locked_list(kref)
> > > >     __release_z3fold_page(zhdr, true)
> > > >       zhdr_to_pool(zhdr)
> > > >         slots_to_pool(zhdr->slots)  *BOOM*
> > >
> > > Thanks for looking into this. I'm not entirely sure I'm all for
> > > splitting free_handle() but let me think about it.
> > >
> > > > Instead we split free_handle into two functions, release_handle()
> > > > and free_slots(). We use release_handle() in place of free_handle(),
> > > > and use free_slots() to call kmem_cache_free() after
> > > > __release_z3fold_page() is done.
> > >
> > > A little less intrusive solution would be to move backlink to pool
> > > from slots back to z3fold_header. Looks like it was a bad idea from
> > > the start.
> > >
> > > Best regards,
> > >    Vitaly
> >
> > We still want z3fold pages to be movable though. Wouldn't moving
> > the backink to the pool from slots to z3fold_header prevent us from
> > enabling migration?
>
> That is a valid point but we can just add back pool pointer to
> z3fold_header. The thing here is, there's another patch in the
> pipeline that allows for a better (inter-page) compaction and it will
> somewhat complicate things, because sometimes slots will have to be
> released after z3fold page is released (because they will hold a
> handle to another z3fold page). I would prefer that we just added back
> pool to z3fold_header and changed zhdr_to_pool to just return
> zhdr->pool, then had the compaction patch valid again, and then we
> could come back to size optimization.

I see your point, patch incoming.

