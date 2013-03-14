Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 157526B0006
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 09:09:56 -0400 (EDT)
Date: Thu, 14 Mar 2013 14:09:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: kernel trace
Message-ID: <20130314130954.GG11631@dhcp22.suse.cz>
References: <CANkm-Fhz2A3vg_egsm15Siimi4X5AQrx0cYyFNAGNcEG5=3_JA@mail.gmail.com>
 <20130314102142.GC11636@dhcp22.suse.cz>
 <CANkm-Fif_PistVd-8JywKz3vBQk1OqMzkwGHwze9aM9cCHLeiw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANkm-Fif_PistVd-8JywKz3vBQk1OqMzkwGHwze9aM9cCHLeiw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander R <aleromex@gmail.com>
Cc: linux-mm@kvack.org

On Thu 14-03-13 14:52:38, Alexander R wrote:
> On Thu, Mar 14, 2013 at 2:21 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Thu 07-03-13 20:50:05, Alexander R wrote:
> >> Hi,
> >
> > Hi,
> >
> >> i use opensuse12.2 x86_64.
> >>
> >> May be it would helpfully for your development
> >>
> >> [   51.943819] ------------[ cut here ]------------
> >> [   51.943838] WARNING: at
> >> /home/abuild/rpmbuild/BUILD/kernel-default-3.4.28/linux-3.4/mm/memcontrol.c:5007
> >> mem_cgroup_create+0x3ac/0x510()
> >> [   51.943841] Hardware name: ProLiant DL560 Gen8
> >> [   51.943842] Creating hierarchies with use_hierarchy==0 (flat hierarchy)
> >> is considered deprecated. If you believe that your setup is correct, we
> >> kindly ask you to contact linux-mm@kvack.org and let us know
> > [...]
> >> [   51.943880] Pid: 7222, comm: libvirtd Tainted: G        W
> >>  3.4.28-2.20-default #1
> >> [   51.943882] Call Trace:
> >> [   51.943909]  [<ffffffff81004598>] dump_trace+0x78/0x2c0
> >> [   51.943920]  [<ffffffff81532e6a>] dump_stack+0x69/0x6f
> >> [   51.943926]  [<ffffffff8103ead9>] warn_slowpath_common+0x79/0xc0
> >> [   51.943931]  [<ffffffff8103ebd5>] warn_slowpath_fmt+0x45/0x50
> >> [   51.943934]  [<ffffffff8151c04c>] mem_cgroup_create+0x3ac/0x510
> >> [   51.943944]  [<ffffffff810a7983>] cgroup_mkdir+0x103/0x3a0
> >> [   51.943952]  [<ffffffff81160345>] vfs_mkdir+0xb5/0x170
> >> [   51.943958]  [<ffffffff81164444>] sys_mkdirat+0xe4/0xf0
> >> [   51.943968]  [<ffffffff81545c7d>] system_call_fastpath+0x1a/0x1f
> >> [   51.943974]  [<00007f12ed256f77>] 0x7f12ed256f76
> >> [   51.943975] ---[ end trace a6c54db610fd5bb5 ]---
> >
> > This is a known thing. Please have a look at
> > https://bugzilla.novell.com/show_bug.cgi?id=781134
> 
> Access Denied
> You are not authorized to access bug #781134.

Hmm, strange. The bug is not marked as private. Do you have an account
in bugzilla?

Anyway, the point is that this is known and libvirt maintainers are
supposed to fix this. The warning is harmless and it is mentioned to
kick authors of sw. misusing hierarchies to change their layout or speek
loudly if they believe their usage makes sense and it shouldn't be
changed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
