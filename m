Message-ID: <3E646FB0.6040108@aitel.hist.no>
Date: Tue, 04 Mar 2003 10:19:44 +0100
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.5.63-mm2 slab corruption
References: <20030302180959.3c9c437a.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2.5.63-mm2 seems to work fine, but I got this in my dmesg:
Helge Hafting

VFS: Mounted root (ext2 filesystem) readonly.
Freeing unused kernel memory: 320k freed
Adding 1999864k swap on /dev/hdb2.  Priority:-1 extents:1
eth0: no IPv6 routers present
Slab corruption: start=d714cfa4, expend=d714cfe3, problemat=d714cfba
Data: **********************7B ****************************************A5
Next: 71 F0 2C .B8 2F 18 08 14 00 00 00 F7 01 55 55 03 00 00 00 21 3D 00 
03 00 0
0 00 00 74 69 6D 65
slab error in check_poison_obj(): cache `vm_area_struct': object was 
modified af
ter freeing
Call Trace:
  [<c0130711>] __slab_error+0x21/0x28
  [<c01308db>] check_poison_obj+0x103/0x10c
  [<c013197c>] kmem_cache_alloc+0x64/0xe8
  [<c01393a4>] split_vma+0x2c/0xdc
  [<c01394ea>] do_munmap+0x96/0x134
  [<c01395bf>] sys_munmap+0x37/0x54
  [<c0108b17>] syscall_call+0x7/0xb

Slab corruption: start=c3eca854, expend=c3eca893, problemat=c3eca86a
Data: **********************7B ****************************************A5
Next: 71 F0 2C .A5 C2 0F 17 F0 E7 29 D8 00 A0 D9 41 00 A0 DB 41 C4 A7 EC 
C3 25 0
0 00 00 77 00 10 00
slab error in check_poison_obj(): cache `vm_area_struct': object was 
modified af
ter freeing
Call Trace:
  [<c0130711>] __slab_error+0x21/0x28
  [<c01308db>] check_poison_obj+0x103/0x10c
  [<c013197c>] kmem_cache_alloc+0x64/0xe8
  [<c01393a4>] split_vma+0x2c/0xdc
  [<c01394ea>] do_munmap+0x96/0x134
  [<c01395bf>] sys_munmap+0x37/0x54
  [<c0108b17>] syscall_call+0x7/0xb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
