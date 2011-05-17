Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E4BE06B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 20:19:28 -0400 (EDT)
Message-ID: <4DD1BEE9.3060005@redhat.com>
Date: Mon, 16 May 2011 20:18:49 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix typo in the soft_limit stats.
References: <1305583230-2111-1-git-send-email-yinghan@google.com> <20110516231512.GW16531@cmpxchg.org> <BANLkTinohFTQRTViyU5NQ6EGi95xieXwOA@mail.gmail.com> <20110517001318.GX16531@cmpxchg.org>
In-Reply-To: <20110517001318.GX16531@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On 05/16/2011 08:13 PM, Johannes Weiner wrote:
> On Mon, May 16, 2011 at 05:05:02PM -0700, Ying Han wrote:
>> On Mon, May 16, 2011 at 4:15 PM, Johannes Weiner<hannes@cmpxchg.org>  wrote:

>>> Nacked-by: Johannes Weiner<hannes@cmpxchg.org>

> I think it would make sense to not introduce user-facing stats while
> we are discussing approaches that would not be able to maintain them.
>
> I am fine with them being in -mmotm (and receiving fixes), but would
> prefer not having them merged into .40.

Agreed on the stats probably not surviving, since the
underlying thing is going away (if we stick to the
plan we all agreed on at LSF).

Johannes and Ying, it would be a lot easier if you
worked together, rather than against each other :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
