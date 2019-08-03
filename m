Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C3E5C31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 13:24:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 266472075C
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 13:24:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Wbb+yHp4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 266472075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EAAB6B0006; Sat,  3 Aug 2019 09:24:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89A5D6B0008; Sat,  3 Aug 2019 09:24:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 787E26B000A; Sat,  3 Aug 2019 09:24:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC8E6B0006
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 09:24:02 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id g68so30510883vkb.1
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 06:24:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=XRknL6gLsu0CLHkKHaKrKviVONrEjXZLcmQ3mksL63s=;
        b=b/5NYctvvw18db8U3DaF0CcLM7EUmNxODsiwN4ylv67Zb0ucbjSZkk7ISPexJrA4Bm
         wJLF/jTcobOOogxElPl42csth/oxJTNCMFyoycs+USw40ZiYi4FXDCaSUA1dvYVO3gMY
         SQPkl6SVhNPW+j4SegR9vIbMGwr6AlrxVdHwr1E0mp4EMR/L3JQ6A4sWQ4fpMAs2OPe+
         3EYFfzyu8S6lXiqcPkQ8Xs6jHAzrApOJhKl4ThU6Hie9KVpPMQWToB6a4Rg3YI+QFP+U
         kBN6FVTolhJa9hZ3gYOIJ55K5A4Jza1dFpPKe71sudYylcWoUik7qtCgHWv3lMIYe3F4
         AwVg==
X-Gm-Message-State: APjAAAXC3ytwI1yADstnjYSs8kPMWvJGuhx904jtiSE+QxPaRAU3pLI1
	YKfeGuQKVs/cUDpgGcId2Ni3GWKJzRbUTZ+pTeUTvYE7vx/xY62rw1r9jTrJVRsq/zECKda2EH7
	PpNSO5dVyYinvuvYiDg5RZ2Wk9JswGM5iGEjKY8AFO4J/S5qNg8CGCSgPzFqyFxx6BQ==
X-Received: by 2002:ab0:20d8:: with SMTP id z24mr55217330ual.1.1564838641913;
        Sat, 03 Aug 2019 06:24:01 -0700 (PDT)
X-Received: by 2002:ab0:20d8:: with SMTP id z24mr55217274ual.1.1564838640662;
        Sat, 03 Aug 2019 06:24:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564838640; cv=none;
        d=google.com; s=arc-20160816;
        b=bhtLWyVZC8g4v50HrbaTVcWGMTH5mjCEyEGdJk0q2CAlHoY7DHhB8xtYyGdSmaH/zT
         aNJgjBBGQiDRNKZCpqdJ19YkQxn5jm295zwVQeww9rJr6mg2hLVUPJDgr/aISTUCizRX
         6fcbMi3EvGl/jFCipXc1slY1MhX5ydDZ4FHoP3Wi0e/iWD6nk4Y5ZUslikVrfDbVvExy
         txAniXlFlG9wK5ae8ca9uTX/E7goi1XBVN6N4/8fbei31OAwPRWLF9/JjoHk0l96IUkg
         33/6NUVIIAZ5OXXEI+TagA5m2fe6B9RdZL9WiE7OXmmgEzuwTRQeVCCSYauJv1JYKgH7
         hBWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=XRknL6gLsu0CLHkKHaKrKviVONrEjXZLcmQ3mksL63s=;
        b=MukHq7KByVXAyKIhmuKfnsvKPLOerMnKjM6M7WnBh7Zeh5LXzWbrqhnHvB5cMqxyav
         0TRGIsgv74H/nY96JZyNVb7mFaAVGK++5GcrKkZ2KKJfzXqNtxJ4UQdIjwIvI9JV7ac2
         j+BJIgtiwfxtx57dY/LOs1uuswkenBQDOJwCXuzZ9TeLKJ3GqQWZbC4XLv8M2dBWkDzc
         MbLNpsOus/QbZB1PWQWGqkkNrn+MgZcnSkGSbZKj21jjqAfVhlrdjLDoM3KQcLQXwMwX
         wBEHj+vRgwwh2ZdkonipycX07rnGuX2sGQrk/uXrbSN8eMlIrsN+PjdCQm1ioDXxFBs3
         fGLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Wbb+yHp4;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s13sor40696496vsj.55.2019.08.03.06.24.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Aug 2019 06:24:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Wbb+yHp4;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=XRknL6gLsu0CLHkKHaKrKviVONrEjXZLcmQ3mksL63s=;
        b=Wbb+yHp4or2bB3RKikmazO7TFS1lnw3OofzAISbEjVdI9MMhvaDuj/hRWaPHvSOjj5
         ZsOY4I8KsxJpNznlyNuImbYoHUOR95/oI5633Q+1xUVwIAyNR2lyOEF7yFouW2RJGZz1
         YJ3F85oiIGskFmU/V5Jp7/rMnmbkYtCsSmMEfn4Clc6VR8Vr1DB4T/TYbTbRv4+4qyIi
         evoVrgDIHj+XDmzS0LsU/g8VoY9JSIWEy+klQFCWS9wrbMeVKxxvBZPu0AMpQ7rhwgcM
         jTkeI+QwOjIeuKdTqw6tsEjEIF3tBynXFb3Drfo7F5JI7QZdPZug3rIBLmdYQj3pM5W0
         zapQ==
