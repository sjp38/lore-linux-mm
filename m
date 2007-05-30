Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200705292207.58774.ak@suse.de>
References: <1180467234.5067.52.camel@localhost>
	 <200705292207.58774.ak@suse.de>
Content-Type: text/plain
Date: Wed, 30 May 2007 12:04:51 -0400
Message-Id: <1180541091.5850.16.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Michael Kerrisk <mtk-manpages@gmx.net>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-29 at 22:07 +0200, Andi Kleen wrote:
> On Tuesday 29 May 2007 21:33, Lee Schermerhorn wrote:
> > [PATCH] Document Linux Memory Policy
> >
> > I couldn't find any memory policy documentation in the Documentation
> > directory, so here is my attempt to document it.  My objectives are
> > two fold:
> 
> The theory is that the comment at the top of mempolicy.c gives an brief 
> internal oriented overview and the manpages describe the details. I must say 
> I'm not a big fan of too much redundant documentation because the likelihood 
> of bitrotting increases more with more redundancy.  We also normally don't 
> keep  syscall documentation in Documentation/*

I did see the comment in mempolicy.c.  Perhaps that is the best place to
document any design details.  But I found that, and the man pages quite
sparse in the details.  The Linux provides a lot of surprising behavior
for anyone who has used NUMA systems before.  Memory locality and the
control thereof is so important in some NUMA platforms that I think it's
important to describe exactly what the behavior is.  I tried to distill
some general concepts on which to hang the existing behavior--a mental
map, if you will.

Regarding the syscall documentation...

> 
> I see you got a few details that are right now missing in the manpages.
> How about you just add them to the mbind/set_mempolicy/etc manpages 
> (and perhaps a new numa.7)  and send a patch to the manpage
> maintainer (cc'ed)?  I believe having everything in the manpages
> is the most useful for userland programmers who hardly look
> into Documentation/* (in fact it is often not installed on systems
> without kernel source)

Yes, the man pages do need updating.  [I've seen reference in the
set_mempolicy() man page to a non-existent 'flags' argument.  I sort of
wish that it did exist.  Could have used it to set global page cache
policy someday.  That [global page cache policy] is still in your todo
list in the comment block ;-).] 

> 
> The comment in mempolicy.c could probably also be improved a bit
> for anything internal.
> 
> -Andi

<snip>

I'll address Christoph's and your other points in the context of your
response there...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
