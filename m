Message-ID: <40111079.8030801@cyberone.com.au>
Date: Fri, 23 Jan 2004 23:15:53 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
References: <400F630F.80205@cyberone.com.au>	<20040121223608.1ea30097.akpm@osdl.org>	<4010CA48.3000105@cyberone.com.au> <16400.60529.288718.648132@laputa.namesys.com>
In-Reply-To: <16400.60529.288718.648132@laputa.namesys.com>
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
> > 
> > Andrew Morton wrote:
> > 
> > >
> > >Yes, I do think that the "LRU" is a bit of a misnomer - it's very
> > >approximate and only really suits simple workloads.  I suspect that once
> > >things get hot and heavy the "lru" is only four-deep:
> > >unreferenced/inactive, referenced/inactive, unreferenced/active and
> > >referenced/active.
> > >
> > >Can you test the patches separately, see what bits are actually helping?
> > >
> > 
> > OK, sorry for the delay.
> > http://www.kerneltrap.org/~npiggin/vm/namesys.png
> > 
> > The LRU patch is the one that does it.
> > 
>
>I presume (from the picture) that dont-rotate-active-list is meant, right?
>  
>

Thats right


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
