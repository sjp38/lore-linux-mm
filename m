Date: Sun, 8 Jun 2008 19:34:20 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-ID: <20080608193420.2a9cc030@bree.surriel.com>
In-Reply-To: <20080608162208.a2683a6c.akpm@linux-foundation.org>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.291472052@redhat.com>
	<20080606180506.081f686a.akpm@linux-foundation.org>
	<20080608163413.08d46427@bree.surriel.com>
	<20080608135704.a4b0dbe1.akpm@linux-foundation.org>
	<20080608173244.0ac4ad9b@bree.surriel.com>
	<20080608162208.a2683a6c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 8 Jun 2008 16:22:08 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> The this-is-64-bit-only problem really sucks, IMO.  We still don't know
> the reason for that decision.  Presumably it was because we've already
> run out of page flags?  If so, the time for the larger pageframe is
> upon us.

32 bit machines are unlikely to have so much memory that they run
into big scalability issues with mlocked memory.

The obvious exception to that are large PAE systems, which run
into other bottlenecks already and will probably hit the wall in
some other way before suffering greatly from the "kswapd is
scanning unevictable pages" problem.

I'll leave it up to you to decide whether you want this feature
64 bit only, or whether you want to use up the page flag on 32
bit systems too.

Please let me know which direction I should take, so I can fix
up the patch set accordingly.
 
> > > As a starting point: what, in your english-language-paragraph-length
> > > words, does this flag mean?
> > 
> > "Cannot be reclaimed because someone has it locked in memory
> > through mlock, or the page belongs to something that cannot
> > be evicted like ramfs."
> 
> Ray's "unevictable" sounds good.  It's not a term we've used elsewhere.
> 
> It's all a bit arbitrary, but it's just a label which maps onto a
> concept and if we all honour that mapping carefully in our code and
> writings, VM maintenance becomes that bit easier.

OK, I'll rename everything to unevictable and will add documentation
to clear up the meaning.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
