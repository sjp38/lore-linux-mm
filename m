Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E947B6B0022
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 11:08:25 -0400 (EDT)
Date: Thu, 28 Apr 2011 17:08:21 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 2/3] support for broken memory modules (BadRAM)
Message-ID: <20110428150821.GT16484@one.firstfloor.org>
References: <1303921007-1769-1-git-send-email-sassmann@kpanic.de> <1303921007-1769-3-git-send-email-sassmann@kpanic.de> <20110427211258.GQ16484@one.firstfloor.org> <4DB90A66.3020805@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DB90A66.3020805@kpanic.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Assmann <sassmann@kpanic.de>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, tony.luck@intel.com, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, akpm@linux-foundation.org, lwoodman@redhat.com, riel@redhat.com

> You're right, logging every page marked would be too verbose. That's why
> I wrapped that logging into pr_debug.

pr_debug still floods the kernel log buffer. On large systems
it often already overflows.

> However I kept the printk in the case of early allocated pages. The user
> should be notified of the attempt to mark a page that's already been
> allocated by the kernel itself.

That's ok, although if you're unlucky (e.g. hit a large mem_map area)
it can be also very nosiy.

It would be better if you fixed the printks to output ranges.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
