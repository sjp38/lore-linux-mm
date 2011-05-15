Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 007B28D003B
	for <linux-mm@kvack.org>; Sun, 15 May 2011 13:56:35 -0400 (EDT)
Message-ID: <4DD013CB.8080408@redhat.com>
Date: Sun, 15 May 2011 13:56:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] vmscan,memcg: memcg aware swap token
References: <4DCD1824.1060801@jp.fujitsu.com> <4DCD189D.2000207@jp.fujitsu.com>
In-Reply-To: <4DCD189D.2000207@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com

On 05/13/2011 07:40 AM, KOSAKI Motohiro wrote:
> Currently, memcg reclaim can disable swap token even if the swap token
> mm doesn't belong in its memory cgroup. It's slightly risky. If an
> admin creates very small mem-cgroup and silly guy runs contentious heavy
> memory pressure workload, every tasks are going to lose swap token and
> then system may become unresponsive. That's bad.
>
> This patch adds 'memcg' parameter into disable_swap_token(). and if
> the parameter doesn't match swap token, VM doesn't disable it.
>
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
