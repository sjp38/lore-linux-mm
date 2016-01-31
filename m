Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6266C6B0005
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 14:29:49 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id yy13so69233122pab.3
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 11:29:49 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id z2si18649876par.192.2016.01.31.11.29.48
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 11:29:48 -0800 (PST)
From: "Williams, Dan J" <dan.j.williams@intel.com>
Subject: [GIT PULL] libnvdimm-fixes for 4.5-rc2
Date: Sun, 31 Jan 2016 19:29:46 +0000
Message-ID: <1454268585.31193.9.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-7"
Content-ID: <BE1680A9F4FE49419F6BBC8FFA0C60CF@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>

Hi Linus, please pull from:

+AKA- git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm libnvdimm=
-fixes

1/ Fixes to the libnvdimm 'pfn' device that establishes a reserved area
for storing a struct page array.

2/ Fixes for dax operations on a raw block device to prevent pagecache
collisions with dax mappings.

3/ A fix for pfn+AF8-t usage in vm+AF8-insert+AF8-mixed that lead to a null=
 pointer
de-reference.

These have received build success notification from the kbuild robot
across 153 configs and pass the latest ndctl tests.

Note that the below commits are also in -mm, but as Andrew is offline
until tomorrow I thought it best to submit these for 4.5-rc2
consideration. +AKA-Please yell if I should just wait next time:
+AKA-
65f87ee71852 fs, block: force direct-I/O for dax-enabled block devices
03fc2da63b9a mm: fix pfn+AF8-t to page conversion in vm+AF8-insert+AF8-mixe=
d
76e9f0ee52b0 phys+AF8-to+AF8-pfn+AF8-t: use phys+AF8-addr+AF8-t


The following changes since commit 92e963f50fc74041b5e9e744c330dca48e04f08d=
:

+AKA- Linux 4.5-rc1 (2016-01-24 13:06:47 -0800)

are available in the git repository at:

+AKA- git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm libnvdimm=
-fixes

for you to fetch changes up to 76e9f0ee52b0be5761e29847e0ef01f23f24f1df:

+AKA- phys+AF8-to+AF8-pfn+AF8-t: use phys+AF8-addr+AF8-t (2016-01-31 09:10:=
19 -0800)

----------------------------------------------------------------
Dan Williams (8):
+AKAAoACgAKAAoACg-libnvdimm: fix mode determination for e820 devices
+AKAAoACgAKAAoACg-libnvdimm, pfn: fix restoring memmap location
+AKAAoACgAKAAoACg-devm+AF8-memremap+AF8-pages: fix vmem+AF8-altmap lifetime=
 +- alignment handling
+AKAAoACgAKAAoACg-fs, block: force direct-I/O for dax-enabled block devices
+AKAAoACgAKAAoACg-block: revert runtime dax control of the raw block device
+AKAAoACgAKAAoACg-block: use DAX for partition table reads
+AKAAoACgAKAAoACg-mm: fix pfn+AF8-t to page conversion in vm+AF8-insert+AF8=
-mixed
+AKAAoACgAKAAoACg-phys+AF8-to+AF8-pfn+AF8-t: use phys+AF8-addr+AF8-t

+AKA-block/ioctl.c+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACg=
AHw- 38 --------------------------------------
+AKA-block/partition-generic.c+AKAAoACgAKAAoACgAKAAoACgAHw- 18 +-+-+-+-+-+-=
+-+-+-+-+-+-+-+-+----
+AKA-drivers/nvdimm/namespace+AF8-devs.c+AKAAoACgAHwAoACg-8 +-+-+-+-+----
+AKA-drivers/nvdimm/pfn+AF8-devs.c+AKAAoACgAKAAoACgAKAAoACgAHwAoACg-4 +----
+AKA-fs/block+AF8-dev.c+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKA=
AoAB8- 28 ----------------------------
+AKA-fs/dax.c+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAo=
ACgAKAAoAB8- 20 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
+AKA-include/linux/dax.h+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAHw- 11 +-=
+-+-+-+-+-+-+-+-+-+-
+AKA-include/linux/fs.h+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAfACgAKA=
-5 +-----
+AKA-include/linux/pfn+AF8-t.h+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAfACgAKA-=
4 +-+---
+AKA-include/uapi/linux/fs.h+AKAAoACgAKAAoACgAKAAoACgAKAAoAB8AKAAoA-1 -
+AKA-kernel/memremap.c+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoAB8- 20=
 +-+-+-+-+-+-+-+-+-+-+-+---------
