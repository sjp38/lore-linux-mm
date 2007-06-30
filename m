Message-ID: <46863A23.2010001@garzik.org>
Date: Sat, 30 Jun 2007 07:10:27 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [RFC] fsblock
References: <20070624014528.GA17609@wotan.suse.de> <467DE00A.9080700@garzik.org> <20070630104244.GC24123@infradead.org>
In-Reply-To: <20070630104244.GC24123@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Sat, Jun 23, 2007 at 11:07:54PM -0400, Jeff Garzik wrote:
>>> - In line with the above item, filesystem block allocation is performed
>>>  before a page is dirtied. In the buffer layer, mmap writes can dirty a
>>>  page with no backing blocks which is a problem if the filesystem is
>>>  ENOSPC (patches exist for buffer.c for this).
>> This raises an eyebrow...  The handling of ENOSPC prior to mmap write is 
>> more an ABI behavior, so I don't see how this can be fixed with internal 
>> changes, yet without changing behavior currently exported to userland 
>> (and thus affecting code based on such assumptions).

> Not really, the current behaviour is a bug.  And it's not actually buffer
> layer specific - XFS now has a fix for that bug and it's generic enough
> that everyone could use it.

I'm not sure I follow.  If you require block allocation at mmap(2) time, 
rather than when a page is actually dirtied, you are denying userspace 
the ability to do sparse files with mmap.

A quick Google readily turns up people who have built upon the 
mmap-sparse-file assumption, and I don't think we want to break those 
assumptions as a "bug fix."

Where is the bug?

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
