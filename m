Message-ID: <00d701c37786$1dcbbbc0$3600000a@infirewarrior>
From: "Aleksi Asikainen" <aleksi.asikainen@infire.com>
Subject: Buffer and cache sizes
Date: Wed, 10 Sep 2003 13:27:19 +0300
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello all,


I'm facing a confusing problem with the kernel's buffer and cache memory
usage and was suggested in the usenet that this might interest you.

"I had 2GB in cache on 2.4.21 and the Out Of Memory killer struck."


Our server is running on a double Xeon-processor machine with 3 GB of
memory, kernel 2.4.21 installed, RH 8 distribution. We run mysql-server and
roughly four hundred custom processes, which in total take about 800 MB of
RAM. The rest of the free memory just sits there for the time being, and is
slowly eaten to kernel's buffer / cache. Once there's no more to eat, or I
suppose when we fall under some critical line and kernel considers it's time
to free up some more memory, OOM-killer is launched and pop goes the server.
(We have no swap drive, mind you, because kswapd seems to strangle the
machine way too much and I thought that 800 MB of processes could be run
with 3 GB of RAM...)

This is really weird, I've been told by various people that, if I understood
them right, the cache / buffer memory is considered somewhat free, so rather
than OOM-killer appearing, kernel should offer some of the cache / buffer
memory for the use if possible, shouldn't it?

I'm afraid I'm not sure what details to offer about this, below are listings
of some programs and files provided. I guess what I'm trying to find out is,
is there any way to prevent the cache from growing so high? Is there
anything I can do about this? And would buying more memory solve it?

Someone in the usenet asked also why do I have 2 GB in cache. I don't know,
I'm no expert on VM stuff and if I could, I wouldn't have 2 GB in cache. It
just seems that 2.4.21 doesn't contain /proc/sys/vm/buffermem file to limit
this with. Can I force clearing the cache somehow?


Thanks for listening and sorry for any factual errors, this is not my field,


Aleksi Asikainen



free:
             total       used       free     shared    buffers     cached
Mem:       3104344    3060668      43676          0     487024    1698224
-/+ buffers/cache:     875420    2228924
Swap:            0          0          0


/proc/meminfo:
        total:    used:    free:  shared: buffers:  cached:
Mem:  3178848256 3157012480 21835776        0 541364224 1740095488
Swap:        0        0        0
MemTotal:      3104344 kB
MemFree:         21324 kB
MemShared:           0 kB
Buffers:        528676 kB
Cached:        1699312 kB
SwapCached:          0 kB
Active:        1409988 kB
Inactive:      1414960 kB
HighTotal:     2228224 kB
HighFree:        16656 kB
LowTotal:       876120 kB
LowFree:          4668 kB
SwapTotal:           0 kB
SwapFree:            0 kB


top:
  4:09am  up 1 day, 11 min,  2 users,  load average: 27.82, 11.19, 8.16
523 processes: 354 sleeping, 169 running, 0 zombie, 0 stopped
CPU0 states:  2.18% user, 97.17% system,  0.0% nice,  0.5% idle
CPU1 states:  2.29% user, 96.23% system,  0.0% nice,  0.29% idle
CPU2 states:  3.0% user, 94.30% system,  0.0% nice,  2.9% idle
CPU3 states:  3.25% user, 95.23% system,  0.0% nice,  0.32% idle
Mem:  3104344K av, 3004900K used,   99444K free,       0K shrd,  419884K
buff
Swap:       0K av,       0K used,       0K free                 1719352K
cached


