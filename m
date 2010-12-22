Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7599E6B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 10:37:27 -0500 (EST)
Received: by iwn40 with SMTP id 40so5496606iwn.14
        for <linux-mm@kvack.org>; Wed, 22 Dec 2010 07:37:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1293020757.1998.2.camel@localhost.localdomain>
References: <1293020757.1998.2.camel@localhost.localdomain>
Date: Thu, 23 Dec 2010 00:37:11 +0900
Message-ID: <AANLkTin6GMiXHuoVzNWPcj0jXDqWyfWCwW9fd-v=pq=X@mail.gmail.com>
Subject: Re: 2.6.37-rc7: NULL pointer dereference
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Thomas Meyer <thomas@m3y3r.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Cced linux-mm and maintainers of memcg.

On Wed, Dec 22, 2010 at 9:25 PM, Thomas Meyer <thomas@m3y3r.de> wrote:
> BUG: unable to handle kernel NULL pointer dereference at 00000008
> IP: [<c04eae14>] __mem_cgroup_try_charge+0x234/0x430
> *pde =3D 00000000
> Oops: 0000 [#1]
> last sysfs file: /sys/devices/platform/regulatory.0/uevent
> Modules linked in: vfat fat usb_storage fuse sco bnep l2cap bluetooth cpu=
freq_ondemand acpi_cpufreq mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ip=
v6 ip6table_filter ip6_tables kvm_intel kvm uinput arc4 ecb snd_hda_codec_h=
dmi snd_hda_codec_realtek iwlagn snd_hda_intel snd_hda_codec iwlcore uvcvid=
eo snd_hwdep mac80211 snd_seq videodev snd_seq_device snd_pcm cfg80211 snd_=
timer rfkill v4l1_compat wmi snd pcspkr soundcore joydev serio_raw snd_page=
_alloc ipv6 sha256_generic aes_i586 aes_generic cbc dm_crypt [last unloaded=
: scsi_wait_scan]
> Pid: 8058, comm: swapoff Tainted: G =A0 =A0 =A0 =A0 =A0I 2.6.37-rc7 #221 =
JM11-MS/Aspire 1810T
> EIP: 0060:[<c04eae14>] EFLAGS: 00010246 CPU: 0
> EIP is at __mem_cgroup_try_charge+0x234/0x430
> EAX: 00000008 EBX: 00000000 ECX: f2e71f10 EDX: f2f96380
> ESI: f3e55860 EDI: 00020000 EBP: f2e71eb4 ESP: f2e71e54
> =A0DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
> Process swapoff (pid: 8058, ti=3Df2e70000 task=3Df3e55860 task.ti=3Df2e70=
000)
> Stack:
> =A0f2e71e88 c0456607 26ba7c1c f3e55860 00000010 f3e55860 069d208a b2ee651=
d
> =A000000008 000000d0 f2f96380 00000005 01ffffff f2e71f10 00000246 ec1a64a=
e
> =A0ffffffff 00000000 27b52eae f044dc84 00000000 f2f96380 00000000 000000d=
0
> Call Trace:
> =A0[<c0456607>] ? ktime_get_ts+0x107/0x140
> =A0[<c04ebb89>] ? mem_cgroup_try_charge_swapin+0x49/0xb0
> =A0[<c04d9b4b>] ? unuse_mm+0x1db/0x300
> =A0[<c04dad9a>] ? sys_swapoff+0x2aa/0x890
> =A0[<c047cd58>] ? audit_syscall_entry+0x218/0x240
> =A0[<c047d043>] ? audit_syscall_exit+0x1f3/0x220
> =A0[<c0403013>] ? sysenter_do_call+0x12/0x22
> Code: 55 c8 8b 82 90 01 00 00 85 c0 74 09 8b 80 7c 03 00 00 8b 58 2c 3b 1=
d 54 20 a9 c0 74 61 3b 1d 4c ca a4 c0 74 6a 8d 43 08 89 45 c0 <8b> 43 08 a8=
 01 0f 85 73 fe ff ff 8d 4b 04 89 5d bc 8d 76 00 8b
> EIP: [<c04eae14>] __mem_cgroup_try_charge+0x234/0x430 SS:ESP 0068:f2e71e5=
4
> CR2: 0000000000000008
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