X-Google-Smtp-Source: APXvYqyS1mD54WpWG+O39IJCcMXk3wXFjNEn74idqUQiN05w5v+UhgHHtQhokjDEAVxoIVQa1wfgY70gwNtFULUj6+I=
X-Received: by 2002:a67:d894:: with SMTP id f20mr92418638vsj.55.1564838640036;
 Sat, 03 Aug 2019 06:24:00 -0700 (PDT)
MIME-Version: 1.0
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Sat, 3 Aug 2019 18:53:50 +0530
Message-ID: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
Subject: oom-killer
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: pankaj.suryawanshi@einfochips.com
Content-Type: multipart/alternative; boundary="000000000000452ec5058f3663e2"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000452ec5058f3663e2
Content-Type: text/plain; charset="UTF-8"

Hello,

Below are the logs from oom-kller. I am not able to interpret/decode the
logs as well as not able to find root cause of oom-killer.

Note: CPU Arch: Arm 32-bit , Kernel - 4.14.65

[  727.941258] kworker/u8:2 invoked oom-killer:
gfp_mask=0x15080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO), nodemask=(null),
 order=1, oom_score_adj=0
[  727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P           O
 4.14.65 #606
[  727.962450] Hardware name: Android (Flattened Device Tree)
[  727.968812] Workqueue: events_unbound call_usermodehelper_exec_work
[  727.975076] Backtrace:
[  727.977528] [<c020dbec>] (dump_backtrace) from [<c020ded4>]
(show_stack+0x18/0x1c)
[  727.985096]  r6:600f0113 r5:c141c0dc r4:00000000 r3:cf08b34d
[  727.990755] [<c020debc>] (show_stack) from [<c0ba8cf0>]
(dump_stack+0x94/0xa8)
[  727.997979] [<c0ba8c5c>] (dump_stack) from [<c034b284>]
(dump_header+0xa0/0x20c)
[  728.005372]  r6:dd347d7c r5:dd347d7c r4:d5737080 r3:cf08b34d
[  728.011030] [<c034b1e4>] (dump_header) from [<c034a4b8>]
(oom_kill_process+0x424/0x534)
[  728.019033]  r10:00000001 r9:c12169bc r8:00000392 r7:c0e08d5c
r6:dd347d7c r5:d5737080
[  728.026856]  r4:d57375f8
[  728.029390] [<c034a094>] (oom_kill_process) from [<c034af24>]
(out_of_memory+0x140/0x368)
[  728.037569]  r10:00000001 r9:c12169bc r8:00000041 r7:c121e680
r6:c1216588 r5:dd347d7c
[  728.045392]  r4:d5737080
[  728.047929] [<c034ade4>] (out_of_memory) from [<c03519ac>]
(__alloc_pages_nodemask+0x1178/0x124c)
[  728.056798]  r7:c141e7d0 r6:c12166a4 r5:00000000 r4:00001155
[  728.062460] [<c0350834>] (__alloc_pages_nodemask) from [<c021e9d4>]
(copy_process.part.5+0x114/0x1a28)
[  728.071764]  r10:00000000 r9:dd358000 r8:00000000 r7:c1447e08
r6:c1216588 r5:00808111
[  728.079587]  r4:d1063c00
[  728.082119] [<c021e8c0>] (copy_process.part.5) from [<c0220470>]
(_do_fork+0xd0/0x464)
[  728.090034]  r10:00000000 r9:00000000 r8:dd008400 r7:00000000
r6:c1216588 r5:d2d58ac0
[  728.097857]  r4:00808111
[  728.100388] [<c02203a0>] (_do_fork) from [<c0220864>]
(kernel_thread+0x38/0x40)
[  728.107696]  r10:00000000 r9:c1422594 r8:dd008400 r7:00000000
r6:dd004500 r5:d2d58ac0
[  728.115519]  r4:c1216588
[  728.118055] [<c022082c>] (kernel_thread) from [<c0239a74>]
(call_usermodehelper_exec_work+0x44/0xe0)
[  728.127188] [<c0239a30>] (call_usermodehelper_exec_work) from
[<c023d088>] (process_one_work+0x154/0x518)
[  728.136756]  r5:d2d58ac0 r4:dd234100
[  728.140335] [<c023cf34>] (process_one_work) from [<c023d4a4>]
(worker_thread+0x58/0x56c)
[  728.148424]  r10:00000088 r9:dd234100 r8:dd234118 r7:c120f900
r6:dd346038 r5:dd008424
[  728.156247]  r4:dd008400
[  728.158780] [<c023d44c>] (worker_thread) from [<c0244198>]
(kthread+0x134/0x164)
[  728.166174]  r10:dd233e68 r9:dd2341a8 r8:c023d44c r7:dd234100
r6:dd236280 r5:00000000
[  728.173997]  r4:dd234180
[  728.176531] [<c0244064>] (kthread) from [<c0209258>]
(ret_from_fork+0x14/0x3c)
[  728.183752]  r10:00000000 r9:00000000 r8:00000000 r7:00000000
r6:00000000 r5:c0244064
[  728.191575]  r4:dd236280 r3:00000000
[  728.199092] Mem-Info:
[  728.201407] active_anon:97307 inactive_anon:124 isolated_anon:0
[  728.201407]  active_file:583 inactive_file:575 isolated_file:64
[  728.201407]  unevictable:638 dirty:0 writeback:0 unstable:0
[  728.201407]  slab_reclaimable:4681 slab_unreclaimable:7808
[  728.201407]  mapped:1656 shmem:182 pagetables:4482 bounce:0
[  728.201407]  free:143605 free_pcp:230 free_cma:139244
[  728.235525] Node 0 active_anon:389228kB inactive_anon:496kB
active_file:2072kB inactive_file:2456kB unevictable:2552kB
isolated(anon):0kB isolated(file):0kB mapped:5984kB dirty:0kB writeback:0kB
shmem:728kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  728.260031] DMA free:17960kB min:16384kB low:25664kB high:29760kB
active_anon:3556kB inactive_anon:0kB active_file:280kB inactive_file:28kB
unevictable:0kB writepending:0kB present:458752kB managed:422896kB
mlocked:0kB kernel_stack:6496kB pagetables:9904kB bounce:0kB free_pcp:348kB
local_pcp:0kB free_cma:0kB
[  728.287402] lowmem_reserve[]: 0 0 579 579
[  728.292470] HighMem free:553472kB min:512kB low:34024kB high:48808kB
active_anon:385672kB inactive_anon:496kB active_file:1820kB
inactive_file:5284kB unevictable:2552kB writepending:0kB present:1526784kB
managed:1526784kB mlocked:2552kB kernel_stack:0kB pagetables:7272kB
bounce:0kB free_pcp:324kB local_pcp:0kB free_cma:553588kB
[  728.322946] lowmem_reserve[]: 0 0 0 0
[  728.326634] DMA: 71*4kB (EH) 113*8kB (UH) 207*16kB (UMH) 103*32kB (UMH)
70*64kB (UMH) 27*128kB (UMH) 5*256kB (UMH) 1*512kB (H) 0*1024kB 0*2048kB
0*4096kB 0*8192kB 0*16384kB = 17524kB
[  728.344398] HighMem: 8121*4kB (C) 7772*8kB (C) 4391*16kB (C) 2354*32kB
(C) 1335*64kB (C) 514*128kB (C) 162*256kB (C) 76*512kB (C) 27*1024kB (C)
12*2048kB (C) 2*4096kB (C) 2*8192kB (C) 0*16384kB = 548660kB
[  728.364376] 3561 total pagecache pages
[  728.368825] 0 pages in swap cache
[  728.372226] Swap cache stats: add 0, delete 0, find 0/0
[  728.379273] Free swap  = 0kB
[  728.382256] Total swap = 0kB
[  728.385418] 496384 pages RAM
[  728.388337] 381696 pages HighMem/MovableOnly
[  728.393901] 8964 pages reserved
[  728.397087] 233472 pages cma reserved


