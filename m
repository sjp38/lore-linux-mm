Message-ID: <41919EA5.7030200@yahoo.com.au>
Date: Wed, 10 Nov 2004 15:52:53 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
References: <200411081547.iA8FlH90124208@ben.americas.sgi.com>
In-Reply-To: <200411081547.iA8FlH90124208@ben.americas.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, "Martin J. Bligh" <mbligh@aracnet.com>, Christoph Lameter <clameter@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Russ Anderson wrote:
> Matthew Wilcox wrote:
> 
>>On Sun, Nov 07, 2004 at 08:11:24AM -0800, Martin J. Bligh wrote:
>>
>>>Ummm 10K cpus? I hope that's a typo for processes, or this discussion is
>>>getting rather silly ....
>>
>>NASA bought a 10k CPU system, but that's a cluster.  I think the largest
>>single system within that cluster is 256 CPUs.
> 
> 
> Each "node" is a single linux kernel with 512 processors..
> There are 20 nodes in the cluster.  20 x 512p = 10,240 processors.
> 

Sorry for wandering off topic here... did I imagine it or did I read
that you'd tried to get 2048 CPUs going in a single system at NASA?

I guess the lack of triumphant press release means it didn't go well,
or that I was imagining things.

Also, are you using 2.6 kernels on these 512 CPU systems? or are your
2.4 kernels still holding together at that many CPUs?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
