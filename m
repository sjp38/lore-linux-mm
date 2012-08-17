Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 9CDA26B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:33:15 -0400 (EDT)
Message-ID: <502DD6DF.6070404@parallels.com>
Date: Fri, 17 Aug 2012 09:30:07 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/6] memcg: add target_mem_cgroup, mem_cgroup fields
 to shrink_control
References: <1345150434-30957-1-git-send-email-yinghan@google.com>
In-Reply-To: <1345150434-30957-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel
 Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph
 Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On 08/17/2012 12:53 AM, Ying Han wrote:
> Add target_mem_cgroup and mem_cgroup to shrink_control. The former one is the
> "root" memcg under pressure, and the latter one is the "current" memcg under
> pressure.
> 
> The target_mem_cgroup is initialized with the scan_control's target_mem_cgroup
> under target reclaim and default to NULL for rest of the places including
> global reclaim.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Maybe I'll change my mind while I advance in the patchset, but at first,
I don't see the point in having two memcg encoded in the shrinker
structure. It seems to me we should be able to do this internally from
memcg and hide it from the shrinker code.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
