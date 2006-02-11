Date: Sat, 11 Feb 2006 14:10:19 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Skip reclaim_mapped determination if we do not swap
In-Reply-To: <20060211135031.623fdef9.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0602111405340.24923@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602111335560.24685@schroedinger.engr.sgi.com>
 <20060211135031.623fdef9.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, nickpiggin@yahoo.com.au, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Sat, 11 Feb 2006, Andrew Morton wrote:

> For your enjoyment, here is a picture of what the resulting code looks like
> in an 80-col window:
> 
> 	http://www.zip.com.au/~akpm/linux/patches/stuff/x.jpeg

Ahh. Yes looks really ragged...
 
> It would make things somewhat easier if I didn't have to go fixing up after
> you all the time.

I can fix this if this is the final resting place of the code. But should 
this piece of code really be there? Doesnt it belong ito shrink_zone() or 
even in try_to_free_pages() or balance_pgdat(). Shouldn't we pass 
reclaim_mapped as a parameter to refill_inactive_zone?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
