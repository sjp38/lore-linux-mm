Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2F26B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 15:42:39 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 17so414981264pfy.2
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 12:42:39 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u90si6448491pfd.87.2016.12.02.12.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 12:42:38 -0800 (PST)
Date: Sat, 03 Dec 2016 04:41:35 +0800
From: kernel test robot <fengguang.wu@intel.com>
Subject: a3a18061c9:  WARNING: CPU: 0 PID: 1 at mm/hugetlb.c:2918
 hugetlb_add_hstate
Message-ID: <5841dc7f.S1K1TpbvQuMvlyTK%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_5841dc7f.kg4dgRh05+FI1LJxj8kK9stx6n6iP0UbedClA9wSSRcYZLpg"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.orgLinux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com

This is a multi-part message in MIME format.

--=_5841dc7f.kg4dgRh05+FI1LJxj8kK9stx6n6iP0UbedClA9wSSRcYZLpg
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit a3a18061c987aa9da4f5d3cbb31a9e71e9d7191d
Author:     Dave Hansen <dave.hansen@linux.intel.com>
AuthorDate: Thu Dec 1 11:27:23 2016 +1100
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Thu Dec 1 11:27:23 2016 +1100

    proc-mm-export-pte-sizes-directly-in-smaps-v3
    
    Changes from v2:
     * Do not assume (wrongly) that smaps_hugetlb_range() always uses
       PUDs.  (Thanks for pointing this out, Vlastimil).  Also handle
       hstates that are not exactly at PMD/PUD sizes.
    
    Link: http://lkml.kernel.org/r/20161129201703.CE9D5054@viggo.jf.intel.com
    Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
    Cc: Christoph Hellwig <hch@lst.de>
    Cc: Dan Williams <dan.j.williams@intel.com>
    Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
    Cc: Vlastimil Babka <vbabka@suse.cz>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

+-------------------------------------------------+------------+------------+---------------+
|                                                 | 446111661a | a3a18061c9 | next-20161202 |
+-------------------------------------------------+------------+------------+---------------+
| boot_successes                                  | 65         | 0          | 0             |
| boot_failures                                   | 27         | 26         | 19            |
| BUG:kernel_reboot-without-warning_in_test_stage | 27         |            |               |
| WARNING:at_mm/hugetlb.c:#hugetlb_add_hstate     | 0          | 26         | 19            |
| calltrace:hugetlb_init                          | 0          | 26         |               |
+-------------------------------------------------+------------+------------+---------------+

[    0.448484] PCI: PCI BIOS revision 2.10 entry at 0xfd3e3, last bus=0
[    0.449274] PCI: Using configuration type 1 for base access
[    0.488247] ------------[ cut here ]------------
[    0.488712] WARNING: CPU: 0 PID: 1 at mm/hugetlb.c:2918 hugetlb_add_hstate+0x1bc/0x1d2
[    0.489777] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.9.0-rc7-00105-ga3a1806 #1
[    0.490440] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
[    0.491347]  52087e9c 4725705c 00000000 483fed9d 52087eb4 46e96360 00000b66 48d5b220
[    0.492139]  48d5b520 00001000 52087ec8 46e9648c 00000009 00000000 00000000 52087ee4
[    0.492932]  483fed9d 0000000a 00400000 ffffffff 483fedb3 00000000 52087f28 483fee68
[    0.493737] Call Trace:
[    0.493965]  [<4725705c>] dump_stack+0x15f/0x202
[    0.494377]  [<483fed9d>] ? hugetlb_add_hstate+0x1bc/0x1d2
[    0.494872]  [<46e96360>] __warn+0x151/0x192
[    0.495450]  [<46e9648c>] warn_slowpath_null+0x32/0x45
[    0.496181]  [<483fed9d>] hugetlb_add_hstate+0x1bc/0x1d2
[    0.496832]  [<483fedb3>] ? hugetlb_add_hstate+0x1d2/0x1d2
[    0.497497]  [<483fee68>] hugetlb_init+0xb5/0x7c1
[    0.498107]  [<47083aef>] ? bdi_init+0x2c3/0x428
[    0.498740]  [<483fedb3>] ? hugetlb_add_hstate+0x1d2/0x1d2
[    0.499509]  [<483bb950>] do_one_initcall+0x11b/0x248
[    0.499982]  [<483ba6f7>] ? do_early_param+0x128/0x128
[    0.500670]  [<46ec0386>] ? __usermodehelper_set_disable_depth+0x65/0x79
[    0.501626]  [<483bbca6>] ? kernel_init_freeable+0x229/0x3b2
[    0.502281]  [<46f20a62>] ? up_write+0x37/0x6f
[    0.502759]  [<483bbcd4>] kernel_init_freeable+0x257/0x3b2
[    0.503549]  [<47b6fff0>] ? rest_init+0x270/0x270
[    0.504057]  [<47b7000b>] kernel_init+0x1b/0x24d
[    0.504551]  [<47b7e723>] ret_from_fork+0x1b/0x28
[    0.505108] ---[ end trace f888bffec9944273 ]---
[    0.505533] HugeTLB registered 4 MB page size, pre-allocated 0 pages

git bisect start e05f574a0bb1f4502a4b2264fdb0ef6419cf3772 e5517c2a5a49ed5e99047008629f1cd60246ea0e --
git bisect good 84a012eb7f1c73c86304373b5c302fbf15c38cda  # 00:59     20+      4  Merge remote-tracking branch 'jc_docs/docs-next'
git bisect good 9d99be1bcd44e5ce75128d754b72abcf2d7df9a7  # 01:18     22+      6  Merge remote-tracking branch 'trivial/for-next'
git bisect good de0195ee24b6f36b443c8a5adfb122f448bc960b  # 01:27     21+      0  Merge remote-tracking branch 'usb/usb-next'
git bisect good 7aa8bf662a4d5d48b8387bdb3b24be715efff72e  # 01:37     22+      2  Merge remote-tracking branch 'gpio/for-next'
git bisect good 8f7b1ed0e2bd0757e755c44911a4856d752b48af  # 01:59     22+      7  Merge remote-tracking branch 'y2038/y2038'
git bisect good 03ed36f1929f3243b8562d09652933bb4193f49f  # 02:14     20+      3  Merge remote-tracking branch 'rtc/rtc-next'
git bisect  bad 1036073cce5760fa95224f051bf381695f13cff1  # 02:26      0-     13  Merge branch 'akpm-current/current'
git bisect  bad bcc39723928e838f38eb364dc2b3c8643542540d  # 02:41      0-      5  mm: THP page cache support for ppc64
git bisect good 00f83cee9cf1fe8eef0b00e946de9360e4214f3c  # 02:52     22+      1  mm, compaction: fix NR_ISOLATED_* stats for pfn based migration
git bisect good 446111661a3d252221bb520150de864f171be219  # 03:02     22+      9  proc: mm: export PTE sizes directly in smaps
git bisect  bad 94b0c842a24d4dfb4c7d47af8ec4ba69123b6a58  # 03:15      0-     19  lib: radix-tree: update callback for changing leaf nodes
git bisect  bad f86cc05c6afed8070517ddc27397497a0b62b425  # 03:24      0-      2  include/linux/backing-dev-defs.h: shrink struct backing_dev_info
git bisect  bad 52f1bb6ac95bf6c292c4d9d8569f290963c09255  # 03:33      0-     21  filemap-add-comment-for-confusing-logic-in-page_cache_tree_insert-fix
git bisect  bad 642c599c5a0ae1b85005f45401ba00156f989648  # 03:42      0-      1  mm/filemap.c: add comment for confusing logic in page_cache_tree_insert()
git bisect  bad a3a18061c987aa9da4f5d3cbb31a9e71e9d7191d  # 03:52      0-      8  proc-mm-export-pte-sizes-directly-in-smaps-v3
# first bad commit: [a3a18061c987aa9da4f5d3cbb31a9e71e9d7191d] proc-mm-export-pte-sizes-directly-in-smaps-v3
git bisect good 446111661a3d252221bb520150de864f171be219  # 03:55     66+     27  proc: mm: export PTE sizes directly in smaps
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad a3a18061c987aa9da4f5d3cbb31a9e71e9d7191d  # 04:14      0-      4  proc-mm-export-pte-sizes-directly-in-smaps-v3
# extra tests on HEAD of linux-next/master
git bisect  bad e05f574a0bb1f4502a4b2264fdb0ef6419cf3772  # 04:14      0-     19  Add linux-next specific files for 20161202
# extra tests on tree/branch linux-next/master
git bisect  bad e05f574a0bb1f4502a4b2264fdb0ef6419cf3772  # 04:14      0-     19  Add linux-next specific files for 20161202
# extra tests with first bad commit reverted
git bisect good d4ae4276015ffb2c2542a4b70cbed3219b73876b  # 04:29     66+      8  Revert "proc-mm-export-pte-sizes-directly-in-smaps-v3"
# extra tests on tree/branch linus/master
git bisect good ed8d747fd2b9d9204762ca6ab8c843c72c42cc41  # 04:40     64+     17  Fix up a couple of field names in the CREDITS file
# extra tests on tree/branch linux-next/master
git bisect  bad e05f574a0bb1f4502a4b2264fdb0ef6419cf3772  # 04:40      0-     19  Add linux-next specific files for 20161202


