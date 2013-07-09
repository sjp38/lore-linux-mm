Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 399FB6B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 08:57:38 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id q10so5225118pdj.24
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 05:57:37 -0700 (PDT)
Date: Tue, 9 Jul 2013 05:57:34 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
Message-ID: <20130709125734.GA2478@htj.dyndns.org>
References: <20130708100046.14417.12932.stgit@zurg>
 <20130708170047.GA18600@mtj.dyndns.org>
 <20130708175201.GB9094@redhat.com>
 <20130708175607.GB18600@mtj.dyndns.org>
 <51DBC99F.4030301@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DBC99F.4030301@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Jens Axboe <axboe@kernel.dk>

Hello,

On Tue, Jul 09, 2013 at 12:28:15PM +0400, Konstantin Khlebnikov wrote:
> Yep, blkio has plenty problems and flaws and I don't get how it's related
> to vfs layer, dirty set control and non-disk or network backed filesystems.
> Any problem can be fixed by introducing new abstract layer, except too many
> abstraction levels. Cgroup is pluggable subsystem, blkio has it's own plugins
> and it's build on top of io scheduler plugin. All this stuff always have worked

What does that have to do with anything?

> with block devices. Now you suggest to handle all filesystems in this stack.
> I think binding them to unrealated cgroup is rough leveling violation.

How is blkio unrelated to filesystems mounted on block devices?
You're suggesting a duplicate solution which can't be complete.

> NFS cannot be controlled only by network throttlers because we
> cannot slow down writeback process when it happens, we must slow
> down tasks who generates dirty memory.

That's exactly the same problem why blkio doesn't work for async IOs
right now, so if you're interested in the area, please contribute to
fixing that problem.

> Plus it's close to impossible to separate several workloads if they
> share one NFS sb.

Again, the same problem with blkio.  We need separate pressure
channels on bdi for each cgroup.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
