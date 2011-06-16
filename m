Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 994A36B0082
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 03:03:38 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous
 =?iso-8859-1?q?Memory=09Allocator?= added
Date: Thu, 16 Jun 2011 09:03:12 +0200
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com> <201106150937.18524.arnd@arndb.de> <4DF952CC.4010301@balister.org>
In-Reply-To: <4DF952CC.4010301@balister.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201106160903.13135.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philip Balister <philip@balister.org>
Cc: linux-arm-kernel@lists.infradead.org, 'Daniel Walker' <dwalker@codeaurora.org>, linux-mm@kvack.org, 'Mel Gorman' <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-media@vger.kernel.org, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>

On Thursday 16 June 2011 02:48:12 Philip Balister wrote:
> On 06/15/2011 12:37 AM, Arnd Bergmann wrote:
> > On Wednesday 15 June 2011 09:11:39 Marek Szyprowski wrote:
> >> I see your concerns, but I really wonder how to determine the properties
> >> of the global/default cma pool. You definitely don't want to give all
> >> available memory o CMA, because it will have negative impact on kernel
> >> operation (kernel really needs to allocate unmovable pages from time to
> >> time).
> >
> > Exactly. This is a hard problem, so I would prefer to see a solution for
> > coming up with reasonable defaults.
> 
> Is this a situation where passing the information from device tree might 
> help? I know this does not help short term, but I am trying to 
> understand the sorts of problems device tree can help solve.

The device tree is a good place to describe any hardware properties such
as 'this device will need 32 MB of contiguous allocations on the memory
bank described in that other device node'.

It is however not a good place to describe user settings such as 'I want
to give this device a 200 MB pool for large allocations so I can run
application X efficiently', because that would require knowledge in the
boot loader about local policy, which it should generally not care about.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
