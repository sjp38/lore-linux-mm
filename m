Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 315166B004A
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 09:35:25 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so3743418vcb.14
        for <linux-mm@kvack.org>; Sat, 14 Apr 2012 06:35:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334181614-26836-1-git-send-email-yinghan@google.com>
References: <1334181614-26836-1-git-send-email-yinghan@google.com>
Date: Sat, 14 Apr 2012 21:35:23 +0800
Message-ID: <CAJd=RBCsG4YvLf48NQPq0Rkk5QiRb=WU0_ZU7EocUj7od=eQgg@mail.gmail.com>
Subject: Re: [PATCH V2 3/5] memcg: set soft_limit_in_bytes to 0 by default
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Thu, Apr 12, 2012 at 6:00 AM, Ying Han <yinghan@google.com> wrote:
> 1. If soft_limit are all set to MAX, it wastes first three periority iterations
s/periority/priority/

> without scanning anything.
>
> 2. By default every memcg is eligibal for softlimit reclaim, and we can also
s/eligibal/eligible/

> set the value to MAX for special memcg which is immune to soft limit reclaim.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
