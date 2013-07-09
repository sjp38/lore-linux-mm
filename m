Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 435786B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 09:43:15 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id fq12so4730112lab.38
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 06:43:13 -0700 (PDT)
Message-ID: <51DC136E.6020901@openvz.org>
Date: Tue, 09 Jul 2013 17:43:10 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
References: <20130708100046.14417.12932.stgit@zurg> <20130708170047.GA18600@mtj.dyndns.org> <20130708175201.GB9094@redhat.com> <20130708175607.GB18600@mtj.dyndns.org> <51DBC99F.4030301@openvz.org> <20130709125734.GA2478@htj.dyndns.org> <51DC0CE2.2050906@openvz.org> <20130709131605.GB2478@htj.dyndns.org> <20130709131646.GC2478@htj.dyndns.org>
In-Reply-To: <20130709131646.GC2478@htj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Jens Axboe <axboe@kernel.dk>

Tejun Heo wrote:
> On Tue, Jul 09, 2013 at 06:16:05AM -0700, Tejun Heo wrote:
>> On Tue, Jul 09, 2013 at 05:15:14PM +0400, Konstantin Khlebnikov wrote:
>>> blkio controls block devices. not filesystems or superblocks or bdi or pagecache.
>>> It's all about block layer and nothing more. Am I right?
>>>
>>> So, you want to link some completely unrelated subsystems like NFS into the block layer?
>>
>> Heh, yeah, sure, network QoS is completely unrelated to sockets too,
>> right?
>
> And, no, blkio wouldn't have anything to do with NFS.  Where did you
> get that idea?
>

My concept it cgroup which would control io operation on vfs layer for all filesystems.
It will account and manage IO operations. I've found really lightweight technique
for accounting and throttling which don't introduce new locks or priority inversions
(which is major problem in all existing throttlers, including cpu cgroup rate limiter)
So, I've tried to keep code smaller, cleaner and saner as possible while you guys are
trying to push me into the block layer =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
