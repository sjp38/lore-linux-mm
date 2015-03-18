Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id D8B526B006E
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 12:23:14 -0400 (EDT)
Received: by oigv203 with SMTP id v203so40766997oig.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 09:23:14 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id pb7si35474107pdb.193.2015.03.18.09.23.12
        for <linux-mm@kvack.org>;
        Wed, 18 Mar 2015 09:23:14 -0700 (PDT)
Message-ID: <5509A66D.9030406@internode.on.net>
Date: Thu, 19 Mar 2015 02:53:09 +1030
From: Arthur Marsh <arthur.marsh@internode.on.net>
MIME-Version: 1.0
Subject: Re: kernel BUG at mm/rmap.c:399!
References: <54B25DD1.8040100@internode.on.net> <5509A2F1.6040402@yandex-team.ru>
In-Reply-To: <5509A2F1.6040402@yandex-team.ru>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org



Konstantin Khlebnikov wrote on 19/03/15 02:38:
> On 11.01.2015 14:26, Arthur Marsh wrote:
>> Hi, I hit the following when resetting my ADSL modem, which dropped the
>> Ethernet link on this pc using the current Linus' git head kernel
>> compiled for X86-64 in 32 bit mode:
>>
>> Ethernet controller is identified as:
>>
>> 00:12.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II]
>> (rev 7c)
>>
>> [    0.000000] Initializing cgroup subsys cpuset
>> [    0.000000] Initializing cgroup subsys cpu
>> [    0.000000] Initializing cgroup subsys cpuacct
>> [    0.000000] Linux version 3.19.0-rc3+ (root@am64) (gcc version 4.9.2
>> (Debian 4.9.2-10) ) #1453 SMP PREEMPT Sat Jan 10 19:21:40 ACDT 2015
>>
>> [62178.076871] via-rhine 0000:00:12.0 eth0: Reset not complete yet.
>> Trying harder.
>> [62178.077380] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
>> [62358.924028] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>> [62590.593390] ------------[ cut here ]------------
>> [62590.593803] kernel BUG at mm/rmap.c:399!
>> [62590.594140] invalid opcode: 0000 [#1] PREEMPT SMP
>> [62590.594583] Modules linked in: dm_mod cpuid snd_hrtimer nfc
>> cpufreq_stats cpufreq_conservative cpufreq_powersave cpufreq_userspace
>> bnep binfmt_misc nfnetlink_queue nfnetlink_log nfnetlink bluetooth
>> rfkill nls_utf8 nls_cp437 vfat fat hwmon_vid tun snd_emu10k1_synth
>> snd_emux_synth snd_seq_midi_emul snd_seq_virmidi snd_seq_midi_event
>> snd_seq cuse fuse lp uas usb_storage ppdev radeon snd_emu10k1
>> snd_util_mem snd_hwdep snd_rawmidi snd_seq_device snd_ac97_codec snd_pcm
>> ttm snd_timer drm_kms_helper psmouse snd evdev pcspkr serio_raw
>> soundcore i2c_viapro ac97_bus k8temp emu10k1_gp gameport drm
>> i2c_algo_bit asus_atk0110 parport_pc parport button shpchp processor
>> thermal_sys ext4 mbcache crc16 jbd2 sr_mod cdrom ata_generic sg sd_mod
>> eata firewire_ohci firewire_core crc_itu_t ahci libahci via_rhine mii
>> pata_via
>> [62590.596016]  uhci_hcd ehci_pci ehci_hcd usbcore usb_common libata
>> scsi_mod
>> [62590.596016] CPU: 0 PID: 16909 Comm: midori Not tainted 3.19.0-rc3+
>> #1453
>> [62590.596016] Hardware name: System manufacturer System Product
>> Name/A8V-MX, BIOS 0503    12/06/2005
>> [62590.596016] task: f45bd530 ti: e585a000 task.ti: e585a000
>> [62590.596016] EIP: 0060:[<c1157614>] EFLAGS: 00010286 CPU: 0
>> [62590.596016] EIP is at unlink_anon_vmas+0x134/0x1a0
>> [62590.596016] EAX: f3b107c0 EBX: ed2763d4 ECX: 00000018 EDX: e4ac69a0
>> [62590.596016] ESI: ffffffff EDI: ed2763dc EBP: e585bebc ESP: e585bea0
>> [62590.596016]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
>> [62590.596016] CR0: 8005003b CR2: b3cf4054 CR3: 017d7000 CR4: 000007d0
>> [62590.596016] Stack:
>> [62590.596016]  0002d114 ed2763a0 ed2763dc f3b107c0 e2d49f50 ed2763a0
>> a7bee000 e585bee0
>> [62590.596016]  c114bb51 00000000 a7800000 00000000 e585beec e732cf50
>> ea5ef2c0 00000000
>> [62590.596016]  e585bf3c c1154492 00000000 ea5ef2c0 a5c00000 bfaa3000
>> 00000001 e5930000
>> [62590.596016] Call Trace:
>> [62590.596016]  [<c114bb51>] free_pgtables+0x81/0xf0
>> [62590.596016]  [<c1154492>] exit_mmap+0x82/0x120
>> [62590.596016]  [<c104afb3>] mmput+0x43/0xf0
>> [62590.596016]  [<c10501a9>] do_exit+0x259/0xa00
>> [62590.596016]  [<c1286bfa>] ? ___preempt_schedule+0x8/0xe
>> [62590.596016]  [<c10509c2>] do_group_exit+0x32/0x90
>> [62590.596016]  [<c1050a31>] SyS_exit_group+0x11/0x20
>> [62590.596016]  [<c14ceee0>] sysenter_do_call+0x12/0x12
>> [62590.596016] Code: 42 08 00 01 10 00 c7 42 0c 00 02 20 00 e8 b5 1f 01
>> 00 8b 43 08 8d 48 f8 8d 43 08 39 c6 74 38 8b 43 04 89 da 8b 58 4c 85 db
>> 74 bc <0f> 0b 66 90 89 55 f0 e8 40 fe ff ff 8b 55 f0 eb b3 8b 45 e8 c7
>> [62590.596016] EIP: [<c1157614>] unlink_anon_vmas+0x134/0x1a0 SS:ESP
>> 0068:e585bea0
>> [62590.871873] ---[ end trace 03349ef15ff73606 ]---
>> [62590.871881] Fixing recursive fault but reboot is needed!
>>
>> This and other mmamp related problems appear to have surfaced in the
>> Linus' git head kernel in the last few days.
>>
>> I'm happy to supply further information or run tests to help identify
>> the source of the problem.
>
> More likely this is already fixed in v3.19-rc4 by:
> b800c91a0517071156e772d4fb329ad33590da62
> (mm: fix corner case in anon_vma endless growing prevention)
>
> and there is one fix for rare error on error path in linux-mm:
> (mm: fix anon_vma->degree underflow in anon_vma endless growing prevention

Thanks, I haven't seen this problem recently.

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
