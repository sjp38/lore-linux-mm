Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 1B6C86B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 11:30:53 -0400 (EDT)
Message-ID: <5194FB9A.6000300@redhat.com>
Date: Thu, 16 May 2013 11:30:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv11 2/4] zbud: add to mm/
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com> <1368448803-2089-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1368448803-2089-3-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 05/13/2013 08:40 AM, Seth Jennings wrote:
> zbud is an special purpose allocator for storing compressed pages. It is
> designed to store up to two compressed pages per physical page.  While this
> design limits storage density, it has simple and deterministic reclaim
> properties that make it preferable to a higher density approach when reclaim
> will be used.
>
> zbud works by storing compressed pages, or "zpages", together in pairs in a
> single memory page called a "zbud page".  The first buddy is "left
> justifed" at the beginning of the zbud page, and the last buddy is "right
> justified" at the end of the zbud page.  The benefit is that if either
> buddy is freed, the freed buddy space, coalesced with whatever slack space
> that existed between the buddies, results in the largest possible free region
> within the zbud page.
>
> zbud also provides an attractive lower bound on density. The ratio of zpages
> to zbud pages can not be less than 1.  This ensures that zbud can never "do
> harm" by using more pages to store zpages than the uncompressed zpages would
> have used on their own.
>
> This patch adds zbud to mm/ for later use by zswap.
>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
