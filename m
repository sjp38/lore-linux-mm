Message-Id: <5.0.0.25.2.20011004181232.00a459b0@cic-mail.lanl.gov>
Date: Thu, 04 Oct 2001 18:13:39 -0600
From: Mariella Di Giacomo <mariella@lanl.gov>
Subject: __alloc_pages: 0-order allocation failed in 2.4.10
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I'm running 2.4.10 on a SMP box with 4G of memory; I've  installed
the patch to let a process use up to 3.5 GB and I set highmem 4G.
I was using NFS to get remote files and copy them (using cpio) to the
local filesystem (SCSI drive).
After a while I started getting the following errors and the processes died.


  kernel: __alloc_pages: 0-order allocation failed (gfp=0xf0/0) from
c0138adc
  kernel: __alloc_pages: 0-order allocation failed (gfp=0x1f0/0) from
c012e330
  kernel: RPC: sendmsg returned error 105
kernel: nfs: RPC call returned error 105
kernel: __alloc_pages: 0-order allocation failed (gfp=0x1f0/0) from
c012e330
  last message repeated 3 times
  kernel: __alloc_pages: 0-order allocation failed (gfp=0x70/0) from
c0132a00
last message repeated 5 times
  kernel: __alloc_pages: 0-order allocation failed (gfp=0x1f0/0) from
c012e330
kernel: __alloc_pages: 0-order allocation failed (gfp=0x70/0) from
c0132a00
last message repeated 8 times
  kernel: __alloc_pages: 0-order allocation failed (gfp=0xf0/0) from
c0138adc
  kernel: __alloc_pages: 0-order allocation failed (gfp=0x70/0) from
c0132a00
kernel: __alloc_pages: 0-order allocation failed (gfp=0x1f0/0) from
c012e330
kernel: __alloc_pages: 0-order allocation failed (gfp=0x70/0) from
c0132a00
last message repeated 7 times
kernel: __alloc_pages: 0-order allocation failed (gfp=0x1f0/0) from
c012e330
kernel: __alloc_pages: 0-order allocation failed (gfp=0x70/0) from
c0132a00
kernel: __alloc_pages: 0-order allocation failed (gfp=0xf0/0) from
c0138adc

RPC: sendmsg returned error 105

kernel: nfs: RPC call returned error 105
kernel: __alloc_pages: 0-order allocation failed (gfp=0x70/0) from
c0132a00
last message repeated 3 times
kernel: __alloc_pages: 0-order allocation failed (gfp=0xf0/0) from
c0138adc
kernel: __alloc_pages: 0-order allocation failed (gfp=0x70/0) from
c0132a00
kernel: __alloc_pages: 0-order allocation failed (gfp=0x1f0/0) from
c012e330
kernel: RPC: buffer allocation failed for task efa82b40
kernel: __alloc_pages: 0-order allocation failed (gfp=0x1f0/0) from
c012e330
kernel: __alloc_pages: 0-order allocation failed (gfp=0x70/0) from
c0132a00
kernel: __alloc_pages: 0-order allocation failed (gfp=0xf0/0) from
c0138adc

Do I need to install other patches for highmem ?

Thanks a lot in advance for your help,


Mariella

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
