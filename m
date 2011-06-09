Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 07DC36B007D
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 21:15:56 -0400 (EDT)
Message-ID: <4DF01EC2.8010105@redhat.com>
Date: Wed, 08 Jun 2011 21:15:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>	<BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>	<20110602073335.GA20630@cmpxchg.org>	<BANLkTikztP6RoyBgMqUHgrzJFLZrHMCs=Q@mail.gmail.com>	<20110602100007.GB20725@cmpxchg.org> <BANLkTi=xvunhqpXFJ=wJFkCuu+7Czh4nZw@mail.gmail.com>
In-Reply-To: <BANLkTi=xvunhqpXFJ=wJFkCuu+7Czh4nZw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/02/2011 08:59 AM, Hiroyuki Kamezawa wrote:

> It seems your current series is a mixture of 2 works as
> "re-desgin of softlimit" and "removal of global LRU".
> I don't understand why you need 2 works at once.

That seems pretty obvious.

With the global LRU gone, the only way to reclaim
pages in a global fashion (because the zone is low
on memory), is to reclaim from all the memcgs in
the zone.

Doing that requires that the softlimit stuff is
changed, and not only the biggest offender is
attacked.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
