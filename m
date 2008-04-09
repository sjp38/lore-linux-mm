Date: Tue, 8 Apr 2008 22:08:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 0/6] compcache: Compressed Caching
Message-Id: <20080408220829.77051180.akpm@linux-foundation.org>
In-Reply-To: <4cefeab80804082202ub29fad6m2bb2337cbea6ed97@mail.gmail.com>
References: <200803210129.59299.nitingupta910@gmail.com>
	<20080408194740.1219e8b8.akpm@linux-foundation.org>
	<4cefeab80804082202ub29fad6m2bb2337cbea6ed97@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nitin Gupta <nitingupta910@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Apr 2008 10:32:06 +0530 "Nitin Gupta" <nitingupta910@gmail.com> wrote:

> On Wed, Apr 9, 2008 at 8:17 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Fri, 21 Mar 2008 01:29:58 +0530 Nitin Gupta <nitingupta910@gmail.com> wrote:
> >
> >  > Subject: [RFC][PATCH 0/6] compcache: Compressed Caching
> >
> >  Didn't get many C's, did it?
> >
> >  Be sure to cc linux-kernel on the next version.
> >
> >
> 
> I have already posted it again on linux-kernel with link to
> performance figures for allocator (TLSF vs SLUB):
> 
> see: http://lkml.org/lkml/2008/4/8/69
> 

Information like this should be maintained within the changelog, please.

> TLSF comparison with SLUB can be found here:
> 
> http://code.google.com/p/compcache/wiki/AllocatorsComparison

Ditto.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
