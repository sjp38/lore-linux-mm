Received: from wituf11 (172.24.251.133) by estafette.TELINTRANS.FR (MX V5.1-A
          An6s) with SMTP for <linux-mm@kvack.org>;
          Thu, 27 Nov 2003 15:52:21 +0100
Received: from domino-tuf-1.telintrans.fr (172.24.251.85) by
          VITUF3.TUF.TELINTRANS.FR (MX V5.1-A An6s) with ESMTP for
          <linux-mm@kvack.org>; Thu, 27 Nov 2003 15:52:18 +0100
From: Mickael Bailly <mickael.bailly@telintrans.fr>
Subject: Re: looking for explanations on linux memory management
Date: Thu, 27 Nov 2003 15:53:13 +0100
References: <Pine.LNX.4.44.0311261351220.18209-100000@coffee.psychology.mcmaster.ca>
In-Reply-To: <Pine.LNX.4.44.0311261351220.18209-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Message-ID: <200311271553.13324.mickael.bailly@telintrans.fr>
Content-Type: Multipart/Mixed; boundary="Boundary-00=_Z/gx/0Z5zxkR2fM"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-00=_Z/gx/0Z5zxkR2fM
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Disposition: inline


	Hello!,

I try to merge answers from Rob Love and Mark Hahn.

On Wednesday 26 November 2003 20:01, Mark Hahn wrote:
> > 1/ can you explain me what happened in week 47 so cached memory don't get
> > down anymore ? Nothing really changed in this week on the server.
>
> I'm guessing someone did a "find /" or similar, which caused lots of
> dcache/icache entries to be created.  of course, it could also be normal
> cached file pages, stale SHM segments (run ipcs -a), or maybe even
> a big-VM proces that's gotten into some limbo state...
 o no one did a "find /" , however as in any RedHat each night at 4 pm the 
'updatedb' script is launched (even before week 47).
 o for ipcs output I got lots of things but I don't understand it yet I have 
to read some docs on that.

I attach output from '/proc/meminfo' and '/proc/slabinfo' to this mail.

>
> > 2/ how can I know when my server needs more RAM/SWAP, if free memory is
> > always about 0
>
> free memory is WASTED memory - you might as well have not bought it.
> you know you need more memory when you see swapin traffic (NOT swapouts,
> which are normal and in fact good).  swapins are a sign that the kernel
> has either chosen the wrong pages to swap out, or is needing to swap out
> so much that hot pages are getting swapped, or that you simply have a
> working set that's larger than physical memory.

I suppose 'swapin' is the 'Swap - si' column of the 'vmstat' utility, for 
example. OK then if I want to create a script that tell me when memory is 
needed I should monitor this value, right ? (sorry again, my questions are a 
little bit 'corporate'... :-\ )

For my RedHat kernel I'll work on compiling my own... Unfortunately the 
'.spec' of vanilia kernel distributions don't create -BOOT , -smp, etc... 
kernels, which are needed for kickstart installs.

-- 
Mickael Bailly

--Boundary-00=_Z/gx/0Z5zxkR2fM
Content-Transfer-Encoding: 7bit
Content-Type: text/x-log;
  charset="iso-8859-1";
  name="meminfo.log"
Content-Disposition: attachment;
	filename="meminfo.log"

        total:    used:    free:  shared: buffers:  cached:
Mem:  2114347008 2074492928 39854080        0 277983232 1528950784
Swap: 270360576 31682560 238678016
MemTotal:      2064792 kB
MemFree:         38920 kB
MemShared:           0 kB
Buffers:        271468 kB
Cached:        1483524 kB
SwapCached:       9592 kB
Active:        1535044 kB
ActiveAnon:     176340 kB
ActiveCache:   1358704 kB
Inact_dirty:         0 kB
Inact_laundry:  361692 kB
Inact_clean:     22008 kB
Inact_target:   383748 kB
HighTotal:     1179560 kB
HighFree:         1024 kB
LowTotal:       885232 kB
LowFree:         37896 kB
SwapTotal:      264024 kB
SwapFree:       233084 kB

--Boundary-00=_Z/gx/0Z5zxkR2fM
Content-Transfer-Encoding: 7bit
Content-Type: text/x-log;
  charset="iso-8859-1";
  name="slabinfo.log"
Content-Disposition: attachment;
	filename="slabinfo.log"

