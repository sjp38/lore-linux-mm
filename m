Message-ID: <4310E4E7.1040800@argo.co.il>
Date: Sun, 28 Aug 2005 01:10:47 +0300
From: Avi Kivity <avi@argo.co.il>
MIME-Version: 1.0
Subject: Re: [RFT][PATCH 0/2] pagefault scalability alternative
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com> <Pine.LNX.4.62.0508221448480.8933@schroedinger.engr.sgi.com> <Pine.LNX.4.61.0508230822300.5224@goblin.wat.veritas.com> <Pine.LNX.4.62.0508230909120.16321@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508230909120.16321@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

>>A spinlock per page table, not a spinlock per page table entry.
>>    
>>
>
>Thats a spinlock per pmd? Calling it per page table is a bit confusing 
>since page table may refer to the whole tree. Could you develop 
>a clearer way of referring to these locks that is not page_table_lock or 
>ptl?
>  
>
I've heard the term "paging element" used to describe the p*t's.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
