Date: Sun, 19 Jan 2003 20:18:34 +0000
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: 2.5.59-mm2
Message-ID: <20030119201834.A3965@devserv.devel.redhat.com>
References: <3014AAAC8E0930438FD38EBF6DCEB5647D1492@fmsmsx407.fm.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3014AAAC8E0930438FD38EBF6DCEB5647D1492@fmsmsx407.fm.intel.com>; from jun.nakajima@intel.com on Sun, Jan 19, 2003 at 11:45:35AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Nakajima, Jun" <jun.nakajima@intel.com>
Cc: arjanv@redhat.com, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, "Kamble, Nitin A" <nitin.a.kamble@intel.com>, "Mallick, Asit K" <asit.k.mallick@intel.com>, "Saxena, Sunil" <sunil.saxena@intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jan 19, 2003 at 11:45:35AM -0800, Nakajima, Jun wrote:
> We initially implemented it in user level, accessing /proc/interrupts. We have two issues/concerns at that point. And we saw better results with kernel mode.

> - the data structures required, such as kstat, are already in the kernel
>   and converting the text info from /proc/interrupts was costly in
>   user mode.

costly is a relative thing. a dozen cycles perhaps; do it once per
10 seconds and it's invisbile. I agree that if you want to do it thousands
of times per second it might become a problem.But so far I don't see the
real need for that.

> - we suspect that frequent writes (asynchronous to interrupts)
>   to /proc/irq/N/smp_affinity might expose a race condition in interrupt
>   machinery. For example, we saw a hang caused by such a write.

if there's a bug there it needs fixing anyway; even inside the kernel
you'll have a similar race I suspect

> So to implement it in user level efficiently, we need API that
> - that provide binary data that can be easily processed by such a daemon,

there is rightfully a veto on such ABI and it's also not needed.
/proc/interrupts is less than 4Kb normally; it'll be in cache so parsing
it will be cheap. Sure the code I posted isn't optimal (far from it) but
that can be optimized a lot.

Greetings,
  Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
