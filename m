Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id C8E906B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 17:39:56 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 21 Feb 2013 17:39:55 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 16C4B38C86B4
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 17:21:54 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1LMLrGv349498
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 17:21:53 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1LMLgil024663
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 15:21:43 -0700
Message-ID: <51269DF1.9050107@linux.vnet.ibm.com>
Date: Thu, 21 Feb 2013 16:21:37 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv6 1/8] zsmalloc: add to mm/
References: <1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com> <1361397888-14863-2-git-send-email-sjenning@linux.vnet.ibm.com> <20130221203650.GB3778@negative>
In-Reply-To: <20130221203650.GB3778@negative>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/21/2013 02:36 PM, Cody P Schafer wrote:
> On Wed, Feb 20, 2013 at 04:04:41PM -0600, Seth Jennings wrote:
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> +#define MAX(a, b) ((a) >= (b) ? (a) : (b))
>> +/* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
>> +#define ZS_MIN_ALLOC_SIZE \
>> +	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
> 
> Could you use the max(a,b) defined in include/linux/kernel.h?
> 

Andrew Morton made the same point.  We can't use max() or max_t()
because the value of ZS_MIN_ALLOC_SIZE is used to derive the value of
ZS_SIZE_CLASSES which is used to size an array in struct zs_pool.

So the expression must be completely evaluated to a number by the
precompiler.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
