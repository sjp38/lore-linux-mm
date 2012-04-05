Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 079896B004A
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 12:31:19 -0400 (EDT)
Received: by iajr24 with SMTP id r24so2727971iaj.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 09:31:19 -0700 (PDT)
Date: Thu, 5 Apr 2012 09:31:13 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120405163113.GD12854@google.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404201816.GL12676@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120404201816.GL12676@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

Hey, Vivek.

On Wed, Apr 04, 2012 at 04:18:16PM -0400, Vivek Goyal wrote:
> Hey how about reconsidering my other proposal for which I had posted
> the patches. And that is keep throttling still at device level. Reads
> and direct IO get throttled asynchronously but buffered writes get
> throttled synchronously.
> 
> Advantages of this scheme.
> 
> - There are no separate knobs.
> 
> - All the IO (read, direct IO and buffered write) is controlled using
>   same set of knobs and goes in queue of same cgroup.
> 
> - Writeback logic has no knowledge of throttling. It just invokes a 
>   hook into throttling logic of device queue.
> 
> I guess this is a hybrid of active writeback throttling and back pressure
> mechanism.
> 
> But it still does not solve the NFS issue as well as for direct IO,
> filesystems still can get serialized, so metadata issue still needs to 
> be resolved. So one can argue that why not go for full "back pressure"
> method, despite it being more complex.
> 
> Here is the link, just to refresh the memory. Something to keep in mind
> while assessing alternatives.
> 
> https://lkml.org/lkml/2011/6/28/243

Hmmm... so, this only works for blk-throttle and not with the weight.
How do you manage interaction between buffered writes and direct
writes for the same cgroup?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
