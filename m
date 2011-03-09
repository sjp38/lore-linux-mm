Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E06888D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:20:35 -0500 (EST)
Subject: Re: [PATCH/v2] mm/memblock: Properly handle overlaps and fix error
 path
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <4D77E5E0.6010706@kernel.org>
References: <1299466980.8833.973.camel@pasglop>
	 <4D77E5E0.6010706@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Mar 2011 08:20:10 +1100
Message-ID: <1299705610.22236.390.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, David Miller <davem@davemloft.net>

On Wed, 2011-03-09 at 12:41 -0800, Yinghai Lu wrote:
> > Hopefully not damaged with a spurious bit of email header this
> > time around... sorry about that.
> 
> works on my setups...
> 
> [    0.000000] Subtract (26 early reservations)
> [    0.000000]   [000009a000-000009efff]
> [    0.000000]   [000009f400-00000fffff]
> [    0.000000]   [0001000000-0003495048]
> ...
> before:
> [    0.000000] Subtract (27 early reservations)
> [    0.000000]   [000009a000-000009efff]
> [    0.000000]   [000009f400-00000fffff]
> [    0.000000]   [00000f85b0-00000f86b3]
> [    0.000000]   [0001000000-0003495048] 

Ah interesting, so you did have a case of overlap that wasn't properly
handled as well.

If there is no objection, I'll queue that up in powerpc-next for the
upcoming merge window (soon now).

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