+AKA-mm/memory.c+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAK=
AAoAB8AKAAoA-9 +-+-+-+-+-+-+---
+AKA-tools/testing/nvdimm/test/iomap.c +AHwAoACg-2 +--
+AKA-13 files changed, 75 insertions(+-), 93 deletions(-)

commit 9c41242817f4b6d908886c0fdb036d9246c50630
Author: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
Date:+AKAAoACg-Sat Jan 23 15:34:10 2016 -0800

+AKAAoACgAKA-libnvdimm: fix mode determination for e820 devices
+AKAAoACgAKA-
+AKAAoACgAKA-Correctly display +ACI-safe+ACI- mode when a btt is establishe=
d on a e820/memmap
+AKAAoACgAKA-defined pmem namespace.
+AKAAoACgAKA-
+AKAAoACgAKA-Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+=
AD4-

commit 45eb570a0db3391c88cba04510a20fe7e4125497
Author: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
Date:+AKAAoACg-Fri Jan 29 17:42:51 2016 -0800

+AKAAoACgAKA-libnvdimm, pfn: fix restoring memmap location
+AKAAoACgAKA-
+AKAAoACgAKA-This path was missed when turning on the memmap in pmem suppor=
t.+AKAAoA-Permit
+AKAAoACgAKA-'pmem' as a valid location for the map.
+AKAAoACgAKA-
+AKAAoACgAKA-Reported-by: Jeff Moyer +ADw-jmoyer+AEA-redhat.com+AD4-
+AKAAoACgAKA-Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+=
AD4-

commit eb7d78c9e7f6418932bd5fbee45eb46d5ab05002
Author: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
Date:+AKAAoACg-Fri Jan 29 21:48:34 2016 -0800

+AKAAoACgAKA-devm+AF8-memremap+AF8-pages: fix vmem+AF8-altmap lifetime +- a=
lignment handling
+AKAAoACgAKA-
+AKAAoACgAKA-to+AF8-vmem+AF8-altmap() needs to return valid results until
+AKAAoACgAKA-arch+AF8-remove+AF8-memory() completes.+AKAAoA-It also needs t=
o be valid for any pfn
+AKAAoACgAKA-in a section regardless of whether that pfn maps to data.+AKAA=
oA-This escape
+AKAAoACgAKA-was a result of a bug in the unit test.
+AKAAoACgAKA-
+AKAAoACgAKA-The signature of this bug is that free+AF8-pagetable() fails t=
o retrieve a
+AKAAoACgAKA-vmem+AF8-altmap and goes off into the weeds:
+AKAAoACgAKA-
+AKAAoACgAKAAoA-BUG: unable to handle kernel NULL pointer dereference at+AK=
AAoACgAKAAoACgAKAAoACgAKAAoA-(null)
+AKAAoACgAKAAoA-IP: +AFsAPA-ffffffff811d2629+AD4AXQ- get+AF8-pfnblock+AF8-f=
lags+AF8-mask+-0x49/0x60
+AKAAoACgAKAAoABb-..+AF0-
+AKAAoACgAKAAoA-Call Trace:
+AKAAoACgAKAAoACgAFsAPA-ffffffff811d3477+AD4AXQ- free+AF8-hot+AF8-cold+AF8-=
page+-0x97/0x1d0
+AKAAoACgAKAAoACgAFsAPA-ffffffff811d367a+AD4AXQ- +AF8AXw-free+AF8-pages+-0x=
2a/0x40
+AKAAoACgAKAAoACgAFsAPA-ffffffff8191e669+AD4AXQ- free+AF8-pagetable+-0x8c/0=
xd4
+AKAAoACgAKAAoACgAFsAPA-ffffffff8191ef4e+AD4AXQ- remove+AF8-pagetable+-0x37=
a/0x808
+AKAAoACgAKAAoACgAFsAPA-ffffffff8191b210+AD4AXQ- vmemmap+AF8-free+-0x10/0x2=
0
+AKAAoACgAKA-
+AKAAoACgAKA-Fixes: 4b94ffdc4163 (+ACI-x86, mm: introduce vmem+AF8-altmap t=
o augment vmemmap+AF8-populate()+ACI-)
+AKAAoACgAKA-Cc: Andrew Morton +ADw-akpm+AEA-linux-foundation.org+AD4-
+AKAAoACgAKA-Reported-by: Jeff Moyer +ADw-jmoyer+AEA-redhat.com+AD4-
+AKAAoACgAKA-Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+=
AD4-

