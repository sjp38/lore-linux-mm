Received: from mailrelay2.lanl.gov (localhost.localdomain [127.0.0.1])
	by mailwasher-b.lanl.gov (8.12.10/8.12.10/(ccn-5)) with ESMTP id i16M4PHR021722
	for <linux-mm@kvack.org>; Fri, 6 Feb 2004 15:04:26 -0700
Subject: 2.6.2-mm1 problem with umounting reiserfs
From: Steven Cole <elenstev@mesatop.com>
Content-Type: text/plain
Message-Id: <1076104945.1793.12.camel@spc.esa.lanl.gov>
Mime-Version: 1.0
Date: Fri, 06 Feb 2004 15:02:25 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

With kernel 2.6.2-mm1, I got the following when umounting a reiserfs
file system.  I did not get this with 2.6.2-rc2-mm1 or stock kernel.
Base distro is Mandrake 10.0 beta2. System is UP PIII.

Steven

[root@spc1 steven]# df -T
Filesystem    Type    Size  Used Avail Use% Mounted on
/dev/hda1     ext3    236M   79M  145M  36% /
/dev/hda9     ext3     20G   16G  4.2G  79% /home
/dev/hda10
          reiserfs    4.0G  1.9G  2.1G  47% /share_r
/dev/hda8     ext3    236M  4.1M  220M   2% /tmp
/dev/hda6     ext3    2.9G  2.1G  737M  74% /usr
/dev/hda7     ext3    479M  198M  257M  44% /var
[root@spc1 steven]# umount /dev/hda10
Segmentation fault
[root@spc1 steven]# dmesg | tail --lines 40
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda6, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda7, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
atkbd.c: Unknown key released (translated set 2, code 0x7a on isa0060/serio0).
atkbd.c: This is an XFree86 bug. It shouldn't access hardware directly.
atkbd.c: Unknown key released (translated set 2, code 0x7a on isa0060/serio0).
atkbd.c: This is an XFree86 bug. It shouldn't access hardware directly.
Unable to handle kernel NULL pointer dereference at virtual address 00000000
 printing eip:
c012a7b2
*pde = 00000000
Oops: 0000 [#1]
PREEMPT
CPU:    0
EIP:    0060:[<c012a7b2>]    Not tainted VLI
EFLAGS: 00210202
EIP is at destroy_workqueue+0x72/0xe0
eax: 00000001   ebx: ca55e000   ecx: cfca3364   edx: 00000000
esi: cfca3360   edi: cfca3320   ebp: cf926670   esp: ca55fe90
ds: 007b   es: 007b   ss: 0068
Process umount (pid: 1743, threadinfo=ca55e000 task=cd6e5940)
Stack: cf926670 00000001 ca55feb8 cfca1200 c04573c0 ca55ff74 c01acc9d cfca3320
       cfca1200 cf84d688 c040e963 00000001 00000001 00005c46 cfca1200 cf446d78
       ca55fef0 cfca1200 00000000 cfca1200 c019a655 ca55fef0 cfca1200 cf84d688
Call Trace:
 [<c01acc9d>] do_journal_release+0x4d/0xe0
 [<c019a655>] reiserfs_put_super+0x25/0x180
 [<c0154447>] generic_shutdown_super+0x177/0x1e0
 [<c01544cd>] kill_block_super+0x1d/0x50
 [<c01545df>] deactivate_super+0x5f/0xc0
 [<c016b2cb>] sys_umount+0x4b/0x2f0
 [<c0141226>] do_munmap+0x296/0x3c0
 [<c016b585>] sys_oldumount+0x15/0x19
 [<c03f40d2>] sysenter_past_esp+0x43/0x65

Code: ff 4b 14 8b 43 08 a8 08 75 7d 85 ed 74 08 89 2c 24 e8 63 32 00 00 ff 44 24 04 83 c6 40 8b 44 24 04 85 c0 7e c1 8d 4f 44 8b 51 04 <39> 0a 75 4e 8b 47 44 39 48 04 75 3c 89 50 04 89 02 c7 41 04 00


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
