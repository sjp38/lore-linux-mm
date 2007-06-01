Date: Fri, 1 Jun 2007 15:25:14 +0300
Subject: Re: [PATCH] Document Linux Memory Policy
Message-ID: <20070601122514.GF10459@minantech.com>
References: <1180467234.5067.52.camel@localhost> <200705312243.20242.ak@suse.de> <20070601093803.GE10459@minantech.com> <200706011221.33062.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200706011221.33062.ak@suse.de>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 01, 2007 at 12:21:32PM +0200, Andi Kleen wrote:
> On Friday 01 June 2007 11:38:03 Gleb Natapov wrote:
> > On Thu, May 31, 2007 at 10:43:19PM +0200, Andi Kleen wrote:
> > > 
> > > > > > Do I
> > > > > > miss something here?
> > > > > 
> > > > > I think you do.  
> > > > OK. It seems I missed the fact that VMA policy is completely ignored for
> > > > pagecache backed files and only task policy is used. 
> > > 
> > > That's not correct. tmpfs is page cache backed and supports (even shared) VMA policy.
> > > hugetlbfs used to too, but lost its ability, but will hopefully get it again.
> > > 
> > This is even more confusing.
> 
> I see. Anything that doesn't work exactly as your particular 
> application expects it is "unnatural" and "confusing". I suppose only
> in Glebnix it would be different.
Everything that is defined to work on memory, but sometimes doesn't work
because a memory happened to be backed by file on disk (not just any file).
And not that it just doesn't work as in "return error", but just silently ignored
is confusing to me. I don't know what your definition of "confusing" is.

My application doesn't "expect" anything. Just tell me how can I achieve what I need
and I'll change the application. Creating shared file on tmpfs it out my
control, so I really don't care that numa policy happens to be working
for them. The only option left is create shared memory with shmget(). In
you first reply to me you said that this will not work too. But never
followed up on my replies with map page citations.

> 
> > So numa_*_memory() works different 
> > depending on where file is created.
> 
> See it as "it doesn't work for files, but only for shared memory".
> The main reason for that is that there is no way to make it persistent
> for files.
> 
> I only objected to your page cache based description because tmpfs
> (and even anonymous memory) are page cache based too.
> 
You are right. It should have been "disk backed files" of cause.

> > I can't rely on this anyway and 
> > have to assume that numa_*_memory() call is ignored and prefault.
> 
> It's either use shared/anonymous memory or process policy.
That is where confusion is. You use words "shared memory" here. Is shared
memory created with mmap(MAP_SHARED) is not "shared" enough? Suddenly
such memory became a second class citizen.

> 
> > I think Lee's patches should be applied ASAP to fix this inconsistency.
> 
> They have serious semantic problems.
> 
Can you point me to thread where this was discussed?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
