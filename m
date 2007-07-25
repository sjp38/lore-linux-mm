Date: Wed, 25 Jul 2007 15:50:16 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
Message-ID: <20070725135016.GA18633@elte.hu>
References: <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com> <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm> <46A6DFFD.9030202@gmail.com> <30701.1185347660@turing-police.cc.vt.edu> <46A7074B.50608@gmail.com> <20070725082822.GA13098@elte.hu> <46A70D37.3060005@gmail.com> <5c77e14b0707250353r48458316x5e6adde6dbce1fbd@mail.gmail.com> <46A75062.1050809@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46A75062.1050809@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Jos Poortvliet <jos@mijnkamer.nl>, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Valdis.Kletnieks@vt.edu, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* Rene Herman <rene.herman@gmail.com> wrote:

> Nick Piggin is the person to convince it seems and if I've read things 
> right (I only stepped into this thing at the updatedb mention, so 
> maybe I haven't) his main question is _why_ the hell it helps 
> updatedb. [...]

btw., i'd like to make this clear: if you want stuff to go upstream, do 
not concentrate on 'convincing the maintainer'.

Instead concentrate on understanding the _problem_, concentrate on 
making sure that both you and the maintainer understands the problem 
correctly, possibly write some testcase that clearly exposes it, and 
help the maintainer debug the problem. _Optionally_, if you find joy in 
it, you are also free to write a proposed solution for that problem and 
submit it to the maintainer.

But a "here is a solution, take it or leave it" approach, before having 
communicated the problem to the maintainer and before having debugged 
the problem is the wrong way around. It might still work out fine if the 
solution is correct (especially if the patch is small and obvious), but 
if there are any non-trivial tradeoffs involved, or if nontrivial amount 
of code is involved, you might see your patch at the end of a really 
long (and constantly growing) waiting list of patches.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
