Message-ID: <4010CA48.3000105@cyberone.com.au>
Date: Fri, 23 Jan 2004 18:16:24 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
References: <400F630F.80205@cyberone.com.au> <20040121223608.1ea30097.akpm@osdl.org>
In-Reply-To: <20040121223608.1ea30097.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Nikita@Namesys.COM
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>
>Yes, I do think that the "LRU" is a bit of a misnomer - it's very
>approximate and only really suits simple workloads.  I suspect that once
>things get hot and heavy the "lru" is only four-deep:
>unreferenced/inactive, referenced/inactive, unreferenced/active and
>referenced/active.
>
>Can you test the patches separately, see what bits are actually helping?
>

OK, sorry for the delay.
http://www.kerneltrap.org/~npiggin/vm/namesys.png

The LRU patch is the one that does it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
