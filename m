Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1PHm3KI000370
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 12:48:03 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PHmQUK085008
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 10:48:26 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PHmPcc016645
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 10:48:25 -0700
Subject: Re: Page scan keeps touching kernel text pages
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20080225150724.GF2604@shadowen.org>
References: <20080224144710.GD31293@lazybastard.org>
	 <20080225150724.GF2604@shadowen.org>
Content-Type: text/plain
Date: Mon, 25 Feb 2008 09:48:22 -0800
Message-Id: <1203961702.6662.35.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-02-25 at 15:07 +0000, Andy Whitcroft wrote:
> shrink_page_list() would be expected to be passed pages pulled from
> the active or inactive lists via isolate_lru_pages()?  I would not have
> expected to find the kernel text on the LRU and therefore not expect to
> see it passed to shrink_page_list()?

It may have been kernel text at one time, but what about __init
functions?  Don't we free that section back to the normal allocator
after init time?  Those can end up on the LRU.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