slabinfo - version: 1.1 (SMP)
kmem_cache            80     80    244    5    5    1 :  252  126
ip_conntrack         242   9790    384   26  979    1 :  124   62
ip_fib_hash          336    336     32    3    3    1 :  252  126
journal_head         938  21098     48   28  274    1 :  252  126
revoke_table         500    500     12    2    2    1 :  252  126
revoke_record        588   1344     32    7   12    1 :  252  126
clip_arp_cache         0      0    128    0    0    1 :  252  126
ip_mrt_cache           0      0    128    0    0    1 :  252  126
tcp_tw_bucket        384    510    128   17   17    1 :  252  126
tcp_bind_bucket      420    672     32    5    6    1 :  252  126
tcp_open_request     654    780    128   26   26    1 :  252  126
inet_peer_cache      232    232     64    4    4    1 :  252  126
ip_dst_cache         399    525    256   34   35    1 :  252  126
arp_cache            450    450    128   15   15    1 :  252  126
blkdev_requests      810    810    128   27   27    1 :  252  126
dnotify_cache          0      0     20    0    0    1 :  252  126
file_lock_cache      594    720     96   18   18    1 :  252  126
fasync_cache           0      0     16    0    0    1 :  252  126
uid_cache            672    672     32    6    6    1 :  252  126
skbuff_head_cache    810   1440    256   63   96    1 :  252  126
sock                 223    253   1408   23   23    4 :   60   30
sigqueue             628    754    132   26   26    1 :  252  126
kiobuf               174    174     64    3    3    1 :  252  126
cdev_cache           496   3016     64   26   52    1 :  252  126
bdev_cache           232    232     64    4    4    1 :  252  126
mnt_cache            232    232     64    4    4    1 :  252  126
inode_cache         5596   7091    512 1013 1013    1 :  124   62
dentry_cache        2730   6660    128  222  222    1 :  252  126
dquot                  0      0    128    0    0    1 :  252  126
filp                1290   1290    128   43   43    1 :  252  126
names_cache          113    173   4096  113  173    1 :   60   30
buffer_head       365612 559400     96 11582 13985    1 :  252  126
mm_struct            579    705    256   47   47    1 :  252  126
vm_area_struct      3480   4110    128  125  137    1 :  252  126
fs_cache             570    696     64   12   12    1 :  252  126
files_cache          330    392    512   52   56    1 :  124   62
signal_act           152    242   1408   22   22    4 :   60   30
pte_chain          25392  54120    128  894 1804    1 :  252  126
size-131072(DMA)       0      0 131072    0    0   32 :    0    0
size-131072            0      0 131072    0    0   32 :    0    0
size-65536(DMA)        0      0  65536    0    0   16 :    0    0
size-65536             0      0  65536    0    0   16 :    0    0
size-32768(DMA)        0      0  32768    0    0    8 :    0    0
size-32768             0      2  32768    0    2    8 :    0    0
size-16384(DMA)        0      0  16384    0    0    4 :    0    0
size-16384             3      5  16384    3    5    4 :    0    0
size-8192(DMA)         0      0   8192    0    0    2 :    0    0
size-8192              9     16   8192    9   16    2 :    0    0
size-4096(DMA)         0      0   4096    0    0    1 :   60   30
size-4096            830    890   4096  830  890    1 :   60   30
size-2048(DMA)         0      0   2048    0    0    1 :   60   30
size-2048            136    196   2048   68   98    1 :   60   30
size-1024(DMA)         0      0   1024    0    0    1 :  124   62
size-1024            588    712   1024  160  178    1 :  124   62
size-512(DMA)          0      0    512    0    0    1 :  124   62
size-512             420    544    512   60   68    1 :  124   62
size-256(DMA)          0      0    256    0    0    1 :  252  126
size-256             402    780    256   35   52    1 :  252  126
size-128(DMA)          0      0    128    0    0    1 :  252  126
size-128            2742   8790    128  112  293    1 :  252  126
size-64(DMA)           0      0    128    0    0    1 :  252  126
size-64              582   1590    128   40   53    1 :  252  126
size-32(DMA)           0      0     64    0    0    1 :  252  126
size-32             1042   1798     64   28   31    1 :  252  126

--Boundary-00=_Z/gx/0Z5zxkR2fM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