I have sufficient memory is available as per logs, and in logs it requires
order = 1 ?
Then why oom-killer triggered ?

What is  71*4kB (EH) , (UMH) , (UH) and (C) ?

Regards,
Pankaj

--000000000000452ec5058f3663e2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello,<br><br>Below are the logs from oom-kller. I am not =
able to interpret/decode the logs as well as not able to find root cause of=
 oom-killer.<br><br>Note: CPU Arch: Arm 32-bit , Kernel - 4.14.65<br><br>[ =
=C2=A0727.941258] kworker/u8:2 invoked oom-killer: gfp_mask=3D0x15080c0(GFP=
_KERNEL_ACCOUNT|__GFP_ZERO), nodemask=3D(null), =C2=A0order=3D1, oom_score_=
adj=3D0<br>[ =C2=A0727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 O =C2=A0 =C2=A04.14.65 #606<br>[ =C2=A0=
727.962450] Hardware name: Android (Flattened Device Tree)<br>[ =C2=A0727.9=
68812] Workqueue: events_unbound call_usermodehelper_exec_work<br>[ =C2=A07=
27.975076] Backtrace:<br>[ =C2=A0727.977528] [&lt;c020dbec&gt;] (dump_backt=
race) from [&lt;c020ded4&gt;] (show_stack+0x18/0x1c)<br>[ =C2=A0727.985096]=
 =C2=A0r6:600f0113 r5:c141c0dc r4:00000000 r3:cf08b34d<br>[ =C2=A0727.99075=
5] [&lt;c020debc&gt;] (show_stack) from [&lt;c0ba8cf0&gt;] (dump_stack+0x94=
/0xa8)<br>[ =C2=A0727.997979] [&lt;c0ba8c5c&gt;] (dump_stack) from [&lt;c03=
4b284&gt;] (dump_header+0xa0/0x20c)<br>[ =C2=A0728.005372] =C2=A0r6:dd347d7=
c r5:dd347d7c r4:d5737080 r3:cf08b34d<br>[ =C2=A0728.011030] [&lt;c034b1e4&=
gt;] (dump_header) from [&lt;c034a4b8&gt;] (oom_kill_process+0x424/0x534)<b=
r>[ =C2=A0728.019033] =C2=A0r10:00000001 r9:c12169bc r8:00000392 r7:c0e08d5=
c r6:dd347d7c r5:d5737080<br>[ =C2=A0728.026856] =C2=A0r4:d57375f8<br>[ =C2=
=A0728.029390] [&lt;c034a094&gt;] (oom_kill_process) from [&lt;c034af24&gt;=
] (out_of_memory+0x140/0x368)<br>[ =C2=A0728.037569] =C2=A0r10:00000001 r9:=
c12169bc r8:00000041 r7:c121e680 r6:c1216588 r5:dd347d7c<br>[ =C2=A0728.045=
392] =C2=A0r4:d5737080<br>[ =C2=A0728.047929] [&lt;c034ade4&gt;] (out_of_me=
mory) from [&lt;c03519ac&gt;] (__alloc_pages_nodemask+0x1178/0x124c)<br>[ =
=C2=A0728.056798] =C2=A0r7:c141e7d0 r6:c12166a4 r5:00000000 r4:00001155<br>=
[ =C2=A0728.062460] [&lt;c0350834&gt;] (__alloc_pages_nodemask) from [&lt;c=
021e9d4&gt;] (copy_process.part.5+0x114/0x1a28)<br>[ =C2=A0728.071764] =C2=
=A0r10:00000000 r9:dd358000 r8:00000000 r7:c1447e08 r6:c1216588 r5:00808111=
<br>[ =C2=A0728.079587] =C2=A0r4:d1063c00<br>[ =C2=A0728.082119] [&lt;c021e=
8c0&gt;] (copy_process.part.5) from [&lt;c0220470&gt;] (_do_fork+0xd0/0x464=
)<br>[ =C2=A0728.090034] =C2=A0r10:00000000 r9:00000000 r8:dd008400 r7:0000=
0000 r6:c1216588 r5:d2d58ac0<br>[ =C2=A0728.097857] =C2=A0r4:00808111<br>[ =
=C2=A0728.100388] [&lt;c02203a0&gt;] (_do_fork) from [&lt;c0220864&gt;] (ke=
rnel_thread+0x38/0x40)<br>[ =C2=A0728.107696] =C2=A0r10:00000000 r9:c142259=
4 r8:dd008400 r7:00000000 r6:dd004500 r5:d2d58ac0<br>[ =C2=A0728.115519] =
=C2=A0r4:c1216588<br>[ =C2=A0728.118055] [&lt;c022082c&gt;] (kernel_thread)=
 from [&lt;c0239a74&gt;] (call_usermodehelper_exec_work+0x44/0xe0)<br>[ =C2=
=A0728.127188] [&lt;c0239a30&gt;] (call_usermodehelper_exec_work) from [&lt=
;c023d088&gt;] (process_one_work+0x154/0x518)<br>[ =C2=A0728.136756] =C2=A0=
r5:d2d58ac0 r4:dd234100<br>[ =C2=A0728.140335] [&lt;c023cf34&gt;] (process_=
one_work) from [&lt;c023d4a4&gt;] (worker_thread+0x58/0x56c)<br>[ =C2=A0728=
.148424] =C2=A0r10:00000088 r9:dd234100 r8:dd234118 r7:c120f900 r6:dd346038=
 r5:dd008424<br>[ =C2=A0728.156247] =C2=A0r4:dd008400<br>[ =C2=A0728.158780=
] [&lt;c023d44c&gt;] (worker_thread) from [&lt;c0244198&gt;] (kthread+0x134=
/0x164)<br>[ =C2=A0728.166174] =C2=A0r10:dd233e68 r9:dd2341a8 r8:c023d44c r=
7:dd234100 r6:dd236280 r5:00000000<br>[ =C2=A0728.173997] =C2=A0r4:dd234180=
<br>[ =C2=A0728.176531] [&lt;c0244064&gt;] (kthread) from [&lt;c0209258&gt;=
] (ret_from_fork+0x14/0x3c)<br>[ =C2=A0728.183752] =C2=A0r10:00000000 r9:00=
000000 r8:00000000 r7:00000000 r6:00000000 r5:c0244064<br>[ =C2=A0728.19157=
5] =C2=A0r4:dd236280 r3:00000000<br>[ =C2=A0728.199092] Mem-Info:<br>[ =C2=
=A0728.201407] active_anon:97307 inactive_anon:124 isolated_anon:0<br>[ =C2=
=A0728.201407] =C2=A0active_file:583 inactive_file:575 isolated_file:64<br>=
[ =C2=A0728.201407] =C2=A0unevictable:638 dirty:0 writeback:0 unstable:0<br=
>[ =C2=A0728.201407] =C2=A0slab_reclaimable:4681 slab_unreclaimable:7808<br=
>[ =C2=A0728.201407] =C2=A0mapped:1656 shmem:182 pagetables:4482 bounce:0<b=
r>[ =C2=A0728.201407] =C2=A0free:143605 free_pcp:230 free_cma:139244<br>[ =
=C2=A0728.235525] Node 0 active_anon:389228kB inactive_anon:496kB active_fi=
le:2072kB inactive_file:2456kB unevictable:2552kB isolated(anon):0kB isolat=
ed(file):0kB mapped:5984kB dirty:0kB writeback:0kB shmem:728kB writeback_tm=
p:0kB unstable:0kB all_unreclaimable? no<br>[ =C2=A0728.260031] DMA free:17=
960kB min:16384kB low:25664kB high:29760kB active_anon:3556kB inactive_anon=
:0kB active_file:280kB inactive_file:28kB unevictable:0kB writepending:0kB =
present:458752kB managed:422896kB mlocked:0kB kernel_stack:6496kB pagetable=
s:9904kB bounce:0kB free_pcp:348kB local_pcp:0kB free_cma:0kB<br>[ =C2=A072=
8.287402] lowmem_reserve[]: 0 0 579 579<br>[ =C2=A0728.292470] HighMem free=
:553472kB min:512kB low:34024kB high:48808kB active_anon:385672kB inactive_=
anon:496kB active_file:1820kB inactive_file:5284kB unevictable:2552kB write=
pending:0kB present:1526784kB managed:1526784kB mlocked:2552kB kernel_stack=
:0kB pagetables:7272kB bounce:0kB free_pcp:324kB local_pcp:0kB free_cma:553=
588kB<br>[ =C2=A0728.322946] lowmem_reserve[]: 0 0 0 0<br>[ =C2=A0728.32663=
4] DMA: 71*4kB (EH) 113*8kB (UH) 207*16kB (UMH) 103*32kB (UMH) 70*64kB (UMH=
) 27*128kB (UMH) 5*256kB (UMH) 1*512kB (H) 0*1024kB 0*2048kB 0*4096kB 0*819=
2kB 0*16384kB =3D 17524kB<br>[ =C2=A0728.344398] HighMem: 8121*4kB (C) 7772=
*8kB (C) 4391*16kB (C) 2354*32kB (C) 1335*64kB (C) 514*128kB (C) 162*256kB =
(C) 76*512kB (C) 27*1024kB (C) 12*2048kB (C) 2*4096kB (C) 2*8192kB (C) 0*16=
384kB =3D 548660kB<br>[ =C2=A0728.364376] 3561 total pagecache pages<br>[ =
=C2=A0728.368825] 0 pages in swap cache<br>[ =C2=A0728.372226] Swap cache s=
tats: add 0, delete 0, find 0/0<br>[ =C2=A0728.379273] Free swap =C2=A0=3D =
0kB<br>[ =C2=A0728.382256] Total swap =3D 0kB<br>[ =C2=A0728.385418] 496384=
 pages RAM<br>[ =C2=A0728.388337] 381696 pages HighMem/MovableOnly<br>[ =C2=
=A0728.393901] 8964 pages reserved<br>[ =C2=A0728.397087] 233472 pages cma =
reserved<br><br><br>I have sufficient memory is available as per logs, and =
in logs it requires order =3D 1 ?<br>Then why oom-killer triggered ?<br><br=
>What is =C2=A071*4kB (EH) , (UMH) , (UH) and (C) ?<div><br></div><div>Rega=
rds,</div><div>Pankaj<br><div><br></div><div><br></div></div></div>

--000000000000452ec5058f3663e2--

