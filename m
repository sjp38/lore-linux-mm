Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 315576B0012
	for <linux-mm@kvack.org>; Thu, 12 May 2011 11:38:03 -0400 (EDT)
Message-ID: <4DCBF67A.3060700@redhat.com>
Date: Thu, 12 May 2011 11:02:18 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [rfc patch 1/6] memcg: remove unused retry signal from reclaim
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org> <1305212038-15445-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1305212038-15445-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/12/2011 10:53 AM, Johannes Weiner wrote:
> If the memcg reclaim code detects the target memcg below its limit it
> exits and returns a guaranteed non-zero value so that the charge is
> retried.
>
> Nowadays, the charge side checks the memcg limit itself and does not
> rely on this non-zero return value trick.
>
> This patch removes it.  The reclaim code will now always return the
> true number of pages it reclaimed on its own.
>
> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>

Acked-by: Rik van Riel<riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
