Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD906B0005
	for <linux-mm@kvack.org>; Sat,  4 Aug 2018 05:29:06 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id x17-v6so4409515uap.12
        for <linux-mm@kvack.org>; Sat, 04 Aug 2018 02:29:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9-v6sor2791632uaa.201.2018.08.04.02.29.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 04 Aug 2018 02:29:05 -0700 (PDT)
MIME-Version: 1.0
References: <20180411060320.14458-1-willy@infradead.org> <20180411060320.14458-3-willy@infradead.org>
 <alpine.DEB.2.20.1804110842560.3788@nuc-kabylake> <20180411192448.GD22494@bombadil.infradead.org>
 <alpine.DEB.2.20.1804111601090.7458@nuc-kabylake> <20180411235652.GA28279@bombadil.infradead.org>
 <alpine.DEB.2.20.1804120907100.11220@nuc-kabylake> <20180412142718.GA20398@bombadil.infradead.org>
 <20180412191322.GA21205@bombadil.infradead.org> <20180803212257.GA5922@roeck-us.net>
 <20180803223357.GA23284@bombadil.infradead.org>
In-Reply-To: <20180803223357.GA23284@bombadil.infradead.org>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sat, 4 Aug 2018 11:28:52 +0200
Message-ID: <CAMuHMdXXYH_7oVJJ5sGWFj_-WbjuMdooXTqBfV+z0CzR193T3A@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] slab: __GFP_ZERO is incompatible with a constructor
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Guenter Roeck <linux@roeck-us.net>, Christoph Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, jlayton@redhat.com, Mel Gorman <mgorman@techsingularity.net>, Linux-sh list <linux-sh@vger.kernel.org>

On Sat, Aug 4, 2018 at 12:34 AM Matthew Wilcox <willy@infradead.org> wrote:
> On Fri, Aug 03, 2018 at 02:22:57PM -0700, Guenter Roeck wrote:
> > On Thu, Apr 12, 2018 at 12:13:22PM -0700, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > __GFP_ZERO requests that the object be initialised to all-zeroes,
> > > while the purpose of a constructor is to initialise an object to a
> > > particular pattern.  We cannot do both.  Add a warning to catch any
> > > users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
> > > a constructor.
> > >
> > > Fixes: d07dbea46405 ("Slab allocators: support __GFP_ZERO in all allocators")
> > > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> > > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> >
> > Seen with v4.18-rc7-139-gef46808 and v4.18-rc7-178-g0b5b1f9a78b5 when
> > booting sh4 images in qemu:
>
> Thanks!  It's under discussion here:
>
> https://marc.info/?t=153301426900002&r=1&w=2

and https://www.spinics.net/lists/linux-sh/msg53298.html

> also reported here with a bogus backtrace:
>
> https://marc.info/?l=linux-sh&m=153305755505935&w=2
>
> Short version: It's a bug that's been present since 2009 and nobody
> noticed until now.  And nobody's quite sure what the effect of this
> bug is.
Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
