Date: Thu, 29 May 2003 13:30:15 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.70-mm1
Message-ID: <39810000.1054240214@[10.10.2.4]>
In-Reply-To: <20030529115237.33c9c09a.akpm@digeo.com>
References: <20030527004255.5e32297b.akpm@digeo.com><1980000.1054189401@[10.10.2.4]><18080000.1054233607@[10.10.2.4]> <20030529115237.33c9c09a.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> OK, a 10x improvement isn't too bad.  I'm hoping the gap between ext2 and
> ext3 is mainly idle time and not spinning-on-locks time.
> 
> 
>> 
>>    2024927   267.3% total
>>    1677960   472.8% default_idle
>>     116350     0.0% .text.lock.transaction
>>      42783     0.0% do_get_write_access
>>      40293     0.0% journal_dirty_metadata
>>      34251  6414.0% __down
>>      27867  9166.8% .text.lock.attr
> 
> Bah.  In inode_setattr(), move the mark_inode_dirty() outside
> lock_kernel().

OK, will do. 

>>      20016  2619.9% __wake_up
>>      19632   927.4% schedule
>>      12204     0.0% .text.lock.sched
>>      12128     0.0% start_this_handle
>>      10011     0.0% journal_add_journal_head
> 
> hm, lots of context switches still.

I think that's ext3 busily kicking the living crap out of semaphores ;-)
See __down above ...

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