---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_5841dc7f.kg4dgRh05+FI1LJxj8kK9stx6n6iP0UbedClA9wSSRcYZLpg
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-kbuild-6:20161203035216:i386-randconfig-c0-12022226:4.9.0-rc7-00105-ga3a1806:1.gz"

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
B1F/3+PsazxF64bPHhK0098hFl9l7J8sd7PWxBa2XfHmsFwiukN1/lF8/9DHW8Vr1k7w3y8p
XiZaC//9suKhaPT3VxNvXnOn+O+Xq72s5k7x7y8uXutXFG/h40ZTCoSm4a8onl/kQhip8WDd
ism3FG9ou3m9ZXNDby3ez/JIMXcwSvfvOf6y3VpFx1n4bFBxF6oNpdaIAr/JbyUNjLPlyCRK
tiz4LesmlyYT5K1aas99kvKgGuVFtSiEf1OGVEtsj9eax2xdL9hpvO1Sw5RxvQXfan1l9jb6
7pcvcp7zgsZ/MGHPhNhzPVfz3be+eRvnnEVV/xR98zZ+A77r9d1/Pa/Xd698l1WdhuLnCfzG
sJqVPfJdVvXn8d2gr7LPfrVB373yrdZXZm/Tvvvlu0FfZZ/jaIO+e+Vbra+yVztZre9++W7Q
d692coO+b2Kf5Teyz/vmu0HfN7HP++Zbre/b2Od9892g75vY533zrdb3bezzvvlu0PdN7PO+
+c4TYPHKq+aH+XaCPdvJeQL8s/lW6rtXO7lB3z3zrdJ3v3ayWt99863Ud692coO+e+Zbpe9+
7WS1vvvmW6nvnu1kpb4/yz6LCed8en6LnXyeQj8auFLiDZbudRK/FrhK4k226lUSvxq4UuIN
1uZ1Er8WuEriTfbiVRK/GrhS4g0j/nUSvwZ4n++FvsMnOkjl+MH202zp0TqjtvtLpqXPwwOt
xQfP9gM6nG3fk9QzpvkJbQm91fPD0XP5bmTg+aGf3NJirTmjH/wye4uCQb5YbOwnY1ucQPdz
Khagfdpunl5e4PAJ3eAFFfuWjzcoRwvbxNvwEPt/vkph7ZFT+xyv20fTyuf7MFuCB7SmFr7n
XXHXwfvjxHnlGHhuH1z6oOpvwHf4muU/L+VbdNI98X1RJyl3k/dR5B7SpjWQNUX4E8dOeAIT
O0m4+8+yHM/msLSd8HbC01fsIWSyLtG+uzXbBwk540Wr6ucHrZYXg6eJU4fT/NRBsS/kSJNM
6J5/m6/WL8oomm6Y5ldo2YE/jLODXF0e2LQqOZrAQXLn0wbPd9mRiiktLJ/yoyPQFNM4ohOR
olHU7fT6cBBM/moQL2T1bo5uaJrxFSa+O0BV68VpGMW+mzG6rvF0jJfzLeqKZkqaUuxlbUUx
rQ6698WxE2KRvKnMaVF4RSpoWbZ5ttm9zHb5JJBMHVLXmwbBE9jO31M/pvPWaP9eZLvzmlN0
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
T4f1L7F/QOan8aTJ/CJu/Rp4P+P5I/UP40WQ9fnbHkrWt+N1kPzJ2NN/oH0OeUHO74RIkPY/
ROHfb0HWf0I8yfnHkET3N8V6X5IfEjKo/kDoU9Q+KDvfHapC9ndCTcj6Xqg/sr8WGuh8X5w+
Enr+VWR/M06glsS3FyQ/IU7ADsVXNP8KM0e/r7mj8cO6RzR+tnWPpH+0DZ/R3z+Kxv/+kqxv
hws63xe+5pOMr9zQ/mm4J8kfC48k52tOvZec/w2vIPXlYq0z6t9PXoJ8XxvgkvqKsQ6Y1B9Y
/CH773EfmHy/EWx9abNTUn8popLcf7fHk2T/bq2bkP2pyE2ASf+VpzBN4ruQ84+R8Uj9t8Vn
7UPmkPMX+3zZ+m12o/Y5Z0j9iihB+3dR2uR+iihH+6dRoWj9sBKdr4wqVN8v9nmh9qd60PpV
7fMi7UNfA4DEVyf1JaIN5fducmEkf2zDH3Q/QnQZat+6Uf3w6EHnL2IeW58cUZJfFLPvi7w/
Y6h+zkZvqH5+TCapzxY3Hk3GV9OovkrMOMkfPnVLsr6Xj93vk0+N5CfkM3R/dL4QB+OHfJuA
ob+/muSH52t0v3BueEXWJ1NekvtNUiTI/C5Fg4z/U8zJ+CqPX0HaB0m0PrPZHco/TBm0Prz4
KL899Q3JD0mVJucrU1n+XqoVyQ/Zy1mof9Focv4rNZvsj+d+XpLfktpo/zp1Cn1f9tD+wjrf
Iudz0zRJ/ZY0Q/mfm3yh8323/ZE9nxvgJPHLSf2BtHY0vrJB95OmP0PjZxdD7acryo9KNyP1
XdM3fUd/fwRqn2/AmIyvNjwh+SHpg+pDZjxB88cQIfljGYruB8wwQe9nnEIhiR9C8t/yCBDo
9y10v1JeAwx9X/NIfumtD0L9S74h548yWX5aboJB9sfzAizSv6wDIPktuQ8g0PNJdP4xs5rU
n9mfj/a/Mgfln2S9JvkPWdLkfFaWFjlfn7UJGGl/ytn6Sa2DJN9v7RdA72ex9Z/qIvu/Weu+
yPi5X6H2raXQ+Kq10Pzi9E/Q83F0/jQ7ktRvz14PiZ5/ofps636TnK+59ZJo/2teov3lUVR/
IMec1L/Ko5+Q/mU/Lzl/kZsdkfNNOfPI+vmtPyX1desJOj9Sz1D94XruZP5bL5rk59TtJ0J/
f6P125L3SPtfIobeT9Ei8/cSf+R+k5Jwkr9ashkGej4tZPxWMkHW5zc5Qus/G/wbmT9u8pgk
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
fa2RWJsmpR+pb7n4Uyj+DFkfS33ofu1NjuDv1yH1b1Ot2fNxtP+SehUUEr9QfmbqDciR+IPu
70gTVN8sTZOcr89bwIaeT6D6t2ml5P61tC5Sfyb9ofpat/2FnN9MN0HjkxMAIu+/rwcD6xvp
VST/IX3Q/RoZD+0vZ6ih+ctH4CPxw0l914x6qP0Jlv+cX4GJxJcg9wNmwvnjGiBSnyrvgMj3
lYXul8wcIfkz+/GF3s+SIfcH5fEHyN+3DN1vnuVD8if3ej40/qwSkl+R1ZKk/bn11yR+P0Xt
W4ui8UmrofFzG7q/L9ud/X0j0PptJzp/kV2B1ge60fms7Aly/i6HnU9Z987WNzY9IudPc26D
K4nv6H7tnEi0vzOJ7g/KqQ2hSfxG94/nDIpf7xq0JL4kWf+sx+5/3+w6yf5XPU8yPq93DH0S
f58Xej6VZP2nXqP2ud4kyU/Y7CLJ/lqJJDn/UqJJ8pNLLMj5uBJH98eVBBpf1WaPD4yvSgqN
b0s6yPjhyjNk/lX60Pn6UkmyPlm6/pe8/2pofFsK+1+NJPmTpYXu7y7tIOdbrzxJ1sfKnpPz
WWXiaHxiauT8S5kZez6uZH2+LBS1b5ZC7q8pOwF3FH/I/mNZD7lf5msvkPbBX5P62+VSaHzi
WkWev1uh+a872l+r01ch439PdP97nUA/ev7Nxlc+SfID93ImyZ+pWPNP2ufQRO9nGKp/VeHh
pH+JgM8nk+Sfb/YrZP28NjtF328Kul/4pmfR+DAN1RettT7kfszKUzAl8VNR/5ulStqfbHR/
a+UoOV9QG52g8WcJjK9s/rUJMFo/2QCanC+uDSDQ+GENKJp/7QVC84tqQftHNej8SPUTtH7e
gvLTas0nqW956lTk/F21C/p+O9D9zrddmD2fE8Ai8fuh9aUrL5HnM++h8fPIQ+OTkWHPh90P
VeNP0O8PGD8F7W9OofoPNa2k/k/NXiDwfd12HDK/WPfupH7p0Z9J/kY/M3J+s58bqU/YL5SM
3/qlkvOJ/UpJ/9KvlfS/692VnC/Y8FbJ/mNvdEva/xZF54tbTEj+z2ZfaH2sJYTkZ7aw8zst
7Hzl4g85X9nS6P70lkH3y190gvp3lSb3Q7Uqup+31Yqcf2n1IuezWgPdD9Lrvcj5wdZC9/u0
Nqov2jceSr5fe6g+Z9u6F/J+nrwfeT/NDI1vzY3kJ/RG/2T9ti0Nvf9WOuj3Nxs/2yjJz2x/
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
xy8i7UP5kPr8XjHkfI1XNslP9ir4/jdr/2tQ/TFv0Ufen1bW/q/5ROPDdnT/wjovJec7vFNJ
fp13ofuVvJvtX/eg+4983iP1dX3kkfq6PpqPzI/mGC4k/glMk/hR5PyIT7L99z19ND+dDlL/
ymec1P+M95zs78QTdP4i3inQk/jHYCLxw8j4JF6i/f14JSR/O14LaZ/jzSPrq4uP8q9C9g9I
+yBS6P0RRfWfQ1h+bwg7HxqSqH5pSAXJPw9ptH4VMqz/0mekfkKoGFlfClVF/ZeakPWf0PW/
6PmfByDxMwb9ffux96fR/kjoNMnv3eiqSP75Wv8i+9dhmknaf7Mg6zNhHqQ+6oI72V8ISyfr
S2GF8mc2OTU0/vGH6r+FC1p/C1e0/hZuj+QXLf6Q+mn7uobkV4cH2h8JT1T/Obya3O8TV6Ak
788VIMjzD0Hn7+ICRNK/n4Mk788aIJLfG3tAJL83IlF93Yhi6z/Rj/19R0l9sMhX5PzC/rxD
6mNEaqP5aRpbv0pH+9eRge4ficwi9Xki20j+yW2fJftTa37Q/U1Rm0CS+VE5yj+PSkX9+9Fb
SP9ew/Zf+jXan2p1cj4u2h+an3ag+0Oj4f5UNzrfHdeeIs9/JNHfd0yatM8D+99Z80/mv1NF
zo/EDKoPf9t3yPpnPkX3P+ZzJffL5FsLCt6fNT6ovkHe/iDQvqW8JPtHudaT5K+m3IAoiR/o
/oKUQvUnU7rI+kzqM5L/kCpDxp+phurPp4ag9/8WhKPf30LuR0idIuf70sRIfaQ0Rfmfa5wd
tW+2Hhg9n9oQjsTfABqMn3PTL7L+mSdAQ77fE2hAvz8Uvf+bXpD9wfQ2sv6f8VD+TIag/OqM
E3Ah8R3dP56R6P6+vAIZmb9sAo/Ghymsf7/0nbyfeRvSSHxXUt8mM5Tkf250qOz9KSH7d5kt
ZH9qg+dHzndkvUfOdy/+kPu/9udF53OzFN0vc9sF0Phwsxc0PqxItH5464nQ7y82P60bQCXx
B91/l/2C3D+75hPVL9ro3El+1ydfQcZvN3+N/r6hZH8h9/qj+WOvf0fvTwvJz8le/06e/7yH
1mdm/Tt5P9e7o/2R0Sb3Z+XtjyDzx/H1wCR+JMnPyZvvJu3zzXej95/dT5ozqD7thv9G8rvq
iZP85w0O0f3jdes1wPtTz9H6QL1QMr+ol0rqp9V6R1Lftd7m7+j5jJD9nZJbAIPio/69RIbM
70pY/nCJFcmPKvEi88d9XUnOP5asf0e/v1B9+5IO9nxY/fzSF+T8b6l4gvlRqTpqP9WM5O+V
upL5e2kIap81hazvla4FQr+/UX5v6Qg5/1v2UP2Bb70waZ9NH5pfmD1yvrjMH+p/LVD9urJU
9H1ZOfv7svqidfsvyO93MfT3dS1S/6Hchaz/1y0AIOM3T0HjN3g/xb6uR87vl89D6zMnUEh+
f7wm989WSKH+N/b9kv4lrMj+S4UnOV9QEYHe/ziBfhJ/XzBpn6MdrW/EGFmfr3zofvl1juj+
l8pNUEn/ksbWP9MfqT9WeQqsKD46f1GZ6H6xyhqS317ZTfJ76/ZrkL9vvUK/vyTR+1OaaPyz
CSR7/h7k/HttAIH2v9aAkvyB2h+Y1O+66V9yfrlqhORPVj+2vtHyyP0Xiz9of7l10P5FG6o/
Vu2F1lc7Cu0vd6L81erNAEj/0h0kf756HO0fzTO0vjqC6lvWqKLx4RjLr7ifFz3/QOcjalLQ
/GtKSP5eTT/2/gyq/7z4Q8YnX/iA4suQ8y/9dEj73M+anG/q56i+391+0v70yyH5Ff3OgpL4
PeT+oA2fH6lv0yKofuZtRyPr5zfdR/LrFh/dj9yy75e0PxJN6ie0sPsxNzkqkr+02XuR/KVN
T5Pk9/Y+L1K/sVWS5F/1huekvtxeziD1H1rdyf7mt54UPf9E5y9aC50fae0k9TlbN4Ehz99e
kvyoNkmSH9KmSc6/txmqD9nmhcbPFkXm121ZaPx89Hn0fnax93PY8zl9J/J8XJLsH7VrkvoP
Nx5N1lfbPUn+RnvA58/OV7av/0XPp+HvH7S/0PEKja9Cityf1aGF5r/HTyPtWziq79ERyZ5/
ovNNfQL96O/b6H6EPgFu0j7kS1I/v1OSrM/v6Sdaf/gEOkl8h/ED1Se89jJaX8oK9P1udsSe
zzipH971nJw/7RvQJd9vKYxvTs6/bPaF7nfrI6CT/qXWAKH35yZUSPxG9f+7xtH+Tj9UP6Rb
rMn4sNXQ/LfN0PrVJthof2cDdDT+3wAC7e+vgWPx21H+Qw97/vPQ+f0egb9fjeQ39pih/fdx
dP/FbX8n+XW96R1qf6aU1O/qaVRfq2eMnG+d0wcD44d563/B+zNv3y96PmZkfrHmE8YPI+uT
89LI/bPzStnzaVS/Zd6g/OGRh+6/GBEYX5XUtxwxJedHNjxRcn/QSCjZf7ntNWR+MbLvF73/
reR8x8goqa87+oScPxoVVD/qTgf9fdWE7M/Orc9FzyeErA+MJrpfddb6oPHh6Xeh92fQ/dq3
PZrs74+JkPvrv/Ej9PvtofmLsfupx+KR/eWxhPHrofHtZndkfX5sMwzS/vtj35eLkP2vcVWy
/zJuRvJnxt1IfeBxtn41nmx+5KVkf2e8leRPjg+qnzMnP0P6rxAl52smVEn+1akPk/zbiTNA
JH6g+7snUtH4J4qNz+MmwEj8YePDfELqz0yKoPb/rg96PobqJ0+6kPMjkwGfT6L6zJMlhn5/
C2r/c9D971PvDfn9Jah+wpQ+cn/clKHz0VP+UPtf8dD6aiWMXw+NP+sITCT+PFI/c/qx97MF
3b8zvf6X9I9t6H7qaWf9+w2QkPWB3gCIfF9dQvI3plvR+LBHyP16J/+D9o8G7h+Nsv2FMXQ/
yK3vQ+3DhKDxySZIpD7DbIBI6g/P6Wuhv+88Tr+3fvcX3Hz34cvj9HUPXx+nv/2n7cyO4IhB
IJrRlrgh/8QWJof3bVd7rJU4m+bwDT4ff1x97PDjcfXzDx/ULz38XBdM4tdw9vPwe7j48PDX
QJDvS15z86GHL+B+w8PX4vK7w7fi+neH7+D89eFHcf738LM4/tLhF6h/dfhdDz3/q2CB+HoC
hSS+gPs9D19B/bHDN3A+/fAd1Ac7/AiOv3T4GRz/8/ArUP+rHdz86eFPcPnF4tsGWOT33/oX
rD5/+Bpo/GYWHD/z8Pf9ku/LIjj++eFnoPH/hj+o/bEG57sPf8D56MX355y+0OGLc/y9w1dQ
3+DwzVH/4qQ+wOGHc/Wxw0/n9CEPv5ybHzn8dk7f5vDHUPsT6wHI+x/k/rjDV+P4UYdv4H69
w3dwfvPww1D7EAnOhx5+wd/fxs0XHP4Yat9u/yOKL8bp6x6+gvPph2/g/NrhO8gfPnxyv/Ph
J3w+pWh9OBvcz374A/KfF7+eov6lSH714Ss4n3v4pmh9vlzR+uotqEbxk31fVfD5t6L1+RqQ
P7P4/UD+/OGLcvuzDl/h8zHl+OeHD7/fDuX00w4/wf2nh1/g/MvhN3w+5Hzx4s8D50cOXwTN
X47fRcYPKL/r8F3Q+vOQ+gCHn6x9mxJu/8vh34YiEn+E0++qn7yH2gd5As7XHL4KWb+SZ8Lt
Bz98FzJ+kBdCxp9yBQ70/pSQ+Z1sgMjpLx3+SJK/rzzUP4qw/ldkw2fQPu/jBec7Dt/B+dDD
j0fyE/bXfWR/WaTA+anDJ/cXH/6w56MPnJ86/PUw5PtVfah/VwPnHw/fwf2thx/w/UmUP7/4
KL96g5Nh738Pt//i8Ge4+aPFt43QyfMxGTK/W+c7ZH9TzIbs34n5oP7FYsj6klg2yY8Vq0bf
r50APYjvD63vbXjoZH9cfPNT8vzdk+R/iqeS8x17+s3N1x/+OMkPl9gMmPz+0CT7m5tcg/PL
hx9F8itu/AW1P9FN1g83vTOSPymp6PyjpIH70Q4/2PpPHoGDxG8l5wskZzh9ocUvQfnVUieA
S+J7kPOtUikk/0GqhtPXOvwJtD7QIuj9by00fms3Tt/m8G9BKYlf4H7Gwx9Qv2vx5yWnP3z4
Cu7XOHxrtL+wz5f9/mL7X9NJ9n83uEV/X323QILENyPrw/q8yfqbvnQyPtfXQs5f6CP3vy++
CMqfVNHm9JkP353kb+smSCT/QTeAI/UNVEbI/qDuAyPzR1VF+W+qhsZv692N5N+qJlp/Vu3g
9qMt/qZf6PnYXn/y/pgpOd+n631R+2OpZHx+20nJ+qraOLcfcPFdBLU/vg8Y/X4bkl+qHuB+
lsNPReNDLyP109Q3/EG/f4Kcj9OjF5Hx29GHyfcVOmh+F87G/xGbIpH4N8BJ4peT/FuNDvb8
B9X/0XzJ4kuS/Chd88zp3x6+JcmfWedSaP6YUaj93NvD7Tc5/EL5IXt72PikrgBH4gtaf9Zi
54+0DO2PaDmoH374gc4XaKWg+UWVkP1xLXZ+QWsErQ/f/C/p31tQfQZtVXI+S9sUtc+bvqD2
7cI3Mj7sNLT+0AWfTytqP3uU1H/Teaj+jI6w72vUSP78Xh5U/0rHUf0lnTDUf03C31+Gvt+Z
R85/2Ya35Pfbk2S/34Scf7HnRfan7KWR+hL2akj9BHuD7r9Y/CHfr115nvx+eP7UxND4edHR
+fR9vUbGzxscFlnfNulH8lc3u0brD6bvkfwuU0Hnc031CXo+RuMPOZ9i6uh+GdMYkh+12emQ
/R3Tam5/6OF3k/pgN/5I1q82OC9yfs1Mipw/tf2BWXxD+b1mniR/frPHJOsbdzxkfcaM5b+Z
Nbqf5caLyf0a5i9R++wSZH/BXAPNj07/n/x93Z2cfzQPVN/+zA/Z39zTd3J+07yNrG/b6f+T
7yueofH5tb/I3zfUSP1bi40gyPsfbg/FDyX5Fevelayv7uVRsr5t613Q+CcG1W+3fErO11vK
pvAk/jFwSfyNQMn8Kx3VT7CMIPkzl12Q+5ctK9D4PNtJ/VjLiUfi1wlQkviSaP28NNH6fxm6
P/TWu6Hvt6JIfuCmp61k/FnVJP98jf+g+UvNkPMv1m9I/T1rGbT/2DrkflvrTb/I99vxyP0v
1vlI/oZ1CTk/a90oP9BOn588n3mK2ucRdP+CbfiP3v8xI+cfb3wNjX8mlJwftEkl59dsCp1P
sWlD49t1j2T8udYf3U/q7xTsSHwNsr7k7ypAJL6j/Ch/gfZH/BbUgfGtv0L3g/trtH/hj53/
cnlJxg+3PYLU3/BPAJrEtyT5wye/Ss4nXnuNjB9c6pH1H5dG57td5pHzuacuSuZfroLuj3BV
lB/rJ5BB/r7q6HyZayjJn3FNNP53LSP5La5tJP/tpoPQ39c2wELxxcn6oZs6uV/e7RgEJL47
OZ/iF56T9t9Y/bebriH7+34FOPT3nUD91yYYZH1mf1xUX9fPAZDvdy8o+n7di9T/X+uQ5PyR
e6L8zz0eVH/DvQu1Pz6F1k/iDclv8RC0P+JxC3JI/M3gSfsQgeon+PGL0PtThtqfaEPrezce
Qd7PfCi/1FOC5Bd5aqD5aRrKr/B0VH9vkxd0vmODzyH5e+t+h9Sf39NH9xt6vUfyYze6Yusz
pcJ+vylqn8uVnK/0CkXz90pD+y9VKL/x1luR/A1f80Dyb/3Wt5L+sSXJ+QJvLdR+thU5n+u9
/wPSvnW0oOeTQ+qvbnqH7pf0Xv9I2od56P5cH0H1231UyflHHzOSf+izFpp8v5NOzr/4rHlD
v79RfWOfQeuTsc+L1Lffw0/y/sRT1L/EY/cvxDsPRuIHqj8Qrx4ZH8b+OckPiTeC3h95aP4S
tx8H/X5WHzLE0PwlxNH53Nu+SdbHQtJJ/aWQCrL+H7IBNHo+k+R8fehD95vERp9kfyFUh+Sn
hdqQ+W/oehjy/Wo+cr9YrHVG/bu2kPy00FH0fdkz9H6efB15/nYELxLfErX/J5CB4m/6QsbP
Vk72l8N6SH5X+EPni+MjgJL4hvL/wwPtL4RnkvoJ4bB99ilyPjeC1a+OdWDo/d8HgNr/CJTf
svBK1vciGq3vRT6UPxwpTfavI83Q+DN9yPmgyHT0/WY/9H3lBFk/j5JH9mf3+QbJP1zrg+5n
iYok+4NRJeR+z6guUt81+inJD4mWIucTo29BLInvTeoLxe1PIe3PuUcyPukxUv8h5jVa3zt5
MxTf2PrVRKDxyayDIf3LdJL3Z7N3IftH+QTdz77hJ6pPks9R/dt8ifan8lWS+XW+UVKfPGX/
A+D7TVFUHybFitTHOHo1uT8r9/k2GD/krV9Gz3+K3N+dKk7yi059lZz/SvUg+9epKY6efxVZ
f85bkEaej216CsY/abfBnsR39vc9AWL0+wvVN05rVD8z/Slqn53NT9MN1Z/PNW9ofOIZZP6S
3orGb77+EcxfMgTVf87Y60+ef7iT/PCMjdBJ/x4VLP4oqT+QezwkfyY3wGqwfptroEl98sxA
6+e52Tt6f7JZ/14P3Y9wx4PatzJB47di9ZFueyLJ/8/aCJr0j1VO9kcuu0btWw1bP+yXZH88
Wwq1D61N6lNlr3shf9+T5yH9V+cj+5vZm3+h+K1o/t6D7gfPeU7yf3IkUP+14SGpX5d7/GR/
M8eL5I/lRKP3cxLVt8mpIflvOTfAyeHXe0Lqk9QTI+u3N51F8nvrmZP1q3ruJP+tXiTp3+tt
hgS+37rxFBS/m72fMyR/47ZrkPz8WutDxlclpmR+V+Lo/oWScJI/U5JO1uc3fQ8yfitpdL67
ZND4p3T/Anl/VND457o7ZH9zDx+dfykNIfPr0kTrS6WlaPygm8Cj3z9OzqeXvUD978mro/ha
JP+zzAq9P3YKSSR+oPvpbn0iev+tYfxB6z97OdH+/tHz0fjhFhiQ+a/fBmkS3wPN7xaexd/0
Dj3/KnI+vXzzOxR/huRP1gmgkOcfKqj9uQFy9Psd1Z+sCJT/UJFOzodudhekvn1Fs/ljTKL4
+QrNv1LQ/ch16x9J+5M2pD5zHUGKfF+ZrH1b90jq4936azT/zXGyP3XsZDR/LAnU/+7PS86/
VFmS80e1ARyav6wBIvX5Nzo01P9Wo/MLVeOo/+qXaP2tJUn96mpF+bd1+szk79usvkH1/rzk
/e9C9z9WN5u/9ChaH5iH6jfWiKHx26iT83E1Fuj9HE9S/7wmkpxPrElU/6dmPQx6Pj1kfab3
b5D8rn6C6iv2W/MD+q9+JmT+derDZP+rXxi5n+Lot2T80K+cfF/9GtXPWeODzu+3PNS+tUih
5yM6pP3vde/k/GBLPNK/b/gvJH/7o7ej+G1kfallnJy/aH2O2n+VIPvjvb8uaj/VCrU/6k3q
n7dGk/s7eo+f/X0vgiPxB90f2vYUPX8TRf2LKbp/c62nKxlf2W3oJfED7X+1JaoP3CefQ9pP
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
Tz0KPf+GD6S+QbUpWn9rR/UJq9PQ/LerUPvT7P6Fmldk/7dG4fNbo7/vHMGLxK9H9vfX+QZZ
P+z3hOT/rPlMFn/tG/g++50CPYmfqP5Pw/2LfqNkf7zlofsZW06gkMTf+A09fzg5X99SQu43
b2Hrw60P5ce2Cjof3et+Sf5SqxfZP2rd/BSMD1vZ/LR181Py97WXZP12w3918n4Mtm8WTvJz
jp5Gzle2HcELxPenJH+vvwWrJL6h8Xl7CBq/eSY5/9K3QIX8fn2KrK92CLo/rsOE5G90ONp/
6Ugl+fkdVaj/jTGyf9S5CQCKz84vdLqS9b3OaHI/znovJ/s7nSOkPlXD8zW90T+af5Ule/6w
R9rPayCR8XO1ofnpekdyPrqvQED6x9Ym5xN7AziSv9QdTfIPuwvlL/X+A+R+yZ6naP515pm0
z7MJKvn9jmeR8dWcwg2JX4nWZ2bQ/HH2D8j9I/v8jeT/zDN0/9G8ULL+My9R/cPZn5eM/+dN
kvnpiCip3z6iSfJLZ9Nr9PuVQPtHI4X270Y2gyHPr09J/z4qSfI3rr1Pxv+jt8GexE/2/Wih
+vyjo2R9bOyh8/UbvhnJfxuzIvnVY+z+9LFMcj5ljN0fNzbo/N24KFkfmHWPJD/t1hcnev5A
5+/GS0l++HgX2d+feBrk/YQUqe8xt+AQvR9P9H0Gm/9ObP5Lxucx7P3nK3K/8Nx6DdK/pKH6
HpNhaHyYie6vnDwGB4kP5783wE/a/3Uv5PzLFLu/dSrQ/Ue3XoPk50zB/rffI/sL04Lu95ze
9BHFL0Hjt3no/OyMovsRZhMA9vyN9kdm9gum/Lu9373nHL/lww9Ov+jDL25/x+HL4+avP/x1
j9T3++GbYvN3H/6mj+j9XIUSxFfl9FU+fBcs//3wSzD/+OEPVz85fJPA9O0/fBds/u7D3/CH
ip8P38H9LB++KKZf8eE7t7/+w28Ryv9++MPp1x1+KLcf58M3Tn/swy9uf+6H358+w49f//if
f/PTn//y6x9//vHjp3/97S+//OmX3/73r//7337501/99MuPn/7nxy9/+o+ffv33H7/+18+/
/fzTj59/u//i1z//9tMffv8vf/eHf/j73//jP/3tP/8/6nBT0YefyqmefPjGsR4+/GStcg4X
9R9+KWsVygpTPfzwk9t69+E3t7Xg8Hu/W/L9t3Cq0h9+KDY18uE3p2p5+Ju1o/ZhRFl8cOvg
h19Kfl/yHqf6/+FLke9HXnCqSx9+ORl1ijx9oP+6paTY1NSH75zq/4df3FbJw9e1P+D3K3pj
9ST+pkWkfbithuT93FJn8v3Yxlfk+zdDs3ax4qq2H/48jJVz+K5cV/zDN0XtvyfHavzwh32f
oYOpwn/4wbGKPvzmVEkOP19gXccP37itsB9+cqqNH345xqo7/HqGdQU/fE1MVejDDzY+rwpM
tf3w+7H2s431Lyc7QMaHHZwqwOHPU9S+jaJdUxlHq/IyyU0tf/iVpH/X+wPQPujzvSISf68H
vH+Vjf/J+xfhpoI+fONUcz78eKT/Umn2/JtfY6yrD5/tCup1xcn73/wam6r58EfQ97P5NTbV
9+Ebt9Xhw08lWTNqjfbX1B83dfrhi5H5u3pwqtIffgk21Xf48VDWjMY+HzJ+CBeyf7Qf1z4g
Er+NrD9rvibrt5om2NT1h8/2ZzVLyP673tpH0v4XW5/UYuvzWiGY6ueHP4JN5R7+kaLI+LyN
Uz388EFVzg+/2e+rRzFV8sMfM7L+oJNKxs/2npH1bXvGqYZ/+LfXEMSXp9jWpg9fOFXjD7+M
9O8bPCumSvjhe5D+ZV9nou/fJEhWu1lwqrEffjbJ+je/ChyJ70L6L/NE+W/mVej3FSLo+4y1
oOT9RArJH7ZoNP60GBXyfaYK+n5O9ZZ8P5lJ8qMs56HxSQmnmvPhm2CqBh/+ukcy/qwOcmrQ
+gm2NevDFyH5J3ay56T96WLf/00tk7/vpu+ofRhH+3cnuoR+v7P2DcT3x07N+uaPpP30dwVK
Ep+NH/ymosnfV1ywrQIffnCqeB9+KelfXE6XBMS/qWjy/tVR/+4aKL/XT1URjJ99ozeSf+jH
rwbjB7dA+UVubWT9dtN3tL//DUWT9scTVQXwW8pLnn+jc0w188M3tH/qEej83Yk2kv1lz4fy
K47+T86/eIKqPx/+5i/o/XSi8WFOkvG/F7gV/MNPIeu3fltfyPyiBp0f9DZu6++Hn0LyQ/zW
7pD3P09I/rnPxlcofqD8Fp+C8cfJ+vOGD0rGP3GyKuj5B30/tzSRnM8KCbT/GFJO+pfQJ6Rq
XWx6TfrfuK0L6PkTVQW7nTVkfyeOvoTiOzp/HRacqu6H3yj/PPyh+Ve4ofF5eKD9ndgAneTX
hY+T/M9YA0fyDyNcSH5RRKL1jciH8lf3+KiqZaSh80GRidbPI9e+ke8zwa07h1+K9l+iPFD/
XiXYVtXD74fmL9GiZP05OhT1Lz2Cxg8jaH8/Nn0k+YGx+TXZf4lplF+d76HzKbn5NdkfzxdJ
6hPmLS0D7X++2wsI4os0ad9SHM1/UwLNTzd6Q+3/RidO5qep2thW8A9/PRhpH7SCrN+mPXR+
PE24rXcf/iaQ5Pu8/jv5fk7fjLx/F3R+P90E21r54a8FJe/fC+1vpk+gv28oqu+XsRdE3k9s
/kLazw3QUft/8nsovgXqf0+fjbQP2Wh9JnNQfnKWCsm/ygp0K0VWwfdze0lB/FZ0vjvbpFD8
jdBJ/9jNfr/z0PrSfr5C6svlODp/kVMPjQ/n9m5y+LXhP2l/6jn6+9ZLdD59f130+62rb4D+
vUSH1N8rSSXnI0qmyf5yqT+yvlda6Hx9nTwPef/mTW69K2vBtiJ/+IPyb8vVyP5RHYGevP+P
gEviz1PyfkIemR9V2EN/30gl9ScrCt2fUvlQ/YFKNTL+vNsh9fcq08n5sspG9VWuvUzqH1bZ
I/kDtfl1kvdfjfZ3qgad77vjo/ZtowfUPnSi/P/a/Bq9n9nPi7Q/o4PmX9NC6pPXjJD9634v
yPjqW18A/r79Qsn5i37sfquWJyT/bV8nWv/svR1yfrAl0fnHlgqSn9m3vwz0762K7i9rNVSf
pDWTzF9a28n5lzVuyeJv/kXev4WT/LS2RvljbYPGV+36UPvg+4DQ8ycbP3gLqS/aG52Q+V0H
m391pJD7ZTrKSP3ATkH7g52O6kv39ffJ+89G+TmdIyT/rctY+1CuJD+nK4zkn3ftAyXj5ypH
869aC4qef4Lsj3Q/Nj7cBIOsX3VroflXW5Hz492nMEHiR6H+aw00Wf/sfaBoftSD7sfpeUrq
K+7xleTn9LD9xx4z9vyngEXih6Px+aST/N6eQvl1PZ2ofT7+Evj7ztv0BcWXIvOj646T+orz
/JH9/XmB9i/mpZL68/NKyfx0XhuZv88bdD/yel/Uv4xseke+z83uyPmgy05JfaQRD1IfbCSC
3A84kknyu0YKzY9u+pTkT45Mkfoko6/I+OS2X5D9x1Ftkv+z4TPr39WH1OcZjSH7F6M5JD95
vRdaHx4dVF9x7BkaX5kY2R/fx2kk/3/TRyf742OO5ndjt4CWxE8n64dj5eR+h7EO1P7YBGp/
/CU5P3LqnGR9e1yb5FfMCcST8Y/7kPoec/Pj6P0Xup96vFF93fFB+Y0TT9H4P4TNf0ONxV//
SPr32PwR/X0jyP0CE5nk/N3s6cn5yvNe5H6xiSnU/+Zrkl80t56OvJ9c80DmX2no/t/JNdAo
fjTZv7vtCGj9JOH8MQfdfzr1DLU/JWx9qbRR+1z+SP2HqWDjn3UvaHxeFaT+0lQnGt8ef4b0
L/2C5A9PS6D9x9ZE86N2dL/tdDjJn9zkscn52elG53+nB+W3zzwh9Z/n9GnJ9zmK6ofMGFsf
GFfUP16Cir6fNHL/wswRcEn8NvZ9jnH6//K7/QPj+GmHL8b5r8NXsP5/+GZc/nv47px+y+Fv
+IPZt8NP5/qbh1/OzQcd/qYX6PuZ5Orziy8vufr54Uty86GHr8nNLxy+JcfPOXxPTv/n8E/A
hcQ/BVASv0D+5OF3c/t5D38zJNI+64a35PlPXhQ9vw5q/9e9c/33w4/H8ZMPP4Xj3x4+ud/2
8Bvcf3f4A+o/LP7pz5O/r62DxOrnh6/K8Z8P30D9wMN34/Lfww/j5isPP43THzj8MtR/WYPz
y4e/+Slp33xviIw/XfYLI/HXgZHfr5uh9t892fPn4/T/D78eV588/Ab16w5/QP2HxY+n3Pz7
4Uuw59dA86+w4PaXHT6pz3/4CeobH347x084/ClufnPxj39C+sfc/Iu8/zRF7We6o/4lU9H6
alai8Xn2cPzJxV/3hdYP6w1afyt9aP25FJxPOXx/qH+peBx/7/AT3N90+AXqRx1+K8dPO/wR
NL/rq5CR+ALqzx++sv6lyf1uh+/gfPfhB/s+O5Xjlx5+CTe/efgN8n8Of4zjZy7+PJCff/hi
3PzC4atx/J/DN0P77+Ogfv7hB2vfJtn66hSoD3/4Z6BJ/AH3K8nv5D0j8195ouT9y1Mj+yNy
DQAU343jpx1+GNmfkk2AOf3Mwy8r9H22c/onh38TtCD+PiAyfhAR4+ZHDl+drC/t8Y3TXz18
d46ffPjBvk9JUN/s8Av+fRvlv4mMk/GnXPmHPP9Gb2T9TVSd5C/Juneyfr7mB9R/OPxwTv/k
8NPR+FDLyf74RofBnn/A/WuLby/J+oxsdkH2d8S0uPniwzdQf/LwvUj+qmx0zs0vHH4Wp592
+FUkP0TsFHBJ/Bk0f/Q33P7Ww9dH1g/FzdH8zkn97cMPUP/t8LNI/oD4fl9k/OyN8hPET+AY
xI9XZH9cQpqbXzt8bU5f9PA3vCXj/9jwDb2ffNx84uHXY3/fftx+wA+f9V/5Hjl/tPjD7T89
fNg/Jrm/7PA3gEDPH+D+wcNPtL9/2Qs53yHZSs4HSQ4437349YycT5TaDB49vypa3y4D9S0P
Px57/nrcfpzD7+b0RRe/X6L1n1ZH6wPtitq3TnD/wuEXOr8sPUbO98mIoPZ59ucl7388OH3I
w09N8v1PCxrfziQZv+kTlF+kz4TM3/X6++D70RdO/r760sn5en3lZH3ptueS9U99U2T/V0Ue
ad9U9v8APb+h8b+KP1KfRyXA/dGHn0LWN3QTAJJfpBvAcfqZhz9K9n9Vn5L1t2OHk/5dVVF+
7MIbez+OzueqRpD9TdUMbv/v4Vck+X3t6yfrA6qTJP9c7QXZP1KTDYBIfE1y/mU/3yLnX9b6
oP1ltWiS36iWoP754deg/tF60PzIZsj6kvpjz+/Kxifrvsj+lzq5P/fwS1D/5Z2kvoTGxm/k
/cdViEl8dr5Aw4vUb9RIcD/a4VeR9VuNAfVpFz9fk/zAjR7A/aeH7w+9/4wg5zc1YfuWnaT+
sF77iPRfJUny3/bwSva/tDzJ+SCtNHL+Ude6Ofp+Bp0/XedbaH7Um+Gh+Fao/ewwcv5dO43T
5z/8Avd/HX4Hqe+hPUHy53VeoP2RIfebHL6i8yM6FqS+hI6j/AHd7Jd9P+mkPqdOsfHh7Xcg
46th52ftFhiA92NPjJyPWOeo7PkNxnch8y878wx+v/ZY/eoN3oTk59hrcD/R4Y+Q8Y/JeyR/
w0Qead/sBoDR8+8XTL5PWfNMfl/iTfJnTKLR7/fSa/T3rUbtmzTaPzKZIvMX0zWg5P2rFMnP
P3l7sj5j1wAD6w+mnuR8q2kk2X+xK1Ci568g9QdMG82PbBMwkv9sGyCS/XFbBxPk97UfAJn/
mhmq37LwaP/RLOqh90/urz/8Svb+O0l9bLNJUn/G/AWav7gEej+uQc5/mRtr//fzJfm95imk
/uRaN5SfYz5C9sctHrjf9vAlSP65hRY5f2RhqP7Jfl2J5o8Bx5+RaH9k3S+M30nyuyyGzV/y
ofsfLSVR+5AmJD/H0tn3n/lI/QrLIxCQ+G1o/SfHH/n+6zbMkPiSJD/BSoPUR1rvhfLnrTZ9
J99PRaD+sRLdj2MF10+qm9x/ZzXo/iPr/QPy/C1D8m+t7ZHzX9ae5HyN3fp09PyZaH/59AfQ
99PB3s+w8e28QPubI+j8mo062r8YQ/XJbTxJ/oxNDFof3vSFxa9B+8vT6P70k/8k96P5e0Xq
s/mTIvXn/ejh4P3femH2/h3lz/sL1L/7y2DPX2j93F87OV+wyamT86HrXJycL3ARtP/ookby
S10M3T/u4kbmp9feIfW9XVJJ/olLKenfXVrY33cDUPL96zpg8v0ry99zVVQ/1tUeyU9b/CHr
V66OxreuMeR+mU2OUP2BdV5N5neu3ST/xO2h+jbrXVB9CTdTsv5w8vxo/Ly3j36/Vmj936/A
QX5fmwCQ8wW+DobkV7tbkP2vm55C4x/PRO2nt5D1c/cJkt+11y8k/81Dg5yP9nB0v7ZHJDn/
6FGbAZD4nWT/3fMJqf/mKUnuH/H9dUl+13rfYO8nWfufBb+fDZ/J+6+H8kO8lP1+y9j7r/W/
pP2vTLJ/7cXqS3tNkPpjGz4Iqe/hrYG+z3ZUn/am79D4uUvI/pQ3u1/S5wnqHzc9IvUlfOD6
0lyETuLnQ+ufswaajG9n0P1B8R6qHxJP4fNbkN9XvCPok/iJ9qfi1ZDxW7xB578u/SX5JyGK
zseF+CP54SGbvpDvc6NPsr8T0kbWN0ImyfpwqCipzxmq+dDz+wa4JH6g+7lCC60Ph3aQ+nth
64BRfEmy/xWmQeovhW1+TdoH8yDnj8KC/X6Nnf8KK1SfIazR+kPYsPj+gtS//crn6Pk1yPmg
cHPU/rs7ya8O3xeE3n+i+z3Dy0h94/BWcv/UOl9F388mqGT9OS7BIO3zBqCo/90AYsj8IhzV
x4v9AVD/te6d5KdF1CP5IYs/aP4Y3WR9e7MLFn+jT9S/5CbA5PtPLdR/paH8sUgv9veNIvcv
RGaR/PDIKrS+lJ2o/81J1H7WS1J/JkrQ+Y4N/gPNX/b1kPObUcHWxyrR+ZG49Quk/f8/2s4s
CZIbBKI36kDs3P9iDXWHZ396IqeslliTpBrdH72XE+UnR0uR/d/oVyS/NFobtZ9tjfZHOh57
Pony96LrkfzqDT8Vrb/1KBq/jTxy/jTmKVpfHX2k/meMsfdnHOUvxQTKb4zJh97/qYfG/9OC
9ndmhOTXbfApZHyV8oTcX5miQs5vppiQ/IcUR/trubeTtD+56QtZv0opIfVvF3/I/lRKD5m/
p0yT/MC1zoXen/fQ/Qj5FN2PkM+ajD/zeZPxz0bPTfIz8yW6vzXfLSAk8TcBIO3zyY+R9kcF
1T9Jfej+xFRNMj5PNVRfPdXR+l5qJMmPSt3jQc+nUP321E5SfyZ13TuJbxdgkfhvTTSJr0nW
H/IWAJDvy5z177YZPHo+2ah9tmr0fVkXWd9O2/Cf/H1v/Th5Pv6K1Kc99j9Zf063Jvk/6c7m
Lx7w918DlcTf4yHjB+8k93ekT6HxVUiS9b2Mh/bfE95/kWHFno8XGv9EFMmfueiZ1G8/egha
/4lG9ZPzK9CD+Lf/grRvGz2T/ZFNLgKNn5Pd35TnwFD862CT+FlD2s+FZ7+/2frnenc0PikZ
NL6tN06e/3p3Ul8uy1B9wqwNENHzj0b7g+seUfu84TM5f5fVKD9qzQ+qT57w/o7s1+R8xN6e
Jvf7ZN8AGIm/CRJpHzqG5AdmJ3z+VWh+2l1ofaCnUP8yUqS+UM5D9y/kmKL8mXEl9R9yQkl+
Zq71Qe3zlKL+dxrdf7rh7SPnB0vkkfsdSh7Kjy1RYc+H3f9Yx78C4586/hX4vm58hKzP1P66
ZH5U+9/Z+zNC6ifUE1Q/p95D+aWLPyR/u54OuT90g5Mm54vrebH3J5qsz9fpI6HfX0POT9Vr
NH+vvf4kf7XWPZL1k9L9AUj7oFrkfEGpNerfN3pG/btGkfzV0kySf1VayZ5PB5mflk6Q+d1e
flS/8dRPhrTPpmh/p8wC9S/mTup7lJ3CComfTtaHy8pJ/ltZO+ofXYSs39bJS5P3xxXlh5Tf
X0DihyppPz2VrO+VFzpfXL7hJ2k/fdD50woJcr95hQrJb6kwIffjbHAY5H69DQ4Lre/denby
/Uah/K6KLrQ+GVNk/6hS0Pm1SnVSX+XUM8n5qcsu0PrA0etI+3wEAtK+JbtfqXICjZ9L2Pyi
XpDzWVWsfuA+LkfjtzPQpH3YAyLnR6ra0Py6xkj+W7UoyU+rforGb61K8uf353W0/tOB7u+o
TrY/1ethSPvQo6h9GCmSX12z5hnFvwIliW+D9o8mHI1Pptj+4zSqT94iSvLPW16R8xctZmT/
vcWbzE9b0tnvLyfr/y3tpH5gy7Df/6TJ/t2GJ8Z+v6H6//0c1RftS19I+3bjg+T9fIPqs7UK
up9lw1sl/VerFanf0uooP7k1iqwvtWaR+mx9/WvyfWknat/29ZL1sTX+6H69vv1K5PmYo/rM
bWueyfdlC49+fwf6+7oY2Z9qPwITiW/ofEF7JDl/115O6kO2D7rfp+MpGr/FCSSR+Bueo+fD
8kM61sOT9zPlkfPpnQ/VV9nkF53v6PRH6nt03oZVEj8fqX/YeQxuEr9R/v9tHyHrt6eeg/r3
m69H8d+Q/IouE9S/lA3Jb+lb34Hix5D6il2svlxXofyKrkb556deR+or7tcX2b/uCx9I+7AB
Oqk/0BtAOHr+1SQ/sHtSyfOZ5+R8TY9poPjxyP7jHj8bf06j+qgj4mT9f0SVrB+OWJPx7cgm
YKB92OjQSX3UkTH0fN5Tkj8z+3rJ+H/NG7ofc94mSKB9OHkMsv48yu5vGn1N1q9GLUl+y2g4
yR8YLTT+GW1Un3l0htyPM7bpO3n+9tD53w1/itz/OGaoPuGYFxkfrvdC9aXHMkn9gbEqcn5w
rJPkz4xNkvu1xyVJ/ajxh+rTjmug79ctyPrPuAc5PzUegb5fTyfrV+OFzreOt5H88PF9weT7
CjGSP3PpO6l/OKFG9i8mzND4JFzJ+vns8yXrVxOJ6u9NnIIFid+P5G9MzEPfb8oj598nH4yv
QvKTJzfBIO1DupD8k8kQsr660aGg9iELPp9C5y8mR8j5qcVH91tNCbqfdOo1OZ81a/5R+1m3
4IrEd3T/y9Tm16T/rUzUP1YV6l+q2fphDVt/aElyvnJaHY3P25XsX0/nQ/1LV5D8h7kGKpk/
zlNyv8CMCclfmk3gSX7Iet9A6+cbnXD1Gf3tHwDzl8N/oD7/4Vtw9ufwA8zfD79AfYnDb7A/
vvhPkuv/Hr46t3/88F25/ReHn4/j5xx+Fee/Dn+c05dYfH0g//zw7XHx1eGHcPH/4Weh70s7
uPr24puA9dXD18fNXxy+Nbdf8vDJ+d/DL+P0Mw9/QH3FxXcB+QmHr6z/cgf1zQ4/FbVv3o/T
pzr8AfczLn48cP708M24/YaHH4rGD1Hg/Mvhd3H8ycVPCa7/e/hqnP7t4Tu4X+nwA9yPcPgV
XH3s8Afkvy1+PVC/9/BNOP2iw/dC/XslyA85/FMgAPFbwP1fh78JGPr9Fkra5xuQJt9v10Pt
QzeoX7T4I8nNvx++Ote/OHxLTp/n8L05fZvDT0H915Rw+xMPv0H9isPfCwTGJ082QwLtz5MX
XH/58DXJ+swTQ+//bXfj5r8OPx8Znzwp5fgJh99B2s8nE2T++/aAuP04h//A+eLDJ/f3Hb4L
i38FAhI/nYyv3iP1LQ+/U1D8QesD173m+MmHr4/sj7yjJ6Pn487pqx9+OJl/PU1wP8vhn4AF
iX8T0iC+bf5L2rcbzyX9lym4X+/wLbj51sP3JPsjzwLcP3v4CeqrH/4JlJD4A+pfLf5aT06/
9PBfcPztw9fk+POHb8Xx5w9/zQN6Pvk4fd3DL0Xtg7cPej8nHvn9IaC+7uGT+oGHb6x/Dwf1
9w4/lOOvHn46at+iguyPvGhw/v3wjwAK4udmkOT9T1X2+81Jfs6m7072v15GovXDzET9Y1Zz
+gCHP4LmXyWPmz86/I0g0O/X4Pj5h+9of2SNDxtffQsySfwysv9424PY33fA/ZKL3wLOTx3+
Xh+yPtb20PphO8rveh1G8mNfZ6D14S5wfufwm+1f9ID6vYs/76H901FF+1O3XoC8/+PgfrHD
3wSG9I+T6HzHmxo0/v8GCDl8FUH9u96AEIqvTvLPVSzJ+oyKg/u1Dz+G7M+qlJD1N5UG9xMd
/hjJz9Enzu3POvzNMED7rE9B/fnDd1D/5PDjkf5XXyoZv+kmqGT8qRtAc/tZDn+S5P/onj7Z
n9L9C1D7oAbq5x++Kzl/fdEtWR9TTSf57aoV6Pva10vWH1QH1CdZfDsCIon/mqwP3/QROf+i
ZkP239VCuP0gh7/hLfr7Frif4vAbna9XG5Q/o1ceJuMrf+B+w8PfE0Lxjc3vfP8h74+Hk/xw
dXK/4eGXk/O56h2cvt/hD7h/fPFDkuxfrPEE9c8PX5PTTz58S7I/ePRYNL+OgH/fErJ+e9vF
UPsTo2T/S1Oc1L/SVJTfq2ns+81QNH7OVG4/y+EXuF/p8BudH9Gj95L2oYQ9n3pG9ge1NgND
z8dQfR4tN7T+X+Hs75vgfrrDL2fvT4P7oQ7/NgyA+C2B2p9+qL6Bnj4tWR84fQb0fNzR+klH
oPFPJ5s/dgUaf/YJWID4I4bWZ+Y1mp+OGWp/xlH+g87Gh+jvW4XG/7P5C4hvIqC+8eGrcvu/
Dt/Q/oWdwByKn6j+gEk/br/A4U+S8yn2CRyQ+JrkfJ89fyx+BFn/tI/gTuJ3kP0RO4IXyH8w
fej8hamh+lq24TOpr2L7vMj+pm2CSup/2gZYZPxs52DI92XHwCLxLcj504V/pL6QWSbJ7zLr
R/YHzSZJ/omt+yLrJ+ZaZP/Lbv8paR88wf01h9+P1G83nyLz632+QdbHLNbCkfczgn2/kWz8
HK1B+pfY+J88/5Qk6yebPQZq//M68CS+ofVtS0f1xyzD2fuTMH6h+jCWPST/wUqCrI9ZvUTr
S6Xg/vfDP4EkEt+T5GdaBVsfq/VfpH2o/R9Az6eDPf9JNP/th/JXbcMHcn+WtbH1n3bWv8P9
Net0bv/j4RfKD7FudD+U9Rj6/SNs/DywfxxD+4827qQ+oU04Wt9b84zGz1OB9u+m4e8flP/j
Ik72F1weqk/rouj9P/lJMn5wiST9r0sWqd/lUkXyx1y6SP6qyxSpf7XOvUj9W7/2LIqvTepv
+FsPieKHkPpF/ja9A+MHf/XI/pSfPCd6f+aR+hW33Y2M/12fkvUr1/2HvP9qqP6tqxtZn3EN
VH/SNY3Uj7r2Gjl/5Mrur3cdI/svbmKo/z0CEGnfTJ3s7/v+uqQ+wzc+S9o3C3Q+2i2D1G9x
K5Tf5dZofXWtM9r/9U1g0PhwAzg0/3JF92/e6yLrw+6O1m8XPtH41jNJfqx7Jbm/2L2TnK93
H3S/noeg+nJ+8+mk/w1F+f8eVmT/4uQfyPkRjyiSn7bmodD8K6rQ+Ccaxmf3r3lKofbt5H/I
+CePQEziW6HxT66DQc8/4PPPQuO33PdL2v9s+PuH/X3Xe5Hzs14P3V/mpYXGn2U16Pk7Wz+v
aLI/uNanyfk4r2qy/+7VTfLHvKbR/Kulyf0CdzuNPP++CXsS3zrJ37edfV8dQ86vbfo4aP+l
Wf15h/c7eM+g/YURVJ/T5w1aPxx2P7iPDTn/6+Po/g6fFDT/nRK0PzstaH46I2T+GHICByT+
g/EV1d8LMSHtQ4jD37//gvYnJIXsn4aUkPFt7H8n87uQQfWf4+0DI+/Pe+h8dDx9pH5OvGsw
k/j+yPpYvED1DeKlkvoG9/UkPydeK1n/j1sABubvoaIk/z/0KckPCVVF7efxo1B8R/n/oWHo
/b/xPvT7C9U3C20j+QOhY+R+jTAxsn+0t8fI/nucgA5p3/b2oPGDuZH7TcL2bwDrP2FpZH04
rIysP4Q1yi+NRUft5w2QkOfvD+UHhquT+yXDLdD48NaTku/rCBwofqL7zeMaYOT79XZSnyp8
0Pm+my5G7+cmYOR8X2yAiNbH1oGR/YU9nCD3T+3hBMl/i8hA85c9fZIfEtEoP3ZPH9W/jZQg
909FviT1ryI1lfQvaeh+nFj3RfJn9nmh+1P28RY5nxVZRfbHI7vY33dQ/t7+ukXyE6Jeof2X
vT2kfleUofPFcfwo9PeNJvXnN3hA94dG1ZD8t6gRNH9sETS+7Sdofr23k9QniVaU/3C3n5zP
3fBNSH286ET3s0eve0e/v4Xk10WPkPNBMcL2x+ex/IFRQePzk6ci7cP4I/drbHr0yPn3mBQ0
fpgN4ND704L2r2eErD/k/gmy/nDWmcyPUhTdr5Fij4w/U/yR8WFe+RC0zyn5yPw6ZRMk9H72
I/unua+L5Dfmhrdk/yXfuhfS/jx9pP3PZ+j+2XyuZP/35MlJfZJ9vY+sD+e+XjI/zcfuj843
qD5Vqjyyfp7rHsn56FRF4/9UE3I+PdUVtT8aSsaHV55H/e9+Peq/tJXUb0wdlP+ZJkry63LD
TzT+vwVm5O9r9sj6eZoLqU9y7CWSv5TG1q8Wf9j7U4PGz9ZD7k9PmyHre7nXk+wv5Alokr+v
a6Hvyw2df0wPQ/MXz0TjB28h9welj6HxYUiS/OEMRee/8gjQ5P08eVEUP4TkT2YkOh969ArU
vkULWt+LRvuzGTPo/U9pkv9824PI+Z3cBIb9/guASHwvsn+R+8DI/nJmFlo/yUL1hda7o/yZ
3PAcrV+VsOdfr0j922O/kfy3LEP3U2SdQhiJfwKIJH6i+qVHP0Tzu2p0P2Cu9Sf5sdmC7mfP
zR5JfkK2xpDvqw3dP5jtSc6fZkeS83fZG8GR9qfXAJH2oTvQ/LEn0PrkSKD8h3movn2OOpq/
jDna3x9H95flhJP6GznpqP+aQudPcxrdj5wzRu5vKhEj4/M6+gboH0vUyPrPBs9G9mdL3Mj4
pCTQ/m9Jovoem94pOf9b0kra/5JRMj+qJ0rO/9Z7SvI36qmS8Um9NQ/o9zvK/6kXj9RPq5eP
jB+O3UjyM+v1I/n/9eaR/I1SQfmxpQ/VTyvV56T9UXukflepP7L+UBpCxv+lKWR9afFRfeD1
7oPGn7oJMGkfdIbcL1Ymg9p/e0PWV+vk38jf12zI/lGZDxr/WAwa3xqrf/6tj0DvTw9Zny+b
Qe2/S5P6eOXs/oLyI7CS+NZk/6v8NkiQ+DeBTeJnofmjF8ofKO8i+ZnlbH+5NnxD86N4Rc7X
V2ih8fnt70PPx9H9g3X7+8j7GZnk/HVFlZD5RXSS+yMqBuUPVEqS81+VL9H87sZfyPjn9KnQ
8/FE/eOeDho/Z6L9x8r1YOT7yg5y/qI2vUD7LyVO8itqvRfJr6tSb/J9bYKK3v8NoEn9tDoH
j+Kno/5rDwiND6sd9e81qL593Xol8vftp+jv28r2H9uU5Jfu9VG0PtOhKD+hU1H/0oXu76hu
dD63ehTlJ4w8cv6i5smg36+oPtiaTyH3O9Ss+SftA7wfsCbQ/Yw1xyAj8e+ESPx9wKT/nUH3
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
WX9LVXR/TaoLGZ/v7UHrJ6mlqH3WRvffpT2U/5Am6HxowvoYaTchQeInOj+YVk3Wr9LGyfgw
fe0b+b5cA73/7oraH2f3Yybc30nvJvmBGc/I/C5DH1n/zzC0PpARj+y/5BW4SfsTZULGD9Gu
6PmMo/njJnhofHUBNBnfboCC+pf0R/Z/cw3QI+OTm38n7WeWoPYz2fpk5ig5/5X1jKx/7vGj
+kW57h31L2VG6oNluZP95Sx2f2JWovtJswrdH53V6H7erElyfir7FTnfmi37C5P42iR/Lzd7
JOez8tb3od+/ARxpH3pPiLT/XUPOF+zjGnJ+JOc9cr9MjggaH44KGp+MCXo/xwX1jxNCzq/l
JDq/k1NC6sfmtJD6P3n7WcD4qt5D97/UuwUJJL4q2Z/a8B/d71PP0f5yvVBy/qjehp/o+Zey
97+V5MfWGyX5nyVPSf9SImj+XgtPzndvei3o+xIXUt+mJND5hVrrT/ITSkoVzO9qbw85H7HR
A1rfLn1of7z29pD17f11haxvXHeKrF/demRS36M0Hhl/rnd85H720vVgpH3QFpK/VzpC1jfK
npL6gWV7PdHvVyXrt2WG6ueXuaH+0cJI/m3Zxs/k+7Vi7b+1sPdzBL2ft+CTfL/rXtD8wpXN
v9ycrJ+fehdZ3y4PJ+evyxPVp60TgEbx29D4x0fR/C4eW/8JYePbTe/Q+kaYkPNTFWvgyPsZ
IWT/veIY0CR+sfWBW49Mvt+Yh/rffELy6yoF3R9RuQk8eT9zw3/0fAzdr11HMCXjn4wk9Ysq
E91/Vx9BhMRvdH9E5aD6wFUvBew/Vkmg9flSR+sDmwCT8wW1CQDJ36gNgEj+W60DIPvXtRcU
rU9Wo/vvFn9IflfVNGof+jXqf1vQ/XrVOiS//aaD0P5IO6ovVH0KKyT+LQAj8Qvdb1vdgfZ/
1zygv+88V/J8RtD5oBpVtH83pqR+b40LqT9TE0Ly82tSSf2rGnY+Yt2joP5lBtVnWPwh869+
b8j4Z6OrJvs7Cz5k/aqfP3I+qx+rX9ovlZxPPPo/WX/Y8FNJfvIGn4reT3mo/n+LoP2pYw+Q
9bHb7kbyP1tcyPyoJdD+Y0sayS/d9AvVf24Zb/L+rHVA7b/qI/V/bnsK2R9pdSf1q1sD1Q9s
TSf3V7aWo/dfO8n+SOsG6OT32wuS39smQdZn2tTJ+mGbOVl/aHMj88e2E8gg8dPQ92tlJP+q
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
vz/+BPDHYW00ZBsA

