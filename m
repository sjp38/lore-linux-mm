Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3C32B9000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 05:31:34 -0400 (EDT)
Date: Fri, 30 Sep 2011 11:31:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 00/10] memcg naturalization -rc4
Message-ID: <20110930092843.GE32134@tiehlicka.suse.cz>
References: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

[linux-foundation.org seems to be down, so I have changed Andrew's
address]

On Thu 29-09-11 23:00:54, Johannes Weiner wrote:
> Hi,
> 
> this is the fourth revision of the memory cgroup naturalization
> series.
> 
> The changes from v3 have mostly been documentation, changelog, and
> naming fixes based on review feedback:
> 
>     o drop conversion of no longer existing zone-wide unevictable
>       page rescue scanner
>     o fix return value of mem_cgroup_hierarchical_reclaim() in
>       limit-shrinking mode (Michal)
>     o rename @remember to @reclaim in mem_cgroup_iter()
>     o convert vm_swappiness to global_reclaim() in the
>       correct patch (Michal)
>     o rename
>       struct mem_cgroup_iter_state -> struct mem_cgroup_reclaim_iter
>       and
>       struct mem_cgroup_iter -> struct mem_cgroup_reclaim_cookie
>       (Michal)
>     o added/amended comments and changelogs based on feedback (Michal, Kame)

Thanks for those clean ups. The patchset is in a really good shape now.
Nice work!

I will start testing it after I am back from vacation (10th Oct). This
time for real ;). I will try to prepare some numbers for the memcg
meeting during KS.

[...]

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
