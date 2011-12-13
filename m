Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3D52C6B026B
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 10:10:43 -0500 (EST)
Date: Tue, 13 Dec 2011 16:10:37 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] page_cgroup: cleanup lookup_swap_cgroup()
Message-ID: <20111213151037.GD1818@redhat.com>
References: <1323747238-10252-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1323747238-10252-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, bsingharora@gmail.com

On Tue, Dec 13, 2011 at 11:33:58AM +0800, Bob Liu wrote:
> This patch is based on my previous patch:
> page_cgroup: add helper function to get swap_cgroup
> 
> As Johannes suggested, change the public interface to lookup_swap_cgroup_id(),
> replace swap_cgroup_getsc() with lookup_swap_cgroup() and do some extra
> cleanup.
> 
> Cc: Johannes Weiner <jweiner@redhat.com>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Awesome, thanks!  Patch looks good to me.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
