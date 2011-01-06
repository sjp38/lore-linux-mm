Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 89F6E6B0087
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 05:39:57 -0500 (EST)
Date: Thu, 6 Jan 2011 10:39:33 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: ARCH_POPULATES_NODE_MAP option not available on ARM
Message-ID: <20110106103933.GE29257@csn.ul.ie>
References: <AANLkTimVsm=tP2YB8gBGKXL0k2oCWQeP9O_QjM4Vfhpn@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <AANLkTimVsm=tP2YB8gBGKXL0k2oCWQeP9O_QjM4Vfhpn@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: naveen yadav <yad.naveen@gmail.com>
Cc: kernelnewbies@nl.linux.org, linux-arm-request@lists.arm.linux.org.uk, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 29, 2010 at 04:12:13PM +0530, naveen yadav wrote:
> Hi All,
> 
> I want to know why ARCH_POPULATES_NODE_MAP option not exists for ARM
> architecture .
> 

Because ARM does not support use arch-independent zone sizing during
memory initialisation.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
