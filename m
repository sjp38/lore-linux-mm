Date: Sat, 11 Feb 2006 13:50:31 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Skip reclaim_mapped determination if we do not swap
Message-Id: <20060211135031.623fdef9.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.62.0602111335560.24685@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602111335560.24685@schroedinger.engr.sgi.com>
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
> This puts the variables and the way to get to reclaim_mapped in one 
> block. And allows zone_reclaim or other things to skip the determination 
> (maybe this whole block of code does not belong into 
> refill_inactive_zone()?)

For your enjoyment, here is a picture of what the resulting code looks like
in an 80-col window:

	http://www.zip.com.au/~akpm/linux/patches/stuff/x.jpeg

It would make things somewhat easier if I didn't have to go fixing up after
you all the time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
