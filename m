Date: Wed, 23 Oct 2002 00:56:54 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
In-Reply-To: <1035325675.16084.11.camel@rth.ninka.net>
Message-ID: <Pine.LNX.4.44.0210230055410.26602-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@rth.ninka.net>
Cc: Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 22 Oct 2002, David S. Miller wrote:

> > -	flush_tlb_page(vma, addr);
> > +	if (flush)
> > +		flush_tlb_page(vma, addr);
> 
> You're still using page level flushes, even though we agreed that a
> range flush one level up was more appropriate.

yes - i wanted to keep the ->populate() functions as simple as possible.  
I hope to get there soon.

	Ingo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
