Message-ID: <40207B67.7040407@cyberone.com.au>
Date: Wed, 04 Feb 2004 15:56:07 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: More VM benchmarks
References: <40205908.4080600@cyberone.com.au>
In-Reply-To: <40205908.4080600@cyberone.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Nick Piggin wrote:

> http://www.kerneltrap.org/~npiggin/vm/5/
>
> OK I'm not too unhappy with kbuild now. I've flattened the
> curve a bit more since you last saw it. Would be nice if we
> could get j8 and j10 faster but you can't win them all.
>
> I'm not sure what happens further on - Roger indicates that
> perhaps 2.4 overtakes 2.6 again at j24 although the patchset
> he used (http://www.kerneltrap.org/~npiggin/vm/3/) performs
> far worse than this one at j16. This is really not a big
> deal IMO, but I might run it and see what happens.
>

They're about even here at an hour apiece. Thats good,
not that I would ever try to optimise for this case...

2.6.2-rc3-mm1-np3
kbuild: make -j24 bzImage
144.45user 31.58system 1:00:08elapsed 4%CPU (0avgtext+0avgdata 
0maxresident)k
0inputs+0outputs (380524major+919600minor)pagefaults 0swaps
npiggin@ropeable:~/vm$ cat bkb-24.out

2.4.23
kbuild: make -j24 bzImage
148.41user 43.11system 1:02:41elapsed 5%CPU (0avgtext+0avgdata 
0maxresident)k
0inputs+0outputs (612476major+633988minor)pagefaults 0swaps

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
