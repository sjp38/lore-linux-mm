Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id B0EEE6B0036
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 15:07:54 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 13 Jun 2013 15:07:53 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2A2A5C90070
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 15:07:50 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5DJ6Sik282042
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 15:06:29 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5DJ6I5d004102
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 15:06:19 -0400
Date: Thu, 13 Jun 2013 14:06:17 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv13 0/4] zswap: compressed swap caching
Message-ID: <20130613190617.GB2967@medulla>
References: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <51B9BC5E.6060407@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51B9BC5E.6060407@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Thu, Jun 13, 2013 at 08:34:38PM +0800, Bob Liu wrote:
> Hi Seth,
> 
> On 06/04/2013 04:33 AM, Seth Jennings wrote:
> > This is the latest version of the zswap patchset for compressed swap caching.
> > This is submitted for merging into linux-next and inclusion in v3.11.
> > 
> 
> Have you noticed that pool_pages >> stored_pages, like this:
> [root@ca-dev32 zswap]# cat *
> 0
> 424057
> 99538
> 0
> 2749448
> 0
> 24
> 60018
> 16837
> [root@ca-dev32 zswap]# cat pool_pages
> 97372
> [root@ca-dev32 zswap]# cat stored_pages
> 53701
> [root@ca-dev32 zswap]#
> 
> I think it's unreasonable to use more pool pages than stored pages!

Gah, in the moving of the zbud metadata for v13, I forgot to init the new
under_reclaim field of the zbud header.  Patch going out now.

Thanks for reporting!

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
