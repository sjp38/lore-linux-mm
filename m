Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 6C0F26B0033
	for <linux-mm@kvack.org>; Thu, 30 May 2013 21:48:40 -0400 (EDT)
Message-ID: <51A8015C.6020402@oracle.com>
Date: Fri, 31 May 2013 09:48:12 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCHv12 2/4] zbud: add to mm/
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com> <1369067168-12291-3-git-send-email-sjenning@linux.vnet.ibm.com> <20130528145911.bd484cbb0bb7a27c1623c520@linux-foundation.org> <20130529154500.GB428@cerebellum> <20130529113434.b2ced4cc1e66c7a0a520d908@linux-foundation.org> <20130529204236.GD428@cerebellum> <20130529134835.58dd89774f47205da4a06202@linux-foundation.org> <754ae8a0-23af-4c87-953f-d608cba84191@default> <20130529142904.ace2a29b90a9076d0ee251fd@linux-foundation.org> <20130530174344.GA15837@medulla> <20130530212017.GB15837@medulla>
In-Reply-To: <20130530212017.GB15837@medulla>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Dan Magenheimer <dan.magenheimer@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Hi Seth,

On 05/31/2013 05:20 AM, Seth Jennings wrote:
> Andrew, Mel,
> 
> This struct page stuffing is taking a lot of time to work out and _might_ be
> fraught with peril when memmap peekers are considered.
> 
> What do you think about just storing the zbud page metadata inline in the
> memory page in the first zbud page chunk?

How about making zswap based on SLAB? Create a PAGE_SIZE slab and when
zswap need to alloc_page() using kmem_cache_alloc() instead.

So that leave SLAB layer to handler the NUMA problem and do the
dynamical pool size for us.

In this way, an extra struct need to manage the zbud page metadate
instead of using struct page.
But I think it's easy and won't occupy many memory.

> 
> Mel, this kinda hurts you plans for making NCHUNKS = 2, since there would
> only be one chunk available for storage and would make zbud useless.
> 
> Just a way to sidestep this whole issue.  What do you think?
> 
> Seth
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
