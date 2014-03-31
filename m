Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id AA8486B0035
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 16:19:31 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so8773649pad.3
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 13:19:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ub3si6991549pac.194.2014.03.31.13.19.30
        for <linux-mm@kvack.org>;
        Mon, 31 Mar 2014 13:19:30 -0700 (PDT)
Date: Mon, 31 Mar 2014 13:19:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 3.14-rc6: BUG: Bad page map in process objdump pte:483d2025
 pmd:daa04067
Message-Id: <20140331131928.6f00ecbc13b54b53bfe62515@linux-foundation.org>
In-Reply-To: <CACVxJT-d=Sm1-N9wvojgXj0voBABwxrgV728fAyZuPX2BK-3vg@mail.gmail.com>
References: <CACVxJT-d=Sm1-N9wvojgXj0voBABwxrgV728fAyZuPX2BK-3vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

(cc linux-mm)

On Thu, 27 Mar 2014 17:47:06 +0300 Alexey Dobriyan <adobriyan@gmail.com> wrote:

> Hell knows what happened, I did nothing unusual...
> This is the first time I see this message on this box.
> 
> [15173.408570] BUG: Bad page map in process objdump  pte:483d2025 pmd:daa04067
> [15173.408578] page:ffffea000120f480 count:1 mapcount:-1
> mapping:ffff88005316bb10 index:0x9a22
> [15173.408580] page flags:
> 0x400000000002002c(referenced|uptodate|lru|mappedtodisk)
> [15173.408585] page dumped because: bad pte
> [15173.408588] addr:00007fe290749000 vm_flags:00000075 anon_vma:
>    (null) mapping:ffff88007fe518c0 index:24
> [15173.408593] vma->vm_ops->fault: filemap_fault+0x0/0x420
> [15173.408597] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60
> [15173.408601] CPU: 1 PID: 10326 Comm: objdump Not tainted 3.14.0-rc6 #13
> [15173.408603] Hardware name: Hewlett-Packard HP Compaq dc7800
> Convertible Minitower/0AACh, BIOS 786F1 v01.28 02/26/2009
> [15173.408605]  ffff8800bb77faa8 ffff880047899c78 ffffffff814649d0
> 0000000000000007
> [15173.408608]  00007fe290749000 ffff880047899cc8 ffffffff810f7ece
> ffffea0002edf840
> [15173.408611]  ffff88007fe518c0 ffff880047899ca8 00007fe29075e000
> ffff8800daa04a48
> [15173.408614] Call Trace:
> [15173.408620]  [<ffffffff814649d0>] dump_stack+0x4e/0x71
> [15173.408624]  [<ffffffff810f7ece>] print_bad_pte+0x18e/0x240
> [15173.408627]  [<ffffffff810f94eb>] unmap_single_vma+0x5cb/0x5f0
> [15173.408630]  [<ffffffff810f9c09>] unmap_vmas+0x49/0x90
> [15173.408633]  [<ffffffff8110144d>] exit_mmap+0xbd/0x170
> [15173.408637]  [<ffffffff81072cbc>] mmput+0x3c/0xb0
> [15173.408640]  [<ffffffff81076db6>] do_exit+0x1f6/0x900
> [15173.408644]  [<ffffffff8109e1cb>] ? local_clock+0x1b/0x30
> [15173.408647]  [<ffffffff8109eb28>] ? vtime_account_user+0x58/0x70
> [15173.408650]  [<ffffffff810775da>] do_group_exit+0x3a/0xa0
> [15173.408652]  [<ffffffff81077652>] SyS_exit_group+0x12/0x20
> [15173.408656]  [<ffffffff8146a459>] tracesys+0xd0/0xd5

page_mapcount() = -1 in zap_pte_range().

I can't imagine what caused that and objdump is, I assume, a very
simple program - single threaded, does nothing much apart from
open/lseek/read/printf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
