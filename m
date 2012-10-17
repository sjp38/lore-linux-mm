Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 0A5F56B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 03:30:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 860713EE0CB
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 16:30:31 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C32145DEBF
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 16:30:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5349445DEBA
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 16:30:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4283C1DB8045
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 16:30:31 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E2A111DB8041
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 16:30:30 +0900 (JST)
Message-ID: <507E5E6E.7040500@jp.fujitsu.com>
Date: Wed, 17 Oct 2012 16:29:50 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 14/14] Add documentation about the kmem controller
References: <1349690780-15988-1-git-send-email-glommer@parallels.com> <1349690780-15988-15-git-send-email-glommer@parallels.com>
In-Reply-To: <1349690780-15988-15-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, devel@openvz.org, Frederic Weisbecker <fweisbec@gmail.com>

(2012/10/08 19:06), Glauber Costa wrote:
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> ---
>   Documentation/cgroups/memory.txt | 55 +++++++++++++++++++++++++++++++++++++++-
>   1 file changed, 54 insertions(+), 1 deletion(-)
> 

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
