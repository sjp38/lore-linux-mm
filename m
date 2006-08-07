Message-ID: <44D75526.4050108@yahoo.com.au>
Date: Tue, 08 Aug 2006 00:58:46 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch][rfc] possible lock_page fix for Andrea's nopage vs invalidate
 race?
References: <44CF3CB7.7030009@yahoo.com.au> <Pine.LNX.4.64.0608031526400.15351@blonde.wat.veritas.com> <44D74B98.3030305@yahoo.com.au>
In-Reply-To: <44D74B98.3030305@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Hugh Dickins wrote:

>> I suppose this is quite efficient, but I find it confusing.
>> We have lots and lots of drivers already setting vm_flags in their
>> mmap methods, now you add an alternative way of doing the same thing.
>> Can't you just set VM_NOPAGE_LOCKED in the relevant mmap methods?
>> Or did you try it that way and it worked out messy?
> 
> 
> Generic pagecache doesn't have an mmap method, which is where
> I stopped looking. I guess you could add the |= to filemap_nopage,
> but that's much uglier.
> 
> I don't find it at all confusing, just maybe a bit of a violation
> because the structure is technically only for "ops".

Hmm, I guess adding a new mmap method solely to set that flag
would actually be cleaner. And it would allow any filesystems
that override .nopage bug end up calling filemap_nopage could
equivalently override their mmap but still call filemap_mmap.

Yes that might be nicer.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
