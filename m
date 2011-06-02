Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C12BF6B007B
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 17:02:39 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p52L2bPP021420
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 14:02:37 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by hpaq12.eem.corp.google.com with ESMTP id p52L1INs017242
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 14:02:36 -0700
Received: by qyk10 with SMTP id 10so768979qyk.11
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 14:02:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=cHVZP+fZwHNM3cXVyw53kJ2HQmw@mail.gmail.com>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-8-git-send-email-hannes@cmpxchg.org>
	<BANLkTi=cHVZP+fZwHNM3cXVyw53kJ2HQmw@mail.gmail.com>
Date: Thu, 2 Jun 2011 14:02:31 -0700
Message-ID: <BANLkTimvuwLYwzRT-6k_oVwKBzBEo500s-rXETerTskYHfontQ@mail.gmail.com>
Subject: Re: [patch 7/8] vmscan: memcg-aware unevictable page rescue scanner
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jun 2, 2011 at 6:27 AM, Hiroyuki Kamezawa
<kamezawa.hiroyuki@gmail.com> wrote:
> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
>> Once the per-memcg lru lists are exclusive, the unevictable page
>> rescue scanner can no longer work on the global zone lru lists.
>>
>> This converts it to go through all memcgs and scan their respective
>> unevictable lists instead.
>>
>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>
> Hm, isn't it better to have only one GLOBAL LRU for unevictable pages ?
> memcg only needs counter for unevictable pages and LRU is not necessary
> to be per memcg because we don't reclaim it...

Hmm. Are we suggesting to keep one un-evictable LRU list for all
memcgs? So we will have
exclusive lru only for file and anon. If so, we are not done to make
all the lru list being exclusive
which is critical later to improve the zone->lru_lock contention
across the memcgs

Sorry If i misinterpret the suggestion here

--Ying


> Thanks,
> -Kame
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
