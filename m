Date: Tue, 28 Jan 2003 12:06:11 -0500 (EST)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [PATCH] page coloring for 2.5.59 kernel, version 1
In-Reply-To: <p73k7gpz0vu.fsf@oldwotan.suse.de>
Message-ID: <Pine.LNX.3.96.1030128120205.32466B-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 28 Jan 2003, Andi Kleen wrote:

> The main advantage of cache coloring normally is that benchmarks 
> should get stable results. Without it a benchmark result can vary based on 
> random memory allocation patterns.
> 
> Just having stable benchmarks may be worth it.

I have noted in ctxbench that the SMP results have a vast performance
range while the uni (and nosmp) don't. Not clear if this would improve
that, but I sure would like to try.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
