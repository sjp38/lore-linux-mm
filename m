Message-ID: <401F74E8.8080301@aitel.hist.no>
Date: Tue, 03 Feb 2004 11:16:08 +0100
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.6.2-rc3-mm1
References: <20040202235817.5c3feaf3.akpm@osdl.org>
In-Reply-To: <20040202235817.5c3feaf3.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.2-rc3/2.6.2-rc3-mm1/
> 
> 
> - There is a debug patch in here which detects when someone calls
>   i_size_write() without holding the inode's i_sem.  It generates a warning
>   and a stack backtrace.  We know that XFS generates such a trace.  It will
>   turn itself off after the first ten warnings.  Please don't report the XFS
>   case.
> 
Ok, here's an ext2 case, from dmesg:



md: running: <hdb1><hda1>
raid1: raid set md0 active with 2 out of 2 mirrors
md: ... autorun DONE.
VFS: Mounted root (ext2 filesystem) readonly.
Freeing unused kernel memory: 168k freed
Adding 1999864k swap on /dev/hdb2.  Priority:-1 extents:1
Disabled Privacy Extensions on device c042ca80(lo)
i_size_write() called without i_sem
Call Trace:
 [<c012e66c>] i_size_write_check+0x3a/0x4d
 [<c0145444>] generic_commit_write+0x4e/0x70
 [<c0169886>] ext2_commit_chunk+0x28/0x61
 [<c016aa1d>] ext2_make_empty+0x158/0x1e0
 [<c016d3d5>] ext2_mkdir+0xa1/0xff
 [<c016d334>] ext2_mkdir+0x0/0xff
 [<c014d592>] vfs_mkdir+0x60/0x83
 [<c014d639>] sys_mkdir+0x84/0xbf
 [<c036133f>] syscall_call+0x7/0xb

i_size_write() called without i_sem
Call Trace:
 [<c012e66c>] i_size_write_check+0x3a/0x4d
 [<c0145444>] generic_commit_write+0x4e/0x70
 [<c0169886>] ext2_commit_chunk+0x28/0x61
 [<c016aa1d>] ext2_make_empty+0x158/0x1e0
 [<c016d3d5>] ext2_mkdir+0xa1/0xff
 [<c016d334>] ext2_mkdir+0x0/0xff
 [<c014d592>] vfs_mkdir+0x60/0x83
 [<c014d639>] sys_mkdir+0x84/0xbf
 [<c036133f>] syscall_call+0x7/0xb

i_size_write() called without i_sem
Call Trace:
 [<c012e66c>] i_size_write_check+0x3a/0x4d
 [<c0145444>] generic_commit_write+0x4e/0x70
 [<c0169886>] ext2_commit_chunk+0x28/0x61
 [<c016aa1d>] ext2_make_empty+0x158/0x1e0
 [<c016d3d5>] ext2_mkdir+0xa1/0xff
 [<c016d334>] ext2_mkdir+0x0/0xff
 [<c014d592>] vfs_mkdir+0x60/0x83
 [<c014d639>] sys_mkdir+0x84/0xbf
 [<c036133f>] syscall_call+0x7/0xb

eth0: no IPv6 routers present
atkbd.c: Unknown key released (translated set 2, code 0x7a on isa0060/serio0).
atkbd.c: This is an XFree86 bug. It shouldn't access hardware directly.

2.6.2-rc3-mm1 compiled with mregparm3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
