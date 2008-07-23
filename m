Received: by ag-out-0708.google.com with SMTP id 22so13522662agd.8
        for <linux-mm@kvack.org>; Tue, 22 Jul 2008 17:56:46 -0700 (PDT)
Date: Wed, 23 Jul 2008 03:55:08 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 1/4] kmemtrace: Core implementation.
Message-ID: <20080723005508.GA5555@localhost>
References: <1216751493-13785-1-git-send-email-eduard.munteanu@linux360.ro> <1216751493-13785-2-git-send-email-eduard.munteanu@linux360.ro> <y0mvdyx7gnj.fsf@ton.toronto.redhat.com> <20080723005002.GA5206@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080723005002.GA5206@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Frank Ch. Eigler" <fche@redhat.com>
Cc: penberg@cs.helsinki.fi, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Wed, Jul 23, 2008 at 03:50:02AM +0300, Eduard - Gabriel Munteanu wrote:
> On Tue, Jul 22, 2008 at 05:28:16PM -0400, Frank Ch. Eigler wrote:
> > 
> > Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro> writes:
> > 
> > > kmemtrace provides tracing for slab allocator functions, such as kmalloc,
> > > kfree, kmem_cache_alloc, kmem_cache_free etc.. Collected data is then fed
> > > to the userspace application in order to analyse allocation hotspots,
> > > internal fragmentation and so on, making it possible to see how well an
> > > allocator performs, as well as debug and profile kernel code.
> > > [...]
> > 
> > It may make sense to mention in addition that this version of
> > kmemtrace uses markers as the low-level hook mechanism, and this makes
> > the data generated directly accessible to other tracing tools such as
> > systemtap.  Thank you!
> > 
> > 
> > - FChE
> 
> Sounds like a good idea, but I'd like to get rid of markers and use
> Mathieu Desnoyers' tracepoints instead. I'm just waiting for tracepoints
> to get closer to inclusion in mainline/-mm.
> 
> It would be great if tracepoints completely replaced markers, so SystemTap
> would use those instead.
> 
> However, if tracepoints are not ready when kmemtrace is to be merged,
> I'll take your advice and mention markers and SystemTap.
> 
> 
> 	Thanks,
> 	Eduard
>

(fixed Matt's Cc.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
