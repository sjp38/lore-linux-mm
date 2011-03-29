Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB788D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 03:33:35 -0400 (EDT)
Received: by wyf19 with SMTP id 19so4529616wyf.14
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 00:33:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329115546.C08C.A69D9226@jp.fujitsu.com>
References: <20110328215344.GC3008@dastard>
	<BANLkTimHPFMUOCFAruF5J4OMHSkZsMsAgA@mail.gmail.com>
	<20110329115546.C08C.A69D9226@jp.fujitsu.com>
Date: Tue, 29 Mar 2011 11:33:32 +0400
Message-ID: <AANLkTinvo6tZo8GtWohHpu5a0=EQvGz85zU55X5RTUxQ@mail.gmail.com>
Subject: Re: Very aggressive memory reclaim
From: John Lepikhin <johnlepikhin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org

2011/3/29 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:

> If my remember is correct, 2.6.38 is included Mel's anti agressive
> reclaim patch. And original report seems to be using 2.6.37.x.
>
> John, can you try 2.6.38?

I'll ask my boss about it. Unfortunately we found opposite issue with
memory management + XFS (100M of inodes) on 2.6.38: some objects in
xfs_inode and dentry slabs are seems to be never cleared (at least
without "sync && echo 2 >.../drop_caches"). But this is not a
production machine working 24x7, so we don't care about it right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
