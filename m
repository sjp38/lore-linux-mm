Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 413E28D0039
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 22:01:45 -0500 (EST)
Subject: Re: [PATCH] mm/memblock: Properly handle overlaps and fix error
 path
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <4D741890.7000607@kernel.org>
References: <1299453678.8833.969.camel@pasglop>
	 <4D741890.7000607@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Mar 2011 14:01:13 +1100
Message-ID: <1299466873.8833.971.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, David Miller <davem@davemloft.net>

On Sun, 2011-03-06 at 15:28 -0800, Yinghai Lu wrote:
> > From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > Date: Mon, 7 Mar 2011 10:18:38 +1100
> > Subject: 
> 
> you put two patches in one mail?

Odd... must have inadvertently poked the middle button, let me resend.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