--=_5841dc7f.kg4dgRh05+FI1LJxj8kK9stx6n6iP0UbedClA9wSSRcYZLpg
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-quantal-ivb41-114:20161202195350:i386-randconfig-c0-12022226:4.9.0-rc7-00104-g4461116:1.gz"

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

--=_5841dc7f.kg4dgRh05+FI1LJxj8kK9stx6n6iP0UbedClA9wSSRcYZLpg
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-4.9.0-rc7-00105-ga3a1806"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 4.9.0-rc7 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_BITS_MAX=16
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEBUG_RODATA=y
CONFIG_PGTABLE_LEVELS=2
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
CONFIG_KERNEL_XZ=y
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
CONFIG_IRQ_TIME_ACCOUNTING=y
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
CONFIG_TREE_RCU_TRACE=y
# CONFIG_RCU_BOOST is not set
CONFIG_RCU_KTHREAD_PRIO=0
CONFIG_RCU_NOCB_CPU=y
CONFIG_RCU_NOCB_CPU_NONE=y
# CONFIG_RCU_NOCB_CPU_ZERO is not set
# CONFIG_RCU_NOCB_CPU_ALL is not set
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_NMI_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
# CONFIG_CGROUP_PIDS is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_HUGETLB=y
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_DEBUG=y
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_ABSOLUTE_PERCPU is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_ADVISE_SYSCALLS=y
CONFIG_USERFAULTFD=y
CONFIG_PCI_QUIRKS=y
CONFIG_MEMBARRIER=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
CONFIG_KEXEC_CORE=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_UPROBES=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
# CONFIG_HAVE_ARCH_HASH is not set
CONFIG_ISA_BUS_API=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set
# CONFIG_HAVE_ARCH_VMAP_STACK is not set

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_GCOV_PROFILE_ALL=y
CONFIG_GCOV_FORMAT_AUTODETECT=y
# CONFIG_GCOV_FORMAT_3_4 is not set
# CONFIG_GCOV_FORMAT_4_7 is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
# CONFIG_BLOCK is not set
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_FAST_FEATURE_TESTS is not set
CONFIG_X86_MPPARSE=y
# CONFIG_X86_BIGSMP is not set
CONFIG_GOLDFISH=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
# CONFIG_IOSF_MBI is not set
CONFIG_X86_32_IRIS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
CONFIG_MEFFICEON=y
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
# CONFIG_X86_GENERIC is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=5
CONFIG_X86_L1_CACHE_SHIFT=5
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=4
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_NR_CPUS=8
CONFIG_SCHED_SMT=y
# CONFIG_SCHED_MC is not set
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
# CONFIG_PERF_EVENTS_AMD_POWER is not set
CONFIG_X86_LEGACY_VM86=y
CONFIG_VM86=y
# CONFIG_TOSHIBA is not set
CONFIG_I8K=y
# CONFIG_X86_REBOOTFIXUPS is not set
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_HIGHMEM64G is not set
# CONFIG_VMSPLIT_3G is not set
# CONFIG_VMSPLIT_3G_OPT is not set
# CONFIG_VMSPLIT_2G is not set
# CONFIG_VMSPLIT_2G_OPT is not set
CONFIG_VMSPLIT_1G=y
CONFIG_PAGE_OFFSET=0x40000000
CONFIG_HIGHMEM=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_COMPACTION is not set
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CLEANCACHE=y
# CONFIG_CMA is not set
CONFIG_ZPOOL=y
# CONFIG_ZBUD is not set
CONFIG_Z3FOLD=y
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_FRAME_VECTOR=y
CONFIG_HIGHPTE=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
# CONFIG_X86_SMAP is not set
CONFIG_X86_INTEL_MPX=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
# CONFIG_MODIFY_LDT_SYSCALL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_SUSPEND_SKIP_SYNC=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_AUTOSLEEP=y
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
CONFIG_PM_WAKELOCKS_GC=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_DPM_WATCHDOG is not set
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
# CONFIG_SFI is not set
# CONFIG_APM is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_STAT_DETAILS is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_POWERNOW_K6 is not set
CONFIG_X86_POWERNOW_K7=y
CONFIG_X86_POWERNOW_K7_ACPI=y
# CONFIG_X86_GX_SUSPMOD is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_SPEEDSTEP_CENTRINO_TABLE=y
CONFIG_X86_SPEEDSTEP_ICH=y
CONFIG_X86_SPEEDSTEP_SMI=y
CONFIG_X86_P4_CLOCKMOD=y
CONFIG_X86_CPUFREQ_NFORCE2=y
CONFIG_X86_LONGRUN=y
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
# CONFIG_X86_SPEEDSTEP_RELAXED_CAP_CHECK is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
# CONFIG_CPU_IDLE_GOV_MENU is not set
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI host controller drivers
#
CONFIG_ISA_BUS=y
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
CONFIG_EISA=y
# CONFIG_EISA_VLB_PRIMING is not set
CONFIG_EISA_PCI_EISA=y
CONFIG_EISA_VIRTUAL_ROOT=y
# CONFIG_EISA_NAMES is not set
CONFIG_SCx200=y
CONFIG_SCx200HR_TIMER=y
# CONFIG_OLPC is not set
CONFIG_ALIX=y
CONFIG_NET5501=y
# CONFIG_GEOS is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
CONFIG_PCMCIA_PROBE=y
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
# CONFIG_BINFMT_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_PMC_ATOM=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NET_PTP_CLASSIFY is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_HSR is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_SOCK_CGROUP_DATA is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_STREAM_PARSER is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
# CONFIG_LWTUNNEL is not set
# CONFIG_DST_CACHE is not set
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_FENCE_TRACE=y

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_OOPS=y
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
CONFIG_MTD_CFI_LE_BYTE_SWAP=y
# CONFIG_MTD_CFI_GEOMETRY is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_OTP=y
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
# CONFIG_MTD_SBC_GXX is not set
CONFIG_MTD_SCx200_DOCFLASH=y
# CONFIG_MTD_PCI is not set
CONFIG_MTD_GPIO_ADDR=y
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_DATAFLASH=y
CONFIG_MTD_DATAFLASH_WRITE_VERIFY=y
CONFIG_MTD_DATAFLASH_OTP=y
# CONFIG_MTD_M25P80 is not set
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
# CONFIG_MTD_NAND is not set
# CONFIG_MTD_ONENAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_SPI_NOR=y
# CONFIG_MTD_MT81xx_NOR is not set
CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
CONFIG_MTD_UBI_GLUEBI=y
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
# CONFIG_ISAPNP is not set
CONFIG_PNPBIOS=y
# CONFIG_PNPBIOS_PROC_FS is not set
CONFIG_PNPACPI=y

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
# CONFIG_LATTICE_ECP3_CONFIG is not set
# CONFIG_SRAM is not set
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
# CONFIG_PANEL_CHANGE_MESSAGE is not set
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_EEPROM_93XX46 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#

