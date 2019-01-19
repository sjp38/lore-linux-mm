Return-Path: <SRS0=Ztt1=P3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1B7AC61CE4
	for <linux-mm@archiver.kernel.org>; Sat, 19 Jan 2019 11:32:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 725CA20821
	for <linux-mm@archiver.kernel.org>; Sat, 19 Jan 2019 11:32:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 725CA20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE23B8E0003; Sat, 19 Jan 2019 06:32:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6A108E0002; Sat, 19 Jan 2019 06:32:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5BC98E0003; Sat, 19 Jan 2019 06:32:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 980238E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 06:32:05 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id m128so5965028itd.3
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 03:32:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=IWHW3E/586yQ4o2zLnYO0TwsG10I99V4RUW+P2JvPdI=;
        b=EiGkQ9HeUDskhYS2PTH03B+OjOZgg3XDjIgVKmiREDZVVeVNeSsPrr/ce2B7TBQMOo
         yZGnNUta4Q0tW8B+6U1j+w6d03m0mx846/O7L2h9QWhvlJhUFTHdKOJtREezi2gc7WQC
         5zzglsvw5ez20taezq7OAH8Cy1zFJvlqQ4njmLFGk7/OBJDBkbCod7kItag8IcLH5DVv
         bCNDVJjnyxuiC6AIEIJKsOCV2Glc3grs9kU21tVAhIh5MYiuMDdGC+mEmX2sFz3xpYl2
         YroqcOXIfS+Ofgk+gdh5o4gLaJd2B2LDbchfOryIMXL01arNmBLXLXZMox7DhSCU2YQU
         MuPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3swpdxakbalwu01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3swpDXAkbALwu01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AJcUukfXqIYqtghIK1PHJfwDWRW2R04xVO+av0ALX3kgdPPr780OVBDo
	IZiSNVaLf27d8MnUmObDEApjtbrL3/hHPV0q6AUgihcGwJlZNmqqrPNew4r6kcVtMLO8rTyuiDT
	CY77qhccc/bjmUmGMXcZ6YgutKyoKOE0+K7LijzoNzi3w+hX7cE1vRWsQRvgtylwAACM2Div2fE
	5bDw9GwxijqMpWbF1tNfGbhvBEM9ICNVJtdCQuWJWyN14YHpD4OZnb+ojpsJBGiL1YWtpbafij8
	tSBWlQqb0o34MQmxC4L1MuSVDby7CwBhLTdPMz5OaDvKFGIGTR9XuNf+VHQUwYUZN/4z5TV5Eiy
	60I9GOAccNQZPWhkyi+iKq8E5Jj5SuLnMBMGDDsT7Emx/P/sibtZOcfwWb6SrjS/OljsaPNjhw=
	=
X-Received: by 2002:a24:f30b:: with SMTP id t11mr11338126ith.40.1547897525368;
        Sat, 19 Jan 2019 03:32:05 -0800 (PST)
X-Received: by 2002:a24:f30b:: with SMTP id t11mr11338101ith.40.1547897524267;
        Sat, 19 Jan 2019 03:32:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547897524; cv=none;
        d=google.com; s=arc-20160816;
        b=mWO8XCes3nTM97GZH+nYRs7VFYVR+wGsOPDUAlnTS8kuLtwnyJPgwG8DoFa9xsKtof
         obDXGS9sWbLAkj0CZlL434DIqqZbfWFReT858gcClOsAZVwgWftKNPCsFa+rYl0Z5wTY
         TtrvlJwp+bod2IRAH6smef5IIpzuCKcKeZiHW0Z+fjEdu3gkUnKG59f2OMfRlfp3xPQi
         tuZyBRmOTTlSUTuInRFDoQDI3wY+EG78ehTk7S2/1zfeF0ERGt1EFyZL7rj9OJPdovjI
         PAdzqji7UDz21D1a0i5UA0ZpgFb2KngVMNoJMlDpmgOfDzZUjJstBMxzQ6L+FHFmVFpq
         X4Sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=IWHW3E/586yQ4o2zLnYO0TwsG10I99V4RUW+P2JvPdI=;
        b=KpE/NhZmEkdSg2tnGER1chUcqcp/W0b8HMBOyh0CTyfPEcWpTkW8kV+iUgzQ+r7iMG
         BiLHnNiMhyoaTHpRgQfmr7iZ8sazsCnlIeeqrELkEks8tTzY5ryL5apwKHhJ29cW1Fb+
         qsTwcoKA94JyvZq7FhvYZWbtemlARPDF5ySnkD1HdunbcLFbcajcu3f2E5COx4Z/hYgr
         vVGd3yrzeGiit8FljgraCPUqi+cInAuqZ71GsMR6dDF+SH6FmgW4HMkQ9w6Eq3iC/DM+
         WQqwLHCSaou2b1zNdh1lYEvaIWblhVXO5onIjH/X7nlsFdhHlphVqBs1JDvmmLBJl+p3
         /uLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3swpdxakbalwu01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3swpDXAkbALwu01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id b21sor3428882ios.82.2019.01.19.03.32.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 19 Jan 2019 03:32:04 -0800 (PST)