commit 65f87ee71852a754f7981d0653e7136039b8798a
Author: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
Date:+AKAAoACg-Mon Jan 25 17:23:18 2016 -0800

+AKAAoACgAKA-fs, block: force direct-I/O for dax-enabled block devices
+AKAAoACgAKA-
+AKAAoACgAKA-Similar to the file I/O path, re-direct all I/O to the DAX pat=
h for I/O
+AKAAoACgAKA-to a block-device special file.+AKAAoA-Both regular files and =
device special
+AKAAoACgAKA-files can use the common filp-+AD4-f+AF8-mapping-+AD4-host loo=
kup to determing is
+AKAAoACgAKA-DAX is enabled.
+AKAAoACgAKA-
+AKAAoACgAKA-Otherwise, we confuse the DAX code that does not expect to fin=
d live
+AKAAoACgAKA-data in the page cache:
+AKAAoACgAKA-
+AKAAoACgAKAAoACgAKAAoA-------------+AFs- cut here +AF0-------------
+AKAAoACgAKAAoACgAKAAoA-WARNING: CPU: 0 PID: 7676 at mm/filemap.c:217
+AKAAoACgAKAAoACgAKAAoABfAF8-delete+AF8-from+AF8-page+AF8-cache+-0x9f6/0xb6=
0()
+AKAAoACgAKAAoACgAKAAoA-Modules linked in:
+AKAAoACgAKAAoACgAKAAoA-CPU: 0 PID: 7676 Comm: a.out Not tainted 4.4.0+- +A=
CM-276
+AKAAoACgAKAAoACgAKAAoA-Hardware name: QEMU Standard PC (i440FX +- PIIX, 19=
96), BIOS Bochs 01/01/2011
+AKAAoACgAKAAoACgAKAAoACg-00000000ffffffff ffff88006d3f7738 ffffffff82999e2=
d 0000000000000000
+AKAAoACgAKAAoACgAKAAoACg-ffff8800620a0000 ffffffff86473d20 ffff88006d3f777=
8 ffffffff81352089
+AKAAoACgAKAAoACgAKAAoACg-ffffffff81658d36 ffffffff86473d20 00000000000000d=
9 ffffea0000009d60
+AKAAoACgAKAAoACgAKAAoA-Call Trace:
+AKAAoACgAKAAoACgAKAAoACgAFsAPACgAKAAoACgAKA-inline+AKAAoACgAKAAoAA+AF0- +A=
F8AXw-dump+AF8-stack lib/dump+AF8-stack.c:15
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff82999e2d+AD4AXQ- dump+AF8-stack+-0x=
6f/0xa2 lib/dump+AF8-stack.c:50
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff81352089+AD4AXQ- warn+AF8-slowpath+=
AF8-common+-0xd9/0x140 kernel/panic.c:482
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff813522b9+AD4AXQ- warn+AF8-slowpath+=
AF8-null+-0x29/0x30 kernel/panic.c:515
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff81658d36+AD4AXQ- +AF8AXw-delete+AF8=
-from+AF8-page+AF8-cache+-0x9f6/0xb60 mm/filemap.c:217
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff81658fb2+AD4AXQ- delete+AF8-from+AF=
8-page+AF8-cache+-0x112/0x200 mm/filemap.c:244
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff818af369+AD4AXQ- +AF8AXw-dax+AF8-fa=
ult+-0x859/0x1800 fs/dax.c:487
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff8186f4f6+AD4AXQ- blkdev+AF8-dax+AF8=
-fault+-0x26/0x30 fs/block+AF8-dev.c:1730
+AKAAoACgAKAAoACgAKAAoACgAFsAPACgAKAAoACgAKA-inline+AKAAoACgAKAAoAA+AF0- wp=
+AF8-pfn+AF8-shared mm/memory.c:2208
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff816e9145+AD4AXQ- do+AF8-wp+AF8-page=
+-0xc85/0x14f0 mm/memory.c:2307
+AKAAoACgAKAAoACgAKAAoACgAFsAPACgAKAAoACgAKA-inline+AKAAoACgAKAAoAA+AF0- ha=
ndle+AF8-pte+AF8-fault mm/memory.c:3323
+AKAAoACgAKAAoACgAKAAoACgAFsAPACgAKAAoACgAKA-inline+AKAAoACgAKAAoAA+AF0- +A=
F8AXw-handle+AF8-mm+AF8-fault mm/memory.c:3417
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff816ecec3+AD4AXQ- handle+AF8-mm+AF8-=
fault+-0x2483/0x4640 mm/memory.c:3446
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff8127eff6+AD4AXQ- +AF8AXw-do+AF8-pag=
e+AF8-fault+-0x376/0x960 arch/x86/mm/fault.c:1238
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff8127f738+AD4AXQ- trace+AF8-do+AF8-p=
age+AF8-fault+-0xe8/0x420 arch/x86/mm/fault.c:1331
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff812705c4+AD4AXQ- do+AF8-async+AF8-p=
age+AF8-fault+-0x14/0xd0 arch/x86/kernel/kvm.c:264
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff86338f78+AD4AXQ- async+AF8-page+AF8=
-fault+-0x28/0x30 arch/x86/entry/entry+AF8-64.S:986
+AKAAoACgAKAAoACgAKAAoACgAFsAPA-ffffffff86336c36+AD4AXQ- entry+AF8-SYSCALL+=
AF8-64+AF8-fastpath+-0x16/0x7a
+AKAAoACgAKAAoACgAKAAoA-arch/x86/entry/entry+AF8-64.S:185
+AKAAoACgAKAAoACgAKAAoA----+AFs- end trace dae21e0f85f1f98c +AF0----
+AKAAoACgAKA-
+AKAAoACgAKA-Fixes: 5a023cdba50c (+ACI-block: enable dax for raw block devi=
ces+ACI-)
+AKAAoACgAKA-Reported-by: Dmitry Vyukov +ADw-dvyukov+AEA-google.com+AD4-
+AKAAoACgAKA-Reported-by: Kirill A. Shutemov +ADw-kirill+AEA-shutemov.name+=
AD4-
+AKAAoACgAKA-Suggested-by: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
+AKAAoACgAKA-Reviewed-by: Jan Kara +ADw-jack+AEA-suse.cz+AD4-
+AKAAoACgAKA-Suggested-by: Matthew Wilcox +ADw-willy+AEA-linux.intel.com+AD=
4-
+AKAAoACgAKA-Tested-by: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.com+=
AD4-
+AKAAoACgAKA-Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+=
AD4-

