Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id EE3526B00FA
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 19:02:43 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so956383pbc.14
        for <linux-mm@kvack.org>; Wed, 04 Apr 2012 16:02:43 -0700 (PDT)
Date: Wed, 4 Apr 2012 16:02:37 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120404230237.GA2173@dhcp-172-17-108-109.mtv.corp.google.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
 <20120404184909.GB29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404203239.GM12676@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120404203239.GM12676@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

Hello, Vivek.

On Wed, Apr 04, 2012 at 04:32:39PM -0400, Vivek Goyal wrote:
> > Let's say we have iops/bps limitation applied on top of proportional IO
> > distribution
> 
> We already do that. First IO is subjected to throttling limit and only 
> then it is passed to the elevator to do the proportional IO. So throttling
> is already stacked on top of proportional IO. The only question is 
> should it be pushed to even higher layers or not.

Yeah, I know we already can do that.  I was trying to give an example
of non-trivial IO limit configuration.

> So split model is definitely confusing. Anyway, block layer will not
> apply the limits again as flusher IO will go in root cgroup which 
> generally goes to root which is unthrottled generally. Or flusher
> could mark the bios with a flag saying "do not throttle" bios again as
> these have been throttled already. So throttling again is probably not
> an issue. 
> 
> In summary, agreed that split is confusing and it fills a gap existing
> today.

It's not only confusing.  It's broken.  So, what you're saying is that
there's no provision to orchestrate between buffered writes and other
types of IOs.  So, it would essentially work as if there are two
separate controls controlling each of two heavily interacting parts
with no designed provision between them.  What the....

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
