Message-ID: <452DE82F.3080803@yahoo.com.au>
Date: Thu, 12 Oct 2006 17:01:03 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] EXT3: problem with page fault inside a transaction
References: <87mz82vzy1.fsf@sw.ru> <20061011234330.efae4265.akpm@osdl.org>
In-Reply-To: <20061011234330.efae4265.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Dmitriy Monakhov <dmonakhov@openvz.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, devel@openvz.org, ext2-devel@lists.sourceforge.net, Andrey Savochkin <saw@swsoft.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 12 Oct 2006 09:57:26 +0400
> Dmitriy Monakhov <dmonakhov@openvz.org> wrote:
> 
> 
>>While reading Andrew's generic_file_buffered_write patches i've remembered
>>one more EXT3 issue.journal_start() in prepare_write() causes different ranking
>>violations if copy_from_user() triggers a page fault. It could cause 
>>GFP_FS allocation, re-entering into ext3 code possibly with a different
>>superblock and journal, ranking violation of journalling serialization 
>>and mmap_sem and page lock and all other kinds of funny consequences.
> 
> 
> With the stuff Nick and I are looking at, we won't take pagefaults inside
> prepare_write()/commit_write() any more.

Yep. Because the page is locked, it is too much to deal with even
without a filesystem in the picture.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
