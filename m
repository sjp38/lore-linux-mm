Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8801C6B008C
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 04:42:17 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so952589pab.2
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 01:42:17 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id ov3si10168301pbc.228.2014.10.21.01.42.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 01:42:16 -0700 (PDT)
From: Jijiagang <jijiagang@hisilicon.com>
Subject: RE: UBIFS assert failed in ubifs_set_page_dirty at 1421
Date: Tue, 21 Oct 2014 08:41:38 +0000
Message-ID: <BE257DAADD2C0D439647A271332966573949F870@SZXEMA511-MBS.china.huawei.com>
References: <BE257DAADD2C0D439647A271332966573949EFEC@SZXEMA511-MBS.china.huawei.com>
 <1413805935.7906.225.camel@sauron.fi.intel.com>
 <C3050A4DBA34F345975765E43127F10F62CC5D9B@SZXEMA512-MBX.china.huawei.com>
 <1413810719.7906.268.camel@sauron.fi.intel.com>
 <20141021033847.GS17506@dastard>
In-Reply-To: <20141021033847.GS17506@dastard>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Artem Bityutskiy <dedekind1@gmail.com>
Cc: Caizhiyong <caizhiyong@hisilicon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adrian.hunter@intel.com" <adrian.hunter@intel.com>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "Wanli
 (welly)" <welly.wan@hisilicon.com>, "Liuhui (B)" <liuhui88.liuhui@hisilicon.com>

Dear Dave,
Thanks for your reply.
We removed some modules to keep kernel untainted. It still can be reproduce=
d.

