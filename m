Message-ID: <401B02A9.90506@cyberone.com.au>
Date: Sat, 31 Jan 2004 12:19:37 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [BENCHMARKS] 2.6 kbuild results (with add_to_swap patch)
References: <Pine.LNX.4.44.0401300704130.20553-100000@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0401300704130.20553-100000@chimarrao.boston.redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, Nikita Danilov <Nikita@Namesys.COM>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Rik van Riel wrote:

>On Fri, 30 Jan 2004, Nick Piggin wrote:
>
>
>>Small big significantly better on kbuild when tested on top of the other
>>two patches (dont-rotate-active-list and my mapped-fair).
>>
>
>Where can I grab those ?
>
>

I've put the all here for now.
They are against the latest mm with the RSS patch backed out.

http://kerneltrap.org/~npiggin/vm/

>>With this patch as well, we are now as good or better than 2.4 on
>>medium and heavy swapping kbuilds and much better than stock 2.6
>>with light swapping loads (not as good as 2.4 but close).
>>
>>http://www.kerneltrap.org/~npiggin/vm/3/
>>
>
>Neat!  Does it have any side effects to interactive
>desktop behaviour ?
>
>

To be honest I haven't tried them on my desktop. I would guess
they should be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
