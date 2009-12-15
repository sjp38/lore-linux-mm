Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3F76B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 16:47:51 -0500 (EST)
Message-ID: <4B2803D8.10704@agilent.com>
Date: Tue, 15 Dec 2009 13:47:04 -0800
From: Earl Chew <earl_chew@agilent.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
References: <1228379942.5092.14.camel@twins> <4B22DD89.2020901@agilent.com> <20091214192322.GA3245@bluebox.local> <4B27905B.4080006@agilent.com> <20091215210002.GA2432@local>
In-Reply-To: <20091215210002.GA2432@local>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Hans J. Koch" <hjk@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, gregkh@suse.de, hugh <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

Hans J. Koch wrote:
> Sorry, I think I wasn't clear enough: The current interface for static
> mappings shouldn't be changed. Dynamically added mappings need a new
> interface.

Thanks for the quick reply.

Are you ok with changes to the (internal) struct uio_device ?

This content of this structure is only known to uio.c and only its
name is exposed through the client visible uio_driver.h.

Earl



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
