Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 8EEA16B0033
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 11:29:19 -0400 (EDT)
Message-ID: <51AE07CE.9040304@sr71.net>
Date: Tue, 04 Jun 2013 08:29:18 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [v5][PATCH 5/6] mm: vmscan: batch shrink_page_list() locking
 operations
References: <20130603200202.7F5FDE07@viggo.jf.intel.com> <20130603200208.6F71D31F@viggo.jf.intel.com> <20130604050103.GC14719@blaptop> <20130604060224.GE14719@blaptop>
In-Reply-To: <20130604060224.GE14719@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On 06/03/2013 11:02 PM, Minchan Kim wrote:
>> > Why do we need new lru list instead of using @free_pages?
> I got your point that @free_pages could have freed page by
> put_page_testzero of shrink_page_list and they don't have
> valid mapping so __remove_mapping_batch's mapping_release_page
> would access NULL pointer.
> 
> I think it would be better to mention it in comment. :(
> Otherwise, I suggest we can declare another new LIST_HEAD to
> accumulate pages freed by put_page_testzero in shrink_page_list
> so __remove_mapping_batch don't have to declare temporal LRU list
> and can remove unnecessary list_move operation.

If I respin them again, I'll add a comment.

I guess we could splice the whole list over at once instead of moving
the pages individually.  But, what are we trying to optimize here?
Saving a list_head worth of space on the stack?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
