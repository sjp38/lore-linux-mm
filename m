Date: Sun, 1 Aug 2004 17:56:18 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] token based thrashing control
Message-Id: <20040801175618.711a3aac.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0408010856240.13053@dhcp030.home.surriel.com>
References: <Pine.LNX.4.58.0407301730440.9228@dhcp030.home.surriel.com>
	<Pine.LNX.4.58.0408010856240.13053@dhcp030.home.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, sjiang@cs.wm.edu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@redhat.com> wrote:
>
> On Fri, 30 Jul 2004, Rik van Riel wrote:
> 
>  > I have run a very unscientific benchmark on my system to test
>  > the effectiveness of the patch, timing how a 230MB two-process
>  > qsbench run takes, with and without the token thrashing
>  > protection present.
>  > 
>  > normal 2.6.8-rc2:	6m45s
>  > 2.6.8-rc2 + token:	4m24s
> 
>  OK, I've now also ran day-long kernel compilate tests,
>  3 times each with make -j 10, 20, 30, 40, 50 and 60 on
>  my dual pIII w/ 384 MB and a 180 MB named in the background.
> 
>  For make -j 10 through make -j 50 the differences are in
>  the noise, basically giving the same result for each kernel.
> 
>  However, for make -j 60 there's a dramatic difference between
>  a kernel with the token based swapout and a kernel without.
> 
>  normal 2.6.8-rc2:	1h20m runtime / ~26% CPU use average
>  2.6.8-rc2 + token:	  42m runtime / ~52% CPU use average

OK.  My test is usually around 50-60% CPU occupancy so we're not gaining in
the moderate swapping range.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
