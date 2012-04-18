Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 26A8E6B00EF
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 14:18:53 -0400 (EDT)
Date: Wed, 18 Apr 2012 14:18:36 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120418181836.GD2224@redhat.com>
References: <20120404145134.GC12676@redhat.com>
 <20120407080027.GA2584@quack.suse.cz>
 <20120410180653.GJ21801@redhat.com>
 <20120410210505.GE4936@quack.suse.cz>
 <20120410212041.GP21801@redhat.com>
 <20120410222425.GF4936@quack.suse.cz>
 <20120411154005.GD16692@redhat.com>
 <20120411154531.GE16692@redhat.com>
 <20120411170542.GB16008@quack.suse.cz>
 <20120417214831.GE19975@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120417214831.GE19975@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Fengguang Wu <fengguang.wu@intel.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Tue, Apr 17, 2012 at 02:48:31PM -0700, Tejun Heo wrote:
[..]

> As for priority inversion through shared request pool, it is a problem
> which needs to be solved regardless of how async IOs are throttled.
> I'm not determined to which extent yet tho.  Different cgroups
> definitely need to be on separate pools but do we also want
> distinguish sync and async and what about ioprio?  Maybe we need a
> bybrid approach with larger common pool and reserved ones for each
> class?

currently we have global pool with separate limits for sync and async
and there is no consideration of ioprio. I think to keep it simple we
can just extend the same notion to keep per cgroup pool with internal
limits on sync/async requests to make sure sync IO does not get
serialized behind async IO. Personally I am not too worried about
async IO prio. It has never worked.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
