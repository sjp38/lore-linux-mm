Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 49C6B5F0001
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 12:15:10 -0400 (EDT)
Message-ID: <49E8AB11.4000708@nortel.com>
Date: Fri, 17 Apr 2009 10:15:13 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: how to tell if arbitrary kernel memory address is backed by physical
 memory?
References: <49E750CA.4060300@nortel.com> <alpine.DEB.1.10.0904161654480.7855@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0904161654480.7855@qirst.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 16 Apr 2009, Chris Friesen wrote:

>> Is there a portable way to tell whether a particular virtual address in the
>> lowmem address range is backed by physical memory and is readable?
>>
>> For background...we have some guys working on a software memory scrubber for
>> an embedded board.  The memory controller supports ECC but doesn't support
>> scrubbing  in hardware.  What we want to do is walk all of lowmem, reading in
>> memory.  If a fault is encountered, it will be handled by other code.
> 
> Virtual address in the lowmem address range? lowmem address ranges exist
> for physical addresses.
> 
> If you walk lowmem (physical) then you will never see a missing page.

We have a mips board that appears to have holes in the lowmem mappings 
such that blindly walking all of it causes problems.  I assume the 
allocator knows about these holes and simply doesn't assign memory at 
those addresses.

We may have found a solution though...it looks like virt_addr_valid() 
returns false for the problematic addresses.  Would it be reasonable to 
call this once for each page before trying to access it?

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
