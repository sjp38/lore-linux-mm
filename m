Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A75B6B0388
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 01:59:55 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id y193so83189146lfd.3
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 22:59:55 -0700 (PDT)
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id m15si10634921lfj.285.2017.03.20.22.59.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Mar 2017 22:59:52 -0700 (PDT)
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
References: <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
 <20170316082714.GC30501@dhcp22.suse.cz>
 <20170316084733.GP802@shells.gnugeneration.com>
 <20170316090844.GG30501@dhcp22.suse.cz>
 <20170316092318.GQ802@shells.gnugeneration.com>
 <20170316093931.GH30501@dhcp22.suse.cz>
 <a65e4b73-5c97-d915-c79e-7df0771db823@wiesinger.com>
 <20170317171339.GA23957@dhcp22.suse.cz>
 <8cb1d796-aff3-0063-3ef8-880e76d437c0@wiesinger.com>
 <20170319151837.GD12414@dhcp22.suse.cz>
 <555d1f95-7c9e-2691-b14f-0260f90d23a9@wiesinger.com>
 <1489979147.4273.22.camel@gmx.de>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <798104b6-091d-5415-2c51-8992b6b231e5@wiesinger.com>
Date: Tue, 21 Mar 2017 06:59:42 +0100
MIME-Version: 1.0
In-Reply-To: <1489979147.4273.22.camel@gmx.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>, Michal Hocko <mhocko@kernel.org>
Cc: lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 20.03.2017 04:05, Mike Galbraith wrote:
> On Sun, 2017-03-19 at 17:02 +0100, Gerhard Wiesinger wrote:
>
>> mount | grep cgroup
> Just because controllers are mounted doesn't mean they're populated. To
> check that, you want to look for directories under the mount points
> with a non-empty 'tasks'.  You will find some, but memory cgroup
> assignments would likely be most interesting for this thread.  You can
> eliminate any diddling there by booting with cgroup_disable=memory.
>

Is this the correct information?