commit 9f4736fe7ca804aa79b5916221bb13dfc6221a0f
Author: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
Date:+AKAAoACg-Thu Jan 28 20:13:39 2016 -0800

+AKAAoACgAKA-block: revert runtime dax control of the raw block device
+AKAAoACgAKA-
+AKAAoACgAKA-Dynamically enabling DAX requires that the page cache first be=
 flushed
+AKAAoACgAKA-and invalidated.+AKAAoA-This must occur atomically with the ch=
ange of DAX mode
+AKAAoACgAKA-otherwise we confuse the fsync/msync tracking and violate data
+AKAAoACgAKA-durability guarantees.+AKAAoA-Eliminate the possibilty of DAX-=
disabled to
+AKAAoACgAKA-DAX-enabled transitions for now and revisit this for the next =
cycle.
+AKAAoACgAKA-
+AKAAoACgAKA-Cc: Jan Kara +ADw-jack+AEA-suse.com+AD4-
+AKAAoACgAKA-Cc: Jeff Moyer +ADw-jmoyer+AEA-redhat.com+AD4-
+AKAAoACgAKA-Cc: Christoph Hellwig +ADw-hch+AEA-lst.de+AD4-
+AKAAoACgAKA-Cc: Dave Chinner +ADw-david+AEA-fromorbit.com+AD4-
+AKAAoACgAKA-Cc: Matthew Wilcox +ADw-willy+AEA-linux.intel.com+AD4-
+AKAAoACgAKA-Cc: Andrew Morton +ADw-akpm+AEA-linux-foundation.org+AD4-
+AKAAoACgAKA-Cc: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.com+AD4-
+AKAAoACgAKA-Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+=
AD4-

