Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 87BE86B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 12:38:21 -0400 (EDT)
Message-ID: <519A51AC.7010609@parallels.com>
Date: Mon, 20 May 2013 20:39:08 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 07/34] shrinker: convert superblock shrinkers to new
 API
References: <1368994047-5997-1-git-send-email-glommer@openvz.org> <1368994047-5997-8-git-send-email-glommer@openvz.org>
In-Reply-To: <1368994047-5997-8-git-send-email-glommer@openvz.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, hughd@google.com, Dave Chinner <dchinner@redhat.com>

On 05/20/2013 12:07 AM, Glauber Costa wrote:
> +static long super_cache_count(struct shrinker *shrink, struct shrink_control *sc)
> +{
> +	struct super_block *sb;
> +	long	total_objects = 0;
> +
> +	sb = container_of(shrink, struct super_block, s_shrink);
> +
> +	if (!grab_super_passive(sb))
> +		return -1;

Dave,

This is wrong, since mm/vmscan.c will WARN on count returning -1.
Only scan can return -1, and this is probably a mistake while moving
code over. Unless you shout, I am fixing this to "return 0" in this case.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
