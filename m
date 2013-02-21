Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 11A2C6B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 17:44:33 -0500 (EST)
Date: Thu, 21 Feb 2013 14:44:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv6 1/8] zsmalloc: add to mm/
Message-Id: <20130221144430.2d3d77fc.akpm@linux-foundation.org>
In-Reply-To: <51269DF1.9050107@linux.vnet.ibm.com>
References: <1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1361397888-14863-2-git-send-email-sjenning@linux.vnet.ibm.com>
	<20130221203650.GB3778@negative>
	<51269DF1.9050107@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Thu, 21 Feb 2013 16:21:37 -0600
Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:

> On 02/21/2013 02:36 PM, Cody P Schafer wrote:
> > On Wed, Feb 20, 2013 at 04:04:41PM -0600, Seth Jennings wrote:
> >> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> >> +#define MAX(a, b) ((a) >= (b) ? (a) : (b))
> >> +/* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
> >> +#define ZS_MIN_ALLOC_SIZE \
> >> +	MAX(32, (ZS_MAX_PAGES_PER_ZSPAGE << PAGE_SHIFT >> OBJ_INDEX_BITS))
> > 
> > Could you use the max(a,b) defined in include/linux/kernel.h?
> > 
> 
> Andrew Morton made the same point.  We can't use max() or max_t()
> because the value of ZS_MIN_ALLOC_SIZE is used to derive the value of
> ZS_SIZE_CLASSES which is used to size an array in struct zs_pool.
> 
> So the expression must be completely evaluated to a number by the
> precompiler.

Well yes, but the kernel doesn't need eight(!) separate
implementations of

#define MAX(a, b) ((a) > (b) ? (a) : (b))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
