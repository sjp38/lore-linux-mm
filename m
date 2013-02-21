Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 157D26B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 17:23:28 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 21 Feb 2013 17:23:26 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id ACBD038C9914
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 17:11:30 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1LMBT3o275696
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 17:11:29 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1LMBTvs014658
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 19:11:29 -0300
Date: Thu, 21 Feb 2013 12:36:50 -0800
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: Re: [PATCHv6 1/8] zsmalloc: add to mm/
Message-ID: <20130221203650.GB3778@negative>
References: <1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1361397888-14863-2-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1361397888-14863-2-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, Feb 20, 2013 at 04:04:41PM -0600, Seth Jennings wrote:
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> +#define MAX(a, b) ((a) >= (b) ? (a) : (b))
> +/* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
> +#define ZS_MIN_ALLOC_SIZE \
> +	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))

Could you use the max(a,b) defined in include/linux/kernel.h?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
