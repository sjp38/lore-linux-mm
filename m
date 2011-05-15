Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 18A7C6B0012
	for <linux-mm@kvack.org>; Sun, 15 May 2011 18:34:30 -0400 (EDT)
Message-ID: <4DD054EF.4020300@redhat.com>
Date: Sun, 15 May 2011 18:34:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] vmscan: implement swap token priority decay
References: <4DCD1824.1060801@jp.fujitsu.com> <4DCD1913.2090200@jp.fujitsu.com>
In-Reply-To: <4DCD1913.2090200@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com

On 05/13/2011 07:42 AM, KOSAKI Motohiro wrote:
> While testing for memcg aware swap token, I observed a swap token
> was often grabbed an intermittent running process (eg init, auditd)
> and they never release a token.
>
> Why? Currently, swap toke priority is only decreased at page fault
> path. Then, if the process sleep immediately after to grab swap
> token, their swap token priority never be decreased. That makes
> obviously undesired result.
>
> This patch implement very poor (and lightweight) priority decay
> mechanism. It only be affect to the above corner case and doesn't
> change swap tendency workload performance (eg multi process qsbench
> load)

Ohhh, good catch.  The original swap token algorithm did
not have this problem, and I never caught the fact that
the replacement (which is better in many ways) does...

> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel<riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
