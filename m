Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id D25426B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 12:17:30 -0400 (EDT)
Received: by mail-gg0-f174.google.com with SMTP id y3so2339725ggc.5
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 09:17:29 -0700 (PDT)
Date: Tue, 23 Jul 2013 12:17:24 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH resend 1/3] vmpressure: change vmpressure::sr_lock to
 spinlock
Message-ID: <20130723161724.GA21100@mtj.dyndns.org>
References: <1374252671-11939-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374252671-11939-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Michal.

Sorry about the delay.  Was on the road.

On Fri, Jul 19, 2013 at 06:51:09PM +0200, Michal Hocko wrote:
> There is nothing that can sleep inside critical sections protected by
> this lock and those sections are really small so there doesn't make much
> sense to use mutex for them. Change the log to a spinlock
> 
> Brought-up-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
