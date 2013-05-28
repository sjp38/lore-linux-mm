Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id CF98D6B003B
	for <linux-mm@kvack.org>; Tue, 28 May 2013 10:53:30 -0400 (EDT)
Date: Tue, 28 May 2013 10:53:21 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH][trivial] memcg: Kconfig info update
Message-ID: <20130528145321.GA15576@cmpxchg.org>
References: <1369668984-2787-1-git-send-email-dserrg@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369668984-2787-1-git-send-email-dserrg@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Dyasly <dserrg@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, May 27, 2013 at 07:36:24PM +0400, Sergey Dyasly wrote:
> Now there are only 2 members in struct page_cgroup.
> Update config MEMCG description accordingly.
> 
> Signed-off-by: Sergey Dyasly <dserrg@gmail.com>

Thanks for catching that!

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
