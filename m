Message-ID: <401E0177.1050007@cyberone.com.au>
Date: Mon, 02 Feb 2004 18:51:19 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: VM benchmarks
References: <401D8D64.8010605@cyberone.com.au> <20040201160818.1499be18.akpm@osdl.org> <401D95C2.3080208@cyberone.com.au> <67050000.1075703499@[10.10.2.4]>
In-Reply-To: <67050000.1075703499@[10.10.2.4]>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Martin J. Bligh wrote:

>>efax is a compilation as well. I would be up for trying it, but it
>>needs quite a lot of GUI dev libraries installed to compile it.
>>I'll get onto it sometime I suppose, but for now I'll try to leave
>>my test box unchanged.
>>
>>Unfortunately starting mozilla / kde / openoffice is another one
>>people complain about but harder to test...
>>
>
>Maybe you could just get gentoo to compile the whole distro ;-)
>
>What kind of parallelism are you putting into make?
>
>


On the graph here: http://www.kerneltrap.org/~npiggin/vm/4/
the x axis is the -j factor, and I'm compiling a 2.4.21
source with gcc 3.3 booting with mem=64M.

You can see it just starts to swap at -j6 and I'm going up
to -j16 which is then fairly heavy swapping (takes >20minutes).

Another thing that will need looking at is non swapping
pagecache performance of course.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
