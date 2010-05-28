Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3BB266B01C1
	for <linux-mm@kvack.org>; Thu, 27 May 2010 22:51:32 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4S2pTWX014574
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 28 May 2010 11:51:29 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D5AB045DE54
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:51:28 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A0CF945DE50
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:51:28 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 72F6CE08002
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:51:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 079AFE0800A
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:51:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 07/10] vmscan: Remove unnecessary temporary variables in shrink_zone()
In-Reply-To: <20100526112143.GM29038@csn.ul.ie>
References: <20100416230332.GH20640@cmpxchg.org> <20100526112143.GM29038@csn.ul.ie>
Message-Id: <20100528114003.7E1B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 28 May 2010 11:51:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

> On Sat, Apr 17, 2010 at 01:03:32AM +0200, Johannes Weiner wrote:
> > On Fri, Apr 16, 2010 at 11:51:26AM +0900, KOSAKI Motohiro wrote:
> > > > Two variables are declared that are unnecessary in shrink_zone() as they
> > > > already exist int the scan_control. Remove them
> > > > 
> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > 
> > > ok.
> > > 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > 
> > You confuse me, you added the local variables yourself in 01dbe5c9
> > for performance reasons.  Doesn't that still hold?
> 
> To avoid a potential regression, I've dropped the patch.

I'm ok either.

Commit 01dbe5c9 issue was only observed on ia64. so it's not important.
But at making 01dbe5c9 time, I didn't realized this stack overflow issue.
So, I thought "Oh, It's no risk. should go!".

but if stack reducing is important, I'm ok to drop this one.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
