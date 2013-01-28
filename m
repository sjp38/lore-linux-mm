Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 3AC116B0005
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:41:31 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 28 Jan 2013 12:41:29 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1FDC1C9003C
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:41:27 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0SHfQ9x314720
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:41:26 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0SHfQWt020563
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 15:41:26 -0200
Message-ID: <5106B83E.2030804@linux.vnet.ibm.com>
Date: Mon, 28 Jan 2013 11:41:18 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 6/9] zsmalloc: promote to lib/
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com> <1357590280-31535-7-git-send-email-sjenning@linux.vnet.ibm.com> <20130128040116.GF3321@blaptop> <20130128043257.GH3321@blaptop>
In-Reply-To: <20130128043257.GH3321@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/27/2013 10:32 PM, Minchan Kim wrote:
> On Mon, Jan 28, 2013 at 01:01:16PM +0900, Minchan Kim wrote:
>> On Mon, Jan 07, 2013 at 02:24:37PM -0600, Seth Jennings wrote:
>>> This patch promotes the slab-based zsmalloc memory allocator
>>> from the staging tree to lib/
>>>
>>> zswap depends on this allocator for storing compressed RAM pages
>>> in an efficient way under system wide memory pressure where
>>> high-order (greater than 0) page allocation are very likely to
>>> fail.
>>>
>>> For more information on zsmalloc and its internals, read the
>>> documentation at the top of the zsmalloc.c file.
>>>
>>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>>
>> Seth, zsmalloc has a bug[1], I sent a patch totay. If it want't known,
>> it mighte be no problem to promote but it's known bug so let's fix it
>> before promoting.
>>
>> Another question. Why do you promote zsmalloc in this patchset?
>> It might make you hard to merge even zswap into staging.
> 
> When I look at [8/9], I realized you are trying to merge this patch
> into mm/, NOT staging. I don't know history why zsmalloc/zram/zscache was
> in staging at the beginning but personally, I don't ojbect zswap into /mm
> directly because I got realized staging is very deep hole to get out,
> expecially related to mm stuff. ;-)

Correct.

As I understand the purpose of the staging tree, it is meant for
drivers whose code doesn't adhere to the kernel coding
standards/guidelines and might have questionable stability.  The point
is to have a TODO, get the code to conform to the kernel standards,
fix known instabilities, then promote into the appropriate place in
the driver tree.

However, with the work on memory compression, it's really become a
prototyping area, which I don't think Greg likes all that much.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
