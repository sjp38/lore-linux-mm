Date: Sat, 11 Feb 2006 15:29:05 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Skip reclaim_mapped determination if we do not swap
Message-Id: <20060211152905.6093258d.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.62.0602111405340.24923@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602111335560.24685@schroedinger.engr.sgi.com>
	<20060211135031.623fdef9.akpm@osdl.org>
	<Pine.LNX.4.62.0602111405340.24923@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, nickpiggin@yahoo.com.au, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> But should 
>  this piece of code really be there? Doesnt it belong ito shrink_zone() or 
>  even in try_to_free_pages() or balance_pgdat(). Shouldn't we pass 
>  reclaim_mapped as a parameter to refill_inactive_zone?

Well, it's only used in refill_inactive_zone().  Does it matter much where
it is?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
