Message-ID: <47FBB497.4050603@cs.helsinki.fi>
Date: Tue, 08 Apr 2008 21:08:23 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch] slub: change the formula which calculates min_objects
 based on number of processors
References: <20080404225019.369359572@sgi.com>	 <20080404225105.959019108@sgi.com> <1207548437.12878.48.camel@ymzhang>	 <47FA346C.4020802@cs.helsinki.fi> <1207635477.12878.74.camel@ymzhang>	 <84144f020804072337s541646d8s999be14b4c17375e@mail.gmail.com> <1207646286.12878.150.camel@ymzhang>
In-Reply-To: <1207646286.12878.150.camel@ymzhang>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Zhang, Yanmin wrote:
> Current formula to calculate min_objects based on number of processors is 
> '4 * fls(nr_cpu_ids)', which is not the best optimization on 16-core tigerton.
> If I add 4 to its result, hackbench result is better.
> 
> On 16-core tigerton, by run
> ./hackbench 100 process 2000
> results are:
> 1) 2.6.25-rc6slab: 23.5seconds
> 2) 2.6.25-rc7SLUB+slub_min_objects=20: 31seconds
> 3) 2.6.25-rc7SLUB+slub_min_objects=24: 23.5seconds
> 
> So adding 4 to the output of '4 * fls(nr_cpu_ids)' could get the similar result
> like CONFIG_SLAB=y.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
