Message-ID: <40205908.4080600@cyberone.com.au>
Date: Wed, 04 Feb 2004 13:29:28 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: More VM benchmarks
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

OK I'm not too unhappy with kbuild now. I've flattened the
curve a bit more since you last saw it. Would be nice if we
could get j8 and j10 faster but you can't win them all.

I'm not sure what happens further on - Roger indicates that
perhaps 2.4 overtakes 2.6 again at j24 although the patchset
he used (http://www.kerneltrap.org/~npiggin/vm/3/) performs
far worse than this one at j16. This is really not a big
deal IMO, but I might run it and see what happens.

The systime benchmarks are just a bit of fun. They don't
mean too much because I didn't measure how much work kswapd
is doing...

Oh, the base kernel is 2.6.2-rc3-mm1 for -np3. I'll release
the patches shortly.

Best regards,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