proc/slabinfo:
slabinfo - version: 1.1 (SMP)
kmem_cache            96     96    244    6    6    1 :  252  126
ip_conntrack        4300   6540    384  654  654    1 :  124   62
tcp_tw_bucket         90     90    128    3    3    1 :  252  126
tcp_bind_bucket     3212   3360     32   30   30    1 :  252  126
tcp_open_request     116    116     64    2    2    1 :  252  126
inet_peer_cache       58     58     64    1    1    1 :  252  126
ip_fib_hash           17    336     32    3    3    1 :  252  126
ip_dst_cache        1141   1410    256   94   94    1 :  252  126
arp_cache             19    150    128    5    5    1 :  252  126
uhci_urb_priv          0      0     60    0    0    1 :  252  126
blkdev_requests      384    450    128   15   15    1 :  252  126
nfs_write_data         0      0    384    0    0    1 :  124   62
nfs_read_data          0      0    384    0    0    1 :  124   62
nfs_page               0      0    128    0    0    1 :  252  126
journal_head        1655   2387     48   29   31    1 :  252  126
revoke_table          13    250     12    1    1    1 :  252  126
revoke_record        112    112     32    1    1    1 :  252  126
dnotify_cache          0      0     20    0    0    1 :  252  126
file_lock_cache      200    200     96    5    5    1 :  252  126
fasync_cache           0      0     16    0    0    1 :  252  126
uid_cache              3    112     32    1    1    1 :  252  126
skbuff_head_cache  12076  35415    256 2361 2361    1 :  252  126
sock                6019   6484    896 1620 1621    1 :  124   62
sigqueue             203    203    132    7    7    1 :  252  126
kiobuf                 0      0     64    0    0    1 :  252  126
cdev_cache            13    116     64    2    2    1 :  252  126
bdev_cache            13    116     64    2    2    1 :  252  126
mnt_cache             24    116     64    2    2    1 :  252  126
inode_cache        84886  92505    512 13214 13215    1 :  124   62
dentry_cache       41896  51780    128 1726 1726    1 :  252  126
dquot                  0      0    128    0    0    1 :  252  126
filp               15332  15360    128  512  512    1 :  252  126
names_cache           63     63   4096   63   63    1 :   60   30
buffer_head       667847 672390    128 22413 22413    1 :  252  126
mm_struct            875    915    256   59   61    1 :  252  126
vm_area_struct     13584  14070    128  468  469    1 :  252  126
fs_cache             877   1044     64   18   18    1 :  252  126
files_cache          623    735    512  103  105    1 :  124   62
signal_act           575    627   1408   56   57    4 :   60   30
size-131072(DMA)       0      0 131072    0    0   32 :    0    0
size-131072            0      0 131072    0    0   32 :    0    0
size-65536(DMA)        0      0  65536    0    0   16 :    0    0
size-65536             0      0  65536    0    0   16 :    0    0
size-32768(DMA)        0      0  32768    0    0    8 :    0    0
size-32768             2      2  32768    2    2    8 :    0    0
size-16384(DMA)        0      0  16384    0    0    4 :    0    0
size-16384             0      1  16384    0    1    4 :    0    0
size-8192(DMA)         0      0   8192    0    0    2 :    0    0
size-8192           2374   2926   8192 2374 2926    2 :    0    0
size-4096(DMA)         0      0   4096    0    0    1 :   60   30
size-4096           2159   2159   4096 2159 2159    1 :   60   30
size-2048(DMA)         0      0   2048    0    0    1 :   60   30
size-2048           7226   8570   2048 4285 4285    1 :   60   30
size-1024(DMA)         0      0   1024    0    0    1 :  124   62
size-1024            946   1008   1024  252  252    1 :  124   62
size-512(DMA)          0      0    512    0    0    1 :  124   62
size-512             360    648    512   81   81    1 :  124   62
size-256(DMA)          0      0    256    0    0    1 :  252  126
size-256             684    810    256   53   54    1 :  252  126
size-128(DMA)          0      0    128    0    0    1 :  252  126
size-128           10667  15330    128  511  511    1 :  252  126
size-64(DMA)           0      0    128    0    0    1 :  252  126
size-64              630    630    128   21   21    1 :  252  126
size-32(DMA)           0      0     64    0    0    1 :  252  126
size-32             3855   4524     64   78   78    1 :  252  126

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
