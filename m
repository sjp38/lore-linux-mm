Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 92C1F6B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 23:36:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 844253EE0C7
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 12:36:01 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3773A45DEE8
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 12:36:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F52D45DEE4
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 12:36:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FC87E08001
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 12:36:01 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD5A8E08004
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 12:36:00 +0900 (JST)
Message-ID: <4DFACB8A.2020008@jp.fujitsu.com>
Date: Fri, 17 Jun 2011 12:35:38 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/12] Per superblock cache reclaim
References: <1306998067-27659-1-git-send-email-david@fromorbit.com> <20110616113321.GA22422@infradead.org>
In-Reply-To: <20110616113321.GA22422@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hch@infradead.org
Cc: david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

(2011/06/16 20:33), Christoph Hellwig wrote:
> Can we get some comments from the MM folks for patches 1-3?  Those look
> like some pretty urgent fixes for really dumb shrinker behaviour.

Yeah, I'm reviewing today. I'm sorry delayed it. So, generically they are
pretty good to me. thanks Dave. So, I have a few minor comments and I'll post
it when my review is finished. (Maybe some hour later).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