#
# SCIF Bus Driver
#

#
# VOP Bus Driver
#

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
CONFIG_ECHO=y
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_AFU_DRIVER_OPS is not set
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_GOLDFISH_EVENTS is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
CONFIG_INPUT_MOUSE=y
# CONFIG_MOUSE_PS2 is not set
CONFIG_MOUSE_SERIAL=y
CONFIG_MOUSE_APPLETOUCH=y
CONFIG_MOUSE_BCM5974=y
CONFIG_MOUSE_CYAPA=y
CONFIG_MOUSE_ELAN_I2C=y
# CONFIG_MOUSE_ELAN_I2C_I2C is not set
# CONFIG_MOUSE_ELAN_I2C_SMBUS is not set
# CONFIG_MOUSE_INPORT is not set
# CONFIG_MOUSE_LOGIBM is not set
CONFIG_MOUSE_PC110PAD=y
# CONFIG_MOUSE_VSXXXAA is not set
CONFIG_MOUSE_GPIO=y
CONFIG_MOUSE_SYNAPTICS_I2C=y
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
CONFIG_JOYSTICK_A3D=y
# CONFIG_JOYSTICK_ADI is not set
CONFIG_JOYSTICK_COBRA=y
CONFIG_JOYSTICK_GF2K=y
CONFIG_JOYSTICK_GRIP=y
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=y
# CONFIG_JOYSTICK_SIDEWINDER is not set
# CONFIG_JOYSTICK_TMDC is not set
# CONFIG_JOYSTICK_IFORCE is not set
# CONFIG_JOYSTICK_WARRIOR is not set
# CONFIG_JOYSTICK_MAGELLAN is not set
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
# CONFIG_JOYSTICK_STINGER is not set
CONFIG_JOYSTICK_TWIDJOY=y
# CONFIG_JOYSTICK_ZHENHUA is not set
# CONFIG_JOYSTICK_DB9 is not set
# CONFIG_JOYSTICK_GAMECON is not set
CONFIG_JOYSTICK_TURBOGRAFX=y
CONFIG_JOYSTICK_AS5011=y
# CONFIG_JOYSTICK_JOYDUMP is not set
CONFIG_JOYSTICK_XPAD=y
CONFIG_JOYSTICK_XPAD_FF=y
CONFIG_JOYSTICK_XPAD_LEDS=y
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM80X_ONKEY=y
CONFIG_INPUT_AD714X=y
# CONFIG_INPUT_AD714X_I2C is not set
# CONFIG_INPUT_AD714X_SPI is not set
CONFIG_INPUT_BMA150=y
# CONFIG_INPUT_E3X0_BUTTON is not set
# CONFIG_INPUT_MAX8925_ONKEY is not set
CONFIG_INPUT_MC13783_PWRBUTTON=y
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_MPU3050=y
CONFIG_INPUT_APANEL=y
# CONFIG_INPUT_GP2A is not set
# CONFIG_INPUT_GPIO_BEEPER is not set
CONFIG_INPUT_GPIO_TILT_POLLED=y
# CONFIG_INPUT_GPIO_DECODER is not set
# CONFIG_INPUT_WISTRON_BTNS is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
CONFIG_INPUT_ATI_REMOTE2=y
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=y
CONFIG_INPUT_YEALINK=y
CONFIG_INPUT_CM109=y
# CONFIG_INPUT_REGULATOR_HAPTIC is not set
CONFIG_INPUT_RETU_PWRBUTTON=y
# CONFIG_INPUT_TPS65218_PWRBUTTON is not set
CONFIG_INPUT_TWL6040_VIBRA=y
# CONFIG_INPUT_UINPUT is not set
CONFIG_INPUT_PALMAS_PWRBUTTON=y
# CONFIG_INPUT_PCF8574 is not set
CONFIG_INPUT_PWM_BEEPER=y
CONFIG_INPUT_GPIO_ROTARY_ENCODER=y
CONFIG_INPUT_WM831X_ON=y
CONFIG_INPUT_PCAP=y
CONFIG_INPUT_ADXL34X=y
CONFIG_INPUT_ADXL34X_I2C=y
CONFIG_INPUT_ADXL34X_SPI=y
CONFIG_INPUT_IMS_PCU=y
CONFIG_INPUT_CMA3000=y
CONFIG_INPUT_CMA3000_I2C=y
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
# CONFIG_INPUT_DRV260X_HAPTICS is not set
CONFIG_INPUT_DRV2665_HAPTICS=y
# CONFIG_INPUT_DRV2667_HAPTICS is not set
CONFIG_RMI4_CORE=y
# CONFIG_RMI4_I2C is not set
CONFIG_RMI4_SPI=y
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
# CONFIG_RMI4_F12 is not set
# CONFIG_RMI4_F30 is not set
CONFIG_RMI4_F54=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
CONFIG_SERIO_PARKBD=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_USERIO=y
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
# CONFIG_GOLDFISH_TTY is not set
# CONFIG_DEVMEM is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_FSL is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
# CONFIG_PPDEV is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
# CONFIG_HW_RANDOM_VIA is not set
CONFIG_HW_RANDOM_TPM=y
CONFIG_NVRAM=y
CONFIG_DTLK=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set
# CONFIG_MWAVE is not set
CONFIG_SCx200_GPIO=y
# CONFIG_PC8736x_GPIO is not set
CONFIG_NSC_GPIO=y
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_SPI=y
CONFIG_TCG_TIS_I2C_ATMEL=y
CONFIG_TCG_TIS_I2C_INFINEON=y
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
# CONFIG_TCG_NSC is not set
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
CONFIG_TCG_VTPM_PROXY=y
CONFIG_TCG_TIS_ST33ZP24=y
# CONFIG_TCG_TIS_ST33ZP24_I2C is not set
CONFIG_TCG_TIS_ST33ZP24_SPI=y
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_MUX_REG is not set
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_GPIO=y
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
# CONFIG_I2C_DLN2 is not set
CONFIG_I2C_PARPORT=y
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y
CONFIG_I2C_VIPERBOARD=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_PCA_ISA=y
# CONFIG_I2C_CROS_EC_TUNNEL is not set
# CONFIG_SCx200_ACB is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_AXI_SPI_ENGINE=y
CONFIG_SPI_BITBANG=y
# CONFIG_SPI_BUTTERFLY is not set
CONFIG_SPI_CADENCE=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set
# CONFIG_SPI_DW_MMIO is not set
CONFIG_SPI_DLN2=y
CONFIG_SPI_GPIO=y
CONFIG_SPI_LM70_LLP=y
CONFIG_SPI_OC_TINY=y
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_ROCKCHIP is not set
# CONFIG_SPI_SC18IS602 is not set
# CONFIG_SPI_TOPCLIFF_PCH is not set
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
CONFIG_SPI_TLE62X0=y
CONFIG_SPMI=y
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_AMDPT is not set
CONFIG_GPIO_DWAPB=y
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_MOCKUP=y
# CONFIG_GPIO_VX855 is not set
CONFIG_GPIO_ZX=y

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_104_DIO_48E is not set
CONFIG_GPIO_104_IDIO_16=y
CONFIG_GPIO_104_IDI_48=y
CONFIG_GPIO_F7188X=y
# CONFIG_GPIO_GPIO_MM is not set
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_WS16C48 is not set

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
CONFIG_GPIO_ADP5588_IRQ=y
CONFIG_GPIO_MAX7300=y
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TPIC2810=y
CONFIG_GPIO_TS4900=y

