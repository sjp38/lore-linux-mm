Subject: Re: [ck] Re: -mm merge plans for 2.6.23
From: Eric St-Laurent <ericstl34@sympatico.ca>
In-Reply-To: <1185346076.6528.12.camel@Homer.simpson.net>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <1185341449.7105.53.camel@perkele> <46A6E1A1.4010508@yahoo.com.au>
	 <b21f8390707242319gb17e4c9h274635b4c7fc1801@mail.gmail.com>
	 <1185346076.6528.12.camel@Homer.simpson.net>
Content-Type: text/plain
Date: Wed, 25 Jul 2007 03:19:44 -0400
Message-Id: <1185347984.7105.134.camel@perkele>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Matthew Hawkins <darthmdh@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Rene Herman <rene.herman@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-25-07 at 08:47 +0200, Mike Galbraith wrote:

> Heh.  Here we have a VM developer expressing his interest in the problem
> space, and you offer him a steaming jug of STFU because he doesn't say
> what you want to hear.  I wonder how many killfiles you just entered.
> 

Agreed.

(a bit OT)

People should understand that it's not (I think) about a desktop
workload vs enterprise workloads war.

I see it mostly as a progression versus regressions trade-off. And
adding potentially useless or unmaintained code is a regression from the
maintainers POV.

The best way to justify a patch and have it integrated is to have a
scientific testing method with repeatable numbers.

Con has done so for his patch, his benchmark demonstrated good
improvements.

But I feel some of his supporters have indirectly harmed his cause by
their comments.  Also, the fact that Con recently stopped maintaining
his work out of frustration also don't help having his patch merged. 

Again I'm not personally pushing this patch, I don't need it.

Con has worked for many years on two area that still cause problems for
desktop users: scheduler interactivity and pagecache trashing.  Now that
the scheduler has been fixed, let's have the VM fixed too.

Sorry for the slightly OT post, and please don't start a flame war...


- Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
