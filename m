Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 02D1B6B00AB
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:54:32 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so2966084dak.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 08:54:32 -0800 (PST)
Date: Thu, 6 Dec 2012 08:54:26 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
Message-ID: <20121206165426.GM19802@htj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
 <20121203152205.GB17093@dhcp22.suse.cz>
 <20121203165338.GF19802@htj.dyndns.org>
 <50C03A3F.7070605@huawei.com>
 <20121206130904.GC10931@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121206130904.GC10931@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hey, guys.

On Thu, Dec 06, 2012 at 02:09:04PM +0100, Michal Hocko wrote:
> > We shoudn't haste to target this for 3.8, given that we're in late -rc and
> > Michal felt some patches scary and they hasn't got enough review.
> 
> Well, even the original code is scary enough so if the decision should
> be made just based on my feeling then it would be too sensitive
> probably. Anyway I do agree that the series should see review from
> others who are more familiar with the code before considering for
> merging.

It's already too late for 3.8.  All cpuset changes are for 3.9.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
