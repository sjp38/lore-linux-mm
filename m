Message-ID: <4014F915.7060300@cyberone.com.au>
Date: Mon, 26 Jan 2004 22:25:09 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
References: <400F630F.80205@cyberone.com.au>	<20040121223608.1ea30097.akpm@osdl.org>	<16399.42863.159456.646624@laputa.namesys.com>	<40105633.4000800@cyberone.com.au>	<16400.63379.453282.283117@laputa.namesys.com>	<4011392D.1090600@cyberone.com.au>	<16401.16474.881069.437933@laputa.namesys.com>	<4011C537.8040104@cyberone.com.au> <16404.63446.649110.348477@laputa.namesys.com>
In-Reply-To: <16404.63446.649110.348477@laputa.namesys.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Namesys.COM>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Nikita Danilov wrote:

>Nick Piggin writes:
> > 
>
>[...]
>
> > 
> > But by clearing the referenced bit when below the reclaim_mapped
> > threshold, you're throwing this information away.
> > 
> > Say you have 16 mapped pages on the active list, 8 referenced, 8 not.
> > You do a !reclaim_mapped scan. Your 16 pages are now in the same
> > order and none are referenced. You now do a reclaim_mapped scan and
> > reclaim 8 pages. 4 of them were the referenced ones, 4 were not.
> > 
> > With my change, you would reclaim all 8 non referenced pages.
>
>Which is wrong, because none of them was referenced _recently_. These
>pages are cold, according to the VM's notion of hotness. (Long time
>probably has passed between !reclaim_mapped and reclaim_mapped scans in
>your example.)
>

Well you'd have to admit the referenced pages are hotter, but
I guess I can't argue with the numbers: it must not be very
significant.

I just wonder why your patch makes such an improvement. You're
basically putting mapped pages to one side until reclaim_mapped,
which is similar to what my patch does, right?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
