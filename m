Date: Wed, 10 Mar 2004 07:21:40 -0500 (EST)
From: "Richard B. Johnson" <root@chaos.analogic.com>
Reply-To: root@chaos.analogic.com
Subject: Re: inconsistent do_gettimeofday for copy_page
In-Reply-To: <20040310111919.83754.qmail@web10901.mail.yahoo.com>
Message-ID: <Pine.LNX.4.53.0403100719360.15264@chaos>
References: <20040310111919.83754.qmail@web10901.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ashwin Rao <ashwin_s_rao@yahoo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Mar 2004, Ashwin Rao wrote:

> For calculating the time required to copy_page i tried
> the do_gettimeofday for 1000 pages in a loop. But as
> the number of pages changes the time required varies
> non-linearly.
> I also tried reading xtime and using monotonic_clock
> but they didnt help either. For do_gettimeof day for a
> single invocation of copy_page on a pentium 4 gave me
> 10 microsecs but when invoked for a 1000 pages the
> time required was 750ns per page.
> Is there some way of finding out the exact time
> required for copying a page.
>
> Ashwin
>

`rdtsc` on Intel. Gets total CPU clocks. Of course, you will
get jitter unless you disable interrupts during the procedure
you are measuring.


Cheers,
Dick Johnson
Penguin : Linux version 2.4.24 on an i686 machine (797.90 BogoMips).
            Note 96.31% of all statistics are fiction.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
