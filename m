Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60BF5C0650F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:53:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF21A205F4
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:52:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF21A205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CFB36B000A; Wed, 14 Aug 2019 04:52:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 880796B000D; Wed, 14 Aug 2019 04:52:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78D426B000E; Wed, 14 Aug 2019 04:52:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0215.hostedemail.com [216.40.44.215])
	by kanga.kvack.org (Postfix) with ESMTP id 53C476B000A
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 04:52:57 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E27A8180AD7C1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:52:56 +0000 (UTC)
X-FDA: 75820418352.20.girls57_70db2bbea765c
X-HE-Tag: girls57_70db2bbea765c
X-Filterd-Recvd-Size: 4803
Received: from mail3-165.sinamail.sina.com.cn (mail3-165.sinamail.sina.com.cn [202.108.3.165])
	by imf31.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:52:55 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([221.219.6.224])
	by sina.com with ESMTP
	id 5D53CBD9000310C2; Wed, 14 Aug 2019 16:52:50 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 759594701579
From: Hillf Danton <hdanton@sina.com>
To: syzbot <syzbot+0265846a0cb9a0547905@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org,
	baijiaju1990@gmail.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	mhocko@suse.com,
	rppt@linux.ibm.com,
	syzkaller-bugs@googlegroups.com,
	willy@infradead.org
Subject: Re: memory leak in bio_clone_fast
Date: Wed, 14 Aug 2019 16:52:30 +0800
Message-Id: <20190814085230.5772-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 13 Aug 2019 14:08:06 -0700
> Hello,
>=20
> syzbot found the following crash on:
>=20
> HEAD commit:    d45331b0 Linux 5.3-rc4
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=3D1651e6d2600=
000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=3D6c5e70dcab5=
7c6af
> dashboard link: https://syzkaller.appspot.com/bug?extid=3D0265846a0cb9a=
0547905
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=3D12c9c3366=
00000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=3D1766156a600=
000
>=20
> IMPORTANT: if you fix the bug, please add the following tag to the comm=
it:
> Reported-by: syzbot+0265846a0cb9a0547905@syzkaller.appspotmail.com
>=20
> executing program
> executing program
> executing program
> executing program
> BUG: memory leak
> unreferenced object 0xffff8881226da6c0 (size 192):
>    comm "syz-executor332", pid 6977, jiffies 4294941214 (age 15.840s)
>    hex dump (first 32 bytes):
>      00 00 00 00 00 00 00 00 00 f0 bc 28 81 88 ff ff  ...........(....
>      01 c8 60 00 02 0b 00 00 00 00 00 00 00 00 00 00  ..`.............
>    backtrace:
>      [<00000000b06a638e>] kmemleak_alloc_recursive  include/linux/kmeml=
eak.h:43 [inline]
>      [<00000000b06a638e>] slab_post_alloc_hook mm/slab.h:522 [inline]
>      [<00000000b06a638e>] slab_alloc mm/slab.c:3319 [inline]
>      [<00000000b06a638e>] kmem_cache_alloc+0x13f/0x2c0 mm/slab.c:3483
>      [<00000000950a289d>] mempool_alloc_slab+0x1e/0x30 mm/mempool.c:513
>      [<00000000bfcc27e2>] mempool_alloc+0x64/0x1b0 mm/mempool.c:393
>      [<00000000cdf95a4a>] bio_alloc_bioset+0x180/0x2c0 block/bio.c:477
>      [<00000000b239bb68>] bio_clone_fast+0x25/0x90 block/bio.c:609
>      [<000000005d58c2dc>] bio_split+0x4a/0xd0 block/bio.c:1856
>      [<00000000ab943734>] blk_bio_segment_split block/blk-merge.c:250  =
[inline]
>      [<00000000ab943734>] __blk_queue_split+0x355/0x730 block/blk-merge=
.c:272
>      [<00000000e702c0ac>] blk_mq_make_request+0xb0/0x890 block/blk-mq.c=
:1943
>      [<000000003c89773a>] generic_make_request block/blk-core.c:1052 [i=
nline]
>      [<000000003c89773a>] generic_make_request+0xf6/0x4a0   block/blk-c=
ore.c:994
>      [<00000000a4dcaf78>] submit_bio+0x5a/0x1e0 block/blk-core.c:1163
>      [<000000003e1ce7f8>] __blkdev_direct_IO fs/block_dev.c:459 [inline=
]
>      [<000000003e1ce7f8>] blkdev_direct_IO+0x2b3/0x6d0 fs/block_dev.c:5=
15
>      [<0000000087ec76a4>] generic_file_direct_write+0xb0/0x1a0   mm/fil=
emap.c:3230
>      [<00000000ff259b44>] __generic_file_write_iter+0xec/0x230   mm/fil=
emap.c:3413
>      [<00000000223d9b6c>] blkdev_write_iter fs/block_dev.c:2026 [inline=
]
>      [<00000000223d9b6c>] blkdev_write_iter+0xbe/0x160 fs/block_dev.c:2=
003
>      [<000000003c4a5c94>] call_write_iter include/linux/fs.h:1870 [inli=
ne]
>      [<000000003c4a5c94>] aio_write+0x10b/0x1d0 fs/aio.c:1583
>      [<00000000581f0c84>] __io_submit_one fs/aio.c:1815 [inline]
>      [<00000000581f0c84>] io_submit_one+0x59b/0xe50 fs/aio.c:1862

1, add BLK_QC_T_EAGAIN

--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1004,7 +1004,8 @@ blk_qc_t generic_make_request(struct bio
 	blk_qc_t ret =3D BLK_QC_T_NONE;
=20
 	if (!generic_make_request_checks(bio))
-		goto out;
+		/* feed error back to __blkdev_direct_IO fs/block_dev.c:459 */
+		return BLK_QC_T_EAGAIN;
=20
 	/*
 	 * We only want one ->make_request_fn to be active at a time, else
--

2, plan-B, check status if BLK_QC_T_EAGAIN is bad

--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -461,7 +461,7 @@ __blkdev_direct_IO(struct kiocb *iocb, s
 		}
=20
 		qc =3D submit_bio(bio);
-		if (qc =3D=3D BLK_QC_T_EAGAIN) {
+		if (qc =3D=3D BLK_QC_T_EAGAIN || bio->bi_status) {
 			if (!ret)
 				ret =3D -EAGAIN;
 			goto error;
--


