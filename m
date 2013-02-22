Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 077166B0006
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 12:58:11 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 22 Feb 2013 12:58:10 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id BE15AC90026
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 12:58:05 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1MHw5IV273394
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 12:58:05 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1MHw4bZ023363
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 14:58:05 -0300
Message-ID: <5127B1AA.4080904@linux.vnet.ibm.com>
Date: Fri, 22 Feb 2013 11:58:02 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv6 1/8] zsmalloc: add to mm/
References: <1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com> <1361397888-14863-2-git-send-email-sjenning@linux.vnet.ibm.com> <20130222094001.GB8077@lge.com>
In-Reply-To: <20130222094001.GB8077@lge.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/22/2013 03:40 AM, Joonsoo Kim wrote:
> On Wed, Feb 20, 2013 at 04:04:41PM -0600, Seth Jennings wrote:
>> =========
>> DO NOT MERGE, FOR REVIEW ONLY
>> This patch introduces zsmalloc as new code, however, it already
>> exists in drivers/staging.  In order to build successfully, you
>> must select EITHER to driver/staging version OR this version.
>> Once zsmalloc is reviewed in this format (and hopefully accepted),
>> I will create a new patchset that properly promotes zsmalloc from
>> staging.
>> =========
>>
>> This patchset introduces a new slab-based memory allocator,
>> zsmalloc, for storing compressed pages.  It is designed for
>> low fragmentation and high allocation success rate on
>> large object, but <= PAGE_SIZE allocations.
>>
>> zsmalloc differs from the kernel slab allocator in two primary
>> ways to achieve these design goals.
>>
>> zsmalloc never requires high order page allocations to back
>> slabs, or "size classes" in zsmalloc terms. Instead it allows
>> multiple single-order pages to be stitched together into a
>> "zspage" which backs the slab.  This allows for higher allocation
>> success rate under memory pressure.
> 
> I have one more concern. It may be possibly stale question.
> I think that zsmalloc makes system memories more fragmented.
> Pages for zsmalloc can't be moved and may be spread at random location
> because it's order is just 0, so high order allocation success rate
> will be decreased. How do you think about it?

For now, this is true.  NUMA and migration awareness, IMO, are the
highest priorities for additional development on zsmalloc (after merging).

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
