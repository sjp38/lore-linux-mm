Date: Fri, 5 Sep 2003 20:14:44 -0400 (EDT)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: 2.6.0-test4-mm6
In-Reply-To: <20030905015927.472aa760.akpm@osdl.org>
Message-ID: <Pine.LNX.4.53.0309051220290.31201@montezuma.fsmlabs.com>
References: <20030905015927.472aa760.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Sep 2003, Andrew Morton wrote:

>   We didn't get many reports from this in -mm5.  I'd prefer to stick with
>   Con's patches because they're tweaks, rather than fundamental changes and
>   they have had more testing and are more widely understood.
> 
>   But the performance regressions with specjbb and volanomark are a
>   problem.  We need to understand this and get it fixed up.

I believe Con has a lead on this already, the thing to find out is why 
sched_clock() causes such a regression.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
