Message-ID: <42BE6A3E.8030703@yahoo.com.au>
Date: Sun, 26 Jun 2005 18:41:34 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch][rfc] 5/5: core remove PageReserved
References: <42BA5F37.6070405@yahoo.com.au>	<42BA5F5C.3080101@yahoo.com.au>	<42BA5F7B.30904@yahoo.com.au>	<42BA5FA8.7080905@yahoo.com.au>	<42BA5FC8.9020501@yahoo.com.au>	<42BA5FE8.2060207@yahoo.com.au>	<20050623095153.GB3334@holomorphy.com> <20050623215011.0b1e6ef2.akpm@osdl.org>
In-Reply-To: <20050623215011.0b1e6ef2.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com, pbadari@us.ibm.com, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> William Lee Irwin III <wli@holomorphy.com> wrote:

>> Mutatis mutandis for my SCSI tape drive.
> 
> 

OK, for the VM_RESERVED case, it looks like it won't be much of a problem
because get_user_pages faults on VM_IO regions (which is already set in
remap_pfn_range which is used by mem.c and most drivers). So this code will
simply not encounter VM_RESERVED regions - well obviously, get_user_pages
should be made to explicitly check for VM_RESERVED too, but the point being
that introducing such a check will not overly restrict drivers.

[snip SetPageDirty is wrong]

Not that this helps the existing bug...

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
