Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 223F48D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 01:46:35 -0500 (EST)
Date: Thu, 10 Mar 2011 07:46:14 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH/v2] mm/memblock: Properly handle overlaps and fix error
 path
Message-ID: <20110310064614.GE9289@elte.hu>
References: <1299466980.8833.973.camel@pasglop>
 <4D77E5E0.6010706@kernel.org>
 <1299705610.22236.390.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299705610.22236.390.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Yinghai Lu <yinghai@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>


* Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Wed, 2011-03-09 at 12:41 -0800, Yinghai Lu wrote:
> > > Hopefully not damaged with a spurious bit of email header this
> > > time around... sorry about that.
> > 
> > works on my setups...
> > 
> > [    0.000000] Subtract (26 early reservations)
> > [    0.000000]   [000009a000-000009efff]
> > [    0.000000]   [000009f400-00000fffff]
> > [    0.000000]   [0001000000-0003495048]
> > ...
> > before:
> > [    0.000000] Subtract (27 early reservations)
> > [    0.000000]   [000009a000-000009efff]
> > [    0.000000]   [000009f400-00000fffff]
> > [    0.000000]   [00000f85b0-00000f86b3]
> > [    0.000000]   [0001000000-0003495048] 
> 
> Ah interesting, so you did have a case of overlap that wasn't properly
> handled as well.
> 
> If there is no objection, I'll queue that up in powerpc-next for the
> upcoming merge window (soon now).

I think it would be better to do it via -mm, as x86 and other architectures are now 
affected by memblock changes as well.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
