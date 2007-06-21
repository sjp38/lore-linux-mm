Message-ID: <467A7C88.2040102@csn.ul.ie>
Date: Thu, 21 Jun 2007 14:26:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] Compact memory directly by a process when a high-order
 allocation fails
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>	<20070618093042.7790.30669.sendpatchset@skynet.skynet.ie> <20070621052813.ac93e12e.akpm@linux-foundation.org>
In-Reply-To: <20070621052813.ac93e12e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>> On Mon, 18 Jun 2007 10:30:42 +0100 (IST) Mel Gorman <mel@csn.ul.ie> wrote:
>> +
>> +			/*
>> +			 * It's a race if compaction frees a suitable page but
>> +			 * someone else allocates it
>> +			 */
>> +			count_vm_event(COMPACTRACE);
>> +		}
> 
> Could perhaps cause arbitrarily long starvation. 

More likely it will just fail allocations where it could have succeeded.
I knew the situation would occur so I thought I would count how often it
happens before doing.

> A fix would be to free
> the synchronously-compacted higher-order page into somewhere which is
> private to this task (a new field in task_struct would be one such place).

There used to be such fields and a process flag PF_FREE_PAGES for a
similar purpose. I'll look into reintroducing it. Thanks

-- 
Mel Gorman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
