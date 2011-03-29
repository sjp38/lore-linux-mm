Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E69EE8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 22:55:14 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1CB793EE0B5
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:55:05 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 031B345DE96
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:55:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E12C245DE95
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:55:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D5892E18001
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:55:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A240AE08001
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:55:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Very aggressive memory reclaim
In-Reply-To: <BANLkTimHPFMUOCFAruF5J4OMHSkZsMsAgA@mail.gmail.com>
References: <20110328215344.GC3008@dastard> <BANLkTimHPFMUOCFAruF5J4OMHSkZsMsAgA@mail.gmail.com>
Message-Id: <20110329115546.C08C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 29 Mar 2011 11:55:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Chinner <david@fromorbit.com>, John Lepikhin <johnlepikhin@gmail.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org

> Recently, We had a similar issue.
> http://www.spinics.net/lists/linux-mm/msg12243.html
> But it seems to not merge. I don't know why since I didn't follow up the thread.
> Maybe Cced guys can help you.
> 
> Is it a sudden big cache drop at the moment or accumulated small cache
> drop for long time?
> What's your zones' size?
> 
> Please attach the result of cat /proc/zoneinfo for others.

If my remember is correct, 2.6.38 is included Mel's anti agressive 
reclaim patch. And original report seems to be using 2.6.37.x. 

John, can you try 2.6.38?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
