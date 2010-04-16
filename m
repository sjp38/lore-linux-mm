Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DAB5D6B01EF
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 18:48:26 -0400 (EDT)
Date: Sat, 17 Apr 2010 00:48:20 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 02/10] vmscan: move priority variable into scan_control
Message-ID: <20100416224820.GE20640@cmpxchg.org>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-3-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1271352103-2280-3-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 06:21:35PM +0100, Mel Gorman wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Now very lots function in vmscan have `priority' argument. It consume
> stack slightly. To move it on struct scan_control reduce stack.

I don't like this much because it obfuscates value communication.

Functions no longer have obvious arguments and return values, as it's all
passed hidden in that struct.

Do you think it's worth it?  I would much rather see that thing die than
expand on it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
