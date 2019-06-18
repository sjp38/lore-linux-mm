Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72961C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:06:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BA3C20B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:06:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Atm7CO5C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BA3C20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8A326B0003; Tue, 18 Jun 2019 10:06:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3A638E0002; Tue, 18 Jun 2019 10:06:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A01B78E0001; Tue, 18 Jun 2019 10:06:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFDC6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 10:06:32 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id y6so2678618ljj.5
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 07:06:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QTZqy45k7+sDKOksZP/D2s9gAFDBBAHV7AhvC7CBxAQ=;
        b=YVFuaH/N0K4i9oyKmTlYFfxQOE+Qhkzol9aBYkVyI3ytyAFHQ9DefB4SMp2kD512kY
         KvWGklcP+6kkpTSXidVFI0jVJumKIlYEjXOZ7apfcheq+WdhjQY3alk21cJAP+CeGUPu
         q57uL8XI1qSPohq49gzkwU0101s6D41fVNoA4Ln4olgEhHO+2veV75t09rLF0U3XER3V
         2sxylT6yNVE/3qLeQTVjqUV8Mu0Q/jjlu9WbhghMTgXfEvPgVlkEmKy8ITOP/uWRaQ9x
         3rw+GG7t1HveeSTJDp1fOlOdImfb/wcZ6KWDwNqNeJro+A77pVXkVQ2idyJ05BhF5+YA
         aDIA==
X-Gm-Message-State: APjAAAWf4Jr5i6vJahJ7vED3bVW8MXmc2051oaV4NMA160Y4zsg5vD+e
	qdO51W8HdVWEDQunhS8s4Hgzo6+Ew1D7p9ThUtonrJh15Cjp/Ith+P4xO8pwNarX7riksnYSYGJ
	LhJARxdZm4wD7PyZi+cMiVpGw1xFsR3YSbeLl6DtiAI3WWnm7TmskuIgvcQkyiXWAGA==
X-Received: by 2002:ac2:59c9:: with SMTP id x9mr1491103lfn.52.1560866791408;
        Tue, 18 Jun 2019 07:06:31 -0700 (PDT)
X-Received: by 2002:ac2:59c9:: with SMTP id x9mr1491074lfn.52.1560866790592;
        Tue, 18 Jun 2019 07:06:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560866790; cv=none;
        d=google.com; s=arc-20160816;
        b=uUP9EJh+RAw76TFCo8GO2t4IIyEzzUSDo+37iwEypBsa2JityGh3KDWH/uBJBIULhw
         O44BJNRmWYi10/1ATTgKD2GZGjWiM3/YPMtI16dx2qa69P9Ei/WHSYfn4/SL1dya+8lI
         nla3L5tcLwlhNIpff4xsM/oGYJoCEr7cUBcj1XQutNPhqCdB1YtGw5/HbNVkP+s+sHmm
         CQuCiUEevOJ0m66LWmpD2jmJULM8MOR9BqWomlv2vliguVotphGkwEM5PVNu699mkwrY
         j+3ZkSMHxvUnAG4my+HO+TfFgsSULT5BbnycVr5tVWV4BxMis8E8LUiQE4U7NDeKDnnO
         1Cpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=QTZqy45k7+sDKOksZP/D2s9gAFDBBAHV7AhvC7CBxAQ=;
        b=NfMgR66dq+40jtBEbctezIiTYFQGT9uhBkomWFpTzoWaQW9NIfgWPcOPGNIOLvMq99
         mRn242uFbKLZy1xIKS0W2Npd+syTWHGL5bRidv2vmi4ymDR9pFpL/0IaqnIfmzOUKMMS
         qInobPXKQp9OPL+6f5kGBbFtiKREER5BnKdBkxP4YThptoUAntI/b2F8fEIh6uO2obYd
         umtauyyV6PgmJYJ07YK8ilsLtu3o2l8o/C+azBD2XacN/YLVzglZzgDOSG0qpxQRWsRn
         JgZi8DdVPPlxttaW2xLnSiTFil3DDAx7/tSmWmCocTYltEBRQM6GK4vUlu9HMzsjN7cJ
         d+2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Atm7CO5C;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6sor8134569ljc.40.2019.06.18.07.06.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 07:06:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Atm7CO5C;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QTZqy45k7+sDKOksZP/D2s9gAFDBBAHV7AhvC7CBxAQ=;
        b=Atm7CO5Cu6u7ITQBOejBMNudmy6J6C6jPHf8lkqcirJUgLtaP5ac5yQ33LMRr7Dg8P
         9bAspssbkF5m1NiYck3rTXbtN21Z6vGYbWSOEJEl3mIgmUAUxa9dE6609N94K1vQ1y9W
         AYbnm4bbyIb1DOL1GNxgqb8pmFw3YA11xJ28KDcI2k95/DjaplWwuQwWXhW65IQ0uXk9
         yUQ/0Oey7gYcfdoYNSBvzmvgljve31nsG/bS8Ar4UQMh8MQG+YtKdkDG0k3RtYUUi/lz
         9v3/0wjSPGkofCXlPXVcTcJwuzpz+ZfSGivQ4ZWxlaKhhLdbSX8WToxQg0zO2Pj1jOhl
         wN2g==
