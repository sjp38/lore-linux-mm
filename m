Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id A4DC06B0033
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 12:17:56 -0400 (EDT)
Received: by mail-ye0-f179.google.com with SMTP id r3so2606746yen.10
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 09:17:55 -0700 (PDT)
Date: Tue, 23 Jul 2013 12:17:50 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH resend 2/3] vmpressure: do not check for pending work to
 prevent from new work
Message-ID: <20130723161750.GB21100@mtj.dyndns.org>
References: <1374252671-11939-1-git-send-email-mhocko@suse.cz>
 <1374252671-11939-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374252671-11939-2-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jul 19, 2013 at 06:51:10PM +0200, Michal Hocko wrote:
> because it is racy and it doesn't give us much anyway as schedule_work
> handles this case already.
> 
> Brought-up-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
