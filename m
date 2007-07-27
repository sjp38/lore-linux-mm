Message-ID: <46A93C2B.4080902@kite.se>
Date: Fri, 27 Jul 2007 02:28:27 +0200
From: Magnus Naeslund <mag@kite.se>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org> <Pine.LNX.4.64.0707242130470.2229@asgard.lang.hm> <2c0942db0707250855v414cd72di1e859da423fa6a3a@mail.gmail.com> <200707252316.01021.a1426z@gawab.com>
In-Reply-To: <200707252316.01021.a1426z@gawab.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Boldi <a1426z@gawab.com>
Cc: Ray Lee <ray-lk@madrabbit.org>, "david@lang.hm" <david@lang.hm>, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Al Boldi wrote:
> 
> Thanks for asking.  I'm rather surprised why nobody's noticing any of this 
> slowdown.  To be fair, it's not really a regression, on the contrary, 2.4 is 
> lot worse wrt swapin and swapout, and Rik van Riel even considers a 50% 
> swapin slowdown wrt swapout something like better than expected (see thread 
> '[RFC] kswapd: Kernel Swapper performance').  He probably meant random 
> swapin, which seems to offer a 4x slowdown.
> 

Sorry for the late reply.
Well I think I reported this or another swap/tmpfs performance issue earlier ( http://marc.info/?t=116542915700004&r=1&w=2 ), we got the suggestion to increase /proc/sys/vm/page-cluster to 5, but we never came around to try it.
Maybe this was the reason for my report to be almost entirely ignored, sorry for that.

Regards,
Magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
