Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 48C386B00A0
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:31:54 -0400 (EDT)
Message-ID: <515EB64B.8010104@parallels.com>
Date: Fri, 5 Apr 2013 15:32:27 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] page_cgroup cleanups
References: <1365156072-24100-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1365156072-24100-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 04/05/2013 02:01 PM, Glauber Costa wrote:
> Hi,
> 
> Last time I sent the mem cgroup bypass patches, Kame and Michal pointed out
> that some of it was a bit of cleanup, specifically at the page_cgroup side.
> I've decided to separate those patches and send them separately. After these
> patches are applied, page_cgroup will be initialized together with the root
> cgroup, instead of init/main.c
> 
> When we move cgroup initialization to the first non-root cgroup created, all
> we'll have to do from the page_cgroup side would be to move the initialization
> that now happens at root, to the first child.
> 
> Glauber Costa (2):
>   memcg: consistently use vmalloc for page_cgroup allocations
>   memcg: defer page_cgroup initialization
> 
>  include/linux/page_cgroup.h | 21 +------------------
>  init/main.c                 |  2 --
>  mm/memcontrol.c             |  2 ++
>  mm/page_cgroup.c            | 51 +++++++++++++++------------------------------
>  4 files changed, 20 insertions(+), 56 deletions(-)
> 
FYI: There are kbuild warnings with this. I wanted to send it earlier to
see what people think. If there is no changes requested, please let me
know I will send a new version with just the kbuild fixes folded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