#
# MFD GPIO expanders
#
# CONFIG_GPIO_ADP5520 is not set
# CONFIG_GPIO_ARIZONA is not set
CONFIG_GPIO_DLN2=y
CONFIG_GPIO_LP3943=y
CONFIG_GPIO_PALMAS=y
CONFIG_GPIO_TPS65218=y
# CONFIG_GPIO_TPS6586X is not set
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL6040=y
CONFIG_GPIO_WM831X=y
CONFIG_GPIO_WM8994=y

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MC33880 is not set
# CONFIG_GPIO_PISOSR is not set

#
# SPI or I2C GPIO expanders
#

#
# USB GPIO expanders
#
CONFIG_GPIO_VIPERBOARD=y
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2490 is not set
CONFIG_W1_MASTER_DS2482=y
# CONFIG_W1_MASTER_DS1WM is not set
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
# CONFIG_POWER_AVS is not set
CONFIG_POWER_RESET=y
CONFIG_POWER_RESET_RESTART=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
# CONFIG_MAX8925_POWER is not set
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
CONFIG_TEST_POWER=y
# CONFIG_BATTERY_DS2760 is not set
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
CONFIG_BATTERY_SBS=y
# CONFIG_BATTERY_BQ27XXX is not set
CONFIG_BATTERY_DA9030=y
CONFIG_BATTERY_DA9150=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_CHARGER_ISP1704=y
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_MAX14577=y
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
CONFIG_CHARGER_BQ24257=y
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_BQ25890=y
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_CHARGER_TPS65090 is not set
CONFIG_BATTERY_GAUGE_LTC2941=y
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_BATTERY_RT5033 is not set
CONFIG_CHARGER_RT9455=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
# CONFIG_SENSORS_ABITUGURU3 is not set
CONFIG_SENSORS_AD7314=y
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=y
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_MC13783_ADC=y
CONFIG_SENSORS_FSCHMD=y
# CONFIG_SENSORS_GL518SM is not set
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
# CONFIG_SENSORS_LTC2945 is not set
CONFIG_SENSORS_LTC2990=y
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX31722 is not set
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
# CONFIG_SENSORS_MENF21BMC_HWMON is not set
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_LM63=y
# CONFIG_SENSORS_LM70 is not set
CONFIG_SENSORS_LM73=y
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=y
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LM95234=y
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NCT7802 is not set
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_LM25066=y
# CONFIG_SENSORS_LTC2978 is not set
CONFIG_SENSORS_LTC3815=y
# CONFIG_SENSORS_MAX16064 is not set
CONFIG_SENSORS_MAX20751=y
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
CONFIG_SENSORS_TPS40422=y
CONFIG_SENSORS_UCD9000=y
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SHT3x is not set
CONFIG_SENSORS_SHTC1=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_SMM665=y
# CONFIG_SENSORS_ADC128D818 is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_INA3221=y
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=y
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
# CONFIG_SENSORS_W83627EHF is not set
CONFIG_SENSORS_WM831X=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
# CONFIG_THERMAL_WRITABLE_TRIPS is not set
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
CONFIG_SSB_SILENT=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
CONFIG_MFD_AS3711=y
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_BCM590XX=y
# CONFIG_MFD_AXP20X_I2C is not set
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
CONFIG_MFD_CROS_EC_SPI=y
CONFIG_PMIC_DA903X=y
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_DA9150=y
CONFIG_MFD_DLN2=y
CONFIG_MFD_EXYNOS_LPASS=y
CONFIG_MFD_MC13XXX=y
# CONFIG_MFD_MC13XXX_SPI is not set
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=y
CONFIG_EZX_PCAP=y
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RT5033=y
CONFIG_MFD_RTSX_USB=y
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_SEC_CORE=y
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
CONFIG_MFD_SKY81452=y
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65086 is not set
CONFIG_MFD_TPS65090=y
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TI_LP873X is not set
CONFIG_MFD_TPS65218=y
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS65912_SPI=y
CONFIG_MFD_TPS80031=y
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TIMBERDALE is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_ARIZONA_SPI=y
# CONFIG_MFD_CS47L24 is not set
CONFIG_MFD_WM5102=y
CONFIG_MFD_WM5110=y
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8998=y
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM831X_SPI=y
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PM800=y
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AS3711=y
CONFIG_REGULATOR_BCM590XX=y
CONFIG_REGULATOR_DA903X=y
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=y
# CONFIG_REGULATOR_ISL9305 is not set
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
# CONFIG_REGULATOR_LP8788 is not set
CONFIG_REGULATOR_LTC3589=y
# CONFIG_REGULATOR_LTC3676 is not set
# CONFIG_REGULATOR_MAX14577 is not set
CONFIG_REGULATOR_MAX1586=y
# CONFIG_REGULATOR_MAX8649 is not set
CONFIG_REGULATOR_MAX8660=y
# CONFIG_REGULATOR_MAX8907 is not set
CONFIG_REGULATOR_MAX8925=y
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MC13783 is not set
# CONFIG_REGULATOR_MC13892 is not set
# CONFIG_REGULATOR_MT6311 is not set
CONFIG_REGULATOR_MT6323=y
# CONFIG_REGULATOR_MT6397 is not set
CONFIG_REGULATOR_PALMAS=y
# CONFIG_REGULATOR_PCAP is not set
CONFIG_REGULATOR_PFUZE100=y
# CONFIG_REGULATOR_PV88060 is not set
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=y
# CONFIG_REGULATOR_PWM is not set
CONFIG_REGULATOR_QCOM_SPMI=y
CONFIG_REGULATOR_RT5033=y
CONFIG_REGULATOR_S2MPA01=y
CONFIG_REGULATOR_S2MPS11=y
# CONFIG_REGULATOR_S5M8767 is not set
# CONFIG_REGULATOR_SKY81452 is not set
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS65090 is not set
# CONFIG_REGULATOR_TPS6524X is not set
# CONFIG_REGULATOR_TPS6586X is not set
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_TPS80031=y
# CONFIG_REGULATOR_WM831X is not set
CONFIG_REGULATOR_WM8400=y
CONFIG_REGULATOR_WM8994=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
# CONFIG_MEDIA_RADIO_SUPPORT is not set
# CONFIG_MEDIA_SDR_SUPPORT is not set
CONFIG_MEDIA_RC_SUPPORT=y
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
# CONFIG_VIDEO_PCI_SKELETON is not set
CONFIG_VIDEO_TUNER=y
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_VMALLOC=y
CONFIG_VIDEOBUF_DVB=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_DVB_CORE=y
CONFIG_TTPCI_EEPROM=y
CONFIG_DVB_MAX_ADAPTERS=8
# CONFIG_DVB_DYNAMIC_MINORS is not set

