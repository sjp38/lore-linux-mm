Message-ID: <44D7E641.6090306@yahoo.com.au>
Date: Tue, 08 Aug 2006 11:17:53 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch][rfc] possible lock_page fix for Andrea's nopage vs invalidate
 race?
References: <44CF3CB7.7030009@yahoo.com.au> <Pine.LNX.4.64.0608031526400.15351@blonde.wat.veritas.com> <44D74B98.3030305@yahoo.com.au> <44D75526.4050108@yahoo.com.au> <Pine.LNX.4.64.0608071620001.13736@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0608071620001.13736@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 8 Aug 2006, Nick Piggin wrote:
> 
>>Nick Piggin wrote:
>>
>>>Generic pagecache doesn't have an mmap method, which is where
>>>I stopped looking. I guess you could add the |= to filemap_nopage,
>>>but that's much uglier.
> 
> 
> You can't |= vm_flags in nopage, mmap_sem isn't exclusive there.

Well you *could*. So long as nobody else modifies vm_flags under
a read lock ;)

> But what's the matter with generic_file_mmap?

Umm... I don't know. Maybe my eyes?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