Here is the log:
UBIFS assert failed in ubifs_set_page_dirty at 1421 (pid 543)
CPU: 1 PID: 543 Comm: kswapd0 Not tainted 3.10.0_s40 #1
[<8001d8a0>] (unwind_backtrace+0x0/0x108) from [<80019f44>] (show_stack+0x2=
0/0x24)
[<80019f44>] (show_stack+0x20/0x24) from [<80af2ef8>] (dump_stack+0x24/0x2c=
)
[<80af2ef8>] (dump_stack+0x24/0x2c) from [<80297234>] (ubifs_set_page_dirty=
+0x54/0x5c)
[<80297234>] (ubifs_set_page_dirty+0x54/0x5c) from [<800cea60>] (set_page_d=
irty+0x50/0x78)
[<800cea60>] (set_page_dirty+0x50/0x78) from [<800f4be4>] (try_to_unmap_one=
+0x1f8/0x3d0)
[<800f4be4>] (try_to_unmap_one+0x1f8/0x3d0) from [<800f4f44>] (try_to_unmap=
_file+0x9c/0x740)
[<800f4f44>] (try_to_unmap_file+0x9c/0x740) from [<800f5678>] (try_to_unmap=
+0x40/0x78)
[<800f5678>] (try_to_unmap+0x40/0x78) from [<800d6a04>] (shrink_page_list+0=
x23c/0x884)
[<800d6a04>] (shrink_page_list+0x23c/0x884) from [<800d76c8>] (shrink_inact=
ive_list+0x21c/0x3c8)
[<800d76c8>] (shrink_inactive_list+0x21c/0x3c8) from [<800d7c20>] (shrink_l=
ruvec+0x3ac/0x524)
[<800d7c20>] (shrink_lruvec+0x3ac/0x524) from [<800d8970>] (kswapd+0x854/0x=
dc0)
[<800d8970>] (kswapd+0x854/0xdc0) from [<80051e28>] (kthread+0xc8/0xcc)
[<80051e28>] (kthread+0xc8/0xcc) from [<80015198>] (ret_from_fork+0x14/0x20=
)
UBIFS assert failed in ubifs_writepage at 1009 (pid 6)
CPU: 0 PID: 6 Comm: kworker/u8:0 Not tainted 3.10.0_s40 #1
Workqueue: writeback bdi_writeback_workfn (flush-ubifs_1_0)
[<8001d8a0>] (unwind_backtrace+0x0/0x108) from [<80019f44>] (show_stack+0x2=
0/0x24)
[<80019f44>] (show_stack+0x20/0x24) from [<80af2ef8>] (dump_stack+0x24/0x2c=
)
[<80af2ef8>] (dump_stack+0x24/0x2c) from [<80299294>] (ubifs_writepage+0x1d=
0/0x1dc)
[<80299294>] (ubifs_writepage+0x1d0/0x1dc) from [<800cefc0>] (__writepage+0=
x24/0x4c)
[<800cefc0>] (__writepage+0x24/0x4c) from [<800cf288>] (write_cache_pages+0=
x1b0/0x408)
[<800cf288>] (write_cache_pages+0x1b0/0x408) from [<800cf538>] (generic_wri=
tepages+0x58/0x70)
[<800cf538>] (generic_writepages+0x58/0x70) from [<800cf594>] (do_writepage=
s+0x44/0x48)
[<800cf594>] (do_writepages+0x44/0x48) from [<80139a30>] (__writeback_singl=
e_inode+0x50/0x238)
[<80139a30>] (__writeback_single_inode+0x50/0x238) from [<8013ae48>] (write=
back_sb_inodes+0x264/0x44c)
[<8013ae48>] (writeback_sb_inodes+0x264/0x44c) from [<8013b0c4>] (__writeba=
ck_inodes_wb+0x94/0xcc)
[<8013b0c4>] (__writeback_inodes_wb+0x94/0xcc) from [<8013b3dc>] (wb_writeb=
ack+0x228/0x2f8)
[<8013b3dc>] (wb_writeback+0x228/0x2f8) from [<8013b6b4>] (wb_do_writeback+=
0x208/0x24c)
[<8013b6b4>] (wb_do_writeback+0x208/0x24c) from [<8013b774>] (bdi_writeback=
_workfn+0x7c/0x1dc)
[<8013b774>] (bdi_writeback_workfn+0x7c/0x1dc) from [<8004ac64>] (process_o=
ne_work+0x160/0x460)
[<8004ac64>] (process_one_work+0x160/0x460) from [<8004b0ac>] (worker_threa=
d+0x148/0x49c)
[<8004b0ac>] (worker_thread+0x148/0x49c) from [<80051e28>] (kthread+0xc8/0x=
cc)
[<80051e28>] (kthread+0xc8/0xcc) from [<80015198>] (ret_from_fork+0x14/0x20=
)
UBIFS assert failed in do_writepage at 936 (pid 6)
CPU: 3 PID: 6 Comm: kworker/u8:0 Not tainted 3.10.0_s40 #1
Workqueue: writeback bdi_writeback_workfn (flush-ubifs_1_0)
[<8001d8a0>] (unwind_backtrace+0x0/0x108) from [<80019f44>] (show_stack+0x2=
0/0x24)
[<80019f44>] (show_stack+0x20/0x24) from [<80af2ef8>] (dump_stack+0x24/0x2c=
)
[<80af2ef8>] (dump_stack+0x24/0x2c) from [<802990b8>] (do_writepage+0x1b8/0=
x1c4)
[<802990b8>] (do_writepage+0x1b8/0x1c4) from [<802991e8>] (ubifs_writepage+=
0x124/0x1dc)
[<802991e8>] (ubifs_writepage+0x124/0x1dc) from [<800cefc0>] (__writepage+0=
x24/0x4c)
[<800cefc0>] (__writepage+0x24/0x4c) from [<800cf288>] (write_cache_pages+0=
x1b0/0x408)
[<800cf288>] (write_cache_pages+0x1b0/0x408) from [<800cf538>] (generic_wri=
tepages+0x58/0x70)
[<800cf538>] (generic_writepages+0x58/0x70) from [<800cf594>] (do_writepage=
s+0x44/0x48)
[<800cf594>] (do_writepages+0x44/0x48) from [<80139a30>] (__writeback_singl=
e_inode+0x50/0x238)
[<80139a30>] (__writeback_single_inode+0x50/0x238) from [<8013ae48>] (write=
back_sb_inodes+0x264/0x44c)
[<8013ae48>] (writeback_sb_inodes+0x264/0x44c) from [<8013b0c4>] (__writeba=
ck_inodes_wb+0x94/0xcc)
[<8013b0c4>] (__writeback_inodes_wb+0x94/0xcc) from [<8013b3dc>] (wb_writeb=
ack+0x228/0x2f8)
[<8013b3dc>] (wb_writeback+0x228/0x2f8) from [<8013b6b4>] (wb_do_writeback+=
0x208/0x24c)
[<8013b6b4>] (wb_do_writeback+0x208/0x24c) from [<8013b774>] (bdi_writeback=
_workfn+0x7c/0x1dc)
[<8013b774>] (bdi_writeback_workfn+0x7c/0x1dc) from [<8004ac64>] (process_o=
ne_work+0x160/0x460)
[<8004ac64>] (process_one_work+0x160/0x460) from [<8004b0ac>] (worker_threa=
d+0x148/0x49c)
[<8004b0ac>] (worker_thread+0x148/0x49c) from [<80051e28>] (kthread+0xc8/0x=
cc)
[<80051e28>] (kthread+0xc8/0xcc) from [<80015198>] (ret_from_fork+0x14/0x20=
)
UBIFS assert failed in ubifs_release_budget at 567 (pid 6)
CPU: 3 PID: 6 Comm: kworker/u8:0 Not tainted 3.10.0_s40 #1
Workqueue: writeback bdi_writeback_workfn (flush-ubifs_1_0)

-----Original Message-----
From: Dave Chinner [mailto:david@fromorbit.com]=20
Sent: Tuesday, October 21, 2014 11:39 AM
To: Artem Bityutskiy
Cc: Caizhiyong; linux-fsdevel@vger.kernel.org; linux-mm@kvack.org; Jijiagan=
g; adrian.hunter@intel.com; linux-mtd@lists.infradead.org; Wanli (welly)
Subject: Re: UBIFS assert failed in ubifs_set_page_dirty at 1421

On Mon, Oct 20, 2014 at 04:11:59PM +0300, Artem Bityutskiy wrote:
> 3. There are exactly 2 places where UBIFS-backed pages may be marked=20
> as
> dirty:
>=20
>   a) ubifs_write_end() [->wirte_end] - the file write path
>   b) ubifs_page_mkwrite() [->page_mkwirte] - the file mmap() path
>=20
> 4. If anything calls 'ubifs_set_page_dirty()' directly (not through=20
> write_end()/mkwrite()), and the page was not dirty, UBIFS will=20
> complain with the assertion that you see.
>=20
> > CPU: 3 PID: 543 Comm: kswapd0 Tainted: P           O 3.10.0_s40 #1

Kernel is tainted. Not worth wasting time on unless it can be reproduced on=
 an untainted kernel...

Cheers,

Dave.
--
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