#
# Media drivers
#
CONFIG_RC_CORE=y
CONFIG_RC_MAP=y
CONFIG_RC_DECODERS=y
CONFIG_LIRC=y
CONFIG_IR_LIRC_CODEC=y
CONFIG_IR_NEC_DECODER=y
CONFIG_IR_RC5_DECODER=y
CONFIG_IR_RC6_DECODER=y
CONFIG_IR_JVC_DECODER=y
CONFIG_IR_SONY_DECODER=y
CONFIG_IR_SANYO_DECODER=y
CONFIG_IR_SHARP_DECODER=y
CONFIG_IR_MCE_KBD_DECODER=y
# CONFIG_IR_XMP_DECODER is not set
# CONFIG_RC_DEVICES is not set
CONFIG_MEDIA_USB_SUPPORT=y

#
# Webcam devices
#
CONFIG_USB_VIDEO_CLASS=y
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
# CONFIG_USB_GSPCA is not set
CONFIG_USB_PWC=y
CONFIG_USB_PWC_DEBUG=y
CONFIG_USB_PWC_INPUT_EVDEV=y
# CONFIG_VIDEO_CPIA2 is not set
CONFIG_USB_ZR364XX=y
CONFIG_USB_STKWEBCAM=y
CONFIG_USB_S2255=y

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_AU0828=y
CONFIG_VIDEO_AU0828_V4L2=y
CONFIG_VIDEO_AU0828_RC=y
CONFIG_VIDEO_CX231XX=y
# CONFIG_VIDEO_CX231XX_RC is not set
CONFIG_VIDEO_CX231XX_DVB=y
# CONFIG_VIDEO_TM6000 is not set

