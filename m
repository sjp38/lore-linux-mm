Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9286E6B005C
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 06:21:44 -0400 (EDT)
Date: Thu, 14 Mar 2013 11:21:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: kernel trace
Message-ID: <20130314102142.GC11636@dhcp22.suse.cz>
References: <CANkm-Fhz2A3vg_egsm15Siimi4X5AQrx0cYyFNAGNcEG5=3_JA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANkm-Fhz2A3vg_egsm15Siimi4X5AQrx0cYyFNAGNcEG5=3_JA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander R <aleromex@gmail.com>
Cc: linux-mm@kvack.org

On Thu 07-03-13 20:50:05, Alexander R wrote:
> Hi,

Hi,

> i use opensuse12.2 x86_64.
> 
> May be it would helpfully for your development
> 
> [   51.943819] ------------[ cut here ]------------
> [   51.943838] WARNING: at
> /home/abuild/rpmbuild/BUILD/kernel-default-3.4.28/linux-3.4/mm/memcontrol.c:5007
> mem_cgroup_create+0x3ac/0x510()
> [   51.943841] Hardware name: ProLiant DL560 Gen8
> [   51.943842] Creating hierarchies with use_hierarchy==0 (flat hierarchy)
> is considered deprecated. If you believe that your setup is correct, we
> kindly ask you to contact linux-mm@kvack.org and let us know
[...]
> [   51.943880] Pid: 7222, comm: libvirtd Tainted: G        W
>  3.4.28-2.20-default #1
> [   51.943882] Call Trace:
> [   51.943909]  [<ffffffff81004598>] dump_trace+0x78/0x2c0
> [   51.943920]  [<ffffffff81532e6a>] dump_stack+0x69/0x6f
> [   51.943926]  [<ffffffff8103ead9>] warn_slowpath_common+0x79/0xc0
> [   51.943931]  [<ffffffff8103ebd5>] warn_slowpath_fmt+0x45/0x50
> [   51.943934]  [<ffffffff8151c04c>] mem_cgroup_create+0x3ac/0x510
> [   51.943944]  [<ffffffff810a7983>] cgroup_mkdir+0x103/0x3a0
> [   51.943952]  [<ffffffff81160345>] vfs_mkdir+0xb5/0x170
> [   51.943958]  [<ffffffff81164444>] sys_mkdirat+0xe4/0xf0
> [   51.943968]  [<ffffffff81545c7d>] system_call_fastpath+0x1a/0x1f
> [   51.943974]  [<00007f12ed256f77>] 0x7f12ed256f76
> [   51.943975] ---[ end trace a6c54db610fd5bb5 ]---

This is a known thing. Please have a look at
https://bugzilla.novell.com/show_bug.cgi?id=781134

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
