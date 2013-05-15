Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id CBBEE6B0002
	for <linux-mm@kvack.org>; Wed, 15 May 2013 04:38:01 -0400 (EDT)
Message-ID: <5193499C.8080505@parallels.com>
Date: Wed, 15 May 2013 12:38:52 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [patch v3 -mm 2/3] memcg: Get rid of soft-limit tree infrastructure
References: <1368431172-6844-1-git-send-email-mhocko@suse.cz> <1368431172-6844-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1368431172-6844-3-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel
 Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>

On 05/13/2013 11:46 AM, Michal Hocko wrote:
> Now that the soft limit is integrated to the reclaim directly the whole
> soft-limit tree infrastructure is not needed anymore. Rip it out.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |  224 +------------------------------------------------------
>  1 file changed, 1 insertion(+), 223 deletions(-)
Great =)

Reviewed-by: Glauber Costa <glommer@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