#
# Digital TV USB devices
#
CONFIG_DVB_USB=y
CONFIG_DVB_USB_DEBUG=y
CONFIG_DVB_USB_DIB3000MC=y
# CONFIG_DVB_USB_A800 is not set
# CONFIG_DVB_USB_DIBUSB_MB is not set
CONFIG_DVB_USB_DIBUSB_MC=y
CONFIG_DVB_USB_DIB0700=y
# CONFIG_DVB_USB_UMT_010 is not set
CONFIG_DVB_USB_CXUSB=y
CONFIG_DVB_USB_M920X=y
CONFIG_DVB_USB_DIGITV=y
CONFIG_DVB_USB_VP7045=y
CONFIG_DVB_USB_VP702X=y
# CONFIG_DVB_USB_GP8PSK is not set
# CONFIG_DVB_USB_NOVA_T_USB2 is not set
CONFIG_DVB_USB_TTUSB2=y
CONFIG_DVB_USB_DTT200U=y
# CONFIG_DVB_USB_OPERA1 is not set
# CONFIG_DVB_USB_AF9005 is not set
CONFIG_DVB_USB_PCTV452E=y
CONFIG_DVB_USB_DW2102=y
CONFIG_DVB_USB_CINERGY_T2=y
CONFIG_DVB_USB_DTV5100=y
# CONFIG_DVB_USB_FRIIO is not set
# CONFIG_DVB_USB_AZ6027 is not set
CONFIG_DVB_USB_TECHNISAT_USB2=y
CONFIG_DVB_USB_V2=y
CONFIG_DVB_USB_AF9015=y
# CONFIG_DVB_USB_AF9035 is not set
CONFIG_DVB_USB_ANYSEE=y
CONFIG_DVB_USB_AU6610=y
CONFIG_DVB_USB_AZ6007=y
CONFIG_DVB_USB_CE6230=y
CONFIG_DVB_USB_EC168=y
CONFIG_DVB_USB_GL861=y
CONFIG_DVB_USB_LME2510=y
# CONFIG_DVB_USB_MXL111SF is not set
CONFIG_DVB_USB_RTL28XXU=y
# CONFIG_DVB_USB_DVBSKY is not set
# CONFIG_DVB_TTUSB_BUDGET is not set
# CONFIG_DVB_TTUSB_DEC is not set
CONFIG_SMS_USB_DRV=y
CONFIG_DVB_B2C2_FLEXCOP_USB=y
# CONFIG_DVB_B2C2_FLEXCOP_USB_DEBUG is not set
CONFIG_DVB_AS102=y

#
# Webcam, TV (analog/digital) USB devices
#
# CONFIG_VIDEO_EM28XX is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
CONFIG_V4L_MEM2MEM_DRIVERS=y
CONFIG_VIDEO_MEM2MEM_DEINTERLACE=y
# CONFIG_VIDEO_SH_VEU is not set
# CONFIG_V4L_TEST_DRIVERS is not set
# CONFIG_DVB_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=y
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_CX2341X=y
CONFIG_VIDEO_TVEEPROM=y
CONFIG_CYPRESS_FIRMWARE=y
CONFIG_DVB_B2C2_FLEXCOP=y
CONFIG_SMS_SIANO_MDTV=y
CONFIG_SMS_SIANO_RC=y
# CONFIG_SMS_SIANO_DEBUGFS is not set

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_VIDEO_IR_I2C=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#
CONFIG_VIDEO_CX25840=y

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_MT2060=y
CONFIG_MEDIA_TUNER_MT2063=y
CONFIG_MEDIA_TUNER_MT2266=y
CONFIG_MEDIA_TUNER_QT1010=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5005S=y
CONFIG_MEDIA_TUNER_MXL5007T=y
CONFIG_MEDIA_TUNER_MC44S803=y
CONFIG_MEDIA_TUNER_MAX2165=y
CONFIG_MEDIA_TUNER_TDA18218=y
CONFIG_MEDIA_TUNER_FC0012=y
CONFIG_MEDIA_TUNER_FC0013=y
CONFIG_MEDIA_TUNER_TDA18212=y
CONFIG_MEDIA_TUNER_E4000=y
CONFIG_MEDIA_TUNER_FC2580=y
CONFIG_MEDIA_TUNER_TUA9001=y
CONFIG_MEDIA_TUNER_SI2157=y
CONFIG_MEDIA_TUNER_R820T=y

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=y
CONFIG_DVB_STB6100=y
CONFIG_DVB_STV090x=y
CONFIG_DVB_STV6110x=y
CONFIG_DVB_M88DS3103=y

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=y
CONFIG_DVB_TDA18271C2DD=y
CONFIG_DVB_SI2165=y
CONFIG_DVB_MN88472=y
CONFIG_DVB_MN88473=y

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24123=y
CONFIG_DVB_MT312=y
CONFIG_DVB_ZL10039=y
CONFIG_DVB_S5H1420=y
CONFIG_DVB_STV0288=y
CONFIG_DVB_STB6000=y
CONFIG_DVB_STV0299=y
CONFIG_DVB_STV6110=y
CONFIG_DVB_STV0900=y
CONFIG_DVB_TDA10086=y
CONFIG_DVB_TUNER_ITD1000=y
CONFIG_DVB_TUNER_CX24113=y
CONFIG_DVB_TDA826X=y
CONFIG_DVB_CX24116=y
CONFIG_DVB_CX24120=y
CONFIG_DVB_SI21XX=y
CONFIG_DVB_TS2020=y
CONFIG_DVB_DS3000=y

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_CX22702=y
CONFIG_DVB_TDA1004X=y
CONFIG_DVB_NXT6000=y
CONFIG_DVB_MT352=y
CONFIG_DVB_ZL10353=y
CONFIG_DVB_DIB3000MC=y
CONFIG_DVB_DIB7000M=y
CONFIG_DVB_DIB7000P=y
CONFIG_DVB_TDA10048=y
CONFIG_DVB_AF9013=y
CONFIG_DVB_EC100=y
CONFIG_DVB_CXD2820R=y
CONFIG_DVB_RTL2830=y
CONFIG_DVB_RTL2832=y
CONFIG_DVB_SI2168=y
CONFIG_DVB_AS102_FE=y
# CONFIG_DVB_GP8PSK_FE is not set

#
# DVB-C (cable) frontends
#
CONFIG_DVB_TDA10023=y
CONFIG_DVB_STV0297=y

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
CONFIG_DVB_BCM3510=y
CONFIG_DVB_LGDT330X=y
CONFIG_DVB_LGDT3305=y
CONFIG_DVB_LGDT3306A=y
CONFIG_DVB_AU8522=y
CONFIG_DVB_AU8522_DTV=y
CONFIG_DVB_AU8522_V4L=y
CONFIG_DVB_S5H1411=y

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_DIB8000=y
CONFIG_DVB_MB86A20S=y

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y
CONFIG_DVB_TUNER_DIB0070=y
CONFIG_DVB_TUNER_DIB0090=y

#
# SEC control devices for DVB-S
#
CONFIG_DVB_LNBP21=y
CONFIG_DVB_LNBP22=y
CONFIG_DVB_ISL6421=y
CONFIG_DVB_ISL6423=y
CONFIG_DVB_LGS8GXX=y
CONFIG_DVB_ATBM8830=y
CONFIG_DVB_IX2505V=y
CONFIG_DVB_M88RS2000=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_LOAD_EDID_FIRMWARE=y

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
# CONFIG_DRM_I2C_SIL164 is not set
# CONFIG_DRM_I2C_NXP_TDA998X is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_VGEM is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
CONFIG_DRM_UDL=y
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
# CONFIG_DRM_BOCHS is not set
CONFIG_DRM_BRIDGE=y

#
# Display Interface Bridges
#
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
CONFIG_DRM_LEGACY=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
# CONFIG_FB_BOTH_ENDIAN is not set
# CONFIG_FB_BIG_ENDIAN is not set
CONFIG_FB_LITTLE_ENDIAN=y
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
# CONFIG_FB_N411 is not set
CONFIG_FB_HGA=y
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
CONFIG_FB_SM501=y
CONFIG_FB_SMSCUFX=y
# CONFIG_FB_UDL is not set
# CONFIG_FB_IBM_GXT4500 is not set
CONFIG_FB_GOLDFISH=y
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_SIMPLE=y
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_L4F00242T03 is not set
CONFIG_LCD_LMS283GF05=y
CONFIG_LCD_LTV350QV=y
# CONFIG_LCD_ILI922X is not set
CONFIG_LCD_ILI9320=y
# CONFIG_LCD_TDO24M is not set
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
# CONFIG_LCD_S6E63M0 is not set
CONFIG_LCD_LD9040=y
# CONFIG_LCD_AMS369FG06 is not set
# CONFIG_LCD_LMS501KF03 is not set
# CONFIG_LCD_HX8357 is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_LM3533 is not set
CONFIG_BACKLIGHT_PWM=y
CONFIG_BACKLIGHT_DA903X=y
# CONFIG_BACKLIGHT_MAX8925 is not set
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
# CONFIG_BACKLIGHT_ADP5520 is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_LM3630A=y
CONFIG_BACKLIGHT_LM3639=y
# CONFIG_BACKLIGHT_LP855X is not set
CONFIG_BACKLIGHT_LP8788=y
CONFIG_BACKLIGHT_SKY81452=y
CONFIG_BACKLIGHT_AS3711=y
# CONFIG_BACKLIGHT_GPIO is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_VGASTATE is not set
CONFIG_HDMI=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
CONFIG_UHID=y
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
CONFIG_HID_ASUS=y
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CORSAIR is not set
CONFIG_HID_CMEDIA=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_EZKEY is not set
CONFIG_HID_GEMBIRD=y
# CONFIG_HID_GFRM is not set
CONFIG_HID_KEYTOUCH=y
# CONFIG_HID_KYE is not set
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=y
# CONFIG_HID_LCPOWER is not set
CONFIG_HID_LED=y
CONFIG_HID_LENOVO=y
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
# CONFIG_HID_MONTEREY is not set
CONFIG_HID_MULTITOUCH=y
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
CONFIG_HID_SAITEK=y
# CONFIG_HID_SAMSUNG is not set
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
# CONFIG_HID_RMI is not set
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
CONFIG_HID_THINGM=y
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=y
CONFIG_HID_SENSOR_CUSTOM_SENSOR=y
CONFIG_HID_ALPS=y

