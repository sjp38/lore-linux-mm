Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id E5F026B0083
	for <linux-mm@kvack.org>; Thu, 17 May 2012 06:58:06 -0400 (EDT)
Message-ID: <4FB4D945.7060108@parallels.com>
Date: Thu, 17 May 2012 14:56:05 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [patch 6/6] mm: memcg: print statistics from live counters
References: <1337018451-27359-1-git-send-email-hannes@cmpxchg.org> <1337018451-27359-7-git-send-email-hannes@cmpxchg.org> <20120516160131.fecb5ddf.akpm@linux-foundation.org> <4FB43FDB.6050300@jp.fujitsu.com>
In-Reply-To: <4FB43FDB.6050300@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/17/2012 04:01 AM, KAMEZAWA Hiroyuki wrote:
> Hm...sorry. I(fujitsu) am now considering to add meminfo for memcg...,
>
> add an option to override /proc/meminfo if a task is in container or
> meminfo file somewhere.
> (Now, we cannot trust /usr/bin/free, /usr/bin/top etc...in a container.)

Yes, and all the previous times I tried to touch those, I think the 
general agreement was to come up with some kind of fuse overlay that 
would read information available from the kernel, and present it 
correctly formatted through bind-mounts on the files of interest.

But that's mainly because we never reached agreement on how to make that 
appear automatically from such tasks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
