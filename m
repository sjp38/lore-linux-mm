Date: Wed, 25 Jul 2007 18:07:43 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: howto get a patch merged (WAS: Re: -mm merge plans for 2.6.23)
Message-ID: <20070725160743.GB8284@elte.hu>
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kacper Wysocki <kacperw@online.no>
Cc: Rene Herman <rene.herman@gmail.com>, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Valdis.Kletnieks@vt.edu, Ray Lee <ray-lk@madrabbit.org>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Jesper Juhl <jesper.juhl@gmail.com>
List-ID: <linux-mm.kvack.org>

* Kacper Wysocki <kacperw@online.no> wrote:

> [snip howto get a patch merged]

> > But a "here is a solution, take it or leave it" approach, before 
> > having communicated the problem to the maintainer and before having 
> > debugged the problem is the wrong way around. It might still work 
> > out fine if the solution is correct (especially if the patch is 
> > small and obvious), but if there are any non-trivial tradeoffs 
> > involved, or if nontrivial amount of code is involved, you might see 
> > your patch at the end of a really long (and constantly growing) 
> > waiting list of patches.
> 
> Is that what happened with swap prefetch these two years? The approach 
> has been wrong?

i dont know - but one of the maintainers of the code (Nick) says that he 
asked for but did not get debug feedback:

> > > And yet despite my repeated pleas, none of those people has yet 
> > > spent a bit of time with me to help analyse what is happening.

Con, the maintainer of -ck, certainly has (or had, when he maintained 
it) enough clout to coordinate such an effort between non-developer -ck 
users and the MM maintainers. Maybe he attempted to do that and has 
tried to provide debug feedback to MM maintainers?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
