Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6B7E6B034B
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 12:20:23 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id j190-v6so2397434itj.3
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 09:20:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c139-v6sor3928819itc.28.2018.11.06.09.20.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 09:20:22 -0800 (PST)
MIME-Version: 1.0
References: <20181105204000.129023-1-bvanassche@acm.org> <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
 <1541454489.196084.157.camel@acm.org> <ce6faf63-1661-abe5-16a6-8c19cc9f6689@rasmusvillemoes.dk>
 <1541457654.196084.159.camel@acm.org> <CAKgT0Udci4Ai4OD20NSRuDckE_G4RHma3Bg6H1Um6N9Se_zPew@mail.gmail.com>
 <1541462466.196084.163.camel@acm.org> <CAKgT0Ue59US_f-cZtoA=yVbFJ03ca5OMce2opUdQcsvgd8LWMw@mail.gmail.com>
 <1541464370.196084.166.camel@acm.org>
In-Reply-To: <1541464370.196084.166.camel@acm.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 6 Nov 2018 09:20:09 -0800
Message-ID: <CAKgT0UekDV4euPHs-wrZixGN1ryhZBq_42XdK6BapYke_xomJg@mail.gmail.com>
Subject: Re: [PATCH] slab.h: Avoid using & for logical and of booleans
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bvanassche@acm.org
Cc: linux@rasmusvillemoes.dk, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, guro@fb.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>

On Mon, Nov 5, 2018 at 4:32 PM Bart Van Assche <bvanassche@acm.org> wrote:
>
> On Mon, 2018-11-05 at 16:11 -0800, Alexander Duyck wrote:
> > If we really don't care then why even bother with the switch statement
> > anyway? It seems like you could just do one ternary operator and be
> > done with it. Basically all you need is:
> > return (defined(CONFIG_ZONE_DMA) && (flags & __GFP_DMA)) ? KMALLOC_DMA :
> >         (flags & __GFP_RECLAIMABLE) ? KMALLOC_RECLAIM : 0;
> >
> > Why bother with all the extra complexity of the switch statement?
>
> I don't think that defined() can be used in a C expression. Hence the
> IS_ENABLED() macro. If you fix that, leave out four superfluous parentheses,
> test your patch, post that patch and cc me then I will add my Reviewed-by.
>
> Bart.

Actually the defined macro is used multiple spots in if statements
throughout the kernel.

The reason for IS_ENABLED is to address the fact that we can be
dealing with macros that indicate if they are built in or a module
since those end up being two different defines depending on if you
select 'y' or 'm'.

Thanks.

- Alex
