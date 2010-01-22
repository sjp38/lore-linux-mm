Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 533AA6B0083
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 19:16:55 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0M0GrR5012712
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 22 Jan 2010 09:16:53 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 00B2545DE50
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 09:16:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C6ECA45DE4F
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 09:16:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AF9731DB8044
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 09:16:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E56C1DB8040
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 09:16:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC-PATCH 0/7] Memory Compaction v1
In-Reply-To: <20100121101112.GH5154@csn.ul.ie>
References: <20100121115636.73BA.A69D9226@jp.fujitsu.com> <20100121101112.GH5154@csn.ul.ie>
Message-Id: <20100122091504.6BF7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 22 Jan 2010 09:16:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > Comments?
> > 
> > I think "Total pages reclaimed" increasing is not good thing ;)
> 
> First, I made a mistake in the patch. With the bug fixed, they're
> reduced. See the post later in the thread
> http://lkml.org/lkml/2010/1/6/215

Oh, I see. I'm glad the issue was alredy fixed.


> > Honestly, I haven't understand why your patch increase reclaimed and
> > the exactly meaning of the your tool's rclm field.
> > 
> > Can you share your mesurement script? May I run the same test?
> 
> Unfortunately at the moment it's part of a mini-testgrid setup I run out
> of the house. It doesn't lend itself to being stand-alone. I'll break it
> out as part of the next release.

surely good news :)


> > I like this patch, but I don't like increasing reclaim. I'd like to know
> > this patch require any vmscan change and/or its change mitigate the issue.
> > 
> 
> With the bug repaired, reclaims go from 105132 to 45935 with more huge
> pages allocated so right now, no special action is required.

ok. thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
