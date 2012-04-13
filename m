Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E5E216B004D
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:26:57 -0400 (EDT)
Message-ID: <4F88378F.2040502@redhat.com>
Date: Fri, 13 Apr 2012 10:26:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix up the vmscan stat in vmstat
References: <1334253782-22755-1-git-send-email-yinghan@google.com> <20120412153603.fe320f54.akpm@linux-foundation.org>
In-Reply-To: <20120412153603.fe320f54.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On 04/12/2012 06:36 PM, Andrew Morton wrote:

> I was going to have a big whine about the failure to update the
> /proc/vmstat documentation.  But we don't have any /proc/vmstat
> documentation.  That was a sneaky labor-saving device.

I believe that may be a feature, since we use /proc/vmstat
to look at all kinds of VM internals...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
