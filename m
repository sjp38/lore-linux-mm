Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id BE3076B0033
	for <linux-mm@kvack.org>; Thu, 16 May 2013 13:17:00 -0400 (EDT)
Message-ID: <51951478.5010608@redhat.com>
Date: Thu, 16 May 2013 13:16:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv11 3/4] zswap: add to mm/
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com> <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 05/13/2013 08:40 AM, Seth Jennings wrote:
> zswap is a thin compression backend for frontswap. It receives pages from
> frontswap and attempts to store them in a compressed memory pool, resulting in
> an effective partial memory reclaim and dramatically reduced swap device I/O.
>
> Additionally, in most cases, pages can be retrieved from this compressed store
> much more quickly than reading from tradition swap devices resulting in faster
> performance for many workloads.
>
> It also has support for evicting swap pages that are currently compressed in
> zswap to the swap device on an LRU(ish) basis. This functionality is very
> important and make zswap a true cache in that, once the cache is full or can't
> grow due to memory pressure, the oldest pages can be moved out of zswap to the
> swap device so newer pages can be compressed and stored in zswap.
>
> This patch adds the zswap driver to mm/
>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Acked-by: Rik van Riel <riel@redhat.com>

As an aside, I agree with Dan that CONFIG_EXPERIMENTAL might be
appropriate here, or at least some kind of warning in the documentation
stating that this is fairly new code that still needs to be shaken
out in the real world.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