X-Google-Smtp-Source: APXvYqwHPxz5wQf2l7vQGoUuWHaLCHNCKVabuKAlqkhXyXtuR15zj4ULZlZKJJ46pS7yfP1c1Jo+wQ==
X-Received: by 2002:a2e:9b84:: with SMTP id z4mr33791259lji.75.1560866789998;
        Tue, 18 Jun 2019 07:06:29 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id a18sm2614271ljf.35.2019.06.18.07.06.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 07:06:29 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Tue, 18 Jun 2019 16:06:22 +0200
To: Joel Fernandes <joelaf@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Roman Penyaev <rpenyaev@suse.de>,
	Uladzislau Rezki <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/vmalloc: avoid bogus -Wmaybe-uninitialized warning
Message-ID: <20190618140622.bbak3is7yv32hfjn@pc636>
References: <20190618092650.2943749-1-arnd@arndb.de>
 <CAJWu+oqzd8MJqusRV0LAK=Xnm7VSRSu3QbNZ-j5h9_MbzcFhhg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJWu+oqzd8MJqusRV0LAK=Xnm7VSRSu3QbNZ-j5h9_MbzcFhhg@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 09:40:28AM -0400, Joel Fernandes wrote:
> On Tue, Jun 18, 2019 at 5:27 AM Arnd Bergmann <arnd@arndb.de> wrote:
> >
> > gcc gets confused in pcpu_get_vm_areas() because there are too many
> > branches that affect whether 'lva' was initialized before it gets
> > used:
> >
> > mm/vmalloc.c: In function 'pcpu_get_vm_areas':
> > mm/vmalloc.c:991:4: error: 'lva' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> >     insert_vmap_area_augment(lva, &va->rb_node,
> >     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> >      &free_vmap_area_root, &free_vmap_area_list);
> >      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > mm/vmalloc.c:916:20: note: 'lva' was declared here
> >   struct vmap_area *lva;
> >                     ^~~
> >
> > Add an intialization to NULL, and check whether this has changed
> > before the first use.
> >
> > Fixes: 68ad4a330433 ("mm/vmalloc.c: keep track of free blocks for vmap allocation")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > ---
> >  mm/vmalloc.c | 9 +++++++--
> >  1 file changed, 7 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index a9213fc3802d..42a6f795c3ee 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -913,7 +913,12 @@ adjust_va_to_fit_type(struct vmap_area *va,
> >         unsigned long nva_start_addr, unsigned long size,
> >         enum fit_type type)
> >  {
> > -       struct vmap_area *lva;
> > +       /*
> > +        * GCC cannot always keep track of whether this variable
> > +        * was initialized across many branches, therefore set
> > +        * it NULL here to avoid a warning.
> > +        */
> > +       struct vmap_area *lva = NULL;
> 
> Fair enough, but is this 5-line comment really needed here?
> 
How it is rewritten now, probably not. I would just set it NULL and
leave the comment, but that is IMHO. Anyway

Reviewed-by: Uladzislau Rezki (Sony) <urezki@gmail.com>

Thanks!

--
Vlad Rezki

