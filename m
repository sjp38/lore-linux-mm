Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 0E5E26B0070
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 11:44:57 -0500 (EST)
Received: by mail-da0-f50.google.com with SMTP id h15so8782991dan.9
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 08:44:57 -0800 (PST)
Date: Mon, 7 Jan 2013 08:44:53 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET] cpuset: decouple cpuset locking from cgroup core,
 take#2
Message-ID: <20130107164453.GH3926@htj.dyndns.org>
References: <1357248967-24959-1-git-send-email-tj@kernel.org>
 <50E93554.3070102@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50E93554.3070102@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Li.

On Sun, Jan 06, 2013 at 04:27:00PM +0800, Li Zefan wrote:
> I've reviewed and tested the patchset, and it looks good to me!
> 
> Acked-by: Li Zefan <lizefan@huawei.com>

Great.  Ummm... How should we route this?  Paul doesn't seem to be
looking at this.  I can route it through cgroup tree.  Any objections?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
