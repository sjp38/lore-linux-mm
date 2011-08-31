Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CECFE6B00EE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 14:27:40 -0400 (EDT)
Message-ID: <4E5E7D16.4070805@redhat.com>
Date: Wed, 31 Aug 2011 14:27:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] memcg: skip scanning active lists based on individual
 size
References: <20110831090850.GA27345@redhat.com>
In-Reply-To: <20110831090850.GA27345@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/31/2011 05:08 AM, Johannes Weiner wrote:
> Reclaim decides to skip scanning an active list when the corresponding
> inactive list is above a certain size in comparison to leave the
> assumed working set alone while there are still enough reclaim
> candidates around.
>
> The memcg implementation of comparing those lists instead reports
> whether the whole memcg is low on the requested type of inactive
> pages, considering all nodes and zones.
>
> This can lead to an oversized active list not being scanned because of
> the state of the other lists in the memcg, as well as an active list
> being scanned while its corresponding inactive list has enough pages.
>
> Not only is this wrong, it's also a scalability hazard, because the
> global memory state over all nodes and zones has to be gathered for
> each memcg and zone scanned.
>
> Make these calculations purely based on the size of the two LRU lists
> that are actually affected by the outcome of the decision.
>
> Signed-off-by: Johannes Weiner<jweiner@redhat.com>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Daisuke Nishimura<nishimura@mxp.nes.nec.co.jp>
> Cc: Balbir Singh<bsingharora@gmail.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