mount | grep "type cgroup" | cut -f 3 -d ' ' | while read LINE; do echo 
"================================================================================================================================================================";echo 
${LINE};ls -l ${LINE}; done
================================================================================================================================================================
/sys/fs/cgroup/systemd
total 0
-rw-r--r--  1 root root 0 Mar 20 14:31 cgroup.clone_children
-rw-r--r--  1 root root 0 Mar 20 14:31 cgroup.procs
-r--r--r--  1 root root 0 Mar 20 14:31 cgroup.sane_behavior
drwxr-xr-x  2 root root 0 Mar 20 14:31 init.scope
-rw-r--r--  1 root root 0 Mar 20 14:31 notify_on_release
-rw-r--r--  1 root root 0 Mar 20 14:31 release_agent
drwxr-xr-x 60 root root 0 Mar 21 06:50 system.slice
-rw-r--r--  1 root root 0 Mar 20 14:31 tasks
drwxr-xr-x  4 root root 0 Mar 21 06:55 user.slice
================================================================================================================================================================
/sys/fs/cgroup/net_cls,net_prio
total 0
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.clone_children
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.procs
-r--r--r-- 1 root root 0 Mar 20 14:31 cgroup.sane_behavior
-rw-r--r-- 1 root root 0 Mar 20 14:31 net_cls.classid
-rw-r--r-- 1 root root 0 Mar 20 14:31 net_prio.ifpriomap
-r--r--r-- 1 root root 0 Mar 20 14:31 net_prio.prioidx
-rw-r--r-- 1 root root 0 Mar 20 14:31 notify_on_release
-rw-r--r-- 1 root root 0 Mar 20 14:31 release_agent
-rw-r--r-- 1 root root 0 Mar 20 14:31 tasks
================================================================================================================================================================
/sys/fs/cgroup/cpu,cpuacct
total 0
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.clone_children
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.procs
-r--r--r-- 1 root root 0 Mar 20 14:31 cgroup.sane_behavior
-r--r--r-- 1 root root 0 Mar 20 14:31 cpuacct.stat
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpuacct.usage
-r--r--r-- 1 root root 0 Mar 20 14:31 cpuacct.usage_all
-r--r--r-- 1 root root 0 Mar 20 14:31 cpuacct.usage_percpu
-r--r--r-- 1 root root 0 Mar 20 14:31 cpuacct.usage_percpu_sys
-r--r--r-- 1 root root 0 Mar 20 14:31 cpuacct.usage_percpu_user
-r--r--r-- 1 root root 0 Mar 20 14:31 cpuacct.usage_sys
-r--r--r-- 1 root root 0 Mar 20 14:31 cpuacct.usage_user
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpu.cfs_period_us
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpu.cfs_quota_us
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpu.shares
-r--r--r-- 1 root root 0 Mar 20 14:31 cpu.stat
drwxr-xr-x 2 root root 0 Mar 20 14:31 init.scope
-rw-r--r-- 1 root root 0 Mar 20 14:31 notify_on_release
-rw-r--r-- 1 root root 0 Mar 20 14:31 release_agent
drwxr-xr-x 2 root root 0 Mar 20 14:31 system.slice
-rw-r--r-- 1 root root 0 Mar 20 14:31 tasks
drwxr-xr-x 4 root root 0 Mar 21 06:55 user.slice
================================================================================================================================================================
/sys/fs/cgroup/devices
total 0
-rw-r--r--  1 root root 0 Mar 20 14:31 cgroup.clone_children
-rw-r--r--  1 root root 0 Mar 20 14:31 cgroup.procs
-r--r--r--  1 root root 0 Mar 20 14:31 cgroup.sane_behavior
--w-------  1 root root 0 Mar 20 14:31 devices.allow
--w-------  1 root root 0 Mar 20 14:31 devices.deny
-r--r--r--  1 root root 0 Mar 20 14:31 devices.list
drwxr-xr-x  2 root root 0 Mar 20 14:31 init.scope
-rw-r--r--  1 root root 0 Mar 20 14:31 notify_on_release
-rw-r--r--  1 root root 0 Mar 20 14:31 release_agent
drwxr-xr-x 60 root root 0 Mar 21 06:50 system.slice
-rw-r--r--  1 root root 0 Mar 20 14:31 tasks
drwxr-xr-x  4 root root 0 Mar 21 06:55 user.slice
================================================================================================================================================================
/sys/fs/cgroup/freezer
total 0
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.clone_children
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.procs
-r--r--r-- 1 root root 0 Mar 20 14:31 cgroup.sane_behavior
-rw-r--r-- 1 root root 0 Mar 20 14:31 notify_on_release
-rw-r--r-- 1 root root 0 Mar 20 14:31 release_agent
-rw-r--r-- 1 root root 0 Mar 20 14:31 tasks
================================================================================================================================================================
/sys/fs/cgroup/perf_event
total 0
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.clone_children
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.procs
-r--r--r-- 1 root root 0 Mar 20 14:31 cgroup.sane_behavior
-rw-r--r-- 1 root root 0 Mar 20 14:31 notify_on_release
-rw-r--r-- 1 root root 0 Mar 20 14:31 release_agent
-rw-r--r-- 1 root root 0 Mar 20 14:31 tasks
================================================================================================================================================================
/sys/fs/cgroup/cpuset
total 0
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.clone_children
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.procs
-r--r--r-- 1 root root 0 Mar 20 14:31 cgroup.sane_behavior
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpuset.cpu_exclusive
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpuset.cpus
-r--r--r-- 1 root root 0 Mar 20 14:31 cpuset.effective_cpus
-r--r--r-- 1 root root 0 Mar 20 14:31 cpuset.effective_mems
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpuset.mem_exclusive
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpuset.mem_hardwall
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpuset.memory_migrate
-r--r--r-- 1 root root 0 Mar 20 14:31 cpuset.memory_pressure
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpuset.memory_pressure_enabled
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpuset.memory_spread_page
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpuset.memory_spread_slab
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpuset.mems
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpuset.sched_load_balance
-rw-r--r-- 1 root root 0 Mar 20 14:31 cpuset.sched_relax_domain_level
-rw-r--r-- 1 root root 0 Mar 20 14:31 notify_on_release
-rw-r--r-- 1 root root 0 Mar 20 14:31 release_agent
-rw-r--r-- 1 root root 0 Mar 20 14:31 tasks
================================================================================================================================================================
/sys/fs/cgroup/memory
total 0
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.clone_children
--w--w--w- 1 root root 0 Mar 20 14:31 cgroup.event_control
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.procs
-r--r--r-- 1 root root 0 Mar 20 14:31 cgroup.sane_behavior
drwxr-xr-x 2 root root 0 Mar 20 14:31 init.scope
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.failcnt
--w------- 1 root root 0 Mar 20 14:31 memory.force_empty
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.kmem.failcnt
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.kmem.limit_in_bytes
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.kmem.max_usage_in_bytes
-r--r--r-- 1 root root 0 Mar 20 14:31 memory.kmem.slabinfo
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.kmem.tcp.failcnt
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.kmem.tcp.limit_in_bytes
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.kmem.tcp.max_usage_in_bytes
-r--r--r-- 1 root root 0 Mar 20 14:31 memory.kmem.tcp.usage_in_bytes
-r--r--r-- 1 root root 0 Mar 20 14:31 memory.kmem.usage_in_bytes
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.limit_in_bytes
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.max_usage_in_bytes
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.memsw.failcnt
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.memsw.limit_in_bytes
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.memsw.max_usage_in_bytes
-r--r--r-- 1 root root 0 Mar 20 14:31 memory.memsw.usage_in_bytes
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.move_charge_at_immigrate
-r--r--r-- 1 root root 0 Mar 20 14:31 memory.numa_stat
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.oom_control
---------- 1 root root 0 Mar 20 14:31 memory.pressure_level
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.soft_limit_in_bytes
-r--r--r-- 1 root root 0 Mar 20 14:31 memory.stat
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.swappiness
-r--r--r-- 1 root root 0 Mar 20 14:31 memory.usage_in_bytes
-rw-r--r-- 1 root root 0 Mar 20 14:31 memory.use_hierarchy
-rw-r--r-- 1 root root 0 Mar 20 14:31 notify_on_release
-rw-r--r-- 1 root root 0 Mar 20 14:31 release_agent
drwxr-xr-x 2 root root 0 Mar 20 14:31 system.slice
-rw-r--r-- 1 root root 0 Mar 20 14:31 tasks
drwxr-xr-x 4 root root 0 Mar 21 06:55 user.slice
================================================================================================================================================================
/sys/fs/cgroup/pids
total 0
-rw-r--r--  1 root root 0 Mar 20 14:31 cgroup.clone_children
-rw-r--r--  1 root root 0 Mar 20 14:31 cgroup.procs
-r--r--r--  1 root root 0 Mar 20 14:31 cgroup.sane_behavior
drwxr-xr-x  2 root root 0 Mar 20 14:31 init.scope
-rw-r--r--  1 root root 0 Mar 20 14:31 notify_on_release
-rw-r--r--  1 root root 0 Mar 20 14:31 release_agent
drwxr-xr-x 60 root root 0 Mar 21 06:50 system.slice
-rw-r--r--  1 root root 0 Mar 20 14:31 tasks
drwxr-xr-x  4 root root 0 Mar 21 06:55 user.slice
================================================================================================================================================================
/sys/fs/cgroup/hugetlb
total 0
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.clone_children
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.procs
-r--r--r-- 1 root root 0 Mar 20 14:31 cgroup.sane_behavior
-rw-r--r-- 1 root root 0 Mar 20 14:31 hugetlb.2MB.failcnt
-rw-r--r-- 1 root root 0 Mar 20 14:31 hugetlb.2MB.limit_in_bytes
-rw-r--r-- 1 root root 0 Mar 20 14:31 hugetlb.2MB.max_usage_in_bytes
-r--r--r-- 1 root root 0 Mar 20 14:31 hugetlb.2MB.usage_in_bytes
-rw-r--r-- 1 root root 0 Mar 20 14:31 notify_on_release
-rw-r--r-- 1 root root 0 Mar 20 14:31 release_agent
-rw-r--r-- 1 root root 0 Mar 20 14:31 tasks
================================================================================================================================================================
/sys/fs/cgroup/blkio
total 0
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.avg_queue_size
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.dequeue
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.empty_time
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.group_wait_time
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.idle_time
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.io_merged
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.io_merged_recursive
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.io_queued
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.io_queued_recursive
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.io_service_bytes
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.io_service_bytes_recursive
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.io_serviced
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.io_serviced_recursive
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.io_service_time
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.io_service_time_recursive
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.io_wait_time
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.io_wait_time_recursive
-rw-r--r-- 1 root root 0 Mar 20 14:31 blkio.leaf_weight
-rw-r--r-- 1 root root 0 Mar 20 14:31 blkio.leaf_weight_device
--w------- 1 root root 0 Mar 20 14:31 blkio.reset_stats
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.sectors
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.sectors_recursive
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.throttle.io_service_bytes
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.throttle.io_serviced
-rw-r--r-- 1 root root 0 Mar 20 14:31 blkio.throttle.read_bps_device
-rw-r--r-- 1 root root 0 Mar 20 14:31 blkio.throttle.read_iops_device
-rw-r--r-- 1 root root 0 Mar 20 14:31 blkio.throttle.write_bps_device
-rw-r--r-- 1 root root 0 Mar 20 14:31 blkio.throttle.write_iops_device
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.time
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.time_recursive
-r--r--r-- 1 root root 0 Mar 20 14:31 blkio.unaccounted_time
-rw-r--r-- 1 root root 0 Mar 20 14:31 blkio.weight
-rw-r--r-- 1 root root 0 Mar 20 14:31 blkio.weight_device
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.clone_children
-rw-r--r-- 1 root root 0 Mar 20 14:31 cgroup.procs
-r--r--r-- 1 root root 0 Mar 20 14:31 cgroup.sane_behavior
drwxr-xr-x 2 root root 0 Mar 20 14:31 init.scope
-rw-r--r-- 1 root root 0 Mar 20 14:31 notify_on_release
-rw-r--r-- 1 root root 0 Mar 20 14:31 release_agent
drwxr-xr-x 2 root root 0 Mar 20 14:31 system.slice
-rw-r--r-- 1 root root 0 Mar 20 14:31 tasks
drwxr-xr-x 4 root root 0 Mar 21 06:55 user.slice


Thnx.

Ciao,
Gerhard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
