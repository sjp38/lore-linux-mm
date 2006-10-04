Message-ID: <4523887B.2070007@shadowen.org>
Date: Wed, 04 Oct 2006 11:10:03 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Get rid of zone_table V2
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com> <20060924030643.e57f700c.akpm@osdl.org> <20060927021934.9461b867.akpm@osdl.org> <451A6034.20305@shadowen.org> <Pine.LNX.4.64.0609301135430.4012@schroedinger.engr.sgi.com> <20060930130811.2a7c0009.akpm@osdl.org> <Pine.LNX.4.64.0610021008510.12554@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610021008510.12554@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sat, 30 Sep 2006, Andrew Morton wrote:
> 
>> BUILD_BUG_ON()?
> 
> Good idea. We may want to take all of these patches out if Andy can come 
> up with an easy modification to the macros that avoids ZONEID_PGSHIFT to 
> unintentionally become 0.

Sorry, been out handling a unrelated disaster at work, and then sick.

Will look at this and see what I can come up with.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
