Message-ID: <401EDAA5.7020802@cyberone.com.au>
Date: Tue, 03 Feb 2004 10:17:57 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: VM benchmarks
References: <401D8D64.8010605@cyberone.com.au> <20040201160818.1499be18.akpm@osdl.org> <401D95C2.3080208@cyberone.com.au> <20040202165044.GA8156@k3.hellgate.ch>
In-Reply-To: <20040202165044.GA8156@k3.hellgate.ch>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Luethi <rl@hellgate.ch>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Roger Luethi wrote:

>On Mon, 02 Feb 2004 11:11:46 +1100, Nick Piggin wrote:
>
>>efax is a compilation as well. I would be up for trying it, but it
>>
>
>The main advantage of efax over kbuild is that it is completely immune
>to unfairness. And it used to have a low variance (in 2.4). Other than
>that, access patterns are similar enough to make me suspect that gcc
>loads are all quite similar.
>
>
>>needs quite a lot of GUI dev libraries installed to compile it.
>>
>>I'll get onto it sometime I suppose, but for now I'll try to leave
>>my test box unchanged.
>>
>
>You can actually do something like which shouldn't require the
>dependencies on the test box:
>
>/usr/lib/gcc-lib/i586-pc-linux-gnu/3.2.3/cc1plus -fpreprocessed efaxi586.ii \
>-quiet -O2 -Wall -fexceptions -frtti -fsigned-char -fno-check-new -o main.s
>
>

Could you zip up the preprocessed file and send it to me if possible
please? (off list of course)

>All you need is the preprocessed code.
>
>
>I can test a couple of patches I you care, though. Which ones?
>
>

I have 3 patches here http://www.kerneltrap.org/~npiggin/vm/
that should apply in order. If you apply to the -mm tree, please
back out the rss limit patch first.

If you can test them it would be good.

I would be interested in soon looking at some of your patches in
combination with these.

Nick
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
