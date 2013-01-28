Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id CF2346B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 17:08:24 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 28 Jan 2013 17:08:23 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 7672D38C8054
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 17:08:14 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0SM8D8d274688
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 17:08:13 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0SM8DAV015315
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 20:08:13 -0200
Message-ID: <5106F6CA.30705@linux.vnet.ibm.com>
Date: Mon, 28 Jan 2013 16:08:10 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 0/6] zswap: compressed swap caching
References: <1359409767-30092-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1359409767-30092-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/28/2013 03:49 PM, Seth Jennings wrote:
> Changelog:
> 
> v3:
> * Dropped the zsmalloc patches from the set, except the promotion patch
>   which has be converted to a rename patch (vs full diff).  The dropped
>   patches have been Acked and are going into Greg's staging tree soon.
> * Separated [PATCHv2 7/9] into two patches since it makes changes for two
>   different reasons (Minchan)
> * Moved ZSWAP_MAX_OUTSTANDING_FLUSHES near the top in zswap.c (Rik)
> * Rebase to v3.8-rc5. linux-next is a little volatile with the
>   swapper_space per type changes which will effect this patchset.

This patchset will apply but not build on v3.8-rc5 without the
zsmalloc patchset here:

https://lkml.org/lkml/2013/1/25/486

The zsmalloc patches don't apply cleanly without this patch:

https://lkml.org/lkml/2013/1/4/298

Nothing has changed functionally from v2, so it would probably be
easier to do any testing from that version.  However, if you want to
apply this latest version, those are the prerequisite patches.

Or your can pull from here:

git://github.com/spartacus06/linux.git zswap-v3

Seth





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
