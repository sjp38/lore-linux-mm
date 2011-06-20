Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2B96B0012
	for <linux-mm@kvack.org>; Sun, 19 Jun 2011 20:44:52 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BAA133EE0CF
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:44:46 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9763D45DE67
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:44:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F5FF45DE8E
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:44:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 71F591DB803F
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:44:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3ACB31DB803E
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:44:43 +0900 (JST)
Message-ID: <4DFE97F1.2030206@jp.fujitsu.com>
Date: Mon, 20 Jun 2011 09:44:33 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/12] vmscan: add shrink_slab tracepoints
References: <1306998067-27659-1-git-send-email-david@fromorbit.com> <1306998067-27659-2-git-send-email-david@fromorbit.com>
In-Reply-To: <1306998067-27659-2-git-send-email-david@fromorbit.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

(2011/06/02 16:00), Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> D?t is impossible to understand what the shrinkers are actually doing
> without instrumenting the code, so add a some tracepoints to allow
> insight to be gained.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  include/trace/events/vmscan.h |   67 +++++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                   |    6 +++-
>  2 files changed, 72 insertions(+), 1 deletions(-)

This look good to me. I have two minor request. 1) please change patch order,
move this patch after shrinker changes. iow, now both this and [2/12] have
tracepoint change. I don't like it. 2) please avoid cryptic abbreviated variable
names. Instead, please just use the same variable name with vmscan.c source code.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
