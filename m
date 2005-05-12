Date: Thu, 12 May 2005 13:22:30 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: NUMA aware slab allocator V2
Message-Id: <20050512132230.118b0c25.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
	<20050512000444.641f44a9.akpm@osdl.org>
	<Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> On Thu, 12 May 2005, Andrew Morton wrote:
> 
> > Christoph Lameter <clameter@engr.sgi.com> wrote:
> > >
> > > This patch allows kmalloc_node to be as fast as kmalloc by introducing
> > >  node specific page lists for partial, free and full slabs.
> >
> > This patch causes the ppc64 G5 to lock up fairly early in boot.  It's
> > pretty much a default config:
> > http://www.zip.com.au/~akpm/linux/patches/stuff/config-pmac
> >
> > No serial port, no debug environment, but no useful-looking error messages
> > either.  See http://www.zip.com.au/~akpm/linux/patches/stuff/dsc02516.jpg
> 
> I got rc4-mm1 and booted it on an x86_64 machines with similar
> configuration (no NUMA but SMP, numa slab uncommented) but multiple
> configurations worked fine (apart from another error attempting to
> initialize a nonexistand second cpu by the NMI handler that I described
> in another email to you). I have no ppc64 available.
> 
> Could we boot the box without quiet so that we can get better debug
> messages?

OK, I'll try that, but I doubt if it'll give much more info.

> Did the box boot okay without the patch?

Yup, I tested base 2.6.12-rc4 and 2.6.12-rc4+the-patch-you-sent.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
