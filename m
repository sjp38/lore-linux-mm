Message-ID: <403FFD0F.60908@cyberone.com.au>
Date: Sat, 28 Feb 2004 13:29:35 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] VM batching patch problems?
References: <403FDEAA.1000802@cyberone.com.au> <20040227165244.25648122.akpm@osdl.org> <403FF15E.3040800@cyberone.com.au>
In-Reply-To: <403FF15E.3040800@cyberone.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Nick Piggin wrote:

>
> No it doesn't increase ZONE_NORMAL scanning. The scanning is the same 
> rate,
> but because ZONE_NORMAL is 1/4 the size, it has quadruple the 
> pressure. If
> you don't like logic, just pretend it is pinned by mem_map and other 
> things.
> Your batching patch is conceptually wrong and it adds complexity.
>

An unfortunate typo. I was supposed to say "if you don't like *that* logic",
not "if you don't like logic"...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
