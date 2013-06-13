Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id D71406B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 08:36:15 -0400 (EDT)
Message-ID: <51B9BC5E.6060407@oracle.com>
Date: Thu, 13 Jun 2013 20:34:38 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCHv13 0/4] zswap: compressed swap caching
References: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Hi Seth,

On 06/04/2013 04:33 AM, Seth Jennings wrote:
> This is the latest version of the zswap patchset for compressed swap caching.
> This is submitted for merging into linux-next and inclusion in v3.11.
> 

Have you noticed that pool_pages >> stored_pages, like this:
[root@ca-dev32 zswap]# cat *
0
424057
99538
0
2749448
0
24
60018
16837
[root@ca-dev32 zswap]# cat pool_pages
97372
[root@ca-dev32 zswap]# cat stored_pages
53701
[root@ca-dev32 zswap]#

I think it's unreasonable to use more pool pages than stored pages!

Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
