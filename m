Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 95EA76B0035
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 17:22:10 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so24082587pab.5
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 14:22:10 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id gy2si6148819pbb.106.2014.08.26.14.22.09
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 14:22:09 -0700 (PDT)
Date: Tue, 26 Aug 2014 16:22:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm/slab: use percpu allocator for cpu cache
In-Reply-To: <20140826021904.GA1035@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1408261620500.4609@gentwo.org>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.11.1408210918050.32524@gentwo.org> <20140825082615.GA13475@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1408250809420.17236@gentwo.org> <20140826021904.GA1035@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>, linux-kernel@vger.kernel.org

On Tue, 26 Aug 2014, Joonsoo Kim wrote:

> > What case? SLUB uses a linked list and therefore does not have these
> > storage requirements.
>
> I misunderstand that you mentioned just memory usage. My *any case*
> means memory usage of previous SLAB and SLAB with this percpu alloc
> change. Sorry for confusion.

Ok. True the total amount of memory used does not increase.

> > > I know that percpu allocator occupy vmalloc space, so maybe we could
> > > exhaust vmalloc space on 32 bit. 64 bit has no problem on it.
> > > How many cores does largest 32 bit system have? Is it possible
> > > to exhaust vmalloc space if we use percpu allocator?
> >
> > There were NUMA systems on x86 a while back (not sure if they still
> > exists) with 128 or so processors.
> >
> > Some people boot 32 bit kernels on contemporary servers. The Intel ones
> > max out at 18 cores (36 hyperthreaded). I think they support up to 8
> > scokets. So 8 * 36?
> >
> >
> > Its different on other platforms with much higher numbers. Power can
> > easily go up to hundreds of hardware threads and SGI Altixes 7 yearsago
> > where at 8000 or so.
>
> Okay... These large systems with 32 bit kernel could be break with this
> change. I will do more investigation. Possibly, I will drop this patch. :)

Wait the last system mentioned are 64 bit. SGI definitely. Power probably
too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