Received-SPF: pass (google.com: domain of 3swpdxakbalwu01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3swpdxakbalwu01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3swpDXAkbALwu01mcnngtcrrkf.iqqingwugteqpvgpv.eqo@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN7IkJ74rnpEQgQitl4Ol7bIglstA5tVMGAymzN8gJPezGJzZmODNYMLQ2TRF6hkBW9AbP8txslSXNr5Pj/RX8nU6vC5/3Ro
MIME-Version: 1.0
X-Received: by 2002:a5e:df44:: with SMTP id g4mr7868556ioq.0.1547897523973;
 Sat, 19 Jan 2019 03:32:03 -0800 (PST)
Date: Sat, 19 Jan 2019 03:32:03 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000010b2fc057fcdfaba@google.com>
Subject: INFO: rcu detected stall in sys_sendfile64 (2)
From: syzbot <syzbot+1505c80c74256c6118a5@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, amir73il@gmail.com, darrick.wong@oracle.com, 
	david@fromorbit.com, hannes@cmpxchg.org, hughd@google.com, 
	jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	syzkaller-bugs@googlegroups.com, willy@infradead.org
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190119113203.W7zpwFzV6udP6mIjShkQ7-1t4dVuHwsV5pC3pgqe66E@z>

Hello,

syzbot found the following crash on:

HEAD commit:    2339e91d0e66 Merge tag 'media/v5.0-1' of git://git.kernel...
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=175f2638c00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=abc3dc9b7a900258
dashboard link: https://syzkaller.appspot.com/bug?extid=1505c80c74256c6118a5
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12c4dc28c00000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=15df4108c00000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+1505c80c74256c6118a5@syzkaller.appspotmail.com

audit: type=1400 audit(1547895693.874:36): avc:  denied  { map } for   
pid=8427 comm="syz-executor786" path="/root/syz-executor786610373"  
dev="sda1" ino=1426 scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023  
tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=1
hrtimer: interrupt took 42996 ns
rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
rcu: 	(detected by 0, t=10502 jiffies, g=6469, q=3)
rcu: All QSes seen, last rcu_preempt kthread activity 10502  
(4295051508-4295041006), jiffies_till_next_fqs=1, root ->qsmask 0x0
syz-executor786 R  running task    21544  8437   8433 0x00000000
Call Trace:
  <IRQ>
  sched_show_task kernel/sched/core.c:5293 [inline]
  sched_show_task.cold+0x273/0x2d5 kernel/sched/core.c:5268
  print_other_cpu_stall.cold+0x7f2/0x8bb kernel/rcu/tree.c:1301
  check_cpu_stall kernel/rcu/tree.c:1429 [inline]
  rcu_pending kernel/rcu/tree.c:3018 [inline]
  rcu_check_callbacks+0xf36/0x1380 kernel/rcu/tree.c:2521
  update_process_times+0x32/0x80 kernel/time/timer.c:1635
  tick_sched_handle+0xa2/0x190 kernel/time/tick-sched.c:161
  tick_sched_timer+0x47/0x130 kernel/time/tick-sched.c:1271
  __run_hrtimer kernel/time/hrtimer.c:1389 [inline]
  __hrtimer_run_queues+0x3a7/0x1050 kernel/time/hrtimer.c:1451
  hrtimer_interrupt+0x314/0x770 kernel/time/hrtimer.c:1509
  local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1035 [inline]
  smp_apic_timer_interrupt+0x18d/0x760 arch/x86/kernel/apic/apic.c:1060
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
  </IRQ>
RIP: 0010:preempt_count arch/x86/include/asm/preempt.h:26 [inline]
RIP: 0010:check_kcov_mode kernel/kcov.c:67 [inline]
RIP: 0010:write_comp_data+0x9/0x70 kernel/kcov.c:122
Code: 12 00 00 8b 80 dc 12 00 00 48 8b 11 48 83 c2 01 48 39 d0 76 07 48 89  
34 d1 48 89 11 5d c3 0f 1f 00 65 4c 8b 04 25 40 ee 01 00 <65> 8b 05 80 ee  
7f 7e a9 00 01 1f 00 75 51 41 8b 80 d8 12 00 00 83
RSP: 0018:ffff888080466f58 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
RAX: 000000000000226d RBX: ffff888080467140 RCX: ffffffff87f08bdf
RDX: 0000000000000002 RSI: 0000000000000002 RDI: 0000000000000007
RBP: ffff888080466f60 R08: ffff888096338480 R09: ffffed1015cc5b90
R10: ffffed1015cc5b8f R11: ffff8880ae62dc7b R12: 1ffff1101008cdf0
R13: ffff888092b64102 R14: ffff888092b64102 R15: ffff888080467158
  xa_is_node include/linux/xarray.h:946 [inline]
  xas_start+0x1cf/0x720 lib/xarray.c:183
  xas_load+0x21/0x160 lib/xarray.c:227
  find_get_entry+0x350/0x10a0 mm/filemap.c:1476
  pagecache_get_page+0xe6/0x1020 mm/filemap.c:1579
  find_get_page include/linux/pagemap.h:272 [inline]
  generic_file_buffered_read mm/filemap.c:2076 [inline]
  generic_file_read_iter+0x7b2/0x2d40 mm/filemap.c:2350
  ext4_file_read_iter+0x180/0x3c0 fs/ext4/file.c:77
  call_read_iter include/linux/fs.h:1856 [inline]
  generic_file_splice_read+0x5c4/0xa90 fs/splice.c:308
  do_splice_to+0x12a/0x190 fs/splice.c:880
  splice_direct_to_actor+0x31b/0x9d0 fs/splice.c:957
  do_splice_direct+0x2c7/0x420 fs/splice.c:1066
  do_sendfile+0x61a/0xe60 fs/read_write.c:1436
  __do_sys_sendfile64 fs/read_write.c:1491 [inline]
  __se_sys_sendfile64 fs/read_write.c:1483 [inline]
  __x64_sys_sendfile64+0x15a/0x240 fs/read_write.c:1483
  do_syscall_64+0x1a3/0x800 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x446a19
Code: e8 dc e6 ff ff 48 83 c4 18 c3 0f 1f 80 00 00 00 00 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 4b 07 fc ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f53e33cfda8 EFLAGS: 00000297 ORIG_RAX: 0000000000000028
RAX: ffffffffffffffda RBX: 00000000006dcc28 RCX: 0000000000446a19
RDX: 0000000020000380 RSI: 0000000000000003 RDI: 0000000000000003
RBP: 00000000006dcc20 R08: 0000000000000000 R09: 0000000000000000
R10: 00008080fffffffe R11: 0000000000000297 R12: 00000000006dcc2c
R13: 00008080fffffffe R14: 00007f53e33d09c0 R15: 00000000006dcd2c
rcu: rcu_preempt kthread starved for 10502 jiffies! g6469 f0x2  
RCU_GP_WAIT_FQS(5) ->state=0x0 ->cpu=1
rcu: RCU grace-period kthread stack dump:
rcu_preempt     R  running task    26200    10      2 0x80000000
Call Trace:
  context_switch kernel/sched/core.c:2831 [inline]
  __schedule+0x897/0x1e60 kernel/sched/core.c:3472
  schedule+0xfe/0x350 kernel/sched/core.c:3516
  schedule_timeout+0x14a/0x250 kernel/time/timer.c:1803
  rcu_gp_fqs_loop+0x6ba/0x970 kernel/rcu/tree.c:1948
  rcu_gp_kthread+0x2bb/0xc10 kernel/rcu/tree.c:2105
  kthread+0x357/0x430 kernel/kthread.c:246
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
sched: RT throttling activated


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

