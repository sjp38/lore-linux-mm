Message-ID: <463B004D.6060402@yahoo.com.au>
Date: Fri, 04 May 2007 19:43:41 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <4636FDD7.9080401@yahoo.com.au> <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com> <4638009E.3070408@yahoo.com.au> <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com> <46393BA7.6030106@yahoo.com.au> <20070503103756.GA19958@infradead.org> <4639DBEC.2020401@yahoo.com.au> <463AFB8C.2000909@yahoo.com.au>
In-Reply-To: <463AFB8C.2000909@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Nick Piggin wrote:
> 
>> Christoph Hellwig wrote:
> 
> 
>>> Is that every fork/exec or just under certain cicumstances?
>>> A 5% regression on every fork/exec is not acceptable.
>>
>>
>>
>> Well after patch2, G5 fork is 3% and exec is 1%, I'd say the P4
>> numbers will be improved as well with that patch. Then if we have
>> specific lock/unlock bitops, I hope it should reduce that further.
> 
> 
> OK, with the races and missing barriers fixed from the previous patch,
> plus the attached one added (+patch3), numbers are better again (I'm not
> sure if I have the ppc barriers correct though).
> 
> These ops could also be put to use in bit spinlocks, buffer lock, and
> probably a few other places too.
> 
> 2.6.21   1.49-1.51   164.6-170.8   741.8-760.3
> +patch   1.71-1.73   175.2-180.8   780.5-794.2
> +patch2  1.61-1.63   169.8-175.0   748.6-757.0
> +patch3  1.54-1.57   165.6-170.9   748.5-757.5
> 
> So fault performance goes to under 5%, fork is in the noise, exec is
> still up 1%, but maybe that's noise or cache effects again.

OK, with my new lock/unlock_page, dd if=large (bigger than RAM) sparse
file of=/dev/null with an experimentally optimal block size (32K) goes
from 626MB/s to 683MB/s on 2 CPU G5 booted with maxcpus=1.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
