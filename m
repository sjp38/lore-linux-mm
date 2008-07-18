Received: by ti-out-0910.google.com with SMTP id j3so363980tid.8
        for <linux-mm@kvack.org>; Fri, 18 Jul 2008 12:42:27 -0700 (PDT)
Date: Fri, 18 Jul 2008 22:40:59 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 1/4] kmemtrace: Core implementation.
Message-ID: <20080718194059.GA5238@localhost>
References: <cover.1216255034.git.eduard.munteanu@linux360.ro> <4472a3f883b0d9026bb2d8c490233b3eadf9b55e.1216255035.git.eduard.munteanu@linux360.ro> <84144f020807170101x25c9be11qd6e1996460bb24fc@mail.gmail.com> <20080717183206.GC5360@localhost> <Pine.LNX.4.64.0807181140400.3739@sbz-30.cs.Helsinki.FI> <20080718101326.GB5193@localhost> <84144f020807180738m768a3ebana5ebc10999f22f50@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020807180738m768a3ebana5ebc10999f22f50@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 18, 2008 at 05:38:04PM +0300, Pekka Enberg wrote:
> Hi Eduard-Gabriel,
> > I do expect to keep things source-compatible, but even
> > binary-compatible? Developers debug and write patches on the latest kernel,
> > not on a 6-month-old kernel. Isn't it reasonable that they would
> > recompile kmemtrace along with the kernel?
> 
> Yes, I do think it's unreasonable. I, for one, am hoping distributions
> will pick up the kmemtrace userspace at some point after which I don't
> need to ever compile it myself.

Ok, I agree it's nice to have it in distros. I wasn't planning for this,
but it's good to know others' expectations.

Then I'll also add a turn-off mechanism, so maybe it makes it into distro
kernels too (either debug or not). And we don't need to include kernel
headers from userspace anymore and I'll just provide a copy.

BTW, I also expect the kmemtrace-user git repo to become stable soon
(i.e. no more revision history rewrites).

> On Fri, Jul 18, 2008 at 1:13 PM, Eduard - Gabriel Munteanu
> <eduard.munteanu@linux360.ro> wrote:
> > I would deem one ABI or another stable, but then we have to worry about
> > not breaking it, which leads to either bloating the kernel, or keeping
> > improvements away from kmemtrace. Should we do it just because this is an ABI?
> 
> Like I've said before, it's debugging/tracing infrastructure so the
> rules are bit more relaxed. That said, what we should do is (1) make
> the ABI as future-proof as we can, (2) explicitly mark it as unstable
> by documenting it in Documentation/ABI/testing and (3) at some point
> in time move it in Documentation/ABI/stable and hopefully never break
> it again. But sure, we probably don't need to keep any "bloat" around
> like we do with the syscall interface, for example.
> 
> And hopefully, the ABI is good enough to allow adding *new* tracing
> events while retaining the old ones nicely in a backwards compatible
> way.

Sounds like a good plan. I'll also update the docs (Documentation/ABI/ and
Documentation/vm/kmemtrace.txt) to reflect this.

> On Fri, Jul 18, 2008 at 11:48:03AM +0300, Pekka J Enberg wrote:
> >> I really wish we would follow the example set by blktrace here. It uses a
> >> fixed-length header that knows the length of the rest of the packet.
> 
> On Fri, Jul 18, 2008 at 1:13 PM, Eduard - Gabriel Munteanu
> <eduard.munteanu@linux360.ro> wrote:
> > I'd rather export the header length through a separate debugfs entry,
> > rather than add this to every packet. I don't think we need variable
> > length packets, unless we intend to export the whole stack trace, for
> > example.
> 
> Sure, makes sense.
>                                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
