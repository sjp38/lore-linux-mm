Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 5E09D6B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 18:19:06 -0400 (EDT)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 14 Aug 2012 18:19:05 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E27E66E8039
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 18:18:59 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7EMIw9O082500
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 18:18:58 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7EMIwYi028761
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 18:18:58 -0400
Message-ID: <502ACED1.9060808@linux.vnet.ibm.com>
Date: Tue, 14 Aug 2012 17:18:57 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 07/27/2012 01:18 PM, Seth Jennings wrote:
> zcache is the remaining piece of code required to support in-kernel
> memory compression.  The other two features, cleancache and frontswap,
> have been promoted to mainline in 3.0 and 3.5.  This patchset
> promotes zcache from the staging tree to mainline.
> 
> Based on the level of activity and contributions we're seeing from a
> diverse set of people and interests, I think zcache has matured to the
> point where it makes sense to promote this out of staging.

I am wondering if there is any more discussion to be had on
the topic of promoting zcache.  The discussion got dominated
by performance concerns, but hopefully my latest performance
metrics have alleviated those concerns for most and shown
the continuing value of zcache in both I/O and runtime savings.

I'm not saying that zcache development is complete by any
means. There are still many improvements that can be made.
I'm just saying that I believe it is stable and beneficial
enough to leave the staging tree.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
