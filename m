Date: Thu, 29 Jan 2004 19:56:02 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
Message-Id: <20040129195602.469e9586.akpm@osdl.org>
In-Reply-To: <4019D3F8.4090808@cyberone.com.au>
References: <400F630F.80205@cyberone.com.au>
	<20040121223608.1ea30097.akpm@osdl.org>
	<16399.42863.159456.646624@laputa.namesys.com>
	<40105633.4000800@cyberone.com.au>
	<16400.63379.453282.283117@laputa.namesys.com>
	<4011392D.1090600@cyberone.com.au>
	<16401.16474.881069.437933@laputa.namesys.com>
	<4011C537.8040104@cyberone.com.au>
	<16404.63446.649110.348477@laputa.namesys.com>
	<4014F915.7060300@cyberone.com.au>
	<16405.1185.973874.89638@laputa.namesys.com>
	<4019D3F8.4090808@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Nikita@Namesys.COM, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <piggin@cyberone.com.au> wrote:
>
> Hi Nikita,
> 
> Just having a look at your patch. I think maybe this array
> should be in a seperate cacheline per node?
> 
> +/* dummy pages used to scan active lists */
> +static struct page scan_pages[MAX_NUMNODES][MAX_NR_ZONES];
> +

You really want it a member of `struct zone', don't you?

That'll cause include dependency hell, so maybe a page* in struct zone.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
