Date: Tue, 9 Mar 2004 21:35:18 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: blk_congestion_wait racy?
Message-Id: <20040309213518.44adb33d.akpm@osdl.org>
In-Reply-To: <404EA645.8010900@cyberone.com.au>
References: <OFAAC6B1AC.5886C5F2-ONC1256E52.0061A30B-C1256E52.0062656E@de.ibm.com>
	<404EA645.8010900@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: schwidefsky@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <piggin@cyberone.com.au> wrote:
>
> But I'm guessing that you have no requests in flight by the time
>  blk_congestion_wait gets called, so nothing ever gets kicked.

That's why blk_congestion_wait() in -mm propagates the schedule_timeout()
return value.   You can do:

	if (blk_congestion_wait(...))
		printk("ouch\n");

If your kernel says ouch much, we have a problem.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
