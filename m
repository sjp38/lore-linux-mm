Date: Mon, 16 May 2005 13:51:36 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [PATCH] Factor in buddy allocator alignment requirements in node memory alignment
Message-ID: <731890000.1116276696@flay>
In-Reply-To: <Pine.LNX.4.62.0505161240240.13692@ScMPusgw>
References: <Pine.LNX.4.62.0505161204540.4977@ScMPusgw> <1116274451.1005.106.camel@localhost> <Pine.LNX.4.62.0505161240240.13692@ScMPusgw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: christoph <christoph@scalex86.org>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm <linux-mm@kvack.org>, shai@scalex86.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


--On Monday, May 16, 2005 12:43:17 -0700 christoph <christoph@scalex86.org> wrote:

> On Mon, 16 May 2005, Dave Hansen wrote:
> 
>> On Mon, 2005-05-16 at 12:05 -0700, christoph wrote:
>> > Memory for nodes on i386 is currently aligned on 2 MB boundaries.
>> > However, the buddy allocator needs pages to be aligned on
>> > PAGE_SIZE << MAX_ORDER which is 8MB if MAX_ORDER = 11.
>> 
>> Why do you need this?  Are you planning on allowing NUMA KVA remap pages
>> to be handed over to the buddy allocator?  That would be a major
>> departure from what we do now, and I'd be very interested in seeing how
>> that is implemented before a infrastructure for it goes in.
> 
> Because the buddy allocator is complaining about wrongly allocated zones!
> 
> in page_alloc.c:
> 
> static void __init free_area_init_core(struct pglist_data *pgdat,
>                 unsigned long *zones_size, unsigned long *zholes_size)
> {
> ...
> 
>   const unsigned long zone_required_alignment = 1UL << (MAX_ORDER-1);
> 
> ...
> 
>              if ((zone_start_pfn) & (zone_required_alignment-1))
>                         printk(KERN_CRIT "BUG: wrong zone alignment, it will crash\n");

IIRC, we decided that warning was worthless ... and I *think* Andy fixed
it to do non-aligned zones, though it might have been someone else. Andy,
can you remember what you did to fix this up? 

M.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
