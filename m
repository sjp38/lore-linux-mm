Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 44EA56B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 09:16:09 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr13so5445104pbb.20
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 06:16:08 -0700 (PDT)
Date: Tue, 9 Jul 2013 06:16:05 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
Message-ID: <20130709131605.GB2478@htj.dyndns.org>
References: <20130708100046.14417.12932.stgit@zurg>
 <20130708170047.GA18600@mtj.dyndns.org>
 <20130708175201.GB9094@redhat.com>
 <20130708175607.GB18600@mtj.dyndns.org>
 <51DBC99F.4030301@openvz.org>
 <20130709125734.GA2478@htj.dyndns.org>
 <51DC0CE2.2050906@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DC0CE2.2050906@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Jens Axboe <axboe@kernel.dk>

On Tue, Jul 09, 2013 at 05:15:14PM +0400, Konstantin Khlebnikov wrote:
> blkio controls block devices. not filesystems or superblocks or bdi or pagecache.
> It's all about block layer and nothing more. Am I right?
> 
> So, you want to link some completely unrelated subsystems like NFS into the block layer?

Heh, yeah, sure, network QoS is completely unrelated to sockets too,
right?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
