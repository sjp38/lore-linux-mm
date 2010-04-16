Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B7C176B01F0
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 18:38:07 -0400 (EDT)
Date: Sat, 17 Apr 2010 00:37:58 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 01/10] vmscan: kill prev_priority completely
Message-ID: <20100416223758.GD20640@cmpxchg.org>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1271352103-2280-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 06:21:34PM +0100, Mel Gorman wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Since 2.6.28 zone->prev_priority is unused. Then it can be removed
> safely. It reduce stack usage slightly.
> 
> Now I have to say that I'm sorry. 2 years ago, I thghout prev_priority
> can be integrate again, it's useful. but four (or more) times trying
> haven't got good performance number. thus I give up such approach.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
