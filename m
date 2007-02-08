Message-ID: <45CA8C18.9020104@yahoo.com.au>
Date: Thu, 08 Feb 2007 13:34:00 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1 of 2] Implement generic block_page_mkwrite() functionality
References: <20070207124922.GK44411608@melbourne.sgi.com> <Pine.LNX.4.64.0702071256530.25060@blonde.wat.veritas.com> <20070207144415.GN44411608@melbourne.sgi.com> <20070207155245.GB11967@think.oraclecorp.com>
In-Reply-To: <20070207155245.GB11967@think.oraclecorp.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: David Chinner <dgc@sgi.com>, Hugh Dickins <hugh@veritas.com>, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chris Mason wrote:
> On Thu, Feb 08, 2007 at 01:44:15AM +1100, David Chinner wrote:

>>So, do I need to grab the i_mutex here? Is that safe to do that in
>>the middle of a page fault? If we do race with a truncate and the
>>page is now beyond EOF, what am I supposed to return?
> 
> 
> Should it check to make sure the page is still in the address space
> after locking it?

Yes. If the page was truncated/invalidated, then you can just return
and the pagefault handler should notice that it has been removed from
the page tables.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
