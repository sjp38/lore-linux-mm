Date: Sat, 11 Feb 2006 19:47:27 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Get rid of scan_control
In-Reply-To: <43EEAC93.3000803@yahoo.com.au>
Message-ID: <Pine.LNX.4.62.0602111941480.25758@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
 <20060211045355.GA3318@dmt.cnet> <20060211013255.20832152.akpm@osdl.org>
 <20060211014649.7cb3b9e2.akpm@osdl.org> <43EEAC93.3000803@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 12 Feb 2006, Nick Piggin wrote:

> I agree with Marcelo, I prefer scan_control. I'm not sure if it was
> modelled on writeback_control or not, but it is certianly very different:
> writeback_control is spread over many files and subsystems. scan_control
> is vmscan local and is simply used to alleviate the passing of many
> values back and forth between vmscan functions.

The trouble with scan_control is that it contains diverse variables. For 
example it caches nr_mapped, its used to pass results back to the caller 
etc. 

> Luckily there are very limited call stacks which modify this stuff so it isn't
> too hard to keep all in your head at once after you start doing a bit of work
> in vmscan. That said, we could implement a commenting convention to help
> things.
> 
> /*
>  * refill_inactive_list
>  * input:
>  * sc.nr_scan - specifies the number of ...
>  * sc.blah ...
>  *
>  * modifies:
>  * sc.nr_scan - blah blah
>  */

Could we at least pass the number of pages reclaimed back as the return 
value of the functions? I believe most of the savings that Andrew saw was 
due to the number of reclaimed pages being processed directly in 
registers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
