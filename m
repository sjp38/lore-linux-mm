Message-ID: <400CDAC9.40107@cyberone.com.au>
Date: Tue, 20 Jan 2004 18:37:45 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: Memory management in 2.6
References: <400CB3BD.4020601@cyberone.com.au> <1074582020.2246.1.camel@laptop-linux> <200401201519.54619.mhf@linuxmail.org>
In-Reply-To: <200401201519.54619.mhf@linuxmail.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Frank <mhf@linuxmail.org>
Cc: ncunningham@users.sourceforge.net, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


Michael Frank wrote:

>I had already sent a version (ti-tests) dedicated to stress testing to LKML in October.
>
>Just in case I enclose those again. README inside.
>
>I ran 2.6 again for the first time since -test9 yesterday to test
>swsusp and immeadiatly went to elevator=deadline as aio is unusable
>at high io loads which I need to break swsusp in.
>
>If you do on a 2GHz+ machine: 
>
>$ti stat ub17 ddw 4 5000
>
>This gives a load avg of ~40 on a 2.4G P4 with 533MHz FSB
>
>2.4.23 behaves "proportionate" to load - at these loads mouse is jerky but has best throughput.
>
>2.6 with deadline is similar but a bit slower and the mouse is very smooth.
>
>2.6 with aio the mouse is smooth but no io throughput and io is highly intermittent. AFAICS similar to -test9.
>
>It must be recognized that these tests act in a non-anticipatory manner - this is what they are designed for ;)
>

Hmm... thats a bit alarming. I'll have to take a look at why that is so, 
thanks.
(2.6 -bk and -mm kernels have some as-iosched changes by the way)

I'll also see if they might be useful as an mm regression test.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
