Date: Wed, 16 Apr 2008 12:15:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 02/19] x86: Use kbuild.h
Message-Id: <20080416121550.b31f828c.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0804161044250.12019@schroedinger.engr.sgi.com>
References: <20080414221808.269371488@sgi.com>
	<20080414221844.876647987@sgi.com>
	<20080416130128.GF6304@elte.hu>
	<20080416141023.GA25280@elte.hu>
	<Pine.LNX.4.64.0804161044250.12019@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: mingo@elte.hu, apw@shadowen.org, sam@ravnborg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Apr 2008 10:44:55 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 16 Apr 2008, Ingo Molnar wrote:
> 
> > 
> > * Ingo Molnar <mingo@elte.hu> wrote:
> > 
> > > * Christoph Lameter <clameter@sgi.com> wrote:
> > > 
> > > > Drop the macro definitions in asm-offsets_*.c and use kbuild.h
> > > 
> > > thanks Christoph, applied.
> > 
> > the dependency i missed was the existence of include/linux/kbuild.h ;-) 
> > Anyway:
> > 
> > Acked-by: Ingo Molnar <mingo@elte.hu>
> 
> Yes sorry this is dependent on other patches merged by Andrew. This is the 
> classic case of arch changes that depend on core changes.

Yeah, I tricked a few people that way yesterday ;)

For this series I cc'ed 30-odd people on the core patch
(add-kbuildh-that-contains-common-definitions-for-kbuild-users.patch) and
then cc'ed them individually on the dependent patch (eg,
sparc-use-kbuildh-instead-of-defining-macros-in-asm-offsetsc.patch).  So
hopefully it was somewhat obvious what was going on.

In the case of *-use-get-put_unaligned_-helpers.patch it was more obscure
because the core patch
(kernel-add-common-infrastructure-for-unaligned-access.patch) came in a lot
earlier so nobody got to see it.  That tricked 'em.

Perhaps I should put "depends on -mm's
kernel-add-common-infrastructure-for-unaligned-access.patch" in the
changelog.  Problem is that I'd never remember to take that out before
sending the patch onwards.

I guess I could add "this depends on a patch which is only in -mm" into
that email somehow.

hm.  Oh well, it doesn't happen very often.




Related:

I'm now sitting on things like:

kernel-add-common-infrastructure-for-unaligned-access.patch
...
input-use-get_unaligned_-helpers.patch


Strictly and formally, the merge process for these is

a) I send kernel-add-common-infrastructure-for-unaligned-access.patch to
Linus.

b) He merges it

c) I send input-use-get_unaligned_-helpers.patch to Dmitry

d) He merges it

e) He sends input-use-get_unaligned_-helpers.patch to Linus

f) Linus merges it.


This is a lot of fuss and there's a non-zero chance that we'll miss the
merge window.  So I like people to send along acked-by's for this sort of
thing so I can scoot them along to Linus straight away.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
