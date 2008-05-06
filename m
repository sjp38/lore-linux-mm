From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: bad pmd ffff810000207808(9090909090909090).
Date: Tue, 06 May 2008 21:00:12 +0900
Message-ID: <874p9biqwj.fsf@duaron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I've found today the following error in syslog. It seems have a strange
pattern. And it also happened at a month ago.

Any idea for debuging this?

Thanks.


May  6 07:21:36 duaron kernel: kjournald starting.  Commit interval 5 seconds
May  6 07:21:36 duaron kernel: EXT3 FS on sda2, internal journal
May  6 07:21:36 duaron kernel: EXT3-fs: mounted filesystem with ordered data mode.
May  6 07:21:36 duaron kernel: NET: Registered protocol family 15
May  6 07:21:36 duaron kernel: /devel/linux/works/linux-2.6/mm/memory.c:127: bad pmd ffff810000207808(9090909090909090).
May  6 07:21:36 duaron kernel: r8169: eth0: link up
May  6 07:21:36 duaron kernel: r8169: eth0: link up
May  6 07:21:36 duaron kernel: scsi 4:0:0:0: Direct-Access     USB2.0   CF  Card Reader   9144 PQ: 0 ANSI: 0
May  6 07:21:36 duaron kernel: sd 4:0:0:0: [sdc] Attached SCSI removable disk
May  6 07:21:36 duaron kernel: sd 4:0:0:0: Attached scsi generic sg3 type 0
May  6 07:21:36 duaron kernel: scsi 4:0:0:1: Direct-Access     USB2.0   CBO Card Reader   9144 PQ: 0 ANSI: 0
May  6 07:21:36 duaron kernel: sd 4:0:0:1: [sdd] Attached SCSI removable disk


Apr  9 03:53:40 duaron kernel: scsi 4:0:0:1: Direct-Access     USB2.0   CBO Card Reader   9144 PQ: 0 ANSI: 0
Apr  9 03:53:40 duaron kernel: sd 4:0:0:1: [sdd] Attached SCSI removable disk
Apr  9 03:53:40 duaron kernel: sd 4:0:0:1: Attached scsi generic sg4 type 0
Apr  9 03:53:40 duaron kernel: usb-storage: device scan complete
Apr  9 03:53:40 duaron kernel: NET: Registered protocol family 15
Apr  9 03:53:40 duaron kernel: /devel/linux/works/linux-2.6/mm/memory.c:127: bad pmd ffff810000207208(9090909090909090).
Apr  9 03:53:40 duaron kernel: r8169: eth0: link up
Apr  9 03:53:40 duaron kernel: r8169: eth0: link up
Apr  9 03:53:40 duaron kernel: RPC: Registered udp transport module.
Apr  9 03:53:40 duaron kernel: RPC: Registered tcp transport module.
Apr  9 03:53:40 duaron kernel: NET: Registered protocol family 10
Apr  9 03:53:40 duaron kernel: lo: Disabled Privacy Extensions
Apr  9 03:53:42 duaron kernel: p4-clockmod: P4/Xeon(TM) CPU On-Demand Clock Modulation available
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
