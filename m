Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id DAD196B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 19:29:28 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1377985ghr.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 16:29:28 -0700 (PDT)
Date: Wed, 15 Aug 2012 08:29:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/4] promote zcache from staging
Message-ID: <20120814232917.GA2399@barrios>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <502ACED1.9060808@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502ACED1.9060808@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Hi Seth,

On Tue, Aug 14, 2012 at 05:18:57PM -0500, Seth Jennings wrote:
> On 07/27/2012 01:18 PM, Seth Jennings wrote:
> > zcache is the remaining piece of code required to support in-kernel
> > memory compression.  The other two features, cleancache and frontswap,
> > have been promoted to mainline in 3.0 and 3.5.  This patchset
> > promotes zcache from the staging tree to mainline.
> > 
> > Based on the level of activity and contributions we're seeing from a
> > diverse set of people and interests, I think zcache has matured to the
> > point where it makes sense to promote this out of staging.
> 
> I am wondering if there is any more discussion to be had on
> the topic of promoting zcache.  The discussion got dominated
> by performance concerns, but hopefully my latest performance
> metrics have alleviated those concerns for most and shown
> the continuing value of zcache in both I/O and runtime savings.
> 
> I'm not saying that zcache development is complete by any
> means. There are still many improvements that can be made.
> I'm just saying that I believe it is stable and beneficial
> enough to leave the staging tree.
> 
> Seth

I want to do some clean up on zcache but I'm okay after it is promoted
if Andrew merge it. But I'm not sure he doesn't mind it due to not good code
quality which includes not enough comment, not good variable/function name,
many code duplication of ramster).
Anyway, I think  we should unify common code between zcache and ramster
before promoting at least. Otherwise, it would make code refactoring hard
because we always have to touch both side for just a clean up. It means
zcache contributor for the clean up should know well ramster too and it's
not desirable.


> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
