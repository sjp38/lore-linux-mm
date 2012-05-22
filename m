Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id BAB326B004D
	for <linux-mm@kvack.org>; Mon, 21 May 2012 22:25:50 -0400 (EDT)
Date: Mon, 21 May 2012 19:27:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [tip:perf/uprobes] uprobes, mm, x86: Add the ability to install
 and remove uprobes breakpoints
Message-Id: <20120521192700.71bfda5f.akpm@linux-foundation.org>
In-Reply-To: <20120522111618.ca91892dc6027f9a4251235e@canb.auug.org.au>
References: <20120209092642.GE16600@linux.vnet.ibm.com>
	<tip-2b144498350860b6ee9dc57ff27a93ad488de5dc@git.kernel.org>
	<20120521143701.74ab2d0b.akpm@linux-foundation.org>
	<CA+55aFw5ccuvvtyf6iuuw-Finr79ZkPxgCxL5jNvdnX5oMYkgg@mail.gmail.com>
	<20120521151323.f23bd5e9.akpm@linux-foundation.org>
	<20120522111618.ca91892dc6027f9a4251235e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, mingo@redhat.com, a.p.zijlstra@chello.nl, peterz@infradead.org, anton@redhat.com, rostedt@goodmis.org, tglx@linutronix.de, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hpa@zytor.com, jkenisto@us.ibm.com, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, vda.linux@googlemail.com, masami.hiramatsu.pt@hitachi.com, acme@infradead.org, srikar@linux.vnet.ibm.com, roland@hack.frob.com, mingo@elte.hu, linux-tip-commits@vger.kernel.org

On Tue, 22 May 2012 11:16:18 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Andrew,
> 
> On Mon, 21 May 2012 15:13:23 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Mon, 21 May 2012 15:00:28 -0700
> > Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > 
> > > On Mon, May 21, 2012 at 2:37 PM, Andrew Morton
> > > <akpm@linux-foundation.org> wrote:
> > > >
> > > > hm, we seem to have conflicting commits between mainline and linux-next.
> > > > During the merge window. __Again. __Nobody knows why this happens.
> > > 
> > > I didn't have my trivial cleanup branches in linux-next, I'm afraid.
> > 
> > Well, it's a broader issue than that.  I often see a large number of
> > rejects when syncing mainline with linux-next during the merge window. 
> > Right now:
> 
> Some of that is because your patch series is based on the end of
> linux-next and part way through the merge window only some of that has
> been merged by Linus.  Also some of it gets rebased before Linus is asked
> to pull (a real pain) - there hasn't been much of that (yet) this merge
> window (but its early days :-().  Also, sometimes Linus' merge
> resolutions are different to mine.
> 
> I have been meaning to talk to you about basing the majority of your
> patch series on Linus' tree.  This would give it mush greater stability
> and would make the merge resolution my problem (and Linus', of course).

Confused.  None of those conflicts have anything to do with the -mm
patches: the only trees involved there are mainline and
trees-in-next-other-than-mm.

> There will be bits that may need to be based on other work in linux-next,
> but I suspect that it is not very much.

Well, there are a number of reasons why I base off linux-next.  To see
whether others have merged patches which I have merged (and, sometimes,
missed later fixes to them).  Explicit fixes against -next material. 
To get visibility into upcoming merge problems.  And so that I and
others test -next too.

Basing -mm on next is never a problem (for me).  What is a problem is
the mess which happens when people merge things into mainline which are
(I assume) either slightly different from what they merged in -next or
which never were in -next at all.

That's guessing - it's a long time since I sat down and worked out exactly
what is causing this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
