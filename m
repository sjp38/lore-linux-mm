Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2896B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 23:06:02 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so33670314pab.11
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 20:06:02 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id z4si8192132pda.201.2015.01.28.20.06.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jan 2015 20:06:01 -0800 (PST)
Message-ID: <1422504356.6621.4.camel@ellerman.id.au>
Subject: Re: [PATCH v3] powerpc/mm: fix undefined reference to
 `.__kernel_map_pages' on FSL PPC64
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Thu, 29 Jan 2015 15:05:56 +1100
In-Reply-To: <20150128141417.ba2e413fd8ccc8bfd65196e1@freescale.com>
References: <20150120140200.aa7ba0eb28d95e456972e178@freescale.com>
	 <20150120230150.GA14475@cloud>
	 <20150120160738.edfe64806cc8b943beb1dfa0@linux-foundation.org>
	 <CAC5umyieZn7ppXkKb45O=C=BF+iv6R_A1Dwfhro=cBJzFeovrA@mail.gmail.com>
	 <20150122014550.GA21444@js1304-P5Q-DELUXE>
	 <20150122144147.019eedc41f189eac44c3c4cd@freescale.com>
	 <CAC5umyiF52cykH2_5TD0yzXb+842gywpe-+XZHEwmrDe0nYCPw@mail.gmail.com>
	 <20150122212017.4b7032d52a6c75c06d5b4728@freescale.com>
	 <1421987091.24984.13.camel@ellerman.id.au>
	 <20150126132222.6477257be204a3332601ef11@freescale.com>
	 <1422406862.32234.1.camel@ellerman.id.au>
	 <CAAmzW4M3O81wBFeZ+JEVZnjRwMNwXnPKeL62Zz96xe_6a7WZpg@mail.gmail.com>
	 <20150127185711.ee819e4b.akpm@linux-foundation.org>
	 <1422415322.32234.3.camel@ellerman.id.au>
	 <20150128141417.ba2e413fd8ccc8bfd65196e1@freescale.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kim Phillips <kim.phillips@freescale.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, Akinobu Mita <akinobu.mita@gmail.com>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, josh@joshtriplett.org, LKML <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@fb.com>, Minchan Kim <minchan@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Scott Wood <scottwood@freescale.com>

On Wed, 2015-01-28 at 14:14 -0600, Kim Phillips wrote:
> On Wed, 28 Jan 2015 14:22:02 +1100
> Michael Ellerman <mpe@ellerman.id.au> wrote:
> 
> > On Tue, 2015-01-27 at 18:57 -0800, Andrew Morton wrote:
> > > On Wed, 28 Jan 2015 10:33:59 +0900 Joonsoo Kim <js1304@gmail.com> wrote:
> > > 
> > > > 2015-01-28 10:01 GMT+09:00 Michael Ellerman <mpe@ellerman.id.au>:
> > > > > On Mon, 2015-01-26 at 13:22 -0600, Kim Phillips wrote:
> > > > >> arch/powerpc has __kernel_map_pages implementations in mm/pgtable_32.c, and
> > > > >
> > > > > I'd be happy to take this through the powerpc tree for 3.20, but for this:
> > > > >
> > > > >> depends on:
> > > > >> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > > >> Date: Thu, 22 Jan 2015 10:28:58 +0900
> > > > >> Subject: [PATCH] mm/debug_pagealloc: fix build failure on ppc and some other archs
> > > > >
> > > > > I don't have that patch in my tree.
> > > > >
> > > > > But in what way does this patch depend on that one?
> > > > >
> > > > > It looks to me like it'd be safe to take this on its own, or am I wrong?
> > > > 
> > > > Hello,
> > > > 
> > > > These two patches are merged to Andrew's tree now.
> > > 
> > > That didn't answer either of Michael's questions ;)
> > > 
> > > Yes, I think they're independent.  I was holding off on the powerpc
> 
> sorry - my bad, they are indeed completely independent.
 
No worries.

> > > one, waiting to see if it popped up in linux-next via your tree.  I can
> > > merge both if you like?
> > 
> > Right, I didn't think I'd seen it in your tree :)
> > 
> > I'm happy to take this one, saves a possible merge conflict.
> 
> I'm fine either way (I work on linux-next).

Cool. It's in my next as of now, so should be in linux-next tomorrow (30th).

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
