Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 37AA86B005D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 11:53:44 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so1416157dak.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2012 08:53:43 -0800 (PST)
Date: Mon, 3 Dec 2012 08:53:38 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
Message-ID: <20121203165338.GF19802@htj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
 <20121203152205.GB17093@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121203152205.GB17093@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: lizefan@huawei.com, paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Michal.

On Mon, Dec 03, 2012 at 04:22:05PM +0100, Michal Hocko wrote:
> I have glanced through the series and spotten nothing obviously wrong. I
> do not feel I could give my r-b because I am not familiar with cpusets
> internals enough and some patches looks quite scary (like #8).
> Anyway the resulting outcome seems nice.

Thanks a lot for looking at it and, yeah, it's a bit scary.  Li, Paul,
can you guys please review the series?

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
