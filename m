Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 01E066B13F1
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 12:26:17 -0500 (EST)
Received: by obbta7 with SMTP id ta7so4219139obb.14
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 09:26:17 -0800 (PST)
Date: Thu, 2 Feb 2012 09:26:11 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] cgroup: remove cgroup_subsys argument from callbacks
Message-ID: <20120202172611.GF19837@google.com>
References: <4F278078.5030703@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F278078.5030703@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, container cgroup <containers@lists.linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, netdev <netdev@vger.kernel.org>

On Tue, Jan 31, 2012 at 01:47:36PM +0800, Li Zefan wrote:
> The argument is not used at all, and it's not necessary, because
> a specific callback handler of course knows which subsys it
> belongs to.
> 
> Now only ->pupulate() takes this argument, because the handlers of
> this callback always call cgroup_add_file()/cgroup_add_files().
> 
> So we reduce a few lines of code, though the shrinking of object size
> is minimal.
> 
>  16 files changed, 113 insertions(+), 162 deletions(-)
> 
>    text    data     bss     dec     hex filename
> 5486240  656987 7039960 13183187         c928d3 vmlinux.o.orig
> 5486170  656987 7039960 13183117         c9288d vmlinux.o
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Nice cleanup, applied to cgroup/for-3.4.  Thank you!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
