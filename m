Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id CAFBD6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:30:48 -0400 (EDT)
Received: by dakp5 with SMTP id p5so592869dak.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 15:30:48 -0700 (PDT)
Date: Tue, 26 Jun 2012 15:30:43 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] fix bad behavior in use_hierarchy file
Message-ID: <20120626223043.GC15811@google.com>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
 <1340725634-9017-2-git-send-email-glommer@parallels.com>
 <20120626152522.c7161b5a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626152522.c7161b5a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dhaval Giani <dhaval.giani@gmail.com>, Li Zefan <lizefan@huawei.com>

(cc'ing Li)

Hello, Andrew.

On Tue, Jun 26, 2012 at 03:25:22PM -0700, Andrew Morton wrote:
> hm.  The various .write_u64() implementations go and return zero on
> success and cgroup_write_X64() sees this and rewrites the return value
> to `nbytes'.
> 
> That was a bit naughty of us - it prevents a .write_u64() instance from
> being able to fully implement a partial write.  We can *partially*
> implement a partial write, by returning a value between 1 and nbytes-1,
> but we can't return zero.  It's a weird interface, it's a surprising
> interface and it was quite unnecessary to do it this way.  Someone
> please slap Paul.
> 
> It's hardly a big problem I, but that's why the unix write() interface
> was designed the way it is.

The whole file interface is severely over-designed like a lot of other
things in cgorup.  I'm thinking about consolidating all the different
read/write methods into one generic pair, likely based on seq_file and
make all others helpers.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
