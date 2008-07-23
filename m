Received: by mu-out-0910.google.com with SMTP id i2so4428196mue.6
        for <linux-mm@kvack.org>; Wed, 23 Jul 2008 02:33:50 -0700 (PDT)
Message-ID: <4886FA7C.8060809@gmail.com>
Date: Wed, 23 Jul 2008 11:31:40 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: WARNING: at arch/x86/mm/pageattr.c:591 __change_page_attr_set_clr
 [mmotm]
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Hi,

mmotm 2008-07-15-15-39 while booting:

EXT3 FS on dm-0, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
------------[ cut here ]------------
WARNING: at arch/x86/mm/pageattr.c:591 __change_page_attr_set_clr+0x627/0x990()
CPA: called for zero pte. vaddr = ffff88007d5b0000 cpa->vaddr = ffff88007d5b0000
Modules linked in: arc4 ecb crypto_blkcipher cryptomgr crypto_algapi ath5k 
mac80211 led_class ohci1394 usbhid rtc_cmos hid cfg80211 ieee1394 floppy evdev 
ff_memless [last unloaded: freq_table]
Pid: 2024, comm: acpidump Not tainted 2.6.26-mm1_64 #1

Call Trace:
  [<ffffffff80238d27>] warn_slowpath+0xb7/0xf0
  [<ffffffff80280b00>] ? filemap_fault+0x240/0x440
  [<ffffffff802a8bc5>] ? check_object+0x255/0x260
  [<ffffffff802a8410>] ? init_object+0x50/0x90
  [<ffffffff802a8410>] ? init_object+0x50/0x90
  [<ffffffff802c3b3c>] ? d_free+0x6c/0x80
  [<ffffffff802c50f1>] ? __d_lookup+0xb1/0x150
  [<ffffffff80225517>] __change_page_attr_set_clr+0x627/0x990
  [<ffffffff802b910d>] ? permission+0xbd/0x140
  [<ffffffff802a8bc5>] ? check_object+0x255/0x260
  [<ffffffff802a8410>] ? init_object+0x50/0x90
  [<ffffffff80225922>] change_page_attr_set_clr+0xa2/0x1f0
  [<ffffffff80225c43>] _set_memory_uc+0x13/0x20
  [<ffffffff8022466d>] ioremap_change_attr+0x2d/0x50
  [<ffffffff80226ad6>] phys_mem_access_prot_allowed+0x146/0x1d0
  [<ffffffff8039d975>] mmap_mem+0x35/0xb0
  [<ffffffff802998de>] mmap_region+0x21e/0x5d0
  [<ffffffff80299f24>] do_mmap_pgoff+0x294/0x390
  [<ffffffff80211256>] sys_mmap+0x106/0x130
  [<ffffffff8020c4db>] system_call_after_swapgs+0x7b/0x80

---[ end trace 34f56e4f17f94b6d ]---
acpidump:2024 /dev/mem ioremap_change_attr failed uncached-minus for 
7d5b0000-7d5b1000

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
