Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 152A46B0012
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 00:30:43 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 322733EE0B6
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:30:36 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 147F445DE68
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:30:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EFE4745DE4D
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:30:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E41291DB8038
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:30:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AEBE21DB802C
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:30:35 +0900 (JST)
Message-ID: <4DFECCE5.5030409@jp.fujitsu.com>
Date: Mon, 20 Jun 2011 13:30:29 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/12] vmscan: shrinker->nr updates race and go wrong
References: <1306998067-27659-1-git-send-email-david@fromorbit.com> <1306998067-27659-3-git-send-email-david@fromorbit.com> <4DFE987E.1070900@jp.fujitsu.com> <20110620012531.GN561@dastard>
In-Reply-To: <20110620012531.GN561@dastard>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

>> Looks great fix. Please remove tracepoint change from this patch and send it
>> to -stable. iow, I expect I'll ack your next spin.
> 
> I don't believe such a change belongs in -stable. This code has been
> buggy for many years and as I mentioned it actually makes existing
> bad shrinker behaviour worse. I don't test stable kernels, so I've
> got no idea what side effects it will have outside of this series.
> I'm extremely hesitant to change VM behaviour in stable kernels
> without having tested first, so I'm not going to push it for stable
> kernels.

Ok, I have no strong opinion.



> 
> If you want it in stable kernels, then you can always let
> stable@kernel.org know once the commits are in the mainline tree and
> you've tested them...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
