Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 89BEE6B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 11:15:38 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 7 Feb 2013 09:14:47 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id D42C619D8042
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 09:14:37 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r17GEZuJ145094
	for <linux-mm@kvack.org>; Thu, 7 Feb 2013 09:14:36 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r17GGaM5022100
	for <linux-mm@kvack.org>; Thu, 7 Feb 2013 09:16:37 -0700
Message-ID: <5113D291.2020903@linux.vnet.ibm.com>
Date: Thu, 07 Feb 2013 10:13:05 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 8/9] zswap: add to mm/
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com> <1357590280-31535-9-git-send-email-sjenning@linux.vnet.ibm.com> <51030ADA.8030403@redhat.com> <510698F5.5060205@linux.vnet.ibm.com> <5107A2B8.4070505@parallels.com>
In-Reply-To: <5107A2B8.4070505@parallels.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lord Glauber Costa of Sealand <glommer@parallels.com>
Cc: Rik van Riel <riel@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/29/2013 04:21 AM, Lord Glauber Costa of Sealand wrote:
> On 01/28/2013 07:27 PM, Seth Jennings wrote:
>> Yes, I prototyped a shrinker interface for zswap, but, as we both
>> figured, it shrinks the zswap compressed pool too aggressively to the
>> point of being useless.
> Can't you advertise a smaller number of objects that you actively have?

Thanks for looking at the code!

An interesting idea.  I'm just not sure how you would manage the
underlying policy of how aggressively does zswap allow itself to be
shrunk?  The fact that zswap _only_ operates under memory pressure
makes that policy difficult, because it is under continuous shrinking
pressure, unlike other shrinkable caches in the kernel that spend most
of their time operating in unconstrained or lightly/intermittently
strained conditions.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
