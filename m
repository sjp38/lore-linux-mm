Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id BD9646B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 11:08:37 -0400 (EDT)
Date: Wed, 27 Mar 2013 11:08:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: do not check for do_swap_account in
 mem_cgroup_{read,write,reset}
Message-ID: <20130327150829.GE29052@cmpxchg.org>
References: <1363698415-12737-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363698415-12737-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org

On Tue, Mar 19, 2013 at 02:06:55PM +0100, Michal Hocko wrote:
> since 2d11085e (memcg: do not create memsw files if swap accounting
> is disabled) memsw files are created only if memcg swap accounting is
> enabled so there doesn't make any sense to check for it explicitely in
> mem_cgroup_read, mem_cgroup_write and mem_cgroup_reset.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