commit d1a5f2b4d8a125943dcb6b032fc7eaefc2c78296
Author: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
Date:+AKAAoACg-Thu Jan 28 20:25:31 2016 -0800

+AKAAoACgAKA-block: use DAX for partition table reads
+AKAAoACgAKA-
+AKAAoACgAKA-Avoid populating pagecache when the block device is in DAX mod=
e.
+AKAAoACgAKA-Otherwise these page cache entries collide with the fsync/msyn=
c
+AKAAoACgAKA-implementation and break data durability guarantees.
+AKAAoACgAKA-
+AKAAoACgAKA-Cc: Jan Kara +ADw-jack+AEA-suse.com+AD4-
+AKAAoACgAKA-Cc: Jeff Moyer +ADw-jmoyer+AEA-redhat.com+AD4-
+AKAAoACgAKA-Cc: Christoph Hellwig +ADw-hch+AEA-lst.de+AD4-
+AKAAoACgAKA-Cc: Dave Chinner +ADw-david+AEA-fromorbit.com+AD4-
+AKAAoACgAKA-Cc: Andrew Morton +ADw-akpm+AEA-linux-foundation.org+AD4-
+AKAAoACgAKA-Reported-by: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.co=
m+AD4-
+AKAAoACgAKA-Tested-by: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.com+=
AD4-
+AKAAoACgAKA-Reviewed-by: Matthew Wilcox +ADw-willy+AEA-linux.intel.com+AD4=
-
+AKAAoACgAKA-Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+=
AD4-

commit 03fc2da63b9a33dce784a2075c7e068bb97cbf69
Author: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
Date:+AKAAoACg-Tue Jan 26 09:48:05 2016 -0800

+AKAAoACgAKA-mm: fix pfn+AF8-t to page conversion in vm+AF8-insert+AF8-mixe=
d
+AKAAoACgAKA-
+AKAAoACgAKA-pfn+AF8-t+AF8-to+AF8-page() honors the flags in the pfn+AF8-t =
value to determine if a
+AKAAoACgAKA-pfn is backed by a page.+AKAAoA-However, vm+AF8-insert+AF8-mix=
ed() was originally
+AKAAoACgAKA-written to use pfn+AF8-valid() to make this determination.+AKA=
AoA-To restore the
+AKAAoACgAKA-old/correct behavior, ignore the pfn+AF8-t flags in the +ACE-p=
fn+AF8-t+AF8-devmap() case
+AKAAoACgAKA-and fallback to trusting pfn+AF8-valid().
+AKAAoACgAKA-
+AKAAoACgAKA-Fixes: 01c8f1c44b83 (+ACI-mm, dax, gpu: convert vm+AF8-insert+=
AF8-mixed to pfn+AF8-t+ACI-)
+AKAAoACgAKA-Cc: Dave Hansen +ADw-dave+AEA-sr71.net+AD4-
+AKAAoACgAKA-Cc: David Airlie +ADw-airlied+AEA-linux.ie+AD4-
+AKAAoACgAKA-Reported-by: Tomi Valkeinen +ADw-tomi.valkeinen+AEA-ti.com+AD4=
-
+AKAAoACgAKA-Tested-by: Tomi Valkeinen +ADw-tomi.valkeinen+AEA-ti.com+AD4-
+AKAAoACgAKA-Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+=
AD4-

commit 76e9f0ee52b0be5761e29847e0ef01f23f24f1df
Author: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
Date:+AKAAoACg-Fri Jan 22 09:43:28 2016 -0800

+AKAAoACgAKA-phys+AF8-to+AF8-pfn+AF8-t: use phys+AF8-addr+AF8-t
+AKAAoACgAKA-
+AKAAoACgAKA-A dma+AF8-addr+AF8-t is potentially smaller than a phys+AF8-ad=
dr+AF8-t on some archs.
+AKAAoACgAKA-Don't truncate the address when doing the pfn conversion.
+AKAAoACgAKA-
+AKAAoACgAKA-Cc: Ross Zwisler +ADw-ross.zwisler+AEA-linux.intel.com+AD4-
+AKAAoACgAKA-Reported-by: Matthew Wilcox +ADw-willy+AEA-linux.intel.com+AD4=
-
+AKAAoACgAKAAWw-willy: fix pfn+AF8-t+AF8-to+AF8-phys as well+AF0-
+AKAAoACgAKA-Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+=
AD4-=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
