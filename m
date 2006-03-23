Date: Thu, 23 Mar 2006 15:59:39 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 00/34] mm: Page Replacement Policy Framework
In-Reply-To: <Pine.LNX.4.64.0603231243160.26286@g5.osdl.org>
Message-ID: <Pine.LNX.4.63.0603231554220.23558@cuia.boston.redhat.com>
References: <20060322223107.12658.14997.sendpatchset@twins.localnet>
 <20060322145132.0886f742.akpm@osdl.org> <20060323205324.GA11676@dmt.cnet>
 <Pine.LNX.4.64.0603231003390.26286@g5.osdl.org> <20060323223057.GA12895@dmt.cnet>
 <Pine.LNX.4.64.0603231243160.26286@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bob.picco@hp.com, iwamoto@valinux.co.jp, christoph@lameter.com, wfg@mail.ustc.edu.cn, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, 23 Mar 2006, Linus Torvalds wrote:

> > LRU's worst case scenarios were well known before I was born.
> 
> The kernel doesn't actually use LRU, so the fact that LRU isn't good seems 
> a non-argument.

Agreed.  The current algorithm in the kernel is close to 2Q, 
just without the corrections that 2Q gets from non-resident
history and the further tuning that is done by clock-pro.

> > - "Every time I wake up in the morning updatedb has thrown my applications
> >    out of memory".
> > 
> > - "Linux is awful every time I untar something larger than memory to disk".
> 
> People seem to think that the fact that there are bad behaviours means 
> that there are somehow "magic" algorithms that don't have bad behaviours.
> 
> I'd really suggest somebody show better real-life numbers with a new 
> algorithm _before_ we do anything like this.

Remember that it's not necessarily about "making a VM that
handles the common case better", but rather about "making
the VM behave well more of the time".

Furthermore, all VM benchmarks are corner cases.  After all,
most systems have enough memory most of the time, and will
not be evicting much at all.  This makes interpreting VM
benchmark results harder than the interpretation of many
other benchmarks...

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