#
# USB HID support
#
# CONFIG_USB_HID is not set
# CONFIG_HID_PID is not set

#
# USB HID Boot Protocol drivers
#
CONFIG_USB_KBD=y
CONFIG_USB_MOUSE=y

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG=y
CONFIG_USB_OTG_WHITELIST=y
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
CONFIG_USB_OTG_FSM=y
CONFIG_USB_MON=y
CONFIG_USB_WUSB=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_ISP1362_HCD=y
CONFIG_USB_FOTG210_HCD=y
# CONFIG_USB_MAX3421_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
CONFIG_USB_SL811_HCD_ISO=y
CONFIG_USB_R8A66597_HCD=y
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=y
# CONFIG_USB_HCD_SSB is not set
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
# CONFIG_USBIP_CORE is not set
CONFIG_USB_MUSB_HDRC=y
# CONFIG_USB_MUSB_HOST is not set
CONFIG_USB_MUSB_GADGET=y
# CONFIG_USB_MUSB_DUAL_ROLE is not set

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
CONFIG_MUSB_PIO_ONLY=y
# CONFIG_USB_DWC3 is not set
CONFIG_USB_DWC2=y
# CONFIG_USB_DWC2_HOST is not set

#
# Gadget/Dual-role mode requires USB Gadget support to be enabled
#
CONFIG_USB_DWC2_PERIPHERAL=y
# CONFIG_USB_DWC2_DUAL_ROLE is not set
# CONFIG_USB_DWC2_PCI is not set
# CONFIG_USB_DWC2_DEBUG is not set
# CONFIG_USB_DWC2_TRACK_MISSED_SOFS is not set
# CONFIG_USB_CHIPIDEA is not set
# CONFIG_USB_ISP1760 is not set

#
# USB port drivers
#
CONFIG_USB_USS720=y
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=y
CONFIG_USB_RIO500=y
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
# CONFIG_USB_SISUSBVGA is not set
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
CONFIG_USB_EHSET_TEST_FIXTURE=y
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
CONFIG_USB_HSIC_USB3503=y
CONFIG_USB_HSIC_USB4604=y
CONFIG_USB_LINK_LAYER_TEST=y
CONFIG_USB_CHAOSKEY=y
# CONFIG_UCSI is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
# CONFIG_NOP_USB_XCEIV is not set
CONFIG_USB_GPIO_VBUS=y
# CONFIG_TAHVO_USB is not set
CONFIG_USB_ISP1301=y
CONFIG_USB_GADGET=y
CONFIG_USB_GADGET_DEBUG=y
CONFIG_USB_GADGET_VERBOSE=y
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_FUSB300=y
CONFIG_USB_FOTG210_UDC=y
CONFIG_USB_GR_UDC=y
# CONFIG_USB_R8A66597 is not set
CONFIG_USB_PXA27X=y
CONFIG_USB_MV_UDC=y
# CONFIG_USB_MV_U3D is not set
CONFIG_USB_M66592=y
CONFIG_USB_BDC_UDC=y

#
# Platform Support
#
CONFIG_USB_BDC_PCI=y
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
CONFIG_USB_DUMMY_HCD=y
CONFIG_USB_LIBCOMPOSITE=y
CONFIG_USB_F_FS=y
CONFIG_USB_F_HID=y
CONFIG_USB_CONFIGFS=y
# CONFIG_USB_CONFIGFS_SERIAL is not set
# CONFIG_USB_CONFIGFS_ACM is not set
# CONFIG_USB_CONFIGFS_OBEX is not set
# CONFIG_USB_CONFIGFS_NCM is not set
# CONFIG_USB_CONFIGFS_ECM is not set
# CONFIG_USB_CONFIGFS_ECM_SUBSET is not set
# CONFIG_USB_CONFIGFS_RNDIS is not set
# CONFIG_USB_CONFIGFS_EEM is not set
# CONFIG_USB_CONFIGFS_F_LB_SS is not set
CONFIG_USB_CONFIGFS_F_FS=y
CONFIG_USB_CONFIGFS_F_HID=y
# CONFIG_USB_CONFIGFS_F_UVC is not set
# CONFIG_USB_CONFIGFS_F_PRINTER is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
CONFIG_USB_GADGETFS=y
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set
CONFIG_USB_ULPI_BUS=y
CONFIG_UWB=y
CONFIG_UWB_HWA=y
# CONFIG_UWB_WHCI is not set
# CONFIG_UWB_I1480U is not set
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y

#
# MMC/SD/SDIO Card Drivers
#
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_GOLDFISH is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
# CONFIG_MMC_VUB300 is not set
# CONFIG_MMC_USHC is not set
# CONFIG_MMC_USDHI6ROL0 is not set
CONFIG_MMC_REALTEK_USB=y
# CONFIG_MMC_TOSHIBA_PCI is not set
CONFIG_MMC_MTK=y
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_MEMSTICK_REALTEK_USB=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set

#
# LED drivers
#
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_NET48XX=y
CONFIG_LEDS_WRAP=y
CONFIG_LEDS_PCA9532=y
# CONFIG_LEDS_PCA9532_GPIO is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
# CONFIG_LEDS_LP5562 is not set
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_LP8788=y
# CONFIG_LEDS_LP8860 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM831X_STATUS=y
# CONFIG_LEDS_DA903X is not set
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_PWM=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_ADP5520=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_TLC591XX is not set
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_OT200=y
CONFIG_LEDS_MENF21BMC=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
# CONFIG_RTC_SYSTOHC is not set
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
CONFIG_RTC_INTF_DEV_UIE_EMUL=y
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM80X=y
CONFIG_RTC_DRV_ABB5ZES3=y
# CONFIG_RTC_DRV_ABX80X is not set
# CONFIG_RTC_DRV_DS1307 is not set
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1374_WDT=y
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_LP8788=y
CONFIG_RTC_DRV_MAX6900=y
# CONFIG_RTC_DRV_MAX8907 is not set
CONFIG_RTC_DRV_MAX8925=y
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_X1205=y
# CONFIG_RTC_DRV_PCF8523 is not set
# CONFIG_RTC_DRV_PCF85063 is not set
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
CONFIG_RTC_DRV_M41T80_WDT=y
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_PALMAS=y
CONFIG_RTC_DRV_TPS6586X=y
CONFIG_RTC_DRV_TPS80031=y
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8010=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV8803=y
CONFIG_RTC_DRV_S5M=y

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
CONFIG_RTC_DRV_M41T94=y
CONFIG_RTC_DRV_DS1302=y
# CONFIG_RTC_DRV_DS1305 is not set
CONFIG_RTC_DRV_DS1343=y
CONFIG_RTC_DRV_DS1347=y
CONFIG_RTC_DRV_DS1390=y
# CONFIG_RTC_DRV_MAX6916 is not set
CONFIG_RTC_DRV_R9701=y
CONFIG_RTC_DRV_RX4581=y
CONFIG_RTC_DRV_RX6110=y
CONFIG_RTC_DRV_RS5C348=y
# CONFIG_RTC_DRV_MAX6902 is not set
CONFIG_RTC_DRV_PCF2123=y
CONFIG_RTC_DRV_MCP795=y
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_PCF2127 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1685_FAMILY is not set
# CONFIG_RTC_DRV_DS1742 is not set
CONFIG_RTC_DRV_DS2404=y
# CONFIG_RTC_DRV_STK17TA8 is not set
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
# CONFIG_RTC_DRV_MSM6242 is not set
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
# CONFIG_RTC_DRV_WM831X is not set

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_PCAP is not set
CONFIG_RTC_DRV_MC13XXX=y
# CONFIG_RTC_DRV_MT6397 is not set

#
# HID Sensor RTC drivers
#
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
# CONFIG_DMADEVICES_VDEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_INTEL_IDMA64=y
# CONFIG_PCH_DMA is not set
# CONFIG_QCOM_HIDMA_MGMT is not set
CONFIG_QCOM_HIDMA=y
CONFIG_DW_DMAC_CORE=y
# CONFIG_DW_DMAC is not set
# CONFIG_DW_DMAC_PCI is not set
CONFIG_HSU_DMA=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
# CONFIG_SW_SYNC is not set
CONFIG_AUXDISPLAY=y
CONFIG_IMG_ASCII_LCD=y
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
CONFIG_UIO_PRUSS=y
# CONFIG_UIO_MF624 is not set
CONFIG_VIRT_DRIVERS=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_GOLDFISH_BUS=y
CONFIG_GOLDFISH_PIPE=y
CONFIG_CHROME_PLATFORMS=y
# CONFIG_CHROMEOS_LAPTOP is not set
CONFIG_CHROMEOS_PSTORE=y
CONFIG_CROS_EC_CHARDEV=y
CONFIG_CROS_EC_LPC=y
CONFIG_CROS_EC_PROTO=y
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
# CONFIG_PCC is not set
CONFIG_ALTERA_MBOX=y
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#

#
# Broadcom SoC drivers
#
# CONFIG_SUNXI_SRAM is not set
CONFIG_SOC_TI=y
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_GPIO=y
CONFIG_EXTCON_MAX14577=y
CONFIG_EXTCON_MAX3355=y
# CONFIG_EXTCON_PALMAS is not set
CONFIG_EXTCON_QCOM_SPMI_MISC=y
CONFIG_EXTCON_RT8973A=y
CONFIG_EXTCON_SM5502=y
CONFIG_EXTCON_USB_GPIO=y
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_CROS_EC=y
CONFIG_PWM_LP3943=y
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
# CONFIG_PWM_PCA9685 is not set
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
# CONFIG_RESET_CONTROLLER is not set
CONFIG_FMC=y
# CONFIG_FMC_FAKEDEV is not set
CONFIG_FMC_TRIVIAL=y
CONFIG_FMC_WRITE_EEPROM=y
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_PHY_SAMSUNG_USB2=y
# CONFIG_PHY_EXYNOS4210_USB2 is not set
# CONFIG_PHY_EXYNOS4X12_USB2 is not set
# CONFIG_PHY_EXYNOS5250_USB2 is not set
# CONFIG_PHY_TUSB1210 is not set
CONFIG_POWERCAP=y
# CONFIG_MCB is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_THUNDERBOLT is not set

#
# Android
#
CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC is not set
CONFIG_NVMEM=y
CONFIG_STM=y
CONFIG_STM_DUMMY=y
CONFIG_STM_SOURCE_CONSOLE=y
# CONFIG_STM_SOURCE_HEARTBEAT is not set
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
CONFIG_INTEL_TH_GTH=y
# CONFIG_INTEL_TH_STH is not set
CONFIG_INTEL_TH_MSU=y
CONFIG_INTEL_TH_PTI=y
CONFIG_INTEL_TH_DEBUG=y

#
# FPGA Configuration Support
#
# CONFIG_FPGA is not set

#
# Firmware Drivers
#
# CONFIG_ARM_SCPI_PROTOCOL is not set
# CONFIG_EDD is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_FW_CFG_SYSFS is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
# CONFIG_PROC_CHILDREN is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
# CONFIG_JFFS2_FS is not set
CONFIG_UBIFS_FS=y
# CONFIG_UBIFS_FS_ADVANCED_COMPR is not set
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
# CONFIG_UBIFS_ATIME_SUPPORT is not set
# CONFIG_LOGFS is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_MTD=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_ZLIB_COMPRESS is not set
# CONFIG_PSTORE_LZO_COMPRESS is not set
CONFIG_PSTORE_LZ4_COMPRESS=y
CONFIG_PSTORE_CONSOLE=y
CONFIG_PSTORE_PMSG=y
# CONFIG_PSTORE_FTRACE is not set
# CONFIG_PSTORE_RAM is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
# CONFIG_NLS_ISO8859_1 is not set
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_PAGE_REF is not set
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_DEBUG_PER_CPU_MAPS=y
# CONFIG_DEBUG_HIGHMEM is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_WQ_WATCHDOG=y
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHED_INFO is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
CONFIG_DEBUG_TIMEKEEPING=y
# CONFIG_TIMER_STATS is not set
CONFIG_DEBUG_PREEMPT=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
# CONFIG_PROVE_RCU_REPEATEDLY is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT is not set
# CONFIG_RCU_TORTURE_TEST_SLOW_INIT is not set
CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP=y
CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP_DELAY=3
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
# CONFIG_RCU_EQS_DEBUG is not set
CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_MMC_REQUEST is not set
# CONFIG_FAIL_FUTEX is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
# CONFIG_FAULT_INJECTION_STACKTRACE_FILTER is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_PREEMPT_TRACER=y
CONFIG_SCHED_TRACER=y
# CONFIG_HWLAT_TRACER is not set
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_STACK_TRACER=y
CONFIG_UPROBE_EVENT=y
CONFIG_BPF_EVENTS=y
CONFIG_PROBE_EVENTS=y
# CONFIG_DYNAMIC_FTRACE is not set
# CONFIG_FUNCTION_PROFILER is not set
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
CONFIG_TRACEPOINT_BENCHMARK=y
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
CONFIG_TRACE_ENUM_MAP_FILE=y
# CONFIG_TRACING_EVENTS_GPIO is not set

#
# Runtime Testing
#
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
CONFIG_TEST_PRINTF=y
CONFIG_TEST_BITMAP=y
CONFIG_TEST_UUID=y
CONFIG_TEST_RHASHTABLE=y
CONFIG_TEST_HASH=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_FIRMWARE=y
CONFIG_TEST_UDELAY=y
# CONFIG_MEMTEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
# CONFIG_UBSAN_ALIGNMENT is not set
CONFIG_UBSAN_NULL=y
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP_CORE=y
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DEBUG_WX=y
# CONFIG_DOUBLEFAULT is not set
CONFIG_DEBUG_TLBFLUSH=y
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
CONFIG_IO_DELAY_NONE=y
CONFIG_DEFAULT_IO_DELAY_TYPE=3
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_ENTRY=y
CONFIG_DEBUG_NMI_SELFTEST=y
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set

#
# Security options
#
# CONFIG_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_HAVE_ARCH_HARDENED_USERCOPY=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_KPP2=y
# CONFIG_CRYPTO_RSA is not set
# CONFIG_CRYPTO_DH is not set
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
# CONFIG_CRYPTO_ARC4 is not set
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAST_COMMON=y
# CONFIG_CRYPTO_CAST5 is not set
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_SALSA20_586=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_586 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_CRYPTO_DEV_GEODE is not set
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set

#
# Certificates for signature checking
#
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_VHOST_NET is not set
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set
# CONFIG_LGUEST is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
CONFIG_CRC32_SARWATE=y
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
# CONFIG_SG_SPLIT is not set
# CONFIG_SG_POOL is not set
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_STACKDEPOT=y

--=_5841dc7f.kg4dgRh05+FI1LJxj8kK9stx6n6iP0UbedClA9wSSRcYZLpg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
