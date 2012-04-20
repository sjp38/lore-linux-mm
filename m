Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 076736B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 10:18:11 -0400 (EDT)
Message-ID: <4F916FFE.2020401@redhat.com>
Date: Fri, 20 Apr 2012 10:17:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
References: <1334680666-12361-1-git-send-email-yinghan@google.com> <20120418122448.GB1771@cmpxchg.org> <CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com> <20120419170434.GE15634@tiehlicka.suse.cz> <CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com> <20120419223318.GA2536@cmpxchg.org> <CALWz4iy2==jYkYx98EGbqbM2Y7q4atJpv9sH_B7Fjr8aqq++JQ@mail.gmail.com> <4F911C95.4040008@jp.fujitsu.com>
In-Reply-To: <4F911C95.4040008@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 04/20/2012 04:21 AM, KAMEZAWA Hiroyuki wrote:

> If you need smart victim selection under hierarchy, please implement
> victim scheduler which choose A2 rather than A and A1. I think you
> can do it.

Ying and I spent a few hours working out exactly how to do
this, a few weeks ago in San Francisco.

She might still have the pictures of all the stuff we drew
on the whiteboard.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
