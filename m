Subject: Re: [PATCH 1/1] Implement shared page tables
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <16640000.1125498711@[10.10.2.4]>
References: <7C49DFF721CB4E671DB260F9@[10.1.1.4]>
	 <Pine.LNX.4.61.0508311143340.15467@goblin.wat.veritas.com>
	 <1125489077.3213.12.camel@laptopd505.fenrus.org>
	 <Pine.LNX.4.61.0508311437070.16834@goblin.wat.veritas.com>
	 <16640000.1125498711@[10.10.2.4]>
Content-Type: text/plain
Date: Wed, 31 Aug 2005 16:41:57 +0200
Message-Id: <1125499318.3213.18.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Hugh Dickins <hugh@veritas.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Which is indeed a further disincentive against shared page tables.
> 
> Or shared pagetables a disincentive to randomizing the mmap space ;-)
> They're incompatible, but you could be left to choose one or the other
> via config option.
> 
> 3% on "a certain industry-standard database benchmark" (cough) is huge,
> and we expect the benefit for PPC64 will be larger as we can share the
> underlying hardware PTEs without TLB flushing as well.
> 

surely the benchmark people know that the database in question always
mmaps the shared area at the address where the first one started it?
(if not, could make it so ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
