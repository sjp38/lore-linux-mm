Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id AEAAB6B0012
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 18:56:04 -0500 (EST)
Date: Tue, 29 Jan 2013 08:56:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv3 2/6] zsmalloc: promote to lib/
Message-ID: <20130128235602.GE4752@blaptop>
References: <1359409767-30092-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1359409767-30092-3-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359409767-30092-3-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, Jan 28, 2013 at 03:49:23PM -0600, Seth Jennings wrote:
> This patch promotes the slab-based zsmalloc memory allocator
> from the staging tree to lib/
> 
> zswap depends on this allocator for storing compressed RAM pages
> in an efficient way under system wide memory pressure where
> high-order (greater than 0) page allocation are very likely to
> fail.
> 
> For more information on zsmalloc and its internals, read the
> documentation at the top of the zsmalloc.c file.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Acked-by: Minchan Kim <minchan@kernel.org>

At least, maintainer should notice about known bug of zsmalloc.
http://marc.info/?l=linux-mm&m=135933481517809&w=3

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
