Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 8378B6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 14:40:43 -0400 (EDT)
Received: by mail-gh0-f174.google.com with SMTP id r17so3293501ghr.19
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 11:40:41 -0700 (PDT)
Date: Fri, 12 Jul 2013 11:40:36 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] vmpressure: make sure memcg stays alive until all
 users are signaled
Message-ID: <20130712184036.GB23680@mtj.dyndns.org>
References: <20130711083110.GC21667@dhcp22.suse.cz>
 <51DE701C.6010800@huawei.com>
 <20130711092542.GD21667@dhcp22.suse.cz>
 <51DE7AAF.6070004@huawei.com>
 <20130711093300.GE21667@dhcp22.suse.cz>
 <20130711154408.GA9229@mtj.dyndns.org>
 <20130711162215.GM21667@dhcp22.suse.cz>
 <20130711163238.GC9229@mtj.dyndns.org>
 <20130712084039.GA13224@dhcp22.suse.cz>
 <20130712183404.GA23680@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130712183404.GA23680@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, Jul 12, 2013 at 11:34:04AM -0700, Tejun Heo wrote:
> not "bypassing" an existing mechanism at all.  It is an inherent part
> of that model and various kernel subsystems have been doing that
> forever.

Just to clarify, I was talking about two staged object release where
the initial phase shuts down parts which aren't necessary for the
draining stage.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
