Date: Thu, 13 Jan 2005 18:14:26 +0800
From: Bernard Blackham <bernard@blackham.com.au>
Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
Message-ID: <20050113101426.GA4883@blackham.com.au>
References: <20050113061401.GA7404@blackham.com.au> <41E61479.5040704@yahoo.com.au> <20050113085626.GA5374@blackham.com.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Content-Disposition: inline
In-Reply-To: <20050113085626.GA5374@blackham.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jan 13, 2005 at 04:56:27PM +0800, Bernard Blackham wrote:
> > Can you get a couple of Alt+SysRq+M traces during the time when
> > kswapd is going crazy please?
> 
> Embarrasingly, I can't reproduce it at the moment.

Actually I lied - It is still completely reproduceable if I hadn't
confused myself with reversing reversed patches.. :/

Attached are a couple of Alt+Sysrq+M and Alt+Sysrq+T outputs when
kswapd goes crazy, with the last pair when things are back to
normal.

Bernard.

-- 
 Bernard Blackham <bernard at blackham dot com dot au>

--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=dmesg

SysRq : Show Memory
Mem-info:
DMA per-cpu:
cpu 0 hot: low 2, high 6, batch 1
cpu 0 cold: low 0, high 2, batch 1
Normal per-cpu:
cpu 0 hot: low 32, high 96, batch 16
cpu 0 cold: low 0, high 32, batch 16
HighMem per-cpu:
cpu 0 hot: low 12, high 36, batch 6
cpu 0 cold: low 0, high 12, batch 6

Free pages:      943700kB (69840kB HighMem)
Active:10981 inactive:3029 dirty:190 writeback:86 unstable:0 free:235925 slab:2626 mapped:12109 pagetables:452
DMA free:12516kB min:68kB low:84kB high:100kB active:0kB inactive:0kB present:16384kB pages_scanned:0 all_unreclaimable? yes
protections[]: 0 0 0
Normal free:861344kB min:3756kB low:4692kB high:5632kB active:4756kB inactive:10672kB present:901120kB pages_scanned:110 all_unreclaimable? no
protections[]: 0 0 0
HighMem free:69840kB min:128kB low:160kB high:192kB active:39168kB inactive:1444kB present:114624kB pages_scanned:613 all_unreclaimable? no
protections[]: 0 0 0
DMA: 5*4kB 4*8kB 3*16kB 4*32kB 4*64kB 2*128kB 2*256kB 0*512kB 1*1024kB 1*2048kB 2*4096kB = 12516kB
Normal: 1768*4kB 968*8kB 510*16kB 343*32kB 206*64kB 83*128kB 37*256kB 13*512kB 5*1024kB 0*2048kB 191*4096kB = 861344kB
HighMem: 950*4kB 1095*8kB 806*16kB 381*32kB 149*64kB 77*128kB 24*256kB 7*512kB 3*1024kB 0*2048kB 0*4096kB = 69840kB
Swap cache: add 15300, delete 14732, find 202/245, race 0+0
Free swap:       446184kB
258032 pages of RAM
28656 pages of HIGHMEM
3260 reserved pages
31875 pages shared
568 pages swap cached
SysRq : Show State

                                               sibling
  task             PC      pid father child younger older
init          S C04140A0     0     1      0     2               (NOTLB)
c1909eac 00000082 c18dca40 c04140a0 00000000 00000001 00000000 00000000 
       c1909ec0 c1909eac 00000246 000009b5 05a9d4ed 00000044 c18dcb94 00141937 
       c1909ec0 0000000b c1909ee8 c02dae9e c1909ec0 00141937 c1bf5bc0 c0339fe0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
ksoftirqd/0   S C04140A0     0     2      1             3       (L-TLB)
c190bfa4 00000046 c18dc530 c04140a0 c0457000 c190bf80 c011b8b6 00000000 
       00000001 c190bf98 c011b64c 000000f6 686141ca 00000044 c18dc684 00000000 
       c190a000 00000000 c190bfbc c011ba95 c18dc530 00000013 c190a000 c1909f64 
Call Trace:
 [<c011ba95>] ksoftirqd+0xb5/0xd0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
events/0      R running     0     3      1             4     2 (L-TLB)
khelper       S C04140A0     0     4      1             9     3 (L-TLB)
c192bf3c 00000046 c18e5a80 c04140a0 00000292 00000000 c192a000 00000082 
       c192bf3c 00000082 f1e88060 000000d3 d98ba106 00000041 c18e5bd4 c192bf90 
       c192a000 c18cb790 c192bfbc c0126bb5 00000000 c192bf70 00000000 c18cb798 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kthread       S C04140A0     0     9      1    18     148     4 (L-TLB)
c192df3c 00000046 c18e5570 c04140a0 f1cbdddc 00000000 c192c000 00000082 
       c192df3c 00000082 f1e94a40 00000038 d31ae9d1 00000041 c18e56c4 c192df90 
       c192c000 c18ef090 c192dfbc c0126bb5 00000000 c192df70 00000000 c18ef098 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kacpid        S C04140A0     0    18      9           110       (L-TLB)
c193ff3c 00000046 c18e5060 c04140a0 0000001c 00000000 c193e000 00000082 
       c193ff3c 00000082 f76ee530 00003881 66677ead 00000044 c18e51b4 c193ff90 
       c193e000 c18f9b90 c193ffbc c0126bb5 00000000 c193ff70 00000000 c18f9b98 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kblockd/0     S C04140D0     0   110      9           146    18 (L-TLB)
c1af9f3c 00000046 f6a53060 c04140d0 00000044 00000000 c1af8000 00000082 
       6c5aed50 00000044 f6a53060 00000a10 6c5aed50 00000044 c196bb94 c1af9f90 
       c1af8000 c18f9310 c1af9fbc c0126bb5 00000000 c1af9f70 00000000 c18f9318 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
pdflush       S C0414548     0   146      9           147   110 (L-TLB)
c1b2df74 00000046 c196b530 c0414548 00000041 c1b2df48 c0120371 c1b2df74 
       abab4fe9 00000041 c196b530 000000ad ababb115 00000041 c196b174 c1b2c000 
       c1b2dfa8 c1b2c000 c1b2df8c c013c5ea 00004000 c1b2c000 c1909f60 00000000 
Call Trace:
 [<c013c5ea>] __pdflush+0x9a/0x1f0
 [<c013c768>] pdflush+0x28/0x30
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
pdflush       S C04140A0     0   147      9           149   146 (L-TLB)
c1b2bf74 00000046 c196b530 c04140a0 00000000 00000000 00000000 00000000 
       00000005 00000041 c1b08a80 000025a2 07c466b5 00000044 c196b684 c1b2a000 
       c1b2bfa8 c1b2a000 c1b2bf8c c013c5ea 00000000 c1b2a000 c1909f60 00000000 
Call Trace:
 [<c013c5ea>] __pdflush+0x9a/0x1f0
 [<c013c768>] pdflush+0x28/0x30
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
aio/0         S C0414548     0   149      9           849   147 (L-TLB)
c1b81f3c 00000046 c1bd7020 c0414548 00000041 c1b81f10 c0120371 c1b81f3c 
       abab5085 00000041 c1bd7020 0000009d ababa49f 00000041 c1b086c4 c1b81f90 
       c1b80000 c1b4ff10 c1b81fbc c0126bb5 00004000 c1b81f70 00000000 00000082 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kswapd0       D C04140A0     0   148      1           739     9 (L-TLB)
c1b2fe84 00000046 c1b08a80 c04140a0 00000001 c17d5200 c17d4380 00000000 
       c1b2fe98 c1b2fe84 00000246 00001117 6c67325d 00000044 c1b08bd4 001412cf 
       c1b2fe98 c037c028 c1b2fec0 c02dae9e c1b2fe98 001412cf c1b2ff04 c0455d60 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c02dae11>] io_schedule_timeout+0x11/0x20
 [<c02489ae>] blk_congestion_wait+0x6e/0x90
 [<c0141c1c>] balance_pgdat+0x23c/0x390
 [<c0141e4d>] kswapd+0xdd/0x100
 [<c0101325>] kernel_thread_helper+0x5/0x10
kseriod       S C0414548     0   739      1           981   148 (L-TLB)
c1b83f8c 00000046 f70aea40 c0414548 00000041 c1b83f60 c0120371 c1b83f8c 
       abac0641 00000041 f70aea40 000000f6 abae028b 00000041 c1b081b4 ffffe000 
       c1b83fc0 c1b82000 c1b83fec c023da85 00004000 c18e5a80 c1b82000 00000000 
Call Trace:
 [<c023da85>] serio_thread+0x105/0x130
 [<c0101325>] kernel_thread_helper+0x5/0x10
reiserfs/0    S C04140A0     0   849      9          4473   149 (L-TLB)
f7ec9f3c 00000046 c1bd7020 c04140a0 c01355d2 00000000 f7ec8000 00000082 
       f7ec9f3c 00000082 c196b530 000011bc 07c313ff 00000044 c1bd7174 f7ec9f90 
       f7ec8000 f7ea5e10 f7ec9fbc c0126bb5 00000000 f7ec9f70 00000000 f7ea5e18 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
devfsd        S C04140A0     0   981      1          1278   739 (NOTLB)
f7657ed8 00000086 f761ca80 c04140a0 00000042 00000000 f7656000 00000286 
       f7657ed8 00000286 c046bd70 00001a06 6a2f64b8 00000042 f761cbd4 c046bd70 
       c046bd40 f7656000 f7657f64 c01bd704 00000000 f1cbf254 00000005 c046bd68 
Call Trace:
 [<c01bd704>] devfsd_read+0xd4/0x3f0
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
khubd         S C0414548     0  1278      1          2646   981 (L-TLB)
f7051f8c 00000046 c1bd7530 c0414548 00000041 f7051f60 c0120371 f7051f8c 
       abac0a78 00000041 c1bd7530 000000f4 abae0c1a 00000041 f70aeb94 ffffe000 
       f7051fc0 f7050000 f7051fec f89f8ea5 00004000 f7607020 f7050000 00000000 
Call Trace:
 [<f89f8ea5>] packet_sklist_lock+0x385785a5/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
khpsbpkt      S C0414548     0  2646      1          2699  1278 (L-TLB)
f774df84 00000046 f7072a40 c0414548 00000041 f70aea40 c1bd7530 f70aea40 
       abac0f1a 00000041 f7072a40 000000d5 abae146c 00000041 c1bd7684 f8c3e038 
       00000246 f774c000 f774dfc8 c02da387 f774c000 f8c3e040 c1bd7530 00000000 
Call Trace:
 [<c02da387>] __down_interruptible+0xa7/0x12c
 [<c02da426>] __down_failed_interruptible+0xa/0x10
 [<f8bffbb5>] packet_sklist_lock+0x3877f2b5/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
knodemgrd_0   S C04140A0     0  2699      1          2909  2646 (L-TLB)
f7053f68 00000046 f705a060 c04140a0 ffffffff f58ef530 f705a060 f58ef530 
       f705a060 c190eb80 f1c93a40 00000610 ac8377cc 00000041 f705a1b4 f556a5b0 
       00000246 f7052000 f7053fac c02da387 f7052000 f556a5b8 f705a060 00000000 
Call Trace:
 [<c02da387>] __down_interruptible+0xa7/0x12c
 [<c02da426>] __down_failed_interruptible+0xa/0x10
 [<f8c06ad0>] packet_sklist_lock+0x387861d0/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
pccardd       S C04140A0     0  2909      1          3047  2699 (L-TLB)
f7757f84 00000046 f7072a40 c04140a0 00000000 f7757f58 c0120371 f7757f84 
       00000202 00757f6c f1c93a40 000000a5 abae1adf 00000041 f7072b94 f70a7030 
       00000000 f7756000 f7757fec f8c630d3 00004000 f70a7034 00000000 f70a716c 
Call Trace:
 [<f8c630d3>] packet_sklist_lock+0x387e27d3/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
portmap       S C0414548     0  3047      1          3130  2909 (NOTLB)
f7009f08 00000082 f7072530 c0414548 00000041 f73ac8d0 f76cf100 f7009f0c 
       ac0be85e 00000041 f7072530 0000057a ac0c8aad 00000041 f761c6c4 00000000 
       7fffffff f7009f64 f7009f44 c02daeed c02808f9 f76cf100 c18f8040 f7009fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
syslogd       S C04140A0     0  3130      1          3133  3047 (NOTLB)
f7761eac 00000086 f7072530 c04140a0 00000010 c0339e8c 00000000 000000d0 
       000003fe 000000d0 f6a53060 000158a6 3ce14c4b 00000044 f7072684 00000000 
       7fffffff 00000001 f7761ee8 c02daeed 00000000 f7761ed0 c0286e6b f70dcf00 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
klogd         R running     0  3133      1          3149  3130 (NOTLB)
slmodemd      S C04140A0     0  3149      1          3161  3133 (NOTLB)
f522deac 00000086 f708d060 c04140a0 f766ed40 00000000 f522c000 00000000 
       f522dec0 f522deac 00000246 0000063b 68dfbbbf 00000044 f708d1b4 0014141b 
       f522dec0 00000006 f522dee8 c02dae9e f522dec0 0014141b c0168756 f72b1ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
gdm           S C0414548     0  3161      1  3165    3307  3149 (NOTLB)
f7765f08 00000086 f77b6a80 c0414548 00000041 f1cae000 f776edc0 f7765fa0 
       ac0cc7d6 00000041 f77b6a80 0000095a ac0f7477 00000041 f767bbd4 00000000 
       7fffffff f7765f64 f7765f44 c02daeed c1bf58c0 f7765fa0 00000145 f73ac8b8 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gdm           S C0414548     0  3165   3161  3278               (NOTLB)
f77efeac 00000082 f761c060 c0414548 00000041 00000001 00000000 f77b6a80 
       ac0cceb3 00000041 f761c060 00000259 ac0f899f 00000041 f77b6bd4 00000000 
       7fffffff 0000000a f77efee8 c02daeed f77efec8 c0168756 f5866d00 f5dc9c1c 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
X             S C04140A0     0  3278   3165          3891       (NOTLB)
f7603eac 00000082 f761c060 c04140a0 00000044 c0339e8c 00000000 00000000 
       f7603ec0 f7603eac 00000246 00000111 6caea16e 00000044 f761c1b4 00141442 
       f7603ec0 00000020 f7603ee8 c02dae9e f7603ec0 00141442 f8827e7b c0455f88 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
spamd         S C0414548     0  3307      1  3469    3383  3161 (NOTLB)
f77d7fb4 00000082 f708da80 c0414548 00000041 f77d7f88 c0155f88 f77d7fa4 
       ac0d0f65 00000041 f708da80 000000fb ac105e46 00000041 f705abd4 08c14160 
       0814c008 08abc63c f77d7fbc c01237e7 f77d6000 c010309f 08c14160 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
acpid         S C04140A0     0  3383      1          3451  3307 (NOTLB)
f7c39f08 00000086 f708da80 c04140a0 00000246 f1c94000 f76dfd80 f7c39fa0 
       f7c39ef4 c0168756 f1aa9570 00004246 da9c0545 00000041 f708dbd4 00000000 
       7fffffff f7c39f64 f7c39f44 c02daeed c02808f9 f76dfd80 f5911200 f7c39fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
battery-daemo S C04140A0     0  3451      1          3465  3383 (NOTLB)
f509ff48 00000082 f77b6060 c04140a0 f509ff2c c016ffb9 f5f6ab18 00000000 
       f509ff5c f509ff48 00000246 00007b46 d6f5de4a 00000043 f77b61b4 001422ec 
       f509ff5c 000f41a7 f509ff84 c02dae9e f509ff5c 001422ec 00000000 f5f71ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
cpufreqd      S C04140A0     0  3465      1          3475  3451 (NOTLB)
f773bf48 00000086 f76ee530 c04140a0 f52fc4ec 00000000 f52fc4ec 00000000 
       f773bf5c f773bf48 00000246 00023952 667b828f 00000044 f76ee684 001417c2 
       f773bf5c 000f41a7 f773bf84 c02dae9e f773bf5c 001417c2 00000000 c0455fa0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
spamd         S C0414548     0  3469   3307                     (NOTLB)
f50a1df8 00000082 f7072020 c0414548 00000041 c0139e91 c0339d68 c1766a20 
       ac0ed5ae 00000041 f7072020 00000475 ac165084 00000041 f77b66c4 f77b6570 
       7fffffff f50a0000 f50a1e34 c02daeed 00000000 00000246 f50a1e38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
cupsd         S C04140A0     0  3475      1          3487  3465 (NOTLB)
f50b5eac 00000086 f7072020 c04140a0 f27af000 f76cf340 f50b5f44 00000000 
       f50b5ec0 f50b5eac 00000246 0000070e fd378669 00000043 f7072174 00147e38 
       f50b5ec0 00000004 f50b5ee8 c02dae9e f50b5ec0 00147e38 f5866040 c0456170 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
dbus-daemon-1 S C0414548     0  3487      1          3522  3475 (NOTLB)
f6b07f08 00000082 c1bd7a40 c0414548 00000041 f1caa000 f76cfc40 f6b07fa0 
       ac0ef114 00000041 c1bd7a40 000005e3 ac16a515 00000041 f70ae174 00000000 
       7fffffff f6b07f64 f6b07f44 c02daeed c02808f9 f76cfc40 f5f829c0 f6b07fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3522      1  3523    3527  3487 (NOTLB)
f5f73f10 00000086 f762aa40 c0414548 00000041 f5f72000 f5f73fc4 00000000 
       ac2f2855 00000041 f762aa40 000001a1 ac832b40 00000041 f5f47b94 fffffe00 
       f5f72000 f5f47ae0 f5f73f88 c011a0d8 ffffffff 00000004 f58ef530 f5f73f48 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3523   3522          3578       (NOTLB)
f5f5ddf8 00000086 f76ee020 c0414548 00000041 c1754320 00000000 00000202 
       ac2f33d5 00000041 f76ee020 00000348 ac834c16 00000041 f762ab94 f762aa40 
       7fffffff f5f5c000 f5f5de34 c02daeed 00000000 00000246 f5f5de38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
famd          S C04140A0     0  3527      1          3532  3522 (NOTLB)
f5f71eac 00000082 c1bd7a40 c04140a0 f766e8c0 f5f71f44 00000246 00000000 
       f5f71ec0 f5f71eac 00000246 00000b62 411b1e3f 00000044 c1bd7b94 00142229 
       f5f71ec0 0000001d f5f71ee8 c02dae9e f5f71ec0 00142229 f8827e7b c0455ff8 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
inetd         S C0414548     0  3532      1          3580  3527 (NOTLB)
f556feac 00000086 f762a020 c0414548 00000041 f70dd4c0 00000246 f1ef0000 
       ac0f0588 00000041 f762a020 0000030d ac16e41e 00000041 f705a6c4 00000000 
       7fffffff 00000007 f556fee8 c02daeed f70dd4c0 f5f1fc40 f556ff44 00000202 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3578   3522          3615  3523 (NOTLB)
f5f6fdf8 00000082 f58ef530 c0414548 00000041 c17537a0 00000000 00000202 
       ac2f399c 00000041 f58ef530 00000191 ac835bc6 00000041 f76ee174 f76ee020 
       7fffffff f5f6e000 f5f6fe34 c02daeed 00000000 00000246 f5f6fe38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
cardmgr       S C0414548     0  3580      1          3674  3532 (NOTLB)
f5f5beac 00000086 f58d2a80 c0414548 00000041 00000000 00000000 00000001 
       ac0f0c53 00000041 f58d2a80 00000221 ac16f74f 00000041 f762a174 00000000 
       7fffffff 00000004 f5f5bee8 c02daeed f70dcd80 f5f5bf44 f5f5bed0 c0168756 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3615   3522                3578 (NOTLB)
f5d23df8 00000082 f705a060 c0414548 00000041 c0139e91 c0339d68 c174d8e0 
       abeb63d3 00000041 f705a060 00000197 ac836bac 00000041 f58ef684 f58ef530 
       7fffffff f5d22000 f5d23e34 c02daeed 00000000 00000246 f5d23e38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
master        S C0414548     0  3674      1  3678    3684  3580 (NOTLB)
f5d0beac 00000082 f761c060 c0414548 00000041 f731c4c0 00000002 00000000 
       ac2b42ff 00000041 f761c060 00000d72 ac4f4212 00000041 f58d2bd4 00143f11 
       f5d0bec0 00000056 f5d0bee8 c02dae9e f5d0bec0 00143f11 f8827e7b c04560e0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
pickup        S C0414548     0  3678   3674          3679       (NOTLB)
f5895eac 00000082 f5f47020 c0414548 00000041 c0339e8c 00000000 00000000 
       ac0f32ec 00000041 f5f47020 0000023a ac1774a6 00000041 f5f47684 0014db4e 
       f5895ec0 00000007 f5895ee8 c02dae9e f5895ec0 0014db4e f5866580 c047aee0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
qmgr          S C0414548     0  3679   3674                3678 (NOTLB)
f5897eac 00000086 f58d2060 c0414548 00000041 c0339e8c 00000000 00000000 
       ac0f3a2c 00000041 f58d2060 0000027e ac178b1c 00000041 f5f47174 001af5ce 
       f5897ec0 00000007 f5897ee8 c02dae9e f5897ec0 001af5ce f58664c0 c0456240 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
sshd          S C0414548     0  3684      1          3702  3674 (NOTLB)
f5d1feac 00000086 f58ef020 c0414548 00000041 f5d1ff44 00000246 f1a95000 
       ac0f3f8c 00000041 f58ef020 000001d1 ac179b77 00000041 f58d21b4 00000000 
       7fffffff 00000004 f5d1fee8 c02daeed f5d1febc c0120371 f5d1fee8 00000202 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
ssh-guard     S C04140D0     0  3702      1  3777    3705  3684 (NOTLB)
f5419ea4 00000082 f761c060 c04140d0 00000042 f76c2700 f5419ebc c02da712 
       7568799d 00000042 f761c060 00001755 756ce22e 00000042 f58ef174 f5415994 
       f5419ecc f5419ec0 f5419ef8 c01617fe 00000000 f58ef020 c012b190 f5419ed8 
Call Trace:
 [<c01617fe>] pipe_wait+0x6e/0x90
 [<c0161a17>] pipe_readv+0x1c7/0x300
 [<c0161b84>] pipe_read+0x34/0x40
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
uml_switch    S C04140A0     0  3705      1          3763  3702 (NOTLB)
f5d21f08 00000086 f58efa40 c04140a0 00000246 f1a94000 f52fb540 f5d21fa0 
       f5d21ef4 c0168756 f733a7c0 00000575 4d5247fd 00000044 f58efb94 00000000 
       7fffffff f5d21f64 f5d21f44 c02daeed c02808f9 f52fb540 f73330c0 f5d21fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
S20xprint     S C0414548     0  3763      1  3764    3776  3705 (NOTLB)
f5461f10 00000082 f5452530 c0414548 00000041 f5460000 f5461fc4 00000000 
       ac0f525b 00000041 f5452530 0000017f ac17d596 00000041 f5407174 fffffe00 
       f5460000 f54070c0 f5461f88 c011a0d8 ffffffff 00000004 f5452a40 c04140a0 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
S20xprint     S C0414548     0  3764   3763  3765    3767       (NOTLB)
f548bf10 00000082 f5452020 c0414548 00000041 f548a000 f548bfc4 00000000 
       ac0f558a 00000041 f5452020 000000ff ac17de8d 00000041 f5452684 fffffe00 
       f548a000 f54525d0 f548bf88 c011a0d8 ffffffff 00000004 f5452020 bfffe1b4 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
Xprt          S C0414548     0  3765   3764                     (NOTLB)
f548deac 00000082 f5452a40 c0414548 00000041 c0339e8c 00000000 000000d0 
       ac0f5b73 00000041 f5452a40 00000205 ac17f0bc 00000041 f5452174 00000000 
       7fffffff 00000001 f548dee8 c02daeed 00000000 f548ded0 f8827e7b f5403880 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
S20xprint     S C0414548     0  3767   3763                3764 (NOTLB)
f5489ea4 00000082 f541f060 c0414548 00000041 c190e940 f5489ebc c02da712 
       ac0f6010 00000041 f541f060 00000188 ac17fe8b 00000041 f5452b94 f589127c 
       f5489ecc f5489ec0 f5489ef8 c01617fe 00000000 f5452a40 c012b190 f5489ed8 
Call Trace:
 [<c01617fe>] pipe_wait+0x6e/0x90
 [<c0161a17>] pipe_readv+0x1c7/0x300
 [<c0161b84>] pipe_read+0x34/0x40
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
rpc.statd     S C0414548     0  3776      1          3780  3763 (NOTLB)
f5487eac 00000082 f52fd060 c0414548 00000041 f52fb3c0 00000246 f1a92000 
       ac0f6843 00000041 f52fd060 000002c9 ac18179c 00000041 f541f1b4 00000000 
       7fffffff 00000007 f5487ee8 c02daeed f52fb3c0 f7341c40 f5487f44 00000202 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
tail          S C04140D0     0  3777   3702                     (NOTLB)
f543ff48 00000086 f761c060 c04140d0 00000044 00000000 00026cdc 00000000 
       56fc6037 00000044 f761c060 000004f2 56fc6037 00000044 f52fd1b4 001412d6 
       f543ff5c 000f41a7 f543ff84 c02dae9e f543ff5c 001412d6 f543ffac c0455d98 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
atd           S C0414548     0  3780      1          3783  3776 (NOTLB)
f5d0df50 00000086 f541f570 c0414548 00000041 00000000 f5d0df5c 00000000 
       ac0f7caa 00000041 f541f570 00000121 ac1857b7 00000041 f58d26c4 003370de 
       f5d0df64 bffffbbc f5d0df8c c02dae9e f5d0df64 003370de 00000000 c0456300 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c02daf3a>] nanosleep_restart+0x4a/0xa0
 [<c0122796>] sys_restart_syscall+0x16/0x20
 [<c010309f>] syscall_call+0x7/0xb
cron          S C0414548     0  3783      1          3812  3780 (NOTLB)
f5485f50 00000086 f762a530 c0414548 00000041 00000000 f5485f5c 00000000 
       ac0f7ffe 00000041 f762a530 000000ea ac185ff5 00000041 f541f6c4 00146e7e 
       f5485f64 bffffc3c f5485f8c c02dae9e f5485f64 00146e7e 00000000 f707265c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c02daf3a>] nanosleep_restart+0x4a/0xa0
 [<c0122796>] sys_restart_syscall+0x16/0x20
 [<c010309f>] syscall_call+0x7/0xb
bash          S C04140A0     0  3812      1  4568    3813  3783 (NOTLB)
f769ff10 00000086 f762a530 c04140a0 f767cdc0 f767cdec f7698b74 f769ffbc 
       c0111220 f767cdc0 f7698b74 00001e14 3efacdb6 00000042 f762a684 fffffe00 
       f769e000 f762a5d0 f769ff88 c011a0d8 ffffffff 00000006 f1e94020 00000002 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
bash          S C04140A0     0  3813      1          3814  3812 (NOTLB)
f76b5e70 00000082 f767b570 c04140a0 c01e4173 0000000b 0000000d 0000000e 
       00005b0f 00000286 f54db000 00003e68 7e38ee04 00000043 f767b6c4 f54db000 
       7fffffff f766e2c0 f76b5eac c02daeed 0000000b 0000000d 0000000e 00005b0f 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3814      1          3815  3813 (NOTLB)
f5e1fe70 00000086 f52fda80 c0414548 00000041 0000481e 00000000 00000000 
       ac0f9102 00000041 f52fda80 0000019e ac1893e7 00000041 f54f6bd4 f5e5d000 
       7fffffff f7694680 f5e1feac c02daeed c02da712 f767b570 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3815      1          3816  3814 (NOTLB)
f5441e70 00000082 f54fa530 c0414548 00000041 0000481e 00000000 00000000 
       ac0f96d2 00000041 f54fa530 000001cf ac18a431 00000041 f52fdbd4 f5e85000 
       7fffffff f769a4c0 f5441eac c02daeed c02da712 f54f6a80 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3816      1          3817  3815 (NOTLB)
f5e97e70 00000082 f54fa020 c0414548 00000041 0000481e 00000000 00000000 
       ac0f9b15 00000041 f54fa020 00000166 ac18b0cf 00000041 f54fa684 f5e56000 
       7fffffff f766c400 f5e97eac c02daeed c02da712 f52fda80 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3817      1          3944  3816 (NOTLB)
f5e99e70 00000086 f708d570 c0414548 00000041 0000481e 00000000 00000000 
       ac0fa0eb 00000041 f708d570 000001fc ac18c2b3 00000041 f54fa174 f5e9a000 
       7fffffff f766c580 f5e99eac c02daeed c02da712 f54fa530 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
gnome-session S C04140D0     0  3891   3165  3946          3278 (NOTLB)
f50a3f08 00000086 f671f570 c04140d0 00000041 f1a91000 f5645880 f50a3fa0 
       ea95e8ab 00000041 f671f570 00000ad4 ea99cba1 00000041 f708d6c4 00000000 
       7fffffff f50a3f64 f50a3f44 c02daeed c02808f9 f5645880 f6a9a540 f50a3fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
ssh-agent     S C0414548     0  3944      1          3949  3817 (NOTLB)
f6a21eac 00000082 f70ae530 c0414548 00000041 c0339e8c 00000000 000000d0 
       ac0fe936 00000041 f70ae530 000001f8 ac19b0a5 00000041 f5407684 00000000 
       7fffffff 00000004 f6a21ee8 c02daeed 00000003 f6a21ed0 f8827e7b f7774e40 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
ssh-add-all   X C04140D0     0  3946   3891          3950       (L-TLB)
f6a0bf70 00000046 f761c060 c04140d0 00000041 f54f6060 00000011 c18cb800 
       10d5100a 00000041 f761c060 0000017c 10df3faf 00000041 f54f61b4 00000001 
       f54f6060 00000000 f6a0bf9c c0118fe3 f54f6060 c18e7ae0 00000008 f7774780 
Call Trace:
 [<c0118fe3>] do_exit+0x1f3/0x3b0
 [<c0119214>] do_group_exit+0x34/0xa0
 [<c0119295>] sys_exit_group+0x15/0x20
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140A0     0  3949      1  3967    3992  3944 (NOTLB)
f6a43eac 00000082 f70ae530 c04140a0 f5344000 00000000 f6a42000 00000000 
       f6a43ec0 f6a43eac 00000246 000000c7 6bd9046e 00000044 f70ae684 00141600 
       f6a43ec0 00000008 f6a43ee8 c02dae9e f6a43ec0 00141600 f534400c c0455f98 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
Xsession      S C0414548     0  3950   3891  3993          3946 (NOTLB)
f6a0df10 00000082 f541fa80 c0414548 00000041 f6a0c000 f6a0dfc4 00000000 
       ac0ffbb3 00000041 f541fa80 00000179 ac19eb74 00000041 f54f66c4 fffffe00 
       f6a0c000 f54f6610 f6a0df88 c011a0d8 ffffffff 00000004 f6a4ba40 00000000 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  3967   3949                     (NOTLB)
f6a57e70 00000082 f7267530 c0414548 00000041 00000b15 321a3def 00000037 
       ac10011a 00000041 f7267530 0000017e ac19f8e4 00000041 f541fbd4 f7ec5000 
       7fffffff f5e8b0c0 f6a57eac c02daeed c02da712 f54f6570 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
gconfd-2      S C04140A0     0  3992      1          4043  3949 (NOTLB)
f72b3f08 00000086 f7267530 c04140a0 00000246 f1a8e000 f2107140 00000000 
       f72b3f1c f72b3f08 00000246 000059a2 728a5f9b 00000042 f7267684 00142d94 
       f72b3f1c f72b3f64 f72b3f44 c02dae9e f72b3f1c 00142d94 f26500c0 c0456050 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140D0     0  3993   3950  4038    3999       (NOTLB)
f6a55eac 00000082 f6a4b530 c04140d0 00000044 00000000 f6a54000 00000000 
       6bd8bb18 00000044 f6a4b530 0000008e 6bd8f7fb 00000044 f52fd6c4 00141600 
       f6a55ec0 00000005 f6a55ee8 c02dae9e f6a55ec0 00141600 f534300c f6a7fec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140D0     0  3999   3950  4036    4001  3993 (NOTLB)
f6a7feac 00000082 f70ae530 c04140d0 00000044 00000000 f6a7e000 00000000 
       6bd6daf5 00000044 f70ae530 00000077 6bd8fca6 00000044 f6a4b684 00141600 
       f6a7fec0 00000005 f6a7fee8 c02dae9e f6a7fec0 00141600 f6a3100c f6a43ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140A0     0  4001   3950  4040    4002  3999 (NOTLB)
f72b1eac 00000082 f7267a40 c04140a0 f5347000 00000000 f72b0000 00000000 
       f72b1ec0 f72b1eac 00000246 00000b22 69002d76 00000044 f7267b94 00141431 
       f72b1ec0 00000005 f72b1ee8 c02dae9e f72b1ec0 00141431 f534700c f6a83ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
beep-media-pl S C04140D0     0  4002   3950          4011  4001 (NOTLB)
f72aff08 00000082 f761c060 c04140d0 00000044 f3d9b000 f531ad00 00000000 
       6cae6f13 00000044 f761c060 00000691 6cae96c2 00000044 f6a531b4 00141280 
       f72aff1c f72aff64 f72aff44 c02dae9e f72aff1c 00141280 f6a9a9c0 c0455ae8 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
beep-media-pl S C04140A0     0  4012   3950          4044  4011 (NOTLB)
f6a59eac 00000082 f54faa40 c04140a0 00000010 c0339e8c 00000000 00000000 
       f6a59ec0 f6a59eac 00000246 0000011f 6c516cd2 00000044 f54fab94 001412c9 
       f6a59ec0 00000008 f6a59ee8 c02dae9e f6a59ec0 001412c9 f8827e7b c0455d30 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
beep-media-pl S C04140A0     0  4044   3950                4012 (NOTLB)
f6a85f48 00000082 f6a4ba40 c04140a0 c0258d26 c04742b0 f1882424 00000000 
       f6a85f5c f6a85f48 00000246 0000361c 6a33a34a 00000044 f6a4bb94 00141304 
       f6a85f5c 1ddca6a7 f6a85f84 c02dae9e f6a85f5c 00141304 00000000 c0455f80 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140A0     0  4011   3950  4013    4012  4002 (NOTLB)
f6a83eac 00000082 f6a38060 c04140a0 f534b000 00000000 f6a82000 00000000 
       f6a83ec0 f6a83eac 00000246 000008fc 6901ebab 00000044 f6a381b4 00141432 
       f6a83ec0 00000005 f6a83ee8 c02dae9e f6a83ec0 00141432 f534b00c f7603ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4013   4011                     (NOTLB)
f6a6be70 00000082 f6a53a80 c0414548 00000041 0000001a ff12a44a 00000036 
       ac115d5e 00000041 f6a53a80 000001b3 ac1e7cc8 00000041 f6a38bd4 f534c000 
       7fffffff f536b8c0 f6a6beac c02daeed c02da712 f6a38060 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4036   3999  4037               (NOTLB)
f563bf94 00000082 f5608060 c0414548 00000041 00010000 00000000 00000000 
       ac115fde 00000041 f5608060 000000be ac1e837d 00000041 f6a53bd4 f563a000 
       00000000 080c9a40 f563bfbc c010220d f563bfb0 bffff270 00000008 00010000 
Call Trace:
 [<c010220d>] sys_rt_sigsuspend+0xad/0xe0
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140A0     0  4037   4036                     (NOTLB)
f5639fb4 00000086 f5608060 c04140a0 0000000f 00000012 00000000 f5639fbc 
       c011f9db 00000000 f5608a80 00000a30 2e1649bd 00000044 f56081b4 00000000 
       00000012 00000000 f5639fbc c01237e7 f5638000 c010309f 00000000 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4038   3993  4039               (NOTLB)
f6a99f94 00000086 f5608a80 c0414548 00000041 00010000 00000000 00000000 
       ac116650 00000041 f5608a80 000000b6 ac1e943d 00000041 f56086c4 f6a98000 
       00000000 080c9a40 f6a99fbc c010220d f6a99fb0 bffff270 00000008 00010000 
Call Trace:
 [<c010220d>] sys_rt_sigsuspend+0xad/0xe0
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140A0     0  4039   4038                     (NOTLB)
f5637fb4 00000082 f5608a80 c04140a0 0000000f 00000012 00000000 f5637fbc 
       c011f9db 00000000 f6a4b020 000003a3 2e166a7e 00000044 f5608bd4 00000000 
       00000012 00000000 f5637fbc c01237e7 f5636000 c010309f 00000000 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4040   4001  4041               (NOTLB)
f6a81f94 00000082 f6a4b020 c0414548 00000041 00010000 00000000 00000000 
       ac116b9a 00000041 f6a4b020 000000ab ac1ea28d 00000041 f7267174 f6a80000 
       00000000 080c9a40 f6a81fbc c010220d f6a81fb0 bffff270 00000008 00010000 
Call Trace:
 [<c010220d>] sys_rt_sigsuspend+0xad/0xe0
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140D0     0  4041   4040                     (NOTLB)
f5635fb4 00000082 f76eea40 c04140d0 00000044 00000012 00000000 f5635fbc 
       2e0e0699 00000044 f76eea40 000006d4 2e16a7f7 00000044 f6a4b174 00000000 
       00000012 00000000 f5635fbc c01237e7 f5634000 c010309f 00000000 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
gnome-keyring S C0414548     0  4043      1          4046  3992 (NOTLB)
f6a87f08 00000082 f6814530 c0414548 00000041 f1a9f000 f5a27d80 f6a87fa0 
       ac118597 00000041 f6814530 00000838 ac1ef68f 00000041 f6a536c4 00000000 
       7fffffff f6a87f64 f6a87f44 c02daeed c02808f9 f5a27d80 f6a9a3c0 f6a87fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
bonobo-activa S C0414548     0  4046      1          4048  4043 (NOTLB)
f684ff08 00000086 f6814020 c0414548 00000041 f1a9e000 f21b5f00 f684ffa0 
       ac11bfa5 00000041 f6814020 00001589 ac1fb863 00000041 f6814684 00000000 
       7fffffff f684ff64 f684ff44 c02daeed c02808f9 f21b5f00 f21b2940 f684ffa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-smproxy S C0414548     0  4048      1          4050  4046 (NOTLB)
f6741eac 00200086 f671f570 c0414548 00000041 c0339e8c 00000000 000000d0 
       ac11cc07 00000041 f671f570 00000454 ac1fdf5f 00000041 f6814174 00000000 
       7fffffff 0000000b f6741ee8 c02daeed 0000000a f6741ed0 f8827e7b f48a0700 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
gnome-setting S C04140D0     0  4050      1          4090  4048 (NOTLB)
f6765f08 00000086 f761c060 c04140d0 00000041 f1a9c000 f688d680 f6765fa0 
       ea9b5259 00000041 f761c060 00000520 ea9bfc36 00000041 f671f6c4 00000000 
       7fffffff f6765f64 f6765f44 c02daeed c02808f9 f688d680 f68ec7c0 f6765fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
xscreensaver  S C04140A0     0  4090      1          4114  4050 (NOTLB)
f6763eac 00000082 f671f060 c04140a0 00000010 c0339e8c 00000000 00000000 
       f6763ec0 f6763eac 00000246 00000300 48c7ed5c 00000044 f671f1b4 00141fa1 
       f6763ec0 00000005 f6763ee8 c02dae9e f6763ec0 00141fa1 f56059c0 c0455fe0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
metacity      S C04140D0     0  4114      1          4122  4090 (NOTLB)
f63c7f08 00000086 f6814a40 c04140d0 00000041 f1a9a000 f6df3800 f63c7fa0 
       ea94d077 00000041 f6814a40 0000083a ea95f37d 00000041 f671fbd4 00000000 
       7fffffff f63c7f64 f63c7f44 c02daeed c02808f9 f6df3800 f6ccec40 f63c7fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-panel   S C04140D0     0  4122      1          4124  4114 (NOTLB)
f683df08 00000082 f6a53060 c04140d0 00000041 f1a89000 f21b59c0 f683dfa0 
       ea9b0e0d 00000041 f6a53060 00000b50 ea9b7344 00000041 f6814b94 00000000 
       7fffffff f683df64 f683df44 c02daeed c02808f9 f21b59c0 f21b21c0 f683dfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C04140D0     0  4124      1          4136  4122 (NOTLB)
f4d27f08 00000082 f671f570 c04140d0 00000041 f1a88000 f4a6eac0 f4d27fa0 
       ea9b0ea7 00000041 f671f570 000004ff ea9bce16 00000041 f6cad684 00000000 
       7fffffff f4d27f64 f4d27f44 c02daeed c02808f9 f4a6eac0 f63d1dc0 f4d27fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4136      1          4138  4124 (NOTLB)
f4421f08 00000082 f6cad020 c0414548 00000041 f1a87000 f45b8ec0 f4421fa0 
       ac127bd6 00000041 f6cad020 0000061b ac222219 00000041 f4cf46c4 00000000 
       7fffffff f4421f64 f4421f44 c02daeed c02808f9 f45b8ec0 f46829c0 f4421fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4142      1          4143  4139 (NOTLB)
f6c33e84 00000082 f4cf4060 c0414548 00000041 0000003b f6cad530 f6c33e74 
       ac12842d 00000041 f4cf4060 000002ec ac223c65 00000041 f6cad174 081c4b90 
       7fffffff fffffff5 f6c33ec0 c02daeed f767c280 081c4000 76796a33 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4143      1          4144  4142 (NOTLB)
f4d49e84 00000082 f479ca40 c0414548 00000041 f6cad530 f767c280 f4d49e74 
       ac1287a9 00000041 f479ca40 00000119 ac22464b 00000041 f4cf41b4 081c4e80 
       7fffffff fffffff5 f4d49ec0 c02daeed f767c280 081c4000 76796cc7 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4144      1          4146  4143 (NOTLB)
f4463e84 00000082 f479c530 c0414548 00000041 00000000 f4463f58 f4463e74 
       ac128b11 00000041 f479c530 00000113 ac224ff8 00000041 f479cb94 081c5170 
       7fffffff fffffff5 f4463ec0 c02daeed f767c280 081c5000 76796f49 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4147      1          4149  4146 (NOTLB)
f4147e84 00000082 f6cada40 c0414548 00000041 f6cad530 f767c280 f4147e74 
       ac128eb4 00000041 f6cada40 00000126 ac225a52 00000041 f479c684 08213928 
       7fffffff fffffff5 f4147ec0 c02daeed f767c280 08213000 76797212 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
gnome-vfs-dae S C0414548     0  4138      1          4139  4136 (NOTLB)
f4475f08 00000082 f4cf4a80 c0414548 00000041 f1a86000 f45b88c0 f4475fa0 
       ac12a1df 00000041 f4cf4a80 000006f7 ac229908 00000041 f6cadb94 00000000 
       7fffffff f4475f64 f4475f44 c02daeed c02808f9 f45b88c0 f46823c0 f4475fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-vfs-dae S C0414548     0  4139      1          4142  4138 (NOTLB)
f4d4bf08 00000082 f479c020 c0414548 00000041 f1a85000 f45b8740 f4d4bfa0 
       ac12b2a3 00000041 f479c020 0000060e ac22cf8c 00000041 f4cf4bd4 00000000 
       7fffffff f4d4bf64 f4d4bf44 c02daeed c02808f9 f45b8740 f46820c0 f4d4bfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
mapping-daemo S C04140A0     0  4146      1          4147  4144 (NOTLB)
f4135f08 00000082 f479c020 c04140a0 00000246 f3bc4000 f41e4e40 00000000 
       f4135f1c f4135f08 00000246 00000719 6a9b38f5 00000044 f479c174 001424dd 
       f4135f1c f4135f64 f4135f44 c02dae9e f4135f1c 001424dd f46a5c40 c0456008 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
wnck-applet   S C04140D0     0  4149      1          4151  4147 (NOTLB)
f3e3df08 00000082 f4688060 c04140d0 00000041 f1a83000 f3f75d40 f3e3dfa0 
       ea950aed 00000041 f4688060 0000081e ea969208 00000041 f46886c4 00000000 
       7fffffff f3e3df64 f3e3df44 c02daeed c02808f9 f3f75d40 f3f63800 f3e3dfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gweather-appl S C04140D0     0  4151      1          4152  4149 (NOTLB)
f391ff08 00000086 f342d020 c04140d0 00000041 f1a82000 f39cc480 00000000 
       ea9528e5 00000041 f342d020 000008cc ea96ea03 00000041 f46881b4 002d5308 
       f391ff1c f391ff64 f391ff44 c02dae9e f391ff1c 002d5308 f3a31c40 c0473a00 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gweather-appl S C0414548     0  4152      1          4153  4151 (NOTLB)
f3e2be84 00000086 f342da40 c0414548 00000041 00000000 f6a407ac f3e2be74 
       ac130e57 00000041 f342da40 00000256 ac23fd14 00000041 f4688bd4 0819c320 
       7fffffff fffffff5 f3e2bec0 c02daeed f767c4c0 0819c000 7679a461 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
gweather-appl S C0414548     0  4153      1          4155  4152 (NOTLB)
f3461e84 00000086 f342d020 c0414548 00000041 f4688060 f767c4c0 f3461e74 
       ac1311e3 00000041 f342d020 00000120 ac240737 00000041 f342db94 0819c940 
       7fffffff fffffff5 f3461ec0 c02daeed f767c4c0 0819c000 7679aaa3 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
battstat-appl S C04140A0     0  4155      1          4157  4153 (NOTLB)
f34c5f08 00000082 f342d020 c04140a0 00000246 f1e25000 f3567440 00000000 
       f34c5f1c f34c5f08 00000246 00000e88 558edf94 00000044 f342d174 001412bd 
       f34c5f1c f34c5f64 f34c5f44 c02dae9e f34c5f1c 001412bd f3039200 c0455cd0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
clock-applet  S C04140A0     0  4157      1          4159  4155 (NOTLB)
f3077f08 00000082 f304fa80 c04140a0 00000246 f49db000 f314a580 00000000 
       f3077f1c f3077f08 00000246 000004d9 58bc4d7b 00000044 f304fbd4 001412c1 
       f3077f1c f3077f64 f3077f44 c02dae9e f3077f1c 001412c1 f3164940 c0455cf0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
multiload-app S C04140A0     0  4159      1          4161  4157 (NOTLB)
f3399f08 00000086 f304f570 c04140a0 00000044 f775a000 f6a9c340 00000000 
       f3399f1c f3399f08 00000246 000000b0 6bed5729 00000044 f304f6c4 00141284 
       f3399f1c f3399f64 f3399f44 c02dae9e f3399f1c 00141284 f31bc200 c0455b08 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
notification- S C04140D0     0  4161      1          4164  4159 (NOTLB)
f2d6bf08 00000086 f2e8ba40 c04140d0 00000041 f1e06000 f2ddb280 f2d6bfa0 
       ea959d0e 00000041 f2e8ba40 000007d0 ea983de4 00000041 f304f1b4 00000000 
       7fffffff f2d6bf64 f2d6bf44 c02daeed c02808f9 f2ddb280 f2e4c940 f2d6bfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
netloc.py     S C04140D0     0  4164      1          4167  4161 (NOTLB)
f2eadf08 00000086 f304f570 c04140d0 00000044 f1e87000 f2ac86c0 00000000 
       6be58b8e 00000044 f304f570 000008c0 6be58b8e 00000044 f2e8bb94 00141284 
       f2eadf1c f2eadf64 f2eadf44 c02dae9e f2eadf1c 00141284 f65d9b40 f3399f1c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
wireless-appl S C04140D0     0  4167      1          4169  4164 (NOTLB)
f246bf08 00000082 f761c060 c04140d0 00000044 f1a8c000 f257e140 00000000 
       3ce2df93 00000044 f761c060 00000349 3ce37405 00000044 f2e8b684 0014128f 
       f246bf1c f246bf64 f246bf44 c02dae9e f246bf1c 0014128f f25b5340 c0455b60 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
mini_commande S C04140D0     0  4169      1          4171  4167 (NOTLB)
f268df08 00000086 f20afa80 c04140d0 00000041 f1e23000 f2780640 f268dfa0 
       ea95eeb6 00000041 f20afa80 00000688 ea9923ad 00000041 f2e8b174 00000000 
       7fffffff f268df64 f268df44 c02daeed c02808f9 f2780640 f2650b40 f268dfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-cpufreq S C04140D0     0  4171      1                4169 (NOTLB)
f20dff08 00000082 f761c060 c04140d0 00000044 f1e24000 f21b5a80 00000000 
       55cc819f 00000044 f761c060 000000e8 55ce6ab0 00000044 f20afbd4 001412c0 
       f20dff1c f20dff64 f20dff44 c02dae9e f20dff1c 001412c0 f21b2340 c0455ce8 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
ipw2200/0     S C04140A0     0  4473      9                 849 (L-TLB)
f71c5f3c 00000046 f1e94a40 c04140a0 00000046 00000000 f71c4000 00000082 
       f71c5f3c 00000082 f1c8b518 0000010b 4dd1dd46 00000044 f1e94b94 f71c5f90 
       f71c4000 f1c8b510 f71c5fbc c0126bb5 00000000 f71c5f70 00000000 f1c8b518 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
top           S C04140A0     0  4568   3812                     (NOTLB)
f1e2beac 00000086 f1e94020 c04140a0 f766c700 00000000 f1e2a000 00000000 
       f1e2bec0 f1e2beac 00000246 000242b8 1c075152 00000044 f1e94174 001412de 
       f1e2bec0 00000001 f1e2bee8 c02dae9e f1e2bec0 001412de c1bfb00c c0455dd8 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
SysRq : Show Memory
Mem-info:
DMA per-cpu:
cpu 0 hot: low 2, high 6, batch 1
cpu 0 cold: low 0, high 2, batch 1
Normal per-cpu:
cpu 0 hot: low 32, high 96, batch 16
cpu 0 cold: low 0, high 32, batch 16
HighMem per-cpu:
cpu 0 hot: low 12, high 36, batch 6
cpu 0 cold: low 0, high 12, batch 6

Free pages:      953252kB (72096kB HighMem)
Active:10064 inactive:1556 dirty:0 writeback:0 unstable:0 free:238313 slab:2613 mapped:10236 pagetables:452
DMA free:12516kB min:68kB low:84kB high:100kB active:0kB inactive:0kB present:16384kB pages_scanned:0 all_unreclaimable? yes
protections[]: 0 0 0
Normal free:868640kB min:3756kB low:4692kB high:5632kB active:4100kB inactive:4004kB present:901120kB pages_scanned:195 all_unreclaimable? no
protections[]: 0 0 0
HighMem free:72096kB min:128kB low:160kB high:192kB active:36156kB inactive:2220kB present:114624kB pages_scanned:0 all_unreclaimable? no
protections[]: 0 0 0
DMA: 5*4kB 4*8kB 3*16kB 4*32kB 4*64kB 2*128kB 2*256kB 0*512kB 1*1024kB 1*2048kB 2*4096kB = 12516kB
Normal: 1852*4kB 1020*8kB 559*16kB 357*32kB 217*64kB 93*128kB 42*256kB 17*512kB 5*1024kB 0*2048kB 191*4096kB = 868640kB
HighMem: 1174*4kB 1095*8kB 797*16kB 376*32kB 155*64kB 75*128kB 28*256kB 8*512kB 3*1024kB 0*2048kB 0*4096kB = 72096kB
Swap cache: add 17002, delete 16722, find 203/247, race 0+0
Free swap:       439400kB
258032 pages of RAM
28656 pages of HIGHMEM
3260 reserved pages
30791 pages shared
280 pages swap cached
SysRq : Show State

                                               sibling
  task             PC      pid father child younger older
init          S C04140A0     0     1      0     2               (NOTLB)
c1909eac 00000082 c18dca40 c04140a0 00000000 00000001 00000000 00000000 
       c1909ec0 c1909eac 00000246 000009b5 05a9d4ed 00000044 c18dcb94 00141937 
       c1909ec0 0000000b c1909ee8 c02dae9e c1909ec0 00141937 c1bf5bc0 c0339fe0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
ksoftirqd/0   S C04140A0     0     2      1             3       (L-TLB)
c190bfa4 00000046 c18dc530 c04140a0 c0457000 c190bf80 c011b8b6 00000000 
       00000001 c190bf98 c011b64c 000000f6 686141ca 00000044 c18dc684 00000000 
       c190a000 00000000 c190bfbc c011ba95 c18dc530 00000013 c190a000 c1909f64 
Call Trace:
 [<c011ba95>] ksoftirqd+0xb5/0xd0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
events/0      R running     0     3      1             4     2 (L-TLB)
khelper       S C04140A0     0     4      1             9     3 (L-TLB)
c192bf3c 00000046 c18e5a80 c04140a0 00000292 00000000 c192a000 00000082 
       c192bf3c 00000082 f1e88060 000000d3 d98ba106 00000041 c18e5bd4 c192bf90 
       c192a000 c18cb790 c192bfbc c0126bb5 00000000 c192bf70 00000000 c18cb798 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kthread       S C04140A0     0     9      1    18     148     4 (L-TLB)
c192df3c 00000046 c18e5570 c04140a0 f1cbdddc 00000000 c192c000 00000082 
       c192df3c 00000082 f1e94a40 00000038 d31ae9d1 00000041 c18e56c4 c192df90 
       c192c000 c18ef090 c192dfbc c0126bb5 00000000 c192df70 00000000 c18ef098 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kacpid        S C04140A0     0    18      9           110       (L-TLB)
c193ff3c 00000046 c18e5060 c04140a0 0000001c 00000000 c193e000 00000082 
       c193ff3c 00000082 f76ee530 00003881 66677ead 00000044 c18e51b4 c193ff90 
       c193e000 c18f9b90 c193ffbc c0126bb5 00000000 c193ff70 00000000 c18f9b98 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kblockd/0     S C04140A0     0   110      9           146    18 (L-TLB)
c1af9f3c 00000046 c196ba40 c04140a0 c1bda0c0 00000000 c1af8000 00000082 
       c1af9f3c 00000082 c18f9318 00000959 779407b1 00000044 c196bb94 c1af9f90 
       c1af8000 c18f9310 c1af9fbc c0126bb5 00000000 c1af9f70 00000000 c18f9318 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
pdflush       S C0414548     0   146      9           147   110 (L-TLB)
c1b2df74 00000046 c196b530 c0414548 00000041 c1b2df48 c0120371 c1b2df74 
       abab4fe9 00000041 c196b530 000000ad ababb115 00000041 c196b174 c1b2c000 
       c1b2dfa8 c1b2c000 c1b2df8c c013c5ea 00004000 c1b2c000 c1909f60 00000000 
Call Trace:
 [<c013c5ea>] __pdflush+0x9a/0x1f0
 [<c013c768>] pdflush+0x28/0x30
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
pdflush       S C04140A0     0   147      9           149   146 (L-TLB)
c1b2bf74 00000046 c196b530 c04140a0 00000000 00000000 00000000 00000000 
       00000005 00000041 c1b08a80 000025a2 07c466b5 00000044 c196b684 c1b2a000 
       c1b2bfa8 c1b2a000 c1b2bf8c c013c5ea 00000000 c1b2a000 c1909f60 00000000 
Call Trace:
 [<c013c5ea>] __pdflush+0x9a/0x1f0
 [<c013c768>] pdflush+0x28/0x30
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
aio/0         S C0414548     0   149      9           849   147 (L-TLB)
c1b81f3c 00000046 c1bd7020 c0414548 00000041 c1b81f10 c0120371 c1b81f3c 
       abab5085 00000041 c1bd7020 0000009d ababa49f 00000041 c1b086c4 c1b81f90 
       c1b80000 c1b4ff10 c1b81fbc c0126bb5 00004000 c1b81f70 00000000 00000082 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kswapd0       D C04140A0     0   148      1           739     9 (L-TLB)
c1b2fe84 00000046 c1b08a80 c04140a0 00000000 c1b2feb8 c1b2e000 00000000 
       c1b2fe98 c1b2fe84 00000246 000002ca 77cf22d4 00000044 c1b08bd4 00141397 
       c1b2fe98 c037c028 c1b2fec0 c02dae9e c1b2fe98 00141397 00000004 c0455ba0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c02dae11>] io_schedule_timeout+0x11/0x20
 [<c02489ae>] blk_congestion_wait+0x6e/0x90
 [<c0141c1c>] balance_pgdat+0x23c/0x390
 [<c0141e4d>] kswapd+0xdd/0x100
 [<c0101325>] kernel_thread_helper+0x5/0x10
kseriod       S C0414548     0   739      1           981   148 (L-TLB)
c1b83f8c 00000046 f70aea40 c0414548 00000041 c1b83f60 c0120371 c1b83f8c 
       abac0641 00000041 f70aea40 000000f6 abae028b 00000041 c1b081b4 ffffe000 
       c1b83fc0 c1b82000 c1b83fec c023da85 00004000 c18e5a80 c1b82000 00000000 
Call Trace:
 [<c023da85>] serio_thread+0x105/0x130
 [<c0101325>] kernel_thread_helper+0x5/0x10
reiserfs/0    S C04140A0     0   849      9          4473   149 (L-TLB)
f7ec9f3c 00000046 c1bd7020 c04140a0 c01355d2 00000000 f7ec8000 00000082 
       f7ec9f3c 00000082 c196b530 000011bc 07c313ff 00000044 c1bd7174 f7ec9f90 
       f7ec8000 f7ea5e10 f7ec9fbc c0126bb5 00000000 f7ec9f70 00000000 f7ea5e18 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
devfsd        S C04140A0     0   981      1          1278   739 (NOTLB)
f7657ed8 00000086 f761ca80 c04140a0 00000042 00000000 f7656000 00000286 
       f7657ed8 00000286 c046bd70 00001a06 6a2f64b8 00000042 f761cbd4 c046bd70 
       c046bd40 f7656000 f7657f64 c01bd704 00000000 f1cbf254 00000005 c046bd68 
Call Trace:
 [<c01bd704>] devfsd_read+0xd4/0x3f0
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
khubd         S C0414548     0  1278      1          2646   981 (L-TLB)
f7051f8c 00000046 c1bd7530 c0414548 00000041 f7051f60 c0120371 f7051f8c 
       abac0a78 00000041 c1bd7530 000000f4 abae0c1a 00000041 f70aeb94 ffffe000 
       f7051fc0 f7050000 f7051fec f89f8ea5 00004000 f7607020 f7050000 00000000 
Call Trace:
 [<f89f8ea5>] packet_sklist_lock+0x385785a5/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
khpsbpkt      S C0414548     0  2646      1          2699  1278 (L-TLB)
f774df84 00000046 f7072a40 c0414548 00000041 f70aea40 c1bd7530 f70aea40 
       abac0f1a 00000041 f7072a40 000000d5 abae146c 00000041 c1bd7684 f8c3e038 
       00000246 f774c000 f774dfc8 c02da387 f774c000 f8c3e040 c1bd7530 00000000 
Call Trace:
 [<c02da387>] __down_interruptible+0xa7/0x12c
 [<c02da426>] __down_failed_interruptible+0xa/0x10
 [<f8bffbb5>] packet_sklist_lock+0x3877f2b5/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
knodemgrd_0   S C04140A0     0  2699      1          2909  2646 (L-TLB)
f7053f68 00000046 f705a060 c04140a0 ffffffff f58ef530 f705a060 f58ef530 
       f705a060 c190eb80 f1c93a40 00000610 ac8377cc 00000041 f705a1b4 f556a5b0 
       00000246 f7052000 f7053fac c02da387 f7052000 f556a5b8 f705a060 00000000 
Call Trace:
 [<c02da387>] __down_interruptible+0xa7/0x12c
 [<c02da426>] __down_failed_interruptible+0xa/0x10
 [<f8c06ad0>] packet_sklist_lock+0x387861d0/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
pccardd       S C04140A0     0  2909      1          3047  2699 (L-TLB)
f7757f84 00000046 f7072a40 c04140a0 00000000 f7757f58 c0120371 f7757f84 
       00000202 00757f6c f1c93a40 000000a5 abae1adf 00000041 f7072b94 f70a7030 
       00000000 f7756000 f7757fec f8c630d3 00004000 f70a7034 00000000 f70a716c 
Call Trace:
 [<f8c630d3>] packet_sklist_lock+0x387e27d3/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
portmap       S C0414548     0  3047      1          3130  2909 (NOTLB)
f7009f08 00000082 f7072530 c0414548 00000041 f73ac8d0 f76cf100 f7009f0c 
       ac0be85e 00000041 f7072530 0000057a ac0c8aad 00000041 f761c6c4 00000000 
       7fffffff f7009f64 f7009f44 c02daeed c02808f9 f76cf100 c18f8040 f7009fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
syslogd       D C04140A0     0  3130      1          3133  3047 (NOTLB)
f7761c14 00000086 f7072530 c04140a0 c0199c71 f5554bfc 00000000 f7072530 
       c1bdf738 f7761c00 c02479a8 0000178e 750aeab1 00000044 f7072684 f7761c80 
       00000000 f7761c88 f7761c1c c02dadee f7761c2c c0156370 c1bdf7f4 00000000 
Call Trace:
 [<c02dadee>] io_schedule+0xe/0x20
 [<c0156370>] sync_buffer+0x30/0x50
 [<c02daff6>] __wait_on_bit+0x66/0x70
 [<c02db07f>] out_of_line_wait_on_bit+0x7f/0x90
 [<c0156428>] __wait_on_buffer+0x38/0x40
 [<c019f433>] reiserfs_prepare_file_region_for_write+0x573/0x9e0
 [<c019fd9e>] reiserfs_file_write+0x4fe/0x7e0
 [<c01555f6>] do_readv_writev+0x186/0x260
 [<c0155785>] vfs_writev+0x55/0x60
 [<c0155887>] sys_writev+0x47/0xb0
 [<c010309f>] syscall_call+0x7/0xb
klogd         S C04140A0     0  3133      1          3149  3130 (NOTLB)
f77d9d4c 00000086 f76eea40 c04140a0 00000044 00000044 f77d9d3c c0112622 
       6f0e8c53 00000044 f2e8b530 000004fd 6f10b09a 00000044 f76eeb94 f7691dc0 
       7fffffff 00000001 f77d9d88 c02daeed 00000086 00000000 c18f84d8 00000001 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<f88262e7>] packet_sklist_lock+0x383a59e7/0x4
 [<f8826e95>] packet_sklist_lock+0x383a6595/0x4
 [<c02803d1>] sock_aio_write+0xf1/0x120
 [<c0155073>] do_sync_write+0xa3/0xd0
 [<c01551d7>] vfs_write+0x137/0x170
 [<c01552db>] sys_write+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
slmodemd      S C04140A0     0  3149      1          3161  3133 (NOTLB)
f522deac 00000086 f708d060 c04140a0 f766ed40 00000000 f522c000 00000000 
       f522dec0 f522deac 00000246 0000063b 68dfbbbf 00000044 f708d1b4 0014141b 
       f522dec0 00000006 f522dee8 c02dae9e f522dec0 0014141b c0168756 f72b1ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
gdm           S C0414548     0  3161      1  3165    3307  3149 (NOTLB)
f7765f08 00000086 f77b6a80 c0414548 00000041 f1cae000 f776edc0 f7765fa0 
       ac0cc7d6 00000041 f77b6a80 0000095a ac0f7477 00000041 f767bbd4 00000000 
       7fffffff f7765f64 f7765f44 c02daeed c1bf58c0 f7765fa0 00000145 f73ac8b8 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gdm           S C0414548     0  3165   3161  3278               (NOTLB)
f77efeac 00000082 f761c060 c0414548 00000041 00000001 00000000 f77b6a80 
       ac0cceb3 00000041 f761c060 00000259 ac0f899f 00000041 f77b6bd4 00000000 
       7fffffff 0000000a f77efee8 c02daeed f77efec8 c0168756 f5866d00 f5dc9c1c 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
X             S C04140A0     0  3278   3165          3891       (NOTLB)
f7603eac 00000082 f761c060 c04140a0 00000010 c0339e8c 00000000 00000000 
       f7603ec0 f7603eac 00000246 00000561 77edbce2 00000044 f761c1b4 00141442 
       f7603ec0 00000020 f7603ee8 c02dae9e f7603ec0 00141442 f8827e7b c0455f88 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
spamd         S C0414548     0  3307      1  3469    3383  3161 (NOTLB)
f77d7fb4 00000082 f708da80 c0414548 00000041 f77d7f88 c0155f88 f77d7fa4 
       ac0d0f65 00000041 f708da80 000000fb ac105e46 00000041 f705abd4 08c14160 
       0814c008 08abc63c f77d7fbc c01237e7 f77d6000 c010309f 08c14160 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
acpid         S C04140A0     0  3383      1          3451  3307 (NOTLB)
f7c39f08 00000086 f708da80 c04140a0 00000246 f1c94000 f76dfd80 f7c39fa0 
       f7c39ef4 c0168756 f1aa9570 00004246 da9c0545 00000041 f708dbd4 00000000 
       7fffffff f7c39f64 f7c39f44 c02daeed c02808f9 f76dfd80 f5911200 f7c39fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
battery-daemo S C04140A0     0  3451      1          3465  3383 (NOTLB)
f509ff48 00000082 f77b6060 c04140a0 f509ff2c c016ffb9 f5f6ab18 00000000 
       f509ff5c f509ff48 00000246 00007b46 d6f5de4a 00000043 f77b61b4 001422ec 
       f509ff5c 000f41a7 f509ff84 c02dae9e f509ff5c 001422ec 00000000 f5f71ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
cpufreqd      S C04140A0     0  3465      1          3475  3451 (NOTLB)
f773bf48 00000086 f76ee530 c04140a0 f52fc4ec 00000000 f52fc4ec 00000000 
       f773bf5c f773bf48 00000246 00023952 667b828f 00000044 f76ee684 001417c2 
       f773bf5c 000f41a7 f773bf84 c02dae9e f773bf5c 001417c2 00000000 f543ff5c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
spamd         S C0414548     0  3469   3307                     (NOTLB)
f50a1df8 00000082 f7072020 c0414548 00000041 c0139e91 c0339d68 c1766a20 
       ac0ed5ae 00000041 f7072020 00000475 ac165084 00000041 f77b66c4 f77b6570 
       7fffffff f50a0000 f50a1e34 c02daeed 00000000 00000246 f50a1e38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
cupsd         S C04140A0     0  3475      1          3487  3465 (NOTLB)
f50b5eac 00000086 f7072020 c04140a0 f27af000 f76cf340 f50b5f44 00000000 
       f50b5ec0 f50b5eac 00000246 0000070e fd378669 00000043 f7072174 00147e38 
       f50b5ec0 00000004 f50b5ee8 c02dae9e f50b5ec0 00147e38 f5866040 c1bda1e4 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
dbus-daemon-1 S C0414548     0  3487      1          3522  3475 (NOTLB)
f6b07f08 00000082 c1bd7a40 c0414548 00000041 f1caa000 f76cfc40 f6b07fa0 
       ac0ef114 00000041 c1bd7a40 000005e3 ac16a515 00000041 f70ae174 00000000 
       7fffffff f6b07f64 f6b07f44 c02daeed c02808f9 f76cfc40 f5f829c0 f6b07fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3522      1  3523    3527  3487 (NOTLB)
f5f73f10 00000086 f762aa40 c0414548 00000041 f5f72000 f5f73fc4 00000000 
       ac2f2855 00000041 f762aa40 000001a1 ac832b40 00000041 f5f47b94 fffffe00 
       f5f72000 f5f47ae0 f5f73f88 c011a0d8 ffffffff 00000004 f58ef530 f5f73f48 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3523   3522          3578       (NOTLB)
f5f5ddf8 00000086 f76ee020 c0414548 00000041 c1754320 00000000 00000202 
       ac2f33d5 00000041 f76ee020 00000348 ac834c16 00000041 f762ab94 f762aa40 
       7fffffff f5f5c000 f5f5de34 c02daeed 00000000 00000246 f5f5de38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
famd          S C04140A0     0  3527      1          3532  3522 (NOTLB)
f5f71eac 00000082 c1bd7a40 c04140a0 f766e8c0 f5f71f44 00000246 00000000 
       f5f71ec0 f5f71eac 00000246 00000b62 411b1e3f 00000044 c1bd7b94 00142229 
       f5f71ec0 0000001d f5f71ee8 c02dae9e f5f71ec0 00142229 f8827e7b c0455ff8 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
inetd         S C0414548     0  3532      1          3580  3527 (NOTLB)
f556feac 00000086 f762a020 c0414548 00000041 f70dd4c0 00000246 f1ef0000 
       ac0f0588 00000041 f762a020 0000030d ac16e41e 00000041 f705a6c4 00000000 
       7fffffff 00000007 f556fee8 c02daeed f70dd4c0 f5f1fc40 f556ff44 00000202 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3578   3522          3615  3523 (NOTLB)
f5f6fdf8 00000082 f58ef530 c0414548 00000041 c17537a0 00000000 00000202 
       ac2f399c 00000041 f58ef530 00000191 ac835bc6 00000041 f76ee174 f76ee020 
       7fffffff f5f6e000 f5f6fe34 c02daeed 00000000 00000246 f5f6fe38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
cardmgr       S C0414548     0  3580      1          3674  3532 (NOTLB)
f5f5beac 00000086 f58d2a80 c0414548 00000041 00000000 00000000 00000001 
       ac0f0c53 00000041 f58d2a80 00000221 ac16f74f 00000041 f762a174 00000000 
       7fffffff 00000004 f5f5bee8 c02daeed f70dcd80 f5f5bf44 f5f5bed0 c0168756 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3615   3522                3578 (NOTLB)
f5d23df8 00000082 f705a060 c0414548 00000041 c0139e91 c0339d68 c174d8e0 
       abeb63d3 00000041 f705a060 00000197 ac836bac 00000041 f58ef684 f58ef530 
       7fffffff f5d22000 f5d23e34 c02daeed 00000000 00000246 f5d23e38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
master        S C0414548     0  3674      1  3678    3684  3580 (NOTLB)
f5d0beac 00000082 f761c060 c0414548 00000041 f731c4c0 00000002 00000000 
       ac2b42ff 00000041 f761c060 00000d72 ac4f4212 00000041 f58d2bd4 00143f11 
       f5d0bec0 00000056 f5d0bee8 c02dae9e f5d0bec0 00143f11 f8827e7b c04560e0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
pickup        S C0414548     0  3678   3674          3679       (NOTLB)
f5895eac 00000082 f5f47020 c0414548 00000041 c0339e8c 00000000 00000000 
       ac0f32ec 00000041 f5f47020 0000023a ac1774a6 00000041 f5f47684 0014db4e 
       f5895ec0 00000007 f5895ee8 c02dae9e f5895ec0 0014db4e f5866580 c047aee0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
qmgr          S C0414548     0  3679   3674                3678 (NOTLB)
f5897eac 00000086 f58d2060 c0414548 00000041 c0339e8c 00000000 00000000 
       ac0f3a2c 00000041 f58d2060 0000027e ac178b1c 00000041 f5f47174 001af5ce 
       f5897ec0 00000007 f5897ee8 c02dae9e f5897ec0 001af5ce f58664c0 c0456240 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
sshd          S C0414548     0  3684      1          3702  3674 (NOTLB)
f5d1feac 00000086 f58ef020 c0414548 00000041 f5d1ff44 00000246 f1a95000 
       ac0f3f8c 00000041 f58ef020 000001d1 ac179b77 00000041 f58d21b4 00000000 
       7fffffff 00000004 f5d1fee8 c02daeed f5d1febc c0120371 f5d1fee8 00000202 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
ssh-guard     S C04140D0     0  3702      1  3777    3705  3684 (NOTLB)
f5419ea4 00000082 f761c060 c04140d0 00000042 f76c2700 f5419ebc c02da712 
       7568799d 00000042 f761c060 00001755 756ce22e 00000042 f58ef174 f5415994 
       f5419ecc f5419ec0 f5419ef8 c01617fe 00000000 f58ef020 c012b190 f5419ed8 
Call Trace:
 [<c01617fe>] pipe_wait+0x6e/0x90
 [<c0161a17>] pipe_readv+0x1c7/0x300
 [<c0161b84>] pipe_read+0x34/0x40
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
uml_switch    S C04140A0     0  3705      1          3763  3702 (NOTLB)
f5d21f08 00000086 f58efa40 c04140a0 00000246 f1a94000 f52fb540 f5d21fa0 
       f5d21ef4 c0168756 f733a7c0 00000575 4d5247fd 00000044 f58efb94 00000000 
       7fffffff f5d21f64 f5d21f44 c02daeed c02808f9 f52fb540 f73330c0 f5d21fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
S20xprint     S C0414548     0  3763      1  3764    3776  3705 (NOTLB)
f5461f10 00000082 f5452530 c0414548 00000041 f5460000 f5461fc4 00000000 
       ac0f525b 00000041 f5452530 0000017f ac17d596 00000041 f5407174 fffffe00 
       f5460000 f54070c0 f5461f88 c011a0d8 ffffffff 00000004 f5452a40 c04140a0 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
S20xprint     S C0414548     0  3764   3763  3765    3767       (NOTLB)
f548bf10 00000082 f5452020 c0414548 00000041 f548a000 f548bfc4 00000000 
       ac0f558a 00000041 f5452020 000000ff ac17de8d 00000041 f5452684 fffffe00 
       f548a000 f54525d0 f548bf88 c011a0d8 ffffffff 00000004 f5452020 bfffe1b4 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
Xprt          S C0414548     0  3765   3764                     (NOTLB)
f548deac 00000082 f5452a40 c0414548 00000041 c0339e8c 00000000 000000d0 
       ac0f5b73 00000041 f5452a40 00000205 ac17f0bc 00000041 f5452174 00000000 
       7fffffff 00000001 f548dee8 c02daeed 00000000 f548ded0 f8827e7b f5403880 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
S20xprint     S C0414548     0  3767   3763                3764 (NOTLB)
f5489ea4 00000082 f541f060 c0414548 00000041 c190e940 f5489ebc c02da712 
       ac0f6010 00000041 f541f060 00000188 ac17fe8b 00000041 f5452b94 f589127c 
       f5489ecc f5489ec0 f5489ef8 c01617fe 00000000 f5452a40 c012b190 f5489ed8 
Call Trace:
 [<c01617fe>] pipe_wait+0x6e/0x90
 [<c0161a17>] pipe_readv+0x1c7/0x300
 [<c0161b84>] pipe_read+0x34/0x40
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
rpc.statd     S C0414548     0  3776      1          3780  3763 (NOTLB)
f5487eac 00000082 f52fd060 c0414548 00000041 f52fb3c0 00000246 f1a92000 
       ac0f6843 00000041 f52fd060 000002c9 ac18179c 00000041 f541f1b4 00000000 
       7fffffff 00000007 f5487ee8 c02daeed f52fb3c0 f7341c40 f5487f44 00000202 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
tail          S C04140A0     0  3777   3702                     (NOTLB)
f543ff48 00000086 f52fd060 c04140a0 00000000 00000000 00026cdc 00000000 
       f543ff5c f543ff48 00000246 000006c4 77474790 00000044 f52fd1b4 00141713 
       f543ff5c 000f41a7 f543ff84 c02dae9e f543ff5c 00141713 f543ffac c0455fa0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
atd           S C0414548     0  3780      1          3783  3776 (NOTLB)
f5d0df50 00000086 f541f570 c0414548 00000041 00000000 f5d0df5c 00000000 
       ac0f7caa 00000041 f541f570 00000121 ac1857b7 00000041 f58d26c4 003370de 
       f5d0df64 bffffbbc f5d0df8c c02dae9e f5d0df64 003370de 00000000 c0456300 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c02daf3a>] nanosleep_restart+0x4a/0xa0
 [<c0122796>] sys_restart_syscall+0x16/0x20
 [<c010309f>] syscall_call+0x7/0xb
cron          S C0414548     0  3783      1          3812  3780 (NOTLB)
f5485f50 00000086 f762a530 c0414548 00000041 00000000 f5485f5c 00000000 
       ac0f7ffe 00000041 f762a530 000000ea ac185ff5 00000041 f541f6c4 00146e7e 
       f5485f64 bffffc3c f5485f8c c02dae9e f5485f64 00146e7e 00000000 f707265c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c02daf3a>] nanosleep_restart+0x4a/0xa0
 [<c0122796>] sys_restart_syscall+0x16/0x20
 [<c010309f>] syscall_call+0x7/0xb
bash          S C04140A0     0  3812      1  4568    3813  3783 (NOTLB)
f769ff10 00000086 f762a530 c04140a0 f767cdc0 f767cdec f7698b74 f769ffbc 
       c0111220 f767cdc0 f7698b74 00001e14 3efacdb6 00000042 f762a684 fffffe00 
       f769e000 f762a5d0 f769ff88 c011a0d8 ffffffff 00000006 f1e94020 00000002 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
bash          S C04140A0     0  3813      1          3814  3812 (NOTLB)
f76b5e70 00000082 f767b570 c04140a0 c01e4173 0000000b 0000000d 0000000e 
       00005b0f 00000286 f54db000 00003e68 7e38ee04 00000043 f767b6c4 f54db000 
       7fffffff f766e2c0 f76b5eac c02daeed 0000000b 0000000d 0000000e 00005b0f 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3814      1          3815  3813 (NOTLB)
f5e1fe70 00000086 f52fda80 c0414548 00000041 0000481e 00000000 00000000 
       ac0f9102 00000041 f52fda80 0000019e ac1893e7 00000041 f54f6bd4 f5e5d000 
       7fffffff f7694680 f5e1feac c02daeed c02da712 f767b570 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3815      1          3816  3814 (NOTLB)
f5441e70 00000082 f54fa530 c0414548 00000041 0000481e 00000000 00000000 
       ac0f96d2 00000041 f54fa530 000001cf ac18a431 00000041 f52fdbd4 f5e85000 
       7fffffff f769a4c0 f5441eac c02daeed c02da712 f54f6a80 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3816      1          3817  3815 (NOTLB)
f5e97e70 00000082 f54fa020 c0414548 00000041 0000481e 00000000 00000000 
       ac0f9b15 00000041 f54fa020 00000166 ac18b0cf 00000041 f54fa684 f5e56000 
       7fffffff f766c400 f5e97eac c02daeed c02da712 f52fda80 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3817      1          3944  3816 (NOTLB)
f5e99e70 00000086 f708d570 c0414548 00000041 0000481e 00000000 00000000 
       ac0fa0eb 00000041 f708d570 000001fc ac18c2b3 00000041 f54fa174 f5e9a000 
       7fffffff f766c580 f5e99eac c02daeed c02da712 f54fa530 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
gnome-session S C04140D0     0  3891   3165  3946          3278 (NOTLB)
f50a3f08 00000086 f671f570 c04140d0 00000041 f1a91000 f5645880 f50a3fa0 
       ea95e8ab 00000041 f671f570 00000ad4 ea99cba1 00000041 f708d6c4 00000000 
       7fffffff f50a3f64 f50a3f44 c02daeed c02808f9 f5645880 f6a9a540 f50a3fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
ssh-agent     S C0414548     0  3944      1          3949  3817 (NOTLB)
f6a21eac 00000082 f70ae530 c0414548 00000041 c0339e8c 00000000 000000d0 
       ac0fe936 00000041 f70ae530 000001f8 ac19b0a5 00000041 f5407684 00000000 
       7fffffff 00000004 f6a21ee8 c02daeed 00000003 f6a21ed0 f8827e7b f7774e40 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
ssh-add-all   X C04140D0     0  3946   3891          3950       (L-TLB)
f6a0bf70 00000046 f761c060 c04140d0 00000041 f54f6060 00000011 c18cb800 
       10d5100a 00000041 f761c060 0000017c 10df3faf 00000041 f54f61b4 00000001 
       f54f6060 00000000 f6a0bf9c c0118fe3 f54f6060 c18e7ae0 00000008 f7774780 
Call Trace:
 [<c0118fe3>] do_exit+0x1f3/0x3b0
 [<c0119214>] do_group_exit+0x34/0xa0
 [<c0119295>] sys_exit_group+0x15/0x20
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140A0     0  3949      1  3967    3992  3944 (NOTLB)
f6a43eac 00000082 f70ae530 c04140a0 f5344000 00000000 f6a42000 00000000 
       f6a43ec0 f6a43eac 00000246 000000c7 6bd9046e 00000044 f70ae684 00141600 
       f6a43ec0 00000008 f6a43ee8 c02dae9e f6a43ec0 00141600 f534400c f20dff1c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
Xsession      S C0414548     0  3950   3891  3993          3946 (NOTLB)
f6a0df10 00000082 f541fa80 c0414548 00000041 f6a0c000 f6a0dfc4 00000000 
       ac0ffbb3 00000041 f541fa80 00000179 ac19eb74 00000041 f54f66c4 fffffe00 
       f6a0c000 f54f6610 f6a0df88 c011a0d8 ffffffff 00000004 f6a4ba40 00000000 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  3967   3949                     (NOTLB)
f6a57e70 00000082 f7267530 c0414548 00000041 00000b15 321a3def 00000037 
       ac10011a 00000041 f7267530 0000017e ac19f8e4 00000041 f541fbd4 f7ec5000 
       7fffffff f5e8b0c0 f6a57eac c02daeed c02da712 f54f6570 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
gconfd-2      S C04140A0     0  3992      1          4043  3949 (NOTLB)
f72b3f08 00000086 f7267530 c04140a0 00000246 f1a8e000 f2107140 00000000 
       f72b3f1c f72b3f08 00000246 000059a2 728a5f9b 00000042 f7267684 00142d94 
       f72b3f1c f72b3f64 f72b3f44 c02dae9e f72b3f1c 00142d94 f26500c0 c0456050 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140D0     0  3993   3950  4038    3999       (NOTLB)
f6a55eac 00000082 f6a4b530 c04140d0 00000044 00000000 f6a54000 00000000 
       6bd8bb18 00000044 f6a4b530 0000008e 6bd8f7fb 00000044 f52fd6c4 00141600 
       f6a55ec0 00000005 f6a55ee8 c02dae9e f6a55ec0 00141600 f534300c f6a7fec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140D0     0  3999   3950  4036    4001  3993 (NOTLB)
f6a7feac 00000082 f70ae530 c04140d0 00000044 00000000 f6a7e000 00000000 
       6bd6daf5 00000044 f70ae530 00000077 6bd8fca6 00000044 f6a4b684 00141600 
       f6a7fec0 00000005 f6a7fee8 c02dae9e f6a7fec0 00141600 f6a3100c f6a43ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140A0     0  4001   3950  4040    4002  3999 (NOTLB)
f72b1eac 00000082 f7267a40 c04140a0 f5347000 00000000 f72b0000 00000000 
       f72b1ec0 f72b1eac 00000246 00000b22 69002d76 00000044 f7267b94 00141431 
       f72b1ec0 00000005 f72b1ee8 c02dae9e f72b1ec0 00141431 f534700c f6a83ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
beep-media-pl S C04140A0     0  4002   3950          4011  4001 (NOTLB)
f72aff08 00000082 f6a53060 c04140a0 00000246 f3d9b000 f531ad00 00000000 
       f72aff1c f72aff08 00000246 0000094f 77deab64 00000044 f6a531b4 0014133e 
       f72aff1c f72aff64 f72aff44 c02dae9e f72aff1c 0014133e f6a9a9c0 c04558d8 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
beep-media-pl S C04140A0     0  4012   3950          4044  4011 (NOTLB)
f6a59eac 00000082 f54faa40 c04140a0 00000010 c0339e8c 00000000 00000000 
       f6a59ec0 f6a59eac 00000246 000001ca 77830e27 00000044 f54fab94 00141391 
       f6a59ec0 00000008 f6a59ee8 c02dae9e f6a59ec0 00141391 f8827e7b c0455b70 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
beep-media-pl S C04140A0     0  4044   3950                4012 (NOTLB)
f6a85f48 00000082 f6a4ba40 c04140a0 c0258d26 c04742b0 f1882424 00000000 
       f6a85f5c f6a85f48 00000246 00003568 75141acc 00000044 f6a4bb94 001414fa 
       f6a85f5c 1ddca6a7 f6a85f84 c02dae9e f6a85f5c 001414fa 00000000 f7603ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140A0     0  4011   3950  4013    4012  4002 (NOTLB)
f6a83eac 00000082 f6a38060 c04140a0 f534b000 00000000 f6a82000 00000000 
       f6a83ec0 f6a83eac 00000246 000008fc 6901ebab 00000044 f6a381b4 00141432 
       f6a83ec0 00000005 f6a83ee8 c02dae9e f6a83ec0 00141432 f534b00c f6a85f5c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4013   4011                     (NOTLB)
f6a6be70 00000082 f6a53a80 c0414548 00000041 0000001a ff12a44a 00000036 
       ac115d5e 00000041 f6a53a80 000001b3 ac1e7cc8 00000041 f6a38bd4 f534c000 
       7fffffff f536b8c0 f6a6beac c02daeed c02da712 f6a38060 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4036   3999  4037               (NOTLB)
f563bf94 00000082 f5608060 c0414548 00000041 00010000 00000000 00000000 
       ac115fde 00000041 f5608060 000000be ac1e837d 00000041 f6a53bd4 f563a000 
       00000000 080c9a40 f563bfbc c010220d f563bfb0 bffff270 00000008 00010000 
Call Trace:
 [<c010220d>] sys_rt_sigsuspend+0xad/0xe0
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140A0     0  4037   4036                     (NOTLB)
f5639fb4 00000086 f5608060 c04140a0 0000000f 00000012 00000000 f5639fbc 
       c011f9db 00000000 f5608a80 00000a30 2e1649bd 00000044 f56081b4 00000000 
       00000012 00000000 f5639fbc c01237e7 f5638000 c010309f 00000000 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4038   3993  4039               (NOTLB)
f6a99f94 00000086 f5608a80 c0414548 00000041 00010000 00000000 00000000 
       ac116650 00000041 f5608a80 000000b6 ac1e943d 00000041 f56086c4 f6a98000 
       00000000 080c9a40 f6a99fbc c010220d f6a99fb0 bffff270 00000008 00010000 
Call Trace:
 [<c010220d>] sys_rt_sigsuspend+0xad/0xe0
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140A0     0  4039   4038                     (NOTLB)
f5637fb4 00000082 f5608a80 c04140a0 0000000f 00000012 00000000 f5637fbc 
       c011f9db 00000000 f6a4b020 000003a3 2e166a7e 00000044 f5608bd4 00000000 
       00000012 00000000 f5637fbc c01237e7 f5636000 c010309f 00000000 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4040   4001  4041               (NOTLB)
f6a81f94 00000082 f6a4b020 c0414548 00000041 00010000 00000000 00000000 
       ac116b9a 00000041 f6a4b020 000000ab ac1ea28d 00000041 f7267174 f6a80000 
       00000000 080c9a40 f6a81fbc c010220d f6a81fb0 bffff270 00000008 00010000 
Call Trace:
 [<c010220d>] sys_rt_sigsuspend+0xad/0xe0
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140D0     0  4041   4040                     (NOTLB)
f5635fb4 00000082 f76eea40 c04140d0 00000044 00000012 00000000 f5635fbc 
       2e0e0699 00000044 f76eea40 000006d4 2e16a7f7 00000044 f6a4b174 00000000 
       00000012 00000000 f5635fbc c01237e7 f5634000 c010309f 00000000 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
gnome-keyring S C0414548     0  4043      1          4046  3992 (NOTLB)
f6a87f08 00000082 f6814530 c0414548 00000041 f1a9f000 f5a27d80 f6a87fa0 
       ac118597 00000041 f6814530 00000838 ac1ef68f 00000041 f6a536c4 00000000 
       7fffffff f6a87f64 f6a87f44 c02daeed c02808f9 f5a27d80 f6a9a3c0 f6a87fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
bonobo-activa S C0414548     0  4046      1          4048  4043 (NOTLB)
f684ff08 00000086 f6814020 c0414548 00000041 f1a9e000 f21b5f00 f684ffa0 
       ac11bfa5 00000041 f6814020 00001589 ac1fb863 00000041 f6814684 00000000 
       7fffffff f684ff64 f684ff44 c02daeed c02808f9 f21b5f00 f21b2940 f684ffa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-smproxy S C0414548     0  4048      1          4050  4046 (NOTLB)
f6741eac 00200086 f671f570 c0414548 00000041 c0339e8c 00000000 000000d0 
       ac11cc07 00000041 f671f570 00000454 ac1fdf5f 00000041 f6814174 00000000 
       7fffffff 0000000b f6741ee8 c02daeed 0000000a f6741ed0 f8827e7b f48a0700 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
gnome-setting S C04140D0     0  4050      1          4090  4048 (NOTLB)
f6765f08 00000086 f761c060 c04140d0 00000041 f1a9c000 f688d680 f6765fa0 
       ea9b5259 00000041 f761c060 00000520 ea9bfc36 00000041 f671f6c4 00000000 
       7fffffff f6765f64 f6765f44 c02daeed c02808f9 f688d680 f68ec7c0 f6765fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
xscreensaver  S C04140A0     0  4090      1          4114  4050 (NOTLB)
f6763eac 00000082 f671f060 c04140a0 00000010 c0339e8c 00000000 00000000 
       f6763ec0 f6763eac 00000246 00000300 48c7ed5c 00000044 f671f1b4 00141fa1 
       f6763ec0 00000005 f6763ee8 c02dae9e f6763ec0 00141fa1 f56059c0 c0455fe0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
metacity      S C04140D0     0  4114      1          4122  4090 (NOTLB)
f63c7f08 00000086 f6814a40 c04140d0 00000041 f1a9a000 f6df3800 f63c7fa0 
       ea94d077 00000041 f6814a40 0000083a ea95f37d 00000041 f671fbd4 00000000 
       7fffffff f63c7f64 f63c7f44 c02daeed c02808f9 f6df3800 f6ccec40 f63c7fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-panel   S C04140D0     0  4122      1          4124  4114 (NOTLB)
f683df08 00000082 f6a53060 c04140d0 00000041 f1a89000 f21b59c0 f683dfa0 
       ea9b0e0d 00000041 f6a53060 00000b50 ea9b7344 00000041 f6814b94 00000000 
       7fffffff f683df64 f683df44 c02daeed c02808f9 f21b59c0 f21b21c0 f683dfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C04140D0     0  4124      1          4136  4122 (NOTLB)
f4d27f08 00000082 f671f570 c04140d0 00000041 f1a88000 f4a6eac0 f4d27fa0 
       ea9b0ea7 00000041 f671f570 000004ff ea9bce16 00000041 f6cad684 00000000 
       7fffffff f4d27f64 f4d27f44 c02daeed c02808f9 f4a6eac0 f63d1dc0 f4d27fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4136      1          4138  4124 (NOTLB)
f4421f08 00000082 f6cad020 c0414548 00000041 f1a87000 f45b8ec0 f4421fa0 
       ac127bd6 00000041 f6cad020 0000061b ac222219 00000041 f4cf46c4 00000000 
       7fffffff f4421f64 f4421f44 c02daeed c02808f9 f45b8ec0 f46829c0 f4421fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4142      1          4143  4139 (NOTLB)
f6c33e84 00000082 f4cf4060 c0414548 00000041 0000003b f6cad530 f6c33e74 
       ac12842d 00000041 f4cf4060 000002ec ac223c65 00000041 f6cad174 081c4b90 
       7fffffff fffffff5 f6c33ec0 c02daeed f767c280 081c4000 76796a33 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4143      1          4144  4142 (NOTLB)
f4d49e84 00000082 f479ca40 c0414548 00000041 f6cad530 f767c280 f4d49e74 
       ac1287a9 00000041 f479ca40 00000119 ac22464b 00000041 f4cf41b4 081c4e80 
       7fffffff fffffff5 f4d49ec0 c02daeed f767c280 081c4000 76796cc7 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4144      1          4146  4143 (NOTLB)
f4463e84 00000082 f479c530 c0414548 00000041 00000000 f4463f58 f4463e74 
       ac128b11 00000041 f479c530 00000113 ac224ff8 00000041 f479cb94 081c5170 
       7fffffff fffffff5 f4463ec0 c02daeed f767c280 081c5000 76796f49 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4147      1          4149  4146 (NOTLB)
f4147e84 00000082 f6cada40 c0414548 00000041 f6cad530 f767c280 f4147e74 
       ac128eb4 00000041 f6cada40 00000126 ac225a52 00000041 f479c684 08213928 
       7fffffff fffffff5 f4147ec0 c02daeed f767c280 08213000 76797212 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
gnome-vfs-dae S C0414548     0  4138      1          4139  4136 (NOTLB)
f4475f08 00000082 f4cf4a80 c0414548 00000041 f1a86000 f45b88c0 f4475fa0 
       ac12a1df 00000041 f4cf4a80 000006f7 ac229908 00000041 f6cadb94 00000000 
       7fffffff f4475f64 f4475f44 c02daeed c02808f9 f45b88c0 f46823c0 f4475fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-vfs-dae S C0414548     0  4139      1          4142  4138 (NOTLB)
f4d4bf08 00000082 f479c020 c0414548 00000041 f1a85000 f45b8740 f4d4bfa0 
       ac12b2a3 00000041 f479c020 0000060e ac22cf8c 00000041 f4cf4bd4 00000000 
       7fffffff f4d4bf64 f4d4bf44 c02daeed c02808f9 f45b8740 f46820c0 f4d4bfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
mapping-daemo S C04140A0     0  4146      1          4147  4144 (NOTLB)
f4135f08 00000082 f479c020 c04140a0 00000246 f3bc4000 f41e4e40 00000000 
       f4135f1c f4135f08 00000246 00000719 6a9b38f5 00000044 f479c174 001424dd 
       f4135f1c f4135f64 f4135f44 c02dae9e f4135f1c 001424dd f46a5c40 c0456008 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
wnck-applet   S C04140D0     0  4149      1          4151  4147 (NOTLB)
f3e3df08 00000082 f4688060 c04140d0 00000041 f1a83000 f3f75d40 f3e3dfa0 
       ea950aed 00000041 f4688060 0000081e ea969208 00000041 f46886c4 00000000 
       7fffffff f3e3df64 f3e3df44 c02daeed c02808f9 f3f75d40 f3f63800 f3e3dfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gweather-appl S C04140D0     0  4151      1          4152  4149 (NOTLB)
f391ff08 00000086 f342d020 c04140d0 00000041 f1a82000 f39cc480 00000000 
       ea9528e5 00000041 f342d020 000008cc ea96ea03 00000041 f46881b4 002d5308 
       f391ff1c f391ff64 f391ff44 c02dae9e f391ff1c 002d5308 f3a31c40 c0473a00 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gweather-appl S C0414548     0  4152      1          4153  4151 (NOTLB)
f3e2be84 00000086 f342da40 c0414548 00000041 00000000 f6a407ac f3e2be74 
       ac130e57 00000041 f342da40 00000256 ac23fd14 00000041 f4688bd4 0819c320 
       7fffffff fffffff5 f3e2bec0 c02daeed f767c4c0 0819c000 7679a461 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
gweather-appl S C0414548     0  4153      1          4155  4152 (NOTLB)
f3461e84 00000086 f342d020 c0414548 00000041 f4688060 f767c4c0 f3461e74 
       ac1311e3 00000041 f342d020 00000120 ac240737 00000041 f342db94 0819c940 
       7fffffff fffffff5 f3461ec0 c02daeed f767c4c0 0819c000 7679aaa3 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
battstat-appl D C04140A0     0  4155      1          4157  4153 (NOTLB)
f34c5da0 00000082 f342d020 c04140a0 c1bdf738 f34c5d7c c02479a8 c1bdf738 
       f34c4000 f34c5d8c c02479df 0000069f 74056970 00000044 f342d174 f34c5e04 
       f34c5e0c c17e1fc0 f34c5da8 c02dadee f34c5db4 c01354d5 c17d4380 f34c5dd4 
Call Trace:
 [<c02dadee>] io_schedule+0xe/0x20
 [<c01354d5>] sync_page+0x35/0x50
 [<c02db0ed>] __wait_on_bit_lock+0x5d/0x70
 [<c0135cc4>] __lock_page+0x84/0x90
 [<c0136fd7>] filemap_nopage+0x247/0x380
 [<c0145d19>] do_no_page+0xb9/0x350
 [<c0146192>] handle_mm_fault+0xe2/0x190
 [<c0111220>] do_page_fault+0x1d0/0x6a2
 [<c0103247>] error_code+0x2b/0x30
clock-applet  S C04140A0     0  4157      1          4159  4155 (NOTLB)
f3077f08 00000082 f304fa80 c04140a0 00000246 f1a8c000 f314a580 00000000 
       f3077f1c f3077f08 00000246 00000527 7263d0b6 00000044 f304fbd4 001416aa 
       f3077f1c f3077f64 f3077f44 c02dae9e f3077f1c 001416aa f3164940 c0455f98 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
multiload-app S C04140D0     0  4159      1          4161  4157 (NOTLB)
f3399f08 00000086 f6a53060 c04140d0 00000044 f775a000 f6a9c340 00000000 
       74fe3e9e 00000044 f6a53060 000000c0 74fe784b 00000044 f304f6c4 00141366 
       f3399f1c f3399f64 f3399f44 c02dae9e f3399f1c 00141366 f31bc200 c0455a18 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
notification- S C04140D0     0  4161      1          4164  4159 (NOTLB)
f2d6bf08 00000086 f2e8ba40 c04140d0 00000041 f1e06000 f2ddb280 f2d6bfa0 
       ea959d0e 00000041 f2e8ba40 000007d0 ea983de4 00000041 f304f1b4 00000000 
       7fffffff f2d6bf64 f2d6bf44 c02daeed c02808f9 f2ddb280 f2e4c940 f2d6bfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
netloc.py     S C04140D0     0  4164      1          4167  4161 (NOTLB)
f2eadf08 00000086 f304f570 c04140d0 00000044 f1e87000 f2ac86c0 00000000 
       74f4356d 00000044 f304f570 000011a1 74f4356d 00000044 f2e8bb94 00141366 
       f2eadf1c f2eadf64 f2eadf44 c02dae9e f2eadf1c 00141366 f65d9b40 f3399f1c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
wireless-appl D C04140A0     0  4167      1          4169  4164 (NOTLB)
f246bdf0 00000082 f2e8b530 c04140a0 f246bdc4 c0247a1d c1bdf738 f246bde8 
       c014cf67 c1bdf7f4 c17068c0 00000af0 730b5b6e 00000044 f2e8b684 f246be54 
       f246be5c c17e21c8 f246bdf8 c02dadee f246be04 c01354d5 c17068c0 f246be24 
Call Trace:
 [<c02dadee>] io_schedule+0xe/0x20
 [<c01354d5>] sync_page+0x35/0x50
 [<c02db0ed>] __wait_on_bit_lock+0x5d/0x70
 [<c0135cc4>] __lock_page+0x84/0x90
 [<c01459e7>] do_swap_page+0x217/0x2d0
 [<c014616e>] handle_mm_fault+0xbe/0x190
 [<c0111220>] do_page_fault+0x1d0/0x6a2
 [<c0103247>] error_code+0x2b/0x30
mini_commande S C04140D0     0  4169      1          4171  4167 (NOTLB)
f268df08 00000086 f20afa80 c04140d0 00000041 f1e23000 f2780640 f268dfa0 
       ea95eeb6 00000041 f20afa80 00000688 ea9923ad 00000041 f2e8b174 00000000 
       7fffffff f268df64 f268df44 c02daeed c02808f9 f2780640 f2650b40 f268dfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-cpufreq S C04140A0     0  4171      1                4169 (NOTLB)
f20dff08 00000082 f20afa80 c04140a0 00000044 f1e24000 f21b5a80 00000000 
       f20dff1c f20dff08 00000246 00000118 711f279c 00000044 f20afbd4 001416a9 
       f20dff1c f20dff64 f20dff44 c02dae9e f20dff1c 001416a9 f21b2340 f3077f1c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
ipw2200/0     S C04140A0     0  4473      9                 849 (L-TLB)
f71c5f3c 00000046 f1e94a40 c04140a0 00000046 00000000 f71c4000 00000082 
       f71c5f3c 00000082 f1c8b518 0000010b 4dd1dd46 00000044 f1e94b94 f71c5f90 
       f71c4000 f1c8b510 f71c5fbc c0126bb5 00000000 f71c5f70 00000000 f1c8b518 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
top           S C04140A0     0  4568   3812                     (NOTLB)
f1e2beac 00000086 f1e94020 c04140a0 f766c700 00000000 f1e2a000 00000000 
       f1e2bec0 f1e2beac 00000246 000238d2 75fd7910 00000044 f1e94174 00141ecb 
       f1e2bec0 00000001 f1e2bee8 c02dae9e f1e2bec0 00141ecb c1bfb00c c0455fd8 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
SysRq : Show Memory
Mem-info:
DMA per-cpu:
cpu 0 hot: low 2, high 6, batch 1
cpu 0 cold: low 0, high 2, batch 1
Normal per-cpu:
cpu 0 hot: low 32, high 96, batch 16
cpu 0 cold: low 0, high 32, batch 16
HighMem per-cpu:
cpu 0 hot: low 12, high 36, batch 6
cpu 0 cold: low 0, high 12, batch 6

Free pages:      953004kB (71784kB HighMem)
Active:10169 inactive:1521 dirty:12 writeback:0 unstable:0 free:238251 slab:2613 mapped:10289 pagetables:452
DMA free:12516kB min:68kB low:84kB high:100kB active:0kB inactive:0kB present:16384kB pages_scanned:0 all_unreclaimable? yes
protections[]: 0 0 0
Normal free:868704kB min:3756kB low:4692kB high:5632kB active:4256kB inactive:3832kB present:901120kB pages_scanned:0 all_unreclaimable? no
protections[]: 0 0 0
HighMem free:71784kB min:128kB low:160kB high:192kB active:36420kB inactive:2252kB present:114624kB pages_scanned:71 all_unreclaimable? no
protections[]: 0 0 0
DMA: 5*4kB 4*8kB 3*16kB 4*32kB 4*64kB 2*128kB 2*256kB 0*512kB 1*1024kB 1*2048kB 2*4096kB = 12516kB
Normal: 1854*4kB 1023*8kB 559*16kB 356*32kB 216*64kB 94*128kB 42*256kB 17*512kB 5*1024kB 0*2048kB 191*4096kB = 868704kB
HighMem: 1096*4kB 1095*8kB 797*16kB 376*32kB 155*64kB 75*128kB 28*256kB 8*512kB 3*1024kB 0*2048kB 0*4096kB = 71784kB
Swap cache: add 17065, delete 16728, find 245/298, race 0+0
Free swap:       439400kB
258032 pages of RAM
28656 pages of HIGHMEM
3260 reserved pages
30815 pages shared
337 pages swap cached
SysRq : Show Memory
Mem-info:
DMA per-cpu:
cpu 0 hot: low 2, high 6, batch 1
cpu 0 cold: low 0, high 2, batch 1
Normal per-cpu:
cpu 0 hot: low 32, high 96, batch 16
cpu 0 cold: low 0, high 32, batch 16
HighMem per-cpu:
cpu 0 hot: low 12, high 36, batch 6
cpu 0 cold: low 0, high 12, batch 6

Free pages:      953492kB (71952kB HighMem)
Active:10539 inactive:1039 dirty:135 writeback:0 unstable:0 free:238373 slab:2607 mapped:10019 pagetables:452
DMA free:12516kB min:68kB low:84kB high:100kB active:0kB inactive:0kB present:16384kB pages_scanned:0 all_unreclaimable? yes
protections[]: 0 0 0
Normal free:869024kB min:3756kB low:4692kB high:5632kB active:4600kB inactive:3184kB present:901120kB pages_scanned:388 all_unreclaimable? no
protections[]: 0 0 0
HighMem free:71952kB min:128kB low:160kB high:192kB active:37556kB inactive:972kB present:114624kB pages_scanned:589 all_unreclaimable? no
protections[]: 0 0 0
DMA: 5*4kB 4*8kB 3*16kB 4*32kB 4*64kB 2*128kB 2*256kB 0*512kB 1*1024kB 1*2048kB 2*4096kB = 12516kB
Normal: 1870*4kB 1029*8kB 560*16kB 358*32kB 218*64kB 94*128kB 42*256kB 17*512kB 5*1024kB 0*2048kB 191*4096kB = 869024kB
HighMem: 966*4kB 1099*8kB 796*16kB 387*32kB 160*64kB 75*128kB 28*256kB 8*512kB 3*1024kB 0*2048kB 0*4096kB = 71952kB
Swap cache: add 17252, delete 16882, find 246/304, race 0+0
Free swap:       438812kB
258032 pages of RAM
28656 pages of HIGHMEM
3260 reserved pages
30382 pages shared
370 pages swap cached
SysRq : Show State

                                               sibling
  task             PC      pid father child younger older
init          S C04140A0     0     1      0     2               (NOTLB)
c1909eac 00000082 c18dca40 c04140a0 00000000 00000001 00000000 00000000 
       c1909ec0 c1909eac 00000246 000009b5 05a9d4ed 00000044 c18dcb94 00141937 
       c1909ec0 0000000b c1909ee8 c02dae9e c1909ec0 00141937 c1bf5bc0 c0339fe0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
ksoftirqd/0   S C04140A0     0     2      1             3       (L-TLB)
c190bfa4 00000046 c18dc530 c04140a0 c0457000 c190bf80 c011b8b6 00000000 
       00000001 c190bf98 c011b64c 000000f6 686141ca 00000044 c18dc684 00000000 
       c190a000 00000000 c190bfbc c011ba95 c18dc530 00000013 c190a000 c1909f64 
Call Trace:
 [<c011ba95>] ksoftirqd+0xb5/0xd0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
events/0      R running     0     3      1             4     2 (L-TLB)
khelper       S C04140A0     0     4      1             9     3 (L-TLB)
c192bf3c 00000046 c18e5a80 c04140a0 00000292 00000000 c192a000 00000082 
       c192bf3c 00000082 f1e88060 000000d3 d98ba106 00000041 c18e5bd4 c192bf90 
       c192a000 c18cb790 c192bfbc c0126bb5 00000000 c192bf70 00000000 c18cb798 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kthread       S C04140A0     0     9      1    18     148     4 (L-TLB)
c192df3c 00000046 c18e5570 c04140a0 f1cbdddc 00000000 c192c000 00000082 
       c192df3c 00000082 f1e94a40 00000038 d31ae9d1 00000041 c18e56c4 c192df90 
       c192c000 c18ef090 c192dfbc c0126bb5 00000000 c192df70 00000000 c18ef098 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kacpid        S C04140A0     0    18      9           110       (L-TLB)
c193ff3c 00000046 c18e5060 c04140a0 0000001c 00000000 c193e000 00000082 
       c193ff3c 00000082 f76eea40 00003c5b 841476cb 00000044 c18e51b4 c193ff90 
       c193e000 c18f9b90 c193ffbc c0126bb5 00000000 c193ff70 00000000 c18f9b98 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kblockd/0     S C04140A0     0   110      9           146    18 (L-TLB)
c1af9f3c 00000046 c196ba40 c04140a0 c0258ef6 00000000 c1af8000 00000082 
       c1af9f3c 00000082 c18f9318 00000bcb 8e21bf70 00000044 c196bb94 c1af9f90 
       c1af8000 c18f9310 c1af9fbc c0126bb5 00000000 c1af9f70 00000000 c18f9318 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
pdflush       S C0414548     0   146      9           147   110 (L-TLB)
c1b2df74 00000046 c196b530 c0414548 00000041 c1b2df48 c0120371 c1b2df74 
       abab4fe9 00000041 c196b530 000000ad ababb115 00000041 c196b174 c1b2c000 
       c1b2dfa8 c1b2c000 c1b2df8c c013c5ea 00004000 c1b2c000 c1909f60 00000000 
Call Trace:
 [<c013c5ea>] __pdflush+0x9a/0x1f0
 [<c013c768>] pdflush+0x28/0x30
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
pdflush       S C04140A0     0   147      9           149   146 (L-TLB)
c1b2bf74 00000046 c196b530 c04140a0 00000000 00000000 00000000 00000000 
       00000005 00000041 c1b08a80 000025a2 07c466b5 00000044 c196b684 c1b2a000 
       c1b2bfa8 c1b2a000 c1b2bf8c c013c5ea 00000000 c1b2a000 c1909f60 00000000 
Call Trace:
 [<c013c5ea>] __pdflush+0x9a/0x1f0
 [<c013c768>] pdflush+0x28/0x30
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
aio/0         S C0414548     0   149      9           849   147 (L-TLB)
c1b81f3c 00000046 c1bd7020 c0414548 00000041 c1b81f10 c0120371 c1b81f3c 
       abab5085 00000041 c1bd7020 0000009d ababa49f 00000041 c1b086c4 c1b81f90 
       c1b80000 c1b4ff10 c1b81fbc c0126bb5 00004000 c1b81f70 00000000 00000082 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kswapd0       D C04140A0     0   148      1           739     9 (L-TLB)
c1b2fe84 00000046 c1b08a80 c04140a0 00000001 c1b2feb8 c1b2e000 00000000 
       c1b2fe98 c1b2fe84 00000246 00003771 8e2875a1 00000044 c1b08bd4 001416dc 
       c1b2fe98 c037c028 c1b2fec0 c02dae9e c1b2fe98 001416dc 0000001d c0455dc8 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c02dae11>] io_schedule_timeout+0x11/0x20
 [<c02489ae>] blk_congestion_wait+0x6e/0x90
 [<c0141c1c>] balance_pgdat+0x23c/0x390
 [<c0141e4d>] kswapd+0xdd/0x100
 [<c0101325>] kernel_thread_helper+0x5/0x10
kseriod       S C0414548     0   739      1           981   148 (L-TLB)
c1b83f8c 00000046 f70aea40 c0414548 00000041 c1b83f60 c0120371 c1b83f8c 
       abac0641 00000041 f70aea40 000000f6 abae028b 00000041 c1b081b4 ffffe000 
       c1b83fc0 c1b82000 c1b83fec c023da85 00004000 c18e5a80 c1b82000 00000000 
Call Trace:
 [<c023da85>] serio_thread+0x105/0x130
 [<c0101325>] kernel_thread_helper+0x5/0x10
reiserfs/0    S C04140A0     0   849      9          4473   149 (L-TLB)
f7ec9f3c 00000046 c1bd7020 c04140a0 c01355d2 00000000 f7ec8000 00000082 
       f7ec9f3c 00000082 c196b530 000011bc 07c313ff 00000044 c1bd7174 f7ec9f90 
       f7ec8000 f7ea5e10 f7ec9fbc c0126bb5 00000000 f7ec9f70 00000000 f7ea5e18 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
devfsd        S C04140A0     0   981      1          1278   739 (NOTLB)
f7657ed8 00000086 f761ca80 c04140a0 00000042 00000000 f7656000 00000286 
       f7657ed8 00000286 c046bd70 00001a06 6a2f64b8 00000042 f761cbd4 c046bd70 
       c046bd40 f7656000 f7657f64 c01bd704 00000000 f1cbf254 00000005 c046bd68 
Call Trace:
 [<c01bd704>] devfsd_read+0xd4/0x3f0
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
khubd         S C0414548     0  1278      1          2646   981 (L-TLB)
f7051f8c 00000046 c1bd7530 c0414548 00000041 f7051f60 c0120371 f7051f8c 
       abac0a78 00000041 c1bd7530 000000f4 abae0c1a 00000041 f70aeb94 ffffe000 
       f7051fc0 f7050000 f7051fec f89f8ea5 00004000 f7607020 f7050000 00000000 
Call Trace:
 [<f89f8ea5>] packet_sklist_lock+0x385785a5/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
khpsbpkt      S C0414548     0  2646      1          2699  1278 (L-TLB)
f774df84 00000046 f7072a40 c0414548 00000041 f70aea40 c1bd7530 f70aea40 
       abac0f1a 00000041 f7072a40 000000d5 abae146c 00000041 c1bd7684 f8c3e038 
       00000246 f774c000 f774dfc8 c02da387 f774c000 f8c3e040 c1bd7530 00000000 
Call Trace:
 [<c02da387>] __down_interruptible+0xa7/0x12c
 [<c02da426>] __down_failed_interruptible+0xa/0x10
 [<f8bffbb5>] packet_sklist_lock+0x3877f2b5/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
knodemgrd_0   S C04140A0     0  2699      1          2909  2646 (L-TLB)
f7053f68 00000046 f705a060 c04140a0 ffffffff f58ef530 f705a060 f58ef530 
       f705a060 c190eb80 f1c93a40 00000610 ac8377cc 00000041 f705a1b4 f556a5b0 
       00000246 f7052000 f7053fac c02da387 f7052000 f556a5b8 f705a060 00000000 
Call Trace:
 [<c02da387>] __down_interruptible+0xa7/0x12c
 [<c02da426>] __down_failed_interruptible+0xa/0x10
 [<f8c06ad0>] packet_sklist_lock+0x387861d0/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
pccardd       S C04140A0     0  2909      1          3047  2699 (L-TLB)
f7757f84 00000046 f7072a40 c04140a0 00000000 f7757f58 c0120371 f7757f84 
       00000202 00757f6c f1c93a40 000000a5 abae1adf 00000041 f7072b94 f70a7030 
       00000000 f7756000 f7757fec f8c630d3 00004000 f70a7034 00000000 f70a716c 
Call Trace:
 [<f8c630d3>] packet_sklist_lock+0x387e27d3/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
portmap       S C0414548     0  3047      1          3130  2909 (NOTLB)
f7009f08 00000082 f7072530 c0414548 00000041 f73ac8d0 f76cf100 f7009f0c 
       ac0be85e 00000041 f7072530 0000057a ac0c8aad 00000041 f761c6c4 00000000 
       7fffffff f7009f64 f7009f44 c02daeed c02808f9 f76cf100 c18f8040 f7009fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
syslogd       S C04140A0     0  3130      1          3133  3047 (NOTLB)
f7761eac 00000086 f7072530 c04140a0 00000010 c0339e8c 00000000 000000d0 
       000003fe 000000d0 f70dcf00 0000b052 8dccf848 00000044 f7072684 00000000 
       7fffffff 00000001 f7761ee8 c02daeed 00000000 f7761ed0 c0286e6b f70dcf00 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
klogd         R running     0  3133      1          3149  3130 (NOTLB)
slmodemd      S C04140A0     0  3149      1          3161  3133 (NOTLB)
f522deac 00000086 f708d060 c04140a0 f766ed40 00000000 f522c000 00000000 
       f522dec0 f522deac f7072530 00000673 85917438 00000044 f708d1b4 00141803 
       f522dec0 00000006 f522dee8 c02dae9e f522dec0 00141803 c0168756 f72b1ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
gdm           S C0414548     0  3161      1  3165    3307  3149 (NOTLB)
f7765f08 00000086 f77b6a80 c0414548 00000041 f1cae000 f776edc0 f7765fa0 
       ac0cc7d6 00000041 f77b6a80 0000095a ac0f7477 00000041 f767bbd4 00000000 
       7fffffff f7765f64 f7765f44 c02daeed c1bf58c0 f7765fa0 00000145 f73ac8b8 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gdm           S C0414548     0  3165   3161  3278               (NOTLB)
f77efeac 00000082 f761c060 c0414548 00000041 00000001 00000000 f77b6a80 
       ac0cceb3 00000041 f761c060 00000259 ac0f899f 00000041 f77b6bd4 00000000 
       7fffffff 0000000a f77efee8 c02daeed f77efec8 c0168756 f5866d00 f5dc9c1c 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
X             S C04140A0     0  3278   3165          3891       (NOTLB)
f7603eac 00000082 f761c060 c04140a0 00000044 c0339e8c 00000000 00000000 
       f7603ec0 f7603eac 00000246 0000010f 8e972c2b 00000044 f761c1b4 0014182a 
       f7603ec0 00000020 f7603ee8 c02dae9e f7603ec0 0014182a f8827e7b c0455fa8 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
spamd         S C0414548     0  3307      1  3469    3383  3161 (NOTLB)
f77d7fb4 00000082 f708da80 c0414548 00000041 f77d7f88 c0155f88 f77d7fa4 
       ac0d0f65 00000041 f708da80 000000fb ac105e46 00000041 f705abd4 08c14160 
       0814c008 08abc63c f77d7fbc c01237e7 f77d6000 c010309f 08c14160 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
acpid         S C04140A0     0  3383      1          3451  3307 (NOTLB)
f7c39f08 00000086 f708da80 c04140a0 00000246 f1c94000 f76dfd80 f7c39fa0 
       f7c39ef4 c0168756 f1aa9570 00004246 da9c0545 00000041 f708dbd4 00000000 
       7fffffff f7c39f64 f7c39f44 c02daeed c02808f9 f76dfd80 f5911200 f7c39fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
battery-daemo S C04140A0     0  3451      1          3465  3383 (NOTLB)
f509ff48 00000082 f77b6060 c04140a0 f509ff2c c016ffb9 f5f6ab18 00000000 
       f509ff5c f509ff48 00000246 00007b46 d6f5de4a 00000043 f77b61b4 001422ec 
       f509ff5c 000f41a7 f509ff84 c02dae9e f509ff5c 001422ec 00000000 f5f71ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
cpufreqd      S C04140A0     0  3465      1          3475  3451 (NOTLB)
f773bf48 00000086 f76ee530 c04140a0 f52fc4ec 00000000 f52fc4ec 00000000 
       f773bf5c f773bf48 00000246 00023952 667b828f 00000044 f76ee684 001417c2 
       f773bf5c 000f41a7 f773bf84 c02dae9e f773bf5c 001417c2 00000000 f543ff5c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
spamd         S C0414548     0  3469   3307                     (NOTLB)
f50a1df8 00000082 f7072020 c0414548 00000041 c0139e91 c0339d68 c1766a20 
       ac0ed5ae 00000041 f7072020 00000475 ac165084 00000041 f77b66c4 f77b6570 
       7fffffff f50a0000 f50a1e34 c02daeed 00000000 00000246 f50a1e38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
cupsd         S C04140A0     0  3475      1          3487  3465 (NOTLB)
f50b5eac 00000086 f7072020 c04140a0 f27af000 f76cf340 f50b5f44 00000000 
       f50b5ec0 f50b5eac 00000246 0000070e fd378669 00000043 f7072174 00147e38 
       f50b5ec0 00000004 f50b5ee8 c02dae9e f50b5ec0 00147e38 f5866040 c0456170 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
dbus-daemon-1 S C0414548     0  3487      1          3522  3475 (NOTLB)
f6b07f08 00000082 c1bd7a40 c0414548 00000041 f1caa000 f76cfc40 f6b07fa0 
       ac0ef114 00000041 c1bd7a40 000005e3 ac16a515 00000041 f70ae174 00000000 
       7fffffff f6b07f64 f6b07f44 c02daeed c02808f9 f76cfc40 f5f829c0 f6b07fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3522      1  3523    3527  3487 (NOTLB)
f5f73f10 00000086 f762aa40 c0414548 00000041 f5f72000 f5f73fc4 00000000 
       ac2f2855 00000041 f762aa40 000001a1 ac832b40 00000041 f5f47b94 fffffe00 
       f5f72000 f5f47ae0 f5f73f88 c011a0d8 ffffffff 00000004 f58ef530 f5f73f48 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3523   3522          3578       (NOTLB)
f5f5ddf8 00000086 f76ee020 c0414548 00000041 c1754320 00000000 00000202 
       ac2f33d5 00000041 f76ee020 00000348 ac834c16 00000041 f762ab94 f762aa40 
       7fffffff f5f5c000 f5f5de34 c02daeed 00000000 00000246 f5f5de38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
famd          S C04140A0     0  3527      1          3532  3522 (NOTLB)
f5f71eac 00000082 c1bd7a40 c04140a0 f766e8c0 f5f71f44 00000246 00000000 
       f5f71ec0 f5f71eac 00000246 00000b62 411b1e3f 00000044 c1bd7b94 00142229 
       f5f71ec0 0000001d f5f71ee8 c02dae9e f5f71ec0 00142229 f8827e7b c0455ff8 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
inetd         S C0414548     0  3532      1          3580  3527 (NOTLB)
f556feac 00000086 f762a020 c0414548 00000041 f70dd4c0 00000246 f1ef0000 
       ac0f0588 00000041 f762a020 0000030d ac16e41e 00000041 f705a6c4 00000000 
       7fffffff 00000007 f556fee8 c02daeed f70dd4c0 f5f1fc40 f556ff44 00000202 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3578   3522          3615  3523 (NOTLB)
f5f6fdf8 00000082 f58ef530 c0414548 00000041 c17537a0 00000000 00000202 
       ac2f399c 00000041 f58ef530 00000191 ac835bc6 00000041 f76ee174 f76ee020 
       7fffffff f5f6e000 f5f6fe34 c02daeed 00000000 00000246 f5f6fe38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
cardmgr       S C0414548     0  3580      1          3674  3532 (NOTLB)
f5f5beac 00000086 f58d2a80 c0414548 00000041 00000000 00000000 00000001 
       ac0f0c53 00000041 f58d2a80 00000221 ac16f74f 00000041 f762a174 00000000 
       7fffffff 00000004 f5f5bee8 c02daeed f70dcd80 f5f5bf44 f5f5bed0 c0168756 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3615   3522                3578 (NOTLB)
f5d23df8 00000082 f705a060 c0414548 00000041 c0139e91 c0339d68 c174d8e0 
       abeb63d3 00000041 f705a060 00000197 ac836bac 00000041 f58ef684 f58ef530 
       7fffffff f5d22000 f5d23e34 c02daeed 00000000 00000246 f5d23e38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
master        S C0414548     0  3674      1  3678    3684  3580 (NOTLB)
f5d0beac 00000082 f761c060 c0414548 00000041 f731c4c0 00000002 00000000 
       ac2b42ff 00000041 f761c060 00000d72 ac4f4212 00000041 f58d2bd4 00143f11 
       f5d0bec0 00000056 f5d0bee8 c02dae9e f5d0bec0 00143f11 f8827e7b c04560e0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
pickup        S C0414548     0  3678   3674          3679       (NOTLB)
f5895eac 00000082 f5f47020 c0414548 00000041 c0339e8c 00000000 00000000 
       ac0f32ec 00000041 f5f47020 0000023a ac1774a6 00000041 f5f47684 0014db4e 
       f5895ec0 00000007 f5895ee8 c02dae9e f5895ec0 0014db4e f5866580 c047aee0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
qmgr          S C0414548     0  3679   3674                3678 (NOTLB)
f5897eac 00000086 f58d2060 c0414548 00000041 c0339e8c 00000000 00000000 
       ac0f3a2c 00000041 f58d2060 0000027e ac178b1c 00000041 f5f47174 001af5ce 
       f5897ec0 00000007 f5897ee8 c02dae9e f5897ec0 001af5ce f58664c0 c0456240 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
sshd          S C0414548     0  3684      1          3702  3674 (NOTLB)
f5d1feac 00000086 f58ef020 c0414548 00000041 f5d1ff44 00000246 f1a95000 
       ac0f3f8c 00000041 f58ef020 000001d1 ac179b77 00000041 f58d21b4 00000000 
       7fffffff 00000004 f5d1fee8 c02daeed f5d1febc c0120371 f5d1fee8 00000202 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
ssh-guard     S C04140D0     0  3702      1  3777    3705  3684 (NOTLB)
f5419ea4 00000082 f761c060 c04140d0 00000042 f76c2700 f5419ebc c02da712 
       7568799d 00000042 f761c060 00001755 756ce22e 00000042 f58ef174 f5415994 
       f5419ecc f5419ec0 f5419ef8 c01617fe 00000000 f58ef020 c012b190 f5419ed8 
Call Trace:
 [<c01617fe>] pipe_wait+0x6e/0x90
 [<c0161a17>] pipe_readv+0x1c7/0x300
 [<c0161b84>] pipe_read+0x34/0x40
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
uml_switch    S C04140A0     0  3705      1          3763  3702 (NOTLB)
f5d21f08 00000086 f58efa40 c04140a0 00000246 f1a94000 f52fb540 f5d21fa0 
       f5d21ef4 c0168756 f733a7c0 000005a3 89786cbe 00000044 f58efb94 00000000 
       7fffffff f5d21f64 f5d21f44 c02daeed c02808f9 f52fb540 f73330c0 f5d21fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
S20xprint     S C0414548     0  3763      1  3764    3776  3705 (NOTLB)
f5461f10 00000082 f5452530 c0414548 00000041 f5460000 f5461fc4 00000000 
       ac0f525b 00000041 f5452530 0000017f ac17d596 00000041 f5407174 fffffe00 
       f5460000 f54070c0 f5461f88 c011a0d8 ffffffff 00000004 f5452a40 c04140a0 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
S20xprint     S C0414548     0  3764   3763  3765    3767       (NOTLB)
f548bf10 00000082 f5452020 c0414548 00000041 f548a000 f548bfc4 00000000 
       ac0f558a 00000041 f5452020 000000ff ac17de8d 00000041 f5452684 fffffe00 
       f548a000 f54525d0 f548bf88 c011a0d8 ffffffff 00000004 f5452020 bfffe1b4 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
Xprt          S C0414548     0  3765   3764                     (NOTLB)
f548deac 00000082 f5452a40 c0414548 00000041 c0339e8c 00000000 000000d0 
       ac0f5b73 00000041 f5452a40 00000205 ac17f0bc 00000041 f5452174 00000000 
       7fffffff 00000001 f548dee8 c02daeed 00000000 f548ded0 f8827e7b f5403880 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
S20xprint     S C0414548     0  3767   3763                3764 (NOTLB)
f5489ea4 00000082 f541f060 c0414548 00000041 c190e940 f5489ebc c02da712 
       ac0f6010 00000041 f541f060 00000188 ac17fe8b 00000041 f5452b94 f589127c 
       f5489ecc f5489ec0 f5489ef8 c01617fe 00000000 f5452a40 c012b190 f5489ed8 
Call Trace:
 [<c01617fe>] pipe_wait+0x6e/0x90
 [<c0161a17>] pipe_readv+0x1c7/0x300
 [<c0161b84>] pipe_read+0x34/0x40
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
rpc.statd     S C0414548     0  3776      1          3780  3763 (NOTLB)
f5487eac 00000082 f52fd060 c0414548 00000041 f52fb3c0 00000246 f1a92000 
       ac0f6843 00000041 f52fd060 000002c9 ac18179c 00000041 f541f1b4 00000000 
       7fffffff 00000007 f5487ee8 c02daeed f52fb3c0 f7341c40 f5487f44 00000202 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
tail          S C04140A0     0  3777   3702                     (NOTLB)
f543ff48 00000086 f52fd060 c04140a0 00000000 00000000 00026cdc 00000000 
       f543ff5c f543ff48 00000246 000006c4 77474790 00000044 f52fd1b4 00141713 
       f543ff5c 000f41a7 f543ff84 c02dae9e f543ff5c 00141713 f543ffac c0455fa0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
atd           S C0414548     0  3780      1          3783  3776 (NOTLB)
f5d0df50 00000086 f541f570 c0414548 00000041 00000000 f5d0df5c 00000000 
       ac0f7caa 00000041 f541f570 00000121 ac1857b7 00000041 f58d26c4 003370de 
       f5d0df64 bffffbbc f5d0df8c c02dae9e f5d0df64 003370de 00000000 c0456300 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c02daf3a>] nanosleep_restart+0x4a/0xa0
 [<c0122796>] sys_restart_syscall+0x16/0x20
 [<c010309f>] syscall_call+0x7/0xb
cron          S C0414548     0  3783      1          3812  3780 (NOTLB)
f5485f50 00000086 f762a530 c0414548 00000041 00000000 f5485f5c 00000000 
       ac0f7ffe 00000041 f762a530 000000ea ac185ff5 00000041 f541f6c4 00146e7e 
       f5485f64 bffffc3c f5485f8c c02dae9e f5485f64 00146e7e 00000000 f707265c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c02daf3a>] nanosleep_restart+0x4a/0xa0
 [<c0122796>] sys_restart_syscall+0x16/0x20
 [<c010309f>] syscall_call+0x7/0xb
bash          S C04140A0     0  3812      1  4568    3813  3783 (NOTLB)
f769ff10 00000086 f762a530 c04140a0 f767cdc0 f767cdec f7698b74 f769ffbc 
       c0111220 f767cdc0 f7698b74 00001e14 3efacdb6 00000042 f762a684 fffffe00 
       f769e000 f762a5d0 f769ff88 c011a0d8 ffffffff 00000006 f1e94020 00000002 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
bash          S C04140A0     0  3813      1          3814  3812 (NOTLB)
f76b5e70 00000082 f767b570 c04140a0 c01e4173 0000000b 0000000d 0000000e 
       00005b0f 00000286 f54db000 00003e68 7e38ee04 00000043 f767b6c4 f54db000 
       7fffffff f766e2c0 f76b5eac c02daeed 0000000b 0000000d 0000000e 00005b0f 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3814      1          3815  3813 (NOTLB)
f5e1fe70 00000086 f52fda80 c0414548 00000041 0000481e 00000000 00000000 
       ac0f9102 00000041 f52fda80 0000019e ac1893e7 00000041 f54f6bd4 f5e5d000 
       7fffffff f7694680 f5e1feac c02daeed c02da712 f767b570 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3815      1          3816  3814 (NOTLB)
f5441e70 00000082 f54fa530 c0414548 00000041 0000481e 00000000 00000000 
       ac0f96d2 00000041 f54fa530 000001cf ac18a431 00000041 f52fdbd4 f5e85000 
       7fffffff f769a4c0 f5441eac c02daeed c02da712 f54f6a80 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3816      1          3817  3815 (NOTLB)
f5e97e70 00000082 f54fa020 c0414548 00000041 0000481e 00000000 00000000 
       ac0f9b15 00000041 f54fa020 00000166 ac18b0cf 00000041 f54fa684 f5e56000 
       7fffffff f766c400 f5e97eac c02daeed c02da712 f52fda80 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3817      1          3944  3816 (NOTLB)
f5e99e70 00000086 f708d570 c0414548 00000041 0000481e 00000000 00000000 
       ac0fa0eb 00000041 f708d570 000001fc ac18c2b3 00000041 f54fa174 f5e9a000 
       7fffffff f766c580 f5e99eac c02daeed c02da712 f54fa530 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
gnome-session S C04140D0     0  3891   3165  3946          3278 (NOTLB)
f50a3f08 00000086 f671f570 c04140d0 00000041 f1a91000 f5645880 f50a3fa0 
       ea95e8ab 00000041 f671f570 00000ad4 ea99cba1 00000041 f708d6c4 00000000 
       7fffffff f50a3f64 f50a3f44 c02daeed c02808f9 f5645880 f6a9a540 f50a3fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
ssh-agent     S C0414548     0  3944      1          3949  3817 (NOTLB)
f6a21eac 00000082 f70ae530 c0414548 00000041 c0339e8c 00000000 000000d0 
       ac0fe936 00000041 f70ae530 000001f8 ac19b0a5 00000041 f5407684 00000000 
       7fffffff 00000004 f6a21ee8 c02daeed 00000003 f6a21ed0 f8827e7b f7774e40 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
ssh-add-all   X C04140D0     0  3946   3891          3950       (L-TLB)
f6a0bf70 00000046 f761c060 c04140d0 00000041 f54f6060 00000011 c18cb800 
       10d5100a 00000041 f761c060 0000017c 10df3faf 00000041 f54f61b4 00000001 
       f54f6060 00000000 f6a0bf9c c0118fe3 f54f6060 c18e7ae0 00000008 f7774780 
Call Trace:
 [<c0118fe3>] do_exit+0x1f3/0x3b0
 [<c0119214>] do_group_exit+0x34/0xa0
 [<c0119295>] sys_exit_group+0x15/0x20
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140D0     0  3949      1  3967    3992  3944 (NOTLB)
f6a43eac 00000082 f761c060 c04140d0 00000044 00000000 f6a42000 00000000 
       8c69be8a 00000044 f761c060 000000b9 8c69d16c 00000044 f70ae684 001419e9 
       f6a43ec0 00000008 f6a43ee8 c02dae9e f6a43ec0 001419e9 f534400c f6a55ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
Xsession      S C0414548     0  3950   3891  3993          3946 (NOTLB)
f6a0df10 00000082 f541fa80 c0414548 00000041 f6a0c000 f6a0dfc4 00000000 
       ac0ffbb3 00000041 f541fa80 00000179 ac19eb74 00000041 f54f66c4 fffffe00 
       f6a0c000 f54f6610 f6a0df88 c011a0d8 ffffffff 00000004 f6a4ba40 00000000 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  3967   3949                     (NOTLB)
f6a57e70 00000082 f7267530 c0414548 00000041 00000b15 321a3def 00000037 
       ac10011a 00000041 f7267530 0000017e ac19f8e4 00000041 f541fbd4 f7ec5000 
       7fffffff f5e8b0c0 f6a57eac c02daeed c02da712 f54f6570 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
gconfd-2      S C04140A0     0  3992      1          4043  3949 (NOTLB)
f72b3f08 00000086 f7267530 c04140a0 00000246 f1a8e000 f2107140 00000000 
       f72b3f1c f72b3f08 00000246 000059a2 728a5f9b 00000042 f7267684 00142d94 
       f72b3f1c f72b3f64 f72b3f44 c02dae9e f72b3f1c 00142d94 f26500c0 c0456050 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140A0     0  3993   3950  4038    3999       (NOTLB)
f6a55eac 00000082 f52fd570 c04140a0 f5343000 00000000 f6a54000 00000000 
       f6a55ec0 f6a55eac 00000246 00000082 8c6a4a26 00000044 f52fd6c4 001419e9 
       f6a55ec0 00000005 f6a55ee8 c02dae9e f6a55ec0 001419e9 f534300c c0455fb0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140D0     0  3999   3950  4036    4001  3993 (NOTLB)
f6a7feac 00000082 f70ae530 c04140d0 00000044 00000000 f6a7e000 00000000 
       8c6528fb 00000044 f70ae530 00000089 8c665b80 00000044 f6a4b684 001419e8 
       f6a7fec0 00000005 f6a7fee8 c02dae9e f6a7fec0 001419e8 f6a3100c f6a43ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140D0     0  4001   3950  4040    4002  3999 (NOTLB)
f72b1eac 00000082 f6a53060 c04140d0 00000044 00000000 f72b0000 00000000 
       86e126a8 00000044 f6a53060 00000b41 86e126a8 00000044 f7267b94 00141819 
       f72b1ec0 00000005 f72b1ee8 c02dae9e f72b1ec0 00141819 f534700c f6a83ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
beep-media-pl S C04140A0     0  4002   3950          4011  4001 (NOTLB)
f72aff08 00000082 f6a53060 c04140a0 00000246 f3d9b000 f531ad00 00000000 
       f72aff1c f72aff08 00000246 0000096b 8ed9489c 00000044 f6a531b4 001416a7 
       f72aff1c f72aff64 f72aff44 c02dae9e f72aff1c 001416a7 f6a9a9c0 c0455c20 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
beep-media-pl S C04140D0     0  4012   3950          4044  4011 (NOTLB)
f6a59eac 00000082 f6a53060 c04140d0 00000044 c0339e8c 00000000 00000000 
       8ddaf78e 00000044 f6a53060 000002e2 8ddaf78e 00000044 f54fab94 001416b1 
       f6a59ec0 00000008 f6a59ee8 c02dae9e f6a59ec0 001416b1 f8827e7b c0455c70 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
beep-media-pl S C04140A0     0  4044   3950                4012 (NOTLB)
f6a85f48 00000082 f6a4ba40 c04140a0 c0258d26 c04742b0 f1882424 00000000 
       f6a85f5c f6a85f48 00000246 000035a1 8a600267 00000044 f6a4bb94 001416f0 
       f6a85f5c 1ddca6a7 f6a85f84 c02dae9e f6a85f5c 001416f0 00000000 c0455e68 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140A0     0  4011   3950  4013    4012  4002 (NOTLB)
f6a83eac 00000082 f6a38060 c04140a0 f534b000 00000000 f6a82000 00000000 
       f6a83ec0 f6a83eac f7072530 00000475 86f0724a 00000044 f6a381b4 0014181a 
       f6a83ec0 00000005 f6a83ee8 c02dae9e f6a83ec0 0014181a f534b00c f7603ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4013   4011                     (NOTLB)
f6a6be70 00000082 f6a53a80 c0414548 00000041 0000001a ff12a44a 00000036 
       ac115d5e 00000041 f6a53a80 000001b3 ac1e7cc8 00000041 f6a38bd4 f534c000 
       7fffffff f536b8c0 f6a6beac c02daeed c02da712 f6a38060 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4036   3999  4037               (NOTLB)
f563bf94 00000082 f5608060 c0414548 00000041 00010000 00000000 00000000 
       ac115fde 00000041 f5608060 000000be ac1e837d 00000041 f6a53bd4 f563a000 
       00000000 080c9a40 f563bfbc c010220d f563bfb0 bffff270 00000008 00010000 
Call Trace:
 [<c010220d>] sys_rt_sigsuspend+0xad/0xe0
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140A0     0  4037   4036                     (NOTLB)
f5639fb4 00000086 f5608060 c04140a0 0000000f 00000012 00000000 f5639fbc 
       c011f9db 00000000 f5608a80 00000a30 2e1649bd 00000044 f56081b4 00000000 
       00000012 00000000 f5639fbc c01237e7 f5638000 c010309f 00000000 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4038   3993  4039               (NOTLB)
f6a99f94 00000086 f5608a80 c0414548 00000041 00010000 00000000 00000000 
       ac116650 00000041 f5608a80 000000b6 ac1e943d 00000041 f56086c4 f6a98000 
       00000000 080c9a40 f6a99fbc c010220d f6a99fb0 bffff270 00000008 00010000 
Call Trace:
 [<c010220d>] sys_rt_sigsuspend+0xad/0xe0
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140A0     0  4039   4038                     (NOTLB)
f5637fb4 00000082 f5608a80 c04140a0 0000000f 00000012 00000000 f5637fbc 
       c011f9db 00000000 f6a4b020 000003a3 2e166a7e 00000044 f5608bd4 00000000 
       00000012 00000000 f5637fbc c01237e7 f5636000 c010309f 00000000 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4040   4001  4041               (NOTLB)
f6a81f94 00000082 f6a4b020 c0414548 00000041 00010000 00000000 00000000 
       ac116b9a 00000041 f6a4b020 000000ab ac1ea28d 00000041 f7267174 f6a80000 
       00000000 080c9a40 f6a81fbc c010220d f6a81fb0 bffff270 00000008 00010000 
Call Trace:
 [<c010220d>] sys_rt_sigsuspend+0xad/0xe0
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140D0     0  4041   4040                     (NOTLB)
f5635fb4 00000082 f76eea40 c04140d0 00000044 00000012 00000000 f5635fbc 
       2e0e0699 00000044 f76eea40 000006d4 2e16a7f7 00000044 f6a4b174 00000000 
       00000012 00000000 f5635fbc c01237e7 f5634000 c010309f 00000000 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
gnome-keyring S C0414548     0  4043      1          4046  3992 (NOTLB)
f6a87f08 00000082 f6814530 c0414548 00000041 f1a9f000 f5a27d80 f6a87fa0 
       ac118597 00000041 f6814530 00000838 ac1ef68f 00000041 f6a536c4 00000000 
       7fffffff f6a87f64 f6a87f44 c02daeed c02808f9 f5a27d80 f6a9a3c0 f6a87fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
bonobo-activa S C0414548     0  4046      1          4048  4043 (NOTLB)
f684ff08 00000086 f6814020 c0414548 00000041 f1a9e000 f21b5f00 f684ffa0 
       ac11bfa5 00000041 f6814020 00001589 ac1fb863 00000041 f6814684 00000000 
       7fffffff f684ff64 f684ff44 c02daeed c02808f9 f21b5f00 f21b2940 f684ffa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-smproxy S C0414548     0  4048      1          4050  4046 (NOTLB)
f6741eac 00200086 f671f570 c0414548 00000041 c0339e8c 00000000 000000d0 
       ac11cc07 00000041 f671f570 00000454 ac1fdf5f 00000041 f6814174 00000000 
       7fffffff 0000000b f6741ee8 c02daeed 0000000a f6741ed0 f8827e7b f48a0700 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
gnome-setting S C04140D0     0  4050      1          4090  4048 (NOTLB)
f6765f08 00000086 f761c060 c04140d0 00000041 f1a9c000 f688d680 f6765fa0 
       ea9b5259 00000041 f761c060 00000520 ea9bfc36 00000041 f671f6c4 00000000 
       7fffffff f6765f64 f6765f44 c02daeed c02808f9 f688d680 f68ec7c0 f6765fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
xscreensaver  S C04140A0     0  4090      1          4114  4050 (NOTLB)
f6763eac 00000082 f671f060 c04140a0 00000010 c0339e8c 00000000 00000000 
       f6763ec0 f6763eac 00000246 00000300 48c7ed5c 00000044 f671f1b4 00141fa1 
       f6763ec0 00000005 f6763ee8 c02dae9e f6763ec0 00141fa1 f56059c0 c0455fe0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
metacity      S C04140D0     0  4114      1          4122  4090 (NOTLB)
f63c7f08 00000086 f6814a40 c04140d0 00000041 f1a9a000 f6df3800 f63c7fa0 
       ea94d077 00000041 f6814a40 0000083a ea95f37d 00000041 f671fbd4 00000000 
       7fffffff f63c7f64 f63c7f44 c02daeed c02808f9 f6df3800 f6ccec40 f63c7fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-panel   S C04140D0     0  4122      1          4124  4114 (NOTLB)
f683df08 00000082 f6a53060 c04140d0 00000041 f1a89000 f21b59c0 f683dfa0 
       ea9b0e0d 00000041 f6a53060 00000b50 ea9b7344 00000041 f6814b94 00000000 
       7fffffff f683df64 f683df44 c02daeed c02808f9 f21b59c0 f21b21c0 f683dfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C04140D0     0  4124      1          4136  4122 (NOTLB)
f4d27f08 00000082 f671f570 c04140d0 00000041 f1a88000 f4a6eac0 f4d27fa0 
       ea9b0ea7 00000041 f671f570 000004ff ea9bce16 00000041 f6cad684 00000000 
       7fffffff f4d27f64 f4d27f44 c02daeed c02808f9 f4a6eac0 f63d1dc0 f4d27fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4136      1          4138  4124 (NOTLB)
f4421f08 00000082 f6cad020 c0414548 00000041 f1a87000 f45b8ec0 f4421fa0 
       ac127bd6 00000041 f6cad020 0000061b ac222219 00000041 f4cf46c4 00000000 
       7fffffff f4421f64 f4421f44 c02daeed c02808f9 f45b8ec0 f46829c0 f4421fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4142      1          4143  4139 (NOTLB)
f6c33e84 00000082 f4cf4060 c0414548 00000041 0000003b f6cad530 f6c33e74 
       ac12842d 00000041 f4cf4060 000002ec ac223c65 00000041 f6cad174 081c4b90 
       7fffffff fffffff5 f6c33ec0 c02daeed f767c280 081c4000 76796a33 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4143      1          4144  4142 (NOTLB)
f4d49e84 00000082 f479ca40 c0414548 00000041 f6cad530 f767c280 f4d49e74 
       ac1287a9 00000041 f479ca40 00000119 ac22464b 00000041 f4cf41b4 081c4e80 
       7fffffff fffffff5 f4d49ec0 c02daeed f767c280 081c4000 76796cc7 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4144      1          4146  4143 (NOTLB)
f4463e84 00000082 f479c530 c0414548 00000041 00000000 f4463f58 f4463e74 
       ac128b11 00000041 f479c530 00000113 ac224ff8 00000041 f479cb94 081c5170 
       7fffffff fffffff5 f4463ec0 c02daeed f767c280 081c5000 76796f49 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4147      1          4149  4146 (NOTLB)
f4147e84 00000082 f6cada40 c0414548 00000041 f6cad530 f767c280 f4147e74 
       ac128eb4 00000041 f6cada40 00000126 ac225a52 00000041 f479c684 08213928 
       7fffffff fffffff5 f4147ec0 c02daeed f767c280 08213000 76797212 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
gnome-vfs-dae S C0414548     0  4138      1          4139  4136 (NOTLB)
f4475f08 00000082 f4cf4a80 c0414548 00000041 f1a86000 f45b88c0 f4475fa0 
       ac12a1df 00000041 f4cf4a80 000006f7 ac229908 00000041 f6cadb94 00000000 
       7fffffff f4475f64 f4475f44 c02daeed c02808f9 f45b88c0 f46823c0 f4475fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-vfs-dae S C0414548     0  4139      1          4142  4138 (NOTLB)
f4d4bf08 00000082 f479c020 c0414548 00000041 f1a85000 f45b8740 f4d4bfa0 
       ac12b2a3 00000041 f479c020 0000060e ac22cf8c 00000041 f4cf4bd4 00000000 
       7fffffff f4d4bf64 f4d4bf44 c02daeed c02808f9 f45b8740 f46820c0 f4d4bfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
mapping-daemo S C04140A0     0  4146      1          4147  4144 (NOTLB)
f4135f08 00000082 f479c020 c04140a0 00000246 f3bc4000 f41e4e40 00000000 
       f4135f1c f4135f08 00000246 00000719 6a9b38f5 00000044 f479c174 001424dd 
       f4135f1c f4135f64 f4135f44 c02dae9e f4135f1c 001424dd f46a5c40 c0456008 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
wnck-applet   S C04140D0     0  4149      1          4151  4147 (NOTLB)
f3e3df08 00000082 f4688060 c04140d0 00000041 f1a83000 f3f75d40 f3e3dfa0 
       ea950aed 00000041 f4688060 0000081e ea969208 00000041 f46886c4 00000000 
       7fffffff f3e3df64 f3e3df44 c02daeed c02808f9 f3f75d40 f3f63800 f3e3dfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gweather-appl S C04140D0     0  4151      1          4152  4149 (NOTLB)
f391ff08 00000086 f342d020 c04140d0 00000041 f1a82000 f39cc480 00000000 
       ea9528e5 00000041 f342d020 000008cc ea96ea03 00000041 f46881b4 002d5308 
       f391ff1c f391ff64 f391ff44 c02dae9e f391ff1c 002d5308 f3a31c40 c0473a00 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gweather-appl S C0414548     0  4152      1          4153  4151 (NOTLB)
f3e2be84 00000086 f342da40 c0414548 00000041 00000000 f6a407ac f3e2be74 
       ac130e57 00000041 f342da40 00000256 ac23fd14 00000041 f4688bd4 0819c320 
       7fffffff fffffff5 f3e2bec0 c02daeed f767c4c0 0819c000 7679a461 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
gweather-appl S C0414548     0  4153      1          4155  4152 (NOTLB)
f3461e84 00000086 f342d020 c0414548 00000041 f4688060 f767c4c0 f3461e74 
       ac1311e3 00000041 f342d020 00000120 ac240737 00000041 f342db94 0819c940 
       7fffffff fffffff5 f3461ec0 c02daeed f767c4c0 0819c000 7679aaa3 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
battstat-appl S C04140A0     0  4155      1          4157  4153 (NOTLB)
f34c5f08 00000082 f342d020 c04140a0 00000246 f6da6000 f3567440 00000000 
       f34c5f1c f34c5f08 f7072530 0000647d 8539a9cd 00000044 f342d174 001416a6 
       f34c5f1c f34c5f64 f34c5f44 c02dae9e f34c5f1c 001416a6 f3039200 c0455c18 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
clock-applet  S C04140A0     0  4157      1          4159  4155 (NOTLB)
f3077f08 00000082 f304fa80 c04140a0 00000246 f1a8c000 f314a580 00000000 
       f3077f1c f3077f08 00000246 00000527 7263d0b6 00000044 f304fbd4 001416aa 
       f3077f1c f3077f64 f3077f44 c02dae9e f3077f1c 001416aa f3164940 c0455c38 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
multiload-app S C04140A0     0  4159      1          4161  4157 (NOTLB)
f3399f08 00000086 f304f570 c04140a0 00000044 f775a000 f6a9c340 00000000 
       f3399f1c f3399f08 00000246 000000b1 8e84c7aa 00000044 f304f6c4 001416eb 
       f3399f1c f3399f64 f3399f44 c02dae9e f3399f1c 001416eb f31bc200 c0455e40 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
notification- S C04140D0     0  4161      1          4164  4159 (NOTLB)
f2d6bf08 00000086 f2e8ba40 c04140d0 00000041 f1e06000 f2ddb280 f2d6bfa0 
       ea959d0e 00000041 f2e8ba40 000007d0 ea983de4 00000041 f304f1b4 00000000 
       7fffffff f2d6bf64 f2d6bf44 c02daeed c02808f9 f2ddb280 f2e4c940 f2d6bfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
netloc.py     S C04140D0     0  4164      1          4167  4161 (NOTLB)
f2eadf08 00000086 f304f570 c04140d0 00000044 f1e87000 f2ac86c0 00000000 
       8e7b41b0 00000044 f304f570 000010bf 8e7b41b0 00000044 f2e8bb94 001416eb 
       f2eadf1c f2eadf64 f2eadf44 c02dae9e f2eadf1c 001416eb f65d9b40 f3399f1c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
wireless-appl S C04140A0     0  4167      1          4169  4164 (NOTLB)
f246bf08 00000082 f2e8b530 c04140a0 00000246 f1e22000 f257e140 00000000 
       f246bf1c f246bf08 00000246 00001ce9 7accca25 00000044 f2e8b684 00141b35 
       f246bf1c f246bf64 f246bf44 c02dae9e f246bf1c 00141b35 f25b5340 c0455fc0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
mini_commande S C04140D0     0  4169      1          4171  4167 (NOTLB)
f268df08 00000086 f20afa80 c04140d0 00000041 f1e23000 f2780640 f268dfa0 
       ea95eeb6 00000041 f20afa80 00000688 ea9923ad 00000041 f2e8b174 00000000 
       7fffffff f268df64 f268df44 c02daeed c02808f9 f2780640 f2650b40 f268dfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-cpufreq S C04140A0     0  4171      1                4169 (NOTLB)
f20dff08 00000082 f20afa80 c04140a0 00000044 f1e24000 f21b5a80 00000000 
       f20dff1c f20dff08 00000246 00000118 711f279c 00000044 f20afbd4 001416a9 
       f20dff1c f20dff64 f20dff44 c02dae9e f20dff1c 001416a9 f21b2340 c0455c30 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
ipw2200/0     S C04140A0     0  4473      9                 849 (L-TLB)
f71c5f3c 00000046 f1e94a40 c04140a0 00000046 00000000 f71c4000 00000082 
       f71c5f3c 00000082 f1c8b518 000000ff 8a73fd73 00000044 f1e94b94 f71c5f90 
       f71c4000 f1c8b510 f71c5fbc c0126bb5 00000000 f71c5f70 00000000 f1c8b518 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
top           S C04140A0     0  4568   3812                     (NOTLB)
f1e2beac 00000086 f1e94020 c04140a0 f766c700 00000000 f1e2a000 00000000 
       f1e2bec0 f1e2beac 00000246 000238d2 75fd7910 00000044 f1e94174 00141ecb 
       f1e2bec0 00000001 f1e2bee8 c02dae9e f1e2bec0 00141ecb c1bfb00c c0455fd8 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb

***** Things are calm now. -- Bernard.

SysRq : Show Memory
Mem-info:
DMA per-cpu:
cpu 0 hot: low 2, high 6, batch 1
cpu 0 cold: low 0, high 2, batch 1
Normal per-cpu:
cpu 0 hot: low 32, high 96, batch 16
cpu 0 cold: low 0, high 32, batch 16
HighMem per-cpu:
cpu 0 hot: low 12, high 36, batch 6
cpu 0 cold: low 0, high 12, batch 6

Free pages:      977980kB (95160kB HighMem)
Active:4331 inactive:1187 dirty:0 writeback:0 unstable:0 free:244495 slab:2579 mapped:3404 pagetables:452
DMA free:12516kB min:68kB low:84kB high:100kB active:0kB inactive:0kB present:16384kB pages_scanned:0 all_unreclaimable? yes
protections[]: 0 0 0
Normal free:870304kB min:3756kB low:4692kB high:5632kB active:4504kB inactive:2232kB present:901120kB pages_scanned:6657 all_unreclaimable? yes
protections[]: 0 0 0
HighMem free:95160kB min:128kB low:160kB high:192kB active:12820kB inactive:2516kB present:114624kB pages_scanned:0 all_unreclaimable? no
protections[]: 0 0 0
DMA: 5*4kB 4*8kB 3*16kB 4*32kB 4*64kB 2*128kB 2*256kB 0*512kB 1*1024kB 1*2048kB 2*4096kB = 12516kB
Normal: 1708*4kB 982*8kB 542*16kB 349*32kB 213*64kB 103*128kB 46*256kB 17*512kB 6*1024kB 0*2048kB 191*4096kB = 870304kB
HighMem: 0*4kB 539*8kB 628*16kB 403*32kB 235*64kB 125*128kB 54*256kB 25*512kB 4*1024kB 1*2048kB 1*4096kB = 95160kB
Swap cache: add 26208, delete 24495, find 1207/1544, race 0+0
Free swap:       411556kB
258032 pages of RAM
28656 pages of HIGHMEM
3260 reserved pages
18437 pages shared
1713 pages swap cached
SysRq : Show State

                                               sibling
  task             PC      pid father child younger older
init          S C04140A0     0     1      0     2               (NOTLB)
c1909eac 00000082 c18dca40 c04140a0 00000000 00000001 00000000 00000000 
       c1909ec0 c1909eac 00000246 00000863 11d1da41 00000047 c18dcb94 0014b5dd 
       c1909ec0 0000000b c1909ee8 c02dae9e c1909ec0 0014b5dd c1bf5bc0 c0456090 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
ksoftirqd/0   S C04140A0     0     2      1             3       (L-TLB)
c190bfa4 00000046 c18dc530 c04140a0 0000000a c190bf80 c011b8b6 00000000 
       00000001 c190bf98 c011b64c 00000086 fe5af009 00000046 c18dc684 00000000 
       c190a000 00000000 c190bfbc c011ba95 c18dc530 00000013 c190a000 c1909f64 
Call Trace:
 [<c011ba95>] ksoftirqd+0xb5/0xd0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
events/0      R running     0     3      1             4     2 (L-TLB)
khelper       S C04140A0     0     4      1             9     3 (L-TLB)
c192bf3c 00000046 c18e5a80 c04140a0 00000292 00000000 c192a000 00000082 
       c192bf3c 00000082 f1e88060 000000d3 d98ba106 00000041 c18e5bd4 c192bf90 
       c192a000 c18cb790 c192bfbc c0126bb5 00000000 c192bf70 00000000 c18cb798 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kthread       S C04140A0     0     9      1    18     148     4 (L-TLB)
c192df3c 00000046 c18e5570 c04140a0 f1cbdddc 00000000 c192c000 00000082 
       c192df3c 00000082 f1e94a40 00000038 d31ae9d1 00000041 c18e56c4 c192df90 
       c192c000 c18ef090 c192dfbc c0126bb5 00000000 c192df70 00000000 c18ef098 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kacpid        S C04140A0     0    18      9           110       (L-TLB)
c193ff3c 00000046 c18e5060 c04140a0 0000001c 00000000 c193e000 00000082 
       c193ff3c 00000082 f76ee530 00003882 26141d38 00000047 c18e51b4 c193ff90 
       c193e000 c18f9b90 c193ffbc c0126bb5 00000000 c193ff70 00000000 c18f9b98 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kblockd/0     S C04140A0     0   110      9           146    18 (L-TLB)
c1af9f3c 00000046 c196ba40 c04140a0 c1bda0c0 00000000 c1af8000 00000082 
       c1af9f3c 00000082 c18f9318 00000981 200d2d5a 00000047 c196bb94 c1af9f90 
       c1af8000 c18f9310 c1af9fbc c0126bb5 00000000 c1af9f70 00000000 c18f9318 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
pdflush       S C0414548     0   146      9           147   110 (L-TLB)
c1b2df74 00000046 c196b530 c0414548 00000041 c1b2df48 c0120371 c1b2df74 
       abab4fe9 00000041 c196b530 000000ad ababb115 00000041 c196b174 c1b2c000 
       c1b2dfa8 c1b2c000 c1b2df8c c013c5ea 00004000 c1b2c000 c1909f60 00000000 
Call Trace:
 [<c013c5ea>] __pdflush+0x9a/0x1f0
 [<c013c768>] pdflush+0x28/0x30
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
pdflush       S C04140A0     0   147      9           149   146 (L-TLB)
c1b2bf74 00000046 c196b530 c04140a0 00000000 00000000 00000000 00000000 
       00000005 00000041 c1b08a80 00001da1 edb43ebf 00000046 c196b684 c1b2a000 
       c1b2bfa8 c1b2a000 c1b2bf8c c013c5ea 00000000 c1b2a000 c1909f60 00000000 
Call Trace:
 [<c013c5ea>] __pdflush+0x9a/0x1f0
 [<c013c768>] pdflush+0x28/0x30
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
aio/0         S C0414548     0   149      9           849   147 (L-TLB)
c1b81f3c 00000046 c1bd7020 c0414548 00000041 c1b81f10 c0120371 c1b81f3c 
       abab5085 00000041 c1bd7020 0000009d ababa49f 00000041 c1b086c4 c1b81f90 
       c1b80000 c1b4ff10 c1b81fbc c0126bb5 00004000 c1b81f70 00000000 00000082 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
kswapd0       S C04140A0     0   148      1           739     9 (L-TLB)
c1b2ff88 00000046 c1b08a80 c04140a0 00000000 0000000c 00000001 00000004 
       00000140 00000024 00000a91 0000008f 0c80ff3a 00000046 c1b08bd4 c1b2e000 
       0000000a c0339edc c1b2ffec c0141e55 c0339b20 00000000 0000000a 00000000 
Call Trace:
 [<c0141e55>] kswapd+0xe5/0x100
 [<c0101325>] kernel_thread_helper+0x5/0x10
kseriod       S C0414548     0   739      1           981   148 (L-TLB)
c1b83f8c 00000046 f70aea40 c0414548 00000041 c1b83f60 c0120371 c1b83f8c 
       abac0641 00000041 f70aea40 000000f6 abae028b 00000041 c1b081b4 ffffe000 
       c1b83fc0 c1b82000 c1b83fec c023da85 00004000 c18e5a80 c1b82000 00000000 
Call Trace:
 [<c023da85>] serio_thread+0x105/0x130
 [<c0101325>] kernel_thread_helper+0x5/0x10
reiserfs/0    S C04140D0     0   849      9          4473   149 (L-TLB)
f7ec9f3c 00000046 f761c060 c04140d0 00000046 00000000 f7ec8000 00000082 
       ee8f783a 00000046 f761c060 0000014a ee8f783a 00000046 c1bd7174 f7ec9f90 
       f7ec8000 f7ea5e10 f7ec9fbc c0126bb5 00000000 f7ec9f70 00000000 f7ea5e18 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
devfsd        S C04140A0     0   981      1          1278   739 (NOTLB)
f7657ed8 00000086 f761ca80 c04140a0 00000042 00000000 f7656000 00000286 
       f7657ed8 00000286 c046bd70 00001a06 6a2f64b8 00000042 f761cbd4 c046bd70 
       c046bd40 f7656000 f7657f64 c01bd704 00000000 f1cbf254 00000005 c046bd68 
Call Trace:
 [<c01bd704>] devfsd_read+0xd4/0x3f0
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
khubd         S C0414548     0  1278      1          2646   981 (L-TLB)
f7051f8c 00000046 c1bd7530 c0414548 00000041 f7051f60 c0120371 f7051f8c 
       abac0a78 00000041 c1bd7530 000000f4 abae0c1a 00000041 f70aeb94 ffffe000 
       f7051fc0 f7050000 f7051fec f89f8ea5 00004000 f7607020 f7050000 00000000 
Call Trace:
 [<f89f8ea5>] packet_sklist_lock+0x385785a5/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
khpsbpkt      S C0414548     0  2646      1          2699  1278 (L-TLB)
f774df84 00000046 f7072a40 c0414548 00000041 f70aea40 c1bd7530 f70aea40 
       abac0f1a 00000041 f7072a40 000000d5 abae146c 00000041 c1bd7684 f8c3e038 
       00000246 f774c000 f774dfc8 c02da387 f774c000 f8c3e040 c1bd7530 00000000 
Call Trace:
 [<c02da387>] __down_interruptible+0xa7/0x12c
 [<c02da426>] __down_failed_interruptible+0xa/0x10
 [<f8bffbb5>] packet_sklist_lock+0x3877f2b5/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
knodemgrd_0   S C04140A0     0  2699      1          2909  2646 (L-TLB)
f7053f68 00000046 f705a060 c04140a0 ffffffff f58ef530 f705a060 f58ef530 
       f705a060 c190eb80 f1c93a40 00000610 ac8377cc 00000041 f705a1b4 f556a5b0 
       00000246 f7052000 f7053fac c02da387 f7052000 f556a5b8 f705a060 00000000 
Call Trace:
 [<c02da387>] __down_interruptible+0xa7/0x12c
 [<c02da426>] __down_failed_interruptible+0xa/0x10
 [<f8c06ad0>] packet_sklist_lock+0x387861d0/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
pccardd       S C04140A0     0  2909      1          3047  2699 (L-TLB)
f7757f84 00000046 f7072a40 c04140a0 00000000 f7757f58 c0120371 f7757f84 
       00000202 00757f6c f1c93a40 000000a5 abae1adf 00000041 f7072b94 f70a7030 
       00000000 f7756000 f7757fec f8c630d3 00004000 f70a7034 00000000 f70a716c 
Call Trace:
 [<f8c630d3>] packet_sklist_lock+0x387e27d3/0x4
 [<c0101325>] kernel_thread_helper+0x5/0x10
portmap       S C0414548     0  3047      1          3130  2909 (NOTLB)
f7009f08 00000082 f7072530 c0414548 00000041 f73ac8d0 f76cf100 f7009f0c 
       ac0be85e 00000041 f7072530 0000057a ac0c8aad 00000041 f761c6c4 00000000 
       7fffffff f7009f64 f7009f44 c02daeed c02808f9 f76cf100 c18f8040 f7009fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
syslogd       S C04140A0     0  3130      1          3133  3047 (NOTLB)
f7761eac 00000086 f7072530 c04140a0 00000010 c0339e8c 00000000 000000d0 
       c01458e7 000000d0 f70dcf00 00000236 1df38933 00000046 f7072684 00000000 
       7fffffff 00000001 f7761ee8 c02daeed 00000000 f7761ed0 c0286e6b f70dcf00 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
klogd         D C04140A0     0  3133      1          3149  3130 (NOTLB)
f77d9ce0 00000086 f76eea40 c04140a0 f77d9cb4 c0247a1d c1bdf738 f77d9cd8 
       c014cf67 c1bdf7f4 c17368a0 00001f86 3e467019 00000047 f76eeb94 f77d9d44 
       f77d9d4c c17e22a8 f77d9ce8 c02dadee f77d9cf4 c01354d5 c17368a0 f77d9d14 
Call Trace:
 [<c02dadee>] io_schedule+0xe/0x20
 [<c01354d5>] sync_page+0x35/0x50
 [<c02db0ed>] __wait_on_bit_lock+0x5d/0x70
 [<c0135cc4>] __lock_page+0x84/0x90
 [<c01459e7>] do_swap_page+0x217/0x2d0
 [<c014616e>] handle_mm_fault+0xbe/0x190
 [<c0111220>] do_page_fault+0x1d0/0x6a2
 [<c0103247>] error_code+0x2b/0x30
 [<c018647a>] kmsg_read+0x4a/0x60
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
slmodemd      S C04140A0     0  3149      1          3161  3133 (NOTLB)
f522deac 00000086 f708d060 c04140a0 f766ed40 00000000 f522c000 00000000 
       f522dec0 f522deac 00000246 00000461 25c2bd95 00000047 f708d1b4 0014a88b 
       f522dec0 00000006 f522dee8 c02dae9e f522dec0 0014a88b c0168756 f72b1ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
gdm           S C0414548     0  3161      1  3165    3307  3149 (NOTLB)
f7765f08 00000086 f77b6a80 c0414548 00000041 f1cae000 f776edc0 f7765fa0 
       ac0cc7d6 00000041 f77b6a80 0000095a ac0f7477 00000041 f767bbd4 00000000 
       7fffffff f7765f64 f7765f44 c02daeed c1bf58c0 f7765fa0 00000145 f73ac8b8 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gdm           S C0414548     0  3165   3161  3278               (NOTLB)
f77efeac 00000082 f761c060 c0414548 00000041 00000001 00000000 f77b6a80 
       ac0cceb3 00000041 f761c060 00000259 ac0f899f 00000041 f77b6bd4 00000000 
       7fffffff 0000000a f77efee8 c02daeed f77efec8 c0168756 f5866d00 f5dc9c1c 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
X             S C04140A0     0  3278   3165          3891       (NOTLB)
f7603eac 00000082 f761c060 c04140a0 00000047 c0339e8c 00000000 00000000 
       f7603ec0 f7603eac 00000246 00000136 3edd60a8 00000047 f761c1b4 0014a8d9 
       f7603ec0 00000020 f7603ee8 c02dae9e f7603ec0 0014a8d9 f8827e7b c0456028 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
spamd         S C0414548     0  3307      1  3469    3383  3161 (NOTLB)
f77d7fb4 00000082 f708da80 c0414548 00000041 f77d7f88 c0155f88 f77d7fa4 
       ac0d0f65 00000041 f708da80 000000fb ac105e46 00000041 f705abd4 08c14160 
       0814c008 08abc63c f77d7fbc c01237e7 f77d6000 c010309f 08c14160 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
acpid         S C04140A0     0  3383      1          3451  3307 (NOTLB)
f7c39f08 00000086 f708da80 c04140a0 00000246 f1c94000 f76dfd80 f7c39fa0 
       f7c39ef4 c0168756 f1aa9570 00004246 da9c0545 00000041 f708dbd4 00000000 
       7fffffff f7c39f64 f7c39f44 c02daeed c02808f9 f76dfd80 f5911200 f7c39fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
battery-daemo S C04140A0     0  3451      1          3465  3383 (NOTLB)
f509ff48 00000082 f77b6060 c04140a0 f509ff2c c016ffb9 f76ec044 00000000 
       f509ff5c f509ff48 00000246 00007795 f6b31059 00000046 f77b61b4 0014c19b 
       f509ff5c 000f41a7 f509ff84 c02dae9e f509ff5c 0014c19b 00000000 c0455ef0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
cpufreqd      S C04140A0     0  3465      1          3475  3451 (NOTLB)
f773bf48 00000086 f76ee530 c04140a0 f52fc4ec 00000000 f52fc4ec 00000000 
       f773bf5c f773bf48 00000246 0000de26 2625d304 00000047 f76ee684 0014ac7b 
       f773bf5c 000f41a7 f773bf84 c02dae9e f773bf5c 0014ac7b 00000000 c0456048 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
spamd         S C0414548     0  3469   3307                     (NOTLB)
f50a1df8 00000082 f7072020 c0414548 00000041 c0139e91 c0339d68 c1766a20 
       ac0ed5ae 00000041 f7072020 00000475 ac165084 00000041 f77b66c4 f77b6570 
       7fffffff f50a0000 f50a1e34 c02daeed 00000000 00000246 f50a1e38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
cupsd         S C04140A0     0  3475      1          3487  3465 (NOTLB)
f50b5eac 00000086 f7072020 c04140a0 f27af000 f76cf340 f50b5f44 00000000 
       f50b5ec0 f50b5eac 00000246 00000351 b8fe17de 00000046 f7072174 0014f7ac 
       f50b5ec0 00000004 f50b5ee8 c02dae9e f50b5ec0 0014f7ac f5866040 c1bda1e4 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
dbus-daemon-1 S C0414548     0  3487      1          3522  3475 (NOTLB)
f6b07f08 00000082 c1bd7a40 c0414548 00000041 f1caa000 f76cfc40 f6b07fa0 
       ac0ef114 00000041 c1bd7a40 000005e3 ac16a515 00000041 f70ae174 00000000 
       7fffffff f6b07f64 f6b07f44 c02daeed c02808f9 f76cfc40 f5f829c0 f6b07fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3522      1  3523    3527  3487 (NOTLB)
f5f73f10 00000086 f762aa40 c0414548 00000041 f5f72000 f5f73fc4 00000000 
       ac2f2855 00000041 f762aa40 000001a1 ac832b40 00000041 f5f47b94 fffffe00 
       f5f72000 f5f47ae0 f5f73f88 c011a0d8 ffffffff 00000004 f58ef530 f5f73f48 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3523   3522          3578       (NOTLB)
f5f5ddf8 00000086 f76ee020 c0414548 00000041 c1754320 00000000 00000202 
       ac2f33d5 00000041 f76ee020 00000348 ac834c16 00000041 f762ab94 f762aa40 
       7fffffff f5f5c000 f5f5de34 c02daeed 00000000 00000246 f5f5de38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
famd          S C04140A0     0  3527      1          3532  3522 (NOTLB)
f5f71eac 00000082 c1bd7a40 c04140a0 f766e8c0 f5f71f44 00000246 00000000 
       f5f71ec0 f5f71eac 00000246 000010c2 f03f1592 00000046 c1bd7b94 0014aecf 
       f5f71ec0 0000001d f5f71ee8 c02dae9e f5f71ec0 0014aecf f8827e7b c0456058 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
inetd         S C0414548     0  3532      1          3580  3527 (NOTLB)
f556feac 00000086 f762a020 c0414548 00000041 f70dd4c0 00000246 f1ef0000 
       ac0f0588 00000041 f762a020 0000030d ac16e41e 00000041 f705a6c4 00000000 
       7fffffff 00000007 f556fee8 c02daeed f70dd4c0 f5f1fc40 f556ff44 00000202 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3578   3522          3615  3523 (NOTLB)
f5f6fdf8 00000082 f58ef530 c0414548 00000041 c17537a0 00000000 00000202 
       ac2f399c 00000041 f58ef530 00000191 ac835bc6 00000041 f76ee174 f76ee020 
       7fffffff f5f6e000 f5f6fe34 c02daeed 00000000 00000246 f5f6fe38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
cardmgr       S C0414548     0  3580      1          3674  3532 (NOTLB)
f5f5beac 00000086 f58d2a80 c0414548 00000041 00000000 00000000 00000001 
       ac0f0c53 00000041 f58d2a80 00000221 ac16f74f 00000041 f762a174 00000000 
       7fffffff 00000004 f5f5bee8 c02daeed f70dcd80 f5f5bf44 f5f5bed0 c0168756 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
distccd       S C0414548     0  3615   3522                3578 (NOTLB)
f5d23df8 00000082 f705a060 c0414548 00000041 c0139e91 c0339d68 c174d8e0 
       abeb63d3 00000041 f705a060 00000197 ac836bac 00000041 f58ef684 f58ef530 
       7fffffff f5d22000 f5d23e34 c02daeed 00000000 00000246 f5d23e38 00000282 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c02aac5a>] wait_for_connect+0xda/0xe0
 [<c02aacbb>] tcp_accept+0x5b/0x100
 [<c02c8c62>] inet_accept+0x32/0xd0
 [<c02811da>] sys_accept+0xaa/0x180
 [<c0281dd2>] sys_socketcall+0xd2/0x250
 [<c010309f>] syscall_call+0x7/0xb
master        S C04140A0     0  3674      1  3678    3684  3580 (NOTLB)
f5d0beac 00000082 f58d2a80 c04140a0 00000000 00000001 00000246 00000000 
       f5d0bec0 f5d0beac f5f47530 00000937 b210a463 00000045 f58d2bd4 00152a0b 
       f5d0bec0 00000056 f5d0bee8 c02dae9e f5d0bec0 00152a0b f8827e7b f72b3f1c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
pickup        S C04140A0     0  3678   3674          3679       (NOTLB)
f5895eac 00000082 f5f47530 c04140a0 00000010 c0339e8c 00000000 00000000 
       f5895ec0 f5895eac 00000246 00000310 b3e66079 00000045 f5f47684 0015c66a 
       f5895ec0 00000007 f5895ee8 c02dae9e f5895ec0 0015c66a f5866580 c04561a0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
qmgr          S C0414548     0  3679   3674                3678 (NOTLB)
f5897eac 00000086 f58d2060 c0414548 00000041 c0339e8c 00000000 00000000 
       ac0f3a2c 00000041 f58d2060 0000027e ac178b1c 00000041 f5f47174 001af5ce 
       f5897ec0 00000007 f5897ee8 c02dae9e f5897ec0 001af5ce f58664c0 c0456240 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
sshd          S C0414548     0  3684      1          3702  3674 (NOTLB)
f5d1feac 00000086 f58ef020 c0414548 00000041 f5d1ff44 00000246 f1a95000 
       ac0f3f8c 00000041 f58ef020 000001d1 ac179b77 00000041 f58d21b4 00000000 
       7fffffff 00000004 f5d1fee8 c02daeed f5d1febc c0120371 f5d1fee8 00000202 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
ssh-guard     S C04140D0     0  3702      1  3777    3705  3684 (NOTLB)
f5419ea4 00000082 f761c060 c04140d0 00000042 f76c2700 f5419ebc c02da712 
       7568799d 00000042 f761c060 00001755 756ce22e 00000042 f58ef174 f5415994 
       f5419ecc f5419ec0 f5419ef8 c01617fe 00000000 f58ef020 c012b190 f5419ed8 
Call Trace:
 [<c01617fe>] pipe_wait+0x6e/0x90
 [<c0161a17>] pipe_readv+0x1c7/0x300
 [<c0161b84>] pipe_read+0x34/0x40
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
uml_switch    S C04140D0     0  3705      1          3763  3702 (NOTLB)
f5d21f08 00000086 f6a53060 c04140d0 00000047 f5d31000 f52fb540 f5d21fa0 
       111c46f8 00000047 f6a53060 00000426 111c46f8 00000047 f58efb94 00000000 
       7fffffff f5d21f64 f5d21f44 c02daeed c02808f9 f52fb540 f73330c0 f5d21fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
S20xprint     S C0414548     0  3763      1  3764    3776  3705 (NOTLB)
f5461f10 00000082 f5452530 c0414548 00000041 f5460000 f5461fc4 00000000 
       ac0f525b 00000041 f5452530 0000017f ac17d596 00000041 f5407174 fffffe00 
       f5460000 f54070c0 f5461f88 c011a0d8 ffffffff 00000004 f5452a40 c04140a0 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
S20xprint     S C0414548     0  3764   3763  3765    3767       (NOTLB)
f548bf10 00000082 f5452020 c0414548 00000041 f548a000 f548bfc4 00000000 
       ac0f558a 00000041 f5452020 000000ff ac17de8d 00000041 f5452684 fffffe00 
       f548a000 f54525d0 f548bf88 c011a0d8 ffffffff 00000004 f5452020 bfffe1b4 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
Xprt          S C0414548     0  3765   3764                     (NOTLB)
f548deac 00000082 f5452a40 c0414548 00000041 c0339e8c 00000000 000000d0 
       ac0f5b73 00000041 f5452a40 00000205 ac17f0bc 00000041 f5452174 00000000 
       7fffffff 00000001 f548dee8 c02daeed 00000000 f548ded0 f8827e7b f5403880 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
S20xprint     S C0414548     0  3767   3763                3764 (NOTLB)
f5489ea4 00000082 f541f060 c0414548 00000041 c190e940 f5489ebc c02da712 
       ac0f6010 00000041 f541f060 00000188 ac17fe8b 00000041 f5452b94 f589127c 
       f5489ecc f5489ec0 f5489ef8 c01617fe 00000000 f5452a40 c012b190 f5489ed8 
Call Trace:
 [<c01617fe>] pipe_wait+0x6e/0x90
 [<c0161a17>] pipe_readv+0x1c7/0x300
 [<c0161b84>] pipe_read+0x34/0x40
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
rpc.statd     S C0414548     0  3776      1          3780  3763 (NOTLB)
f5487eac 00000082 f52fd060 c0414548 00000041 f52fb3c0 00000246 f1a92000 
       ac0f6843 00000041 f52fd060 000002c9 ac18179c 00000041 f541f1b4 00000000 
       7fffffff 00000007 f5487ee8 c02daeed f52fb3c0 f7341c40 f5487f44 00000202 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
tail          S C04140A0     0  3777   3702                     (NOTLB)
f543ff48 00000086 f52fd060 c04140a0 00000000 00000000 00026cdc 00000000 
       f543ff5c f543ff48 00000246 000003cf 30d60237 00000047 f52fd1b4 0014a947 
       f543ff5c 000f41a7 f543ff84 c02dae9e f543ff5c 0014a947 f543ffac c0456030 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
atd           S C0414548     0  3780      1          3783  3776 (NOTLB)
f5d0df50 00000086 f541f570 c0414548 00000041 00000000 f5d0df5c 00000000 
       ac0f7caa 00000041 f541f570 00000121 ac1857b7 00000041 f58d26c4 003370de 
       f5d0df64 bffffbbc f5d0df8c c02dae9e f5d0df64 003370de 00000000 c0473a00 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c02daf3a>] nanosleep_restart+0x4a/0xa0
 [<c0122796>] sys_restart_syscall+0x16/0x20
 [<c010309f>] syscall_call+0x7/0xb
cron          S C04140A0     0  3783      1          3812  3780 (NOTLB)
f5485f48 00000086 f541f570 c04140a0 f5485fc4 c02f63f3 00000004 00000000 
       f5485f5c f5485f48 00000246 000002f1 8fffa8db 00000046 f541f6c4 0015596f 
       f5485f5c 000f41a7 f5485f84 c02dae9e f5485f5c 0015596f 00000000 c0456190 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
bash          S C04140A0     0  3812      1  4568    3813  3783 (NOTLB)
f769ff10 00000086 f762a530 c04140a0 f767cdc0 f767cdec f7698b74 f769ffbc 
       c0111220 f767cdc0 f7698b74 00001e14 3efacdb6 00000042 f762a684 fffffe00 
       f769e000 f762a5d0 f769ff88 c011a0d8 ffffffff 00000006 f1e94020 00000002 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
bash          S C04140A0     0  3813      1          3814  3812 (NOTLB)
f76b5e70 00000082 f767b570 c04140a0 c01e4173 0000000b 0000000d 0000000e 
       0000db0f 00000286 f54db000 00001dba 1fb60a6a 00000047 f767b6c4 f54db000 
       7fffffff f766e2c0 f76b5eac c02daeed 0000000b 0000000d 0000000e 0000db0f 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3814      1          3815  3813 (NOTLB)
f5e1fe70 00000086 f52fda80 c0414548 00000041 0000481e 00000000 00000000 
       ac0f9102 00000041 f52fda80 0000019e ac1893e7 00000041 f54f6bd4 f5e5d000 
       7fffffff f7694680 f5e1feac c02daeed c02da712 f767b570 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3815      1          3816  3814 (NOTLB)
f5441e70 00000082 f54fa530 c0414548 00000041 0000481e 00000000 00000000 
       ac0f96d2 00000041 f54fa530 000001cf ac18a431 00000041 f52fdbd4 f5e85000 
       7fffffff f769a4c0 f5441eac c02daeed c02da712 f54f6a80 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3816      1          3817  3815 (NOTLB)
f5e97e70 00000082 f54fa020 c0414548 00000041 0000481e 00000000 00000000 
       ac0f9b15 00000041 f54fa020 00000166 ac18b0cf 00000041 f54fa684 f5e56000 
       7fffffff f766c400 f5e97eac c02daeed c02da712 f52fda80 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
getty         S C0414548     0  3817      1          3944  3816 (NOTLB)
f5e99e70 00000086 f708d570 c0414548 00000041 0000481e 00000000 00000000 
       ac0fa0eb 00000041 f708d570 000001fc ac18c2b3 00000041 f54fa174 f5e9a000 
       7fffffff f766c580 f5e99eac c02daeed c02da712 f54fa530 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
gnome-session S C04140D0     0  3891   3165  3946          3278 (NOTLB)
f50a3f08 00000086 f671f570 c04140d0 00000041 f1a91000 f5645880 f50a3fa0 
       ea95e8ab 00000041 f671f570 00000ad4 ea99cba1 00000041 f708d6c4 00000000 
       7fffffff f50a3f64 f50a3f44 c02daeed c02808f9 f5645880 f6a9a540 f50a3fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
ssh-agent     S C0414548     0  3944      1          3949  3817 (NOTLB)
f6a21eac 00000082 f70ae530 c0414548 00000041 c0339e8c 00000000 000000d0 
       ac0fe936 00000041 f70ae530 000001f8 ac19b0a5 00000041 f5407684 00000000 
       7fffffff 00000004 f6a21ee8 c02daeed 00000003 f6a21ed0 f8827e7b f7774e40 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
ssh-add-all   X C04140D0     0  3946   3891          3950       (L-TLB)
f6a0bf70 00000046 f761c060 c04140d0 00000041 f54f6060 00000011 c18cb800 
       10d5100a 00000041 f761c060 0000017c 10df3faf 00000041 f54f61b4 00000001 
       f54f6060 00000000 f6a0bf9c c0118fe3 f54f6060 c18e7ae0 00000008 f7774780 
Call Trace:
 [<c0118fe3>] do_exit+0x1f3/0x3b0
 [<c0119214>] do_group_exit+0x34/0xa0
 [<c0119295>] sys_exit_group+0x15/0x20
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140A0     0  3949      1  3967    3992  3944 (NOTLB)
f6a43eac 00000082 f70ae530 c04140a0 f5344000 00000000 f6a42000 00000000 
       f6a43ec0 f6a43eac 00000246 000000be 3c9f023d 00000047 f70ae684 0014aa76 
       f6a43ec0 00000008 f6a43ee8 c02dae9e f6a43ec0 0014aa76 f534400c c0456038 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
Xsession      S C0414548     0  3950   3891  3993          3946 (NOTLB)
f6a0df10 00000082 f541fa80 c0414548 00000041 f6a0c000 f6a0dfc4 00000000 
       ac0ffbb3 00000041 f541fa80 00000179 ac19eb74 00000041 f54f66c4 fffffe00 
       f6a0c000 f54f6610 f6a0df88 c011a0d8 ffffffff 00000004 f6a4ba40 00000000 
Call Trace:
 [<c011a0d8>] do_wait+0x1a8/0x460
 [<c011a45c>] sys_wait4+0x3c/0x40
 [<c011a485>] sys_waitpid+0x25/0x29
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  3967   3949                     (NOTLB)
f6a57e70 00000082 f7267530 c0414548 00000041 00000b15 321a3def 00000037 
       ac10011a 00000041 f7267530 0000017e ac19f8e4 00000041 f541fbd4 f7ec5000 
       7fffffff f5e8b0c0 f6a57eac c02daeed c02da712 f54f6570 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
gconfd-2      S C04140A0     0  3992      1          4043  3949 (NOTLB)
f72b3f08 00000086 f7267530 c04140a0 00000246 f47f8000 f2107140 00000000 
       f72b3f1c f72b3f08 00000246 000015d5 3b77e140 00000047 f7267684 00151929 
       f72b3f1c f72b3f64 f72b3f44 c02dae9e f72b3f1c 00151929 f26500c0 c0456188 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140D0     0  3993   3950  4038    3999       (NOTLB)
f6a55eac 00000082 f6a4b530 c04140d0 00000047 00000000 f6a54000 00000000 
       3c9ebc0f 00000047 f6a4b530 0000008c 3c9ef618 00000047 f52fd6c4 0014aa76 
       f6a55ec0 00000005 f6a55ee8 c02dae9e f6a55ec0 0014aa76 f534300c f6a7fec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140D0     0  3999   3950  4036    4001  3993 (NOTLB)
f6a7feac 00000082 f70ae530 c04140d0 00000047 00000000 f6a7e000 00000000 
       3c9d234f 00000047 f70ae530 00000078 3c9efacc 00000047 f6a4b684 0014aa76 
       f6a7fec0 00000005 f6a7fee8 c02dae9e f6a7fec0 0014aa76 f6a3100c f6a43ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140A0     0  4001   3950  4040    4002  3999 (NOTLB)
f72b1eac 00000082 f7267a40 c04140a0 f5347000 00000000 f72b0000 00000000 
       f72b1ec0 f72b1eac 00000246 00000973 27124a6a 00000047 f7267b94 0014a8a1 
       f72b1ec0 00000005 f72b1ee8 c02dae9e f72b1ec0 0014a8a1 f534700c f6a83ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
beep-media-pl S C04140D0     0  4002   3950          4011  4001 (NOTLB)
f72aff08 00000082 f761c060 c04140d0 00000047 f7179000 f531ad00 00000000 
       3edd2b3b 00000047 f761c060 000006ff 3edd55bf 00000047 f6a531b4 0014a786 
       f72aff1c f72aff64 f72aff44 c02dae9e f72aff1c 0014a786 f6a9a9c0 c0455b18 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
beep-media-pl S C04140A0     0  4012   3950          4044  4011 (NOTLB)
f6a59eac 00000082 f54faa40 c04140a0 00000010 c0339e8c 00000000 00000000 
       f6a59ec0 f6a59eac 00000246 00000118 3de0a45d 00000047 f54fab94 0014a7c4 
       f6a59ec0 00000008 f6a59ee8 c02dae9e f6a59ec0 0014a7c4 f8827e7b c0455d08 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
beep-media-pl S C04140A0     0  4044   3950                4012 (NOTLB)
f6a85f48 00000082 f6a4ba40 c04140a0 00000046 c04742b0 f1882c58 00000000 
       f6a85f5c f6a85f48 00000246 0000320d 3bdeb6a0 00000047 f6a4bb94 0014a80e 
       f6a85f5c 1ddca6a7 f6a85f84 c02dae9e f6a85f5c 0014a80e 00000000 f7603ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c011fbce>] sys_nanosleep+0xde/0x160
 [<c010309f>] syscall_call+0x7/0xb
xterm         S C04140A0     0  4011   3950  4013    4012  4002 (NOTLB)
f6a83eac 00000082 f6a38060 c04140a0 f534b000 00000000 f6a82000 00000000 
       f6a83ec0 f6a83eac 00000246 000006d2 27216ff4 00000047 f6a381b4 0014a8a2 
       f6a83ec0 00000005 f6a83ee8 c02dae9e f6a83ec0 0014a8a2 f534b00c f6a85f5c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4013   4011                     (NOTLB)
f6a6be70 00000082 f6a53a80 c0414548 00000041 0000001a ff12a44a 00000036 
       ac115d5e 00000041 f6a53a80 000001b3 ac1e7cc8 00000041 f6a38bd4 f534c000 
       7fffffff f536b8c0 f6a6beac c02daeed c02da712 f6a38060 c0414548 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c021b4f0>] read_chan+0x620/0x710
 [<c0215ae5>] tty_read+0xf5/0x120
 [<c0154f2f>] vfs_read+0xcf/0x170
 [<c015525b>] sys_read+0x4b/0x80
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4036   3999  4037               (NOTLB)
f563bf94 00000082 f5608060 c0414548 00000041 00010000 00000000 00000000 
       ac115fde 00000041 f5608060 000000be ac1e837d 00000041 f6a53bd4 f563a000 
       00000000 080c9a40 f563bfbc c010220d f563bfb0 bffff270 00000008 00010000 
Call Trace:
 [<c010220d>] sys_rt_sigsuspend+0xad/0xe0
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140A0     0  4037   4036                     (NOTLB)
f5639fb4 00000086 f5608060 c04140a0 0000000f 00000012 00000000 f5639fbc 
       c011f9db 00000000 f5639fac 00000397 b9ebf17d 00000046 f56081b4 00000000 
       00000012 00000000 f5639fbc c01237e7 f5638000 c010309f 00000000 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4038   3993  4039               (NOTLB)
f6a99f94 00000086 f5608a80 c0414548 00000041 00010000 00000000 00000000 
       ac116650 00000041 f5608a80 000000b6 ac1e943d 00000041 f56086c4 f6a98000 
       00000000 080c9a40 f6a99fbc c010220d f6a99fb0 bffff270 00000008 00010000 
Call Trace:
 [<c010220d>] sys_rt_sigsuspend+0xad/0xe0
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140D0     0  4039   4038                     (NOTLB)
f5637fb4 00000082 f6a4b020 c04140d0 00000046 00000012 00000000 f5637fbc 
       b9ebb1ef 00000046 f6a4b020 000004e6 b9ebb1ef 00000046 f5608bd4 00000000 
       00000012 00000000 f5637fbc c01237e7 f5636000 c010309f 00000000 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
zsh           S C0414548     0  4040   4001  4041               (NOTLB)
f6a81f94 00000082 f6a4b020 c0414548 00000041 00010000 00000000 00000000 
       ac116b9a 00000041 f6a4b020 000000ab ac1ea28d 00000041 f7267174 f6a80000 
       00000000 080c9a40 f6a81fbc c010220d f6a81fb0 bffff270 00000008 00010000 
Call Trace:
 [<c010220d>] sys_rt_sigsuspend+0xad/0xe0
 [<c010309f>] syscall_call+0x7/0xb
screen        S C04140D0     0  4041   4040                     (NOTLB)
f5635fb4 00000082 f5608060 c04140d0 00000046 00000012 00000000 f5635fbc 
       b9ebd126 00000046 f5608060 00000377 b9ebd126 00000046 f6a4b174 00000000 
       00000012 00000000 f5635fbc c01237e7 f5634000 c010309f 00000000 00000000 
Call Trace:
 [<c01237e7>] sys_pause+0x17/0x20
 [<c010309f>] syscall_call+0x7/0xb
gnome-keyring S C0414548     0  4043      1          4046  3992 (NOTLB)
f6a87f08 00000082 f6814530 c0414548 00000041 f1a9f000 f5a27d80 f6a87fa0 
       ac118597 00000041 f6814530 00000838 ac1ef68f 00000041 f6a536c4 00000000 
       7fffffff f6a87f64 f6a87f44 c02daeed c02808f9 f5a27d80 f6a9a3c0 f6a87fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
bonobo-activa S C0414548     0  4046      1          4048  4043 (NOTLB)
f684ff08 00000086 f6814020 c0414548 00000041 f1a9e000 f21b5f00 f684ffa0 
       ac11bfa5 00000041 f6814020 00001589 ac1fb863 00000041 f6814684 00000000 
       7fffffff f684ff64 f684ff44 c02daeed c02808f9 f21b5f00 f21b2940 f684ffa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-smproxy S C0414548     0  4048      1          4050  4046 (NOTLB)
f6741eac 00200086 f671f570 c0414548 00000041 c0339e8c 00000000 000000d0 
       ac11cc07 00000041 f671f570 00000454 ac1fdf5f 00000041 f6814174 00000000 
       7fffffff 0000000b f6741ee8 c02daeed 0000000a f6741ed0 f8827e7b f48a0700 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
gnome-setting S C04140D0     0  4050      1          4090  4048 (NOTLB)
f6765f08 00000086 f761c060 c04140d0 00000041 f1a9c000 f688d680 f6765fa0 
       ea9b5259 00000041 f761c060 00000520 ea9bfc36 00000041 f671f6c4 00000000 
       7fffffff f6765f64 f6765f44 c02daeed c02808f9 f688d680 f68ec7c0 f6765fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
xscreensaver  S C04140D0     0  4090      1          4114  4050 (NOTLB)
f6763eac 00000082 f761c060 c04140d0 00000046 c0339e8c 00000000 00000000 
       ec76a52d 00000046 f761c060 00000331 ec76b650 00000046 f671f1b4 0014a8ea 
       f6763ec0 00000005 f6763ee8 c02dae9e f6763ec0 0014a8ea f56059c0 f20dff1c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb
metacity      S C04140D0     0  4114      1          4122  4090 (NOTLB)
f63c7f08 00000086 f6814a40 c04140d0 00000041 f1a9a000 f6df3800 f63c7fa0 
       ea94d077 00000041 f6814a40 0000083a ea95f37d 00000041 f671fbd4 00000000 
       7fffffff f63c7f64 f63c7f44 c02daeed c02808f9 f6df3800 f6ccec40 f63c7fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-panel   S C04140D0     0  4122      1          4124  4114 (NOTLB)
f683df08 00000082 f6a53060 c04140d0 00000041 f1a89000 f21b59c0 f683dfa0 
       ea9b0e0d 00000041 f6a53060 00000b50 ea9b7344 00000041 f6814b94 00000000 
       7fffffff f683df64 f683df44 c02daeed c02808f9 f21b59c0 f21b21c0 f683dfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C04140D0     0  4124      1          4136  4122 (NOTLB)
f4d27f08 00000082 f671f570 c04140d0 00000041 f1a88000 f4a6eac0 f4d27fa0 
       ea9b0ea7 00000041 f671f570 000004ff ea9bce16 00000041 f6cad684 00000000 
       7fffffff f4d27f64 f4d27f44 c02daeed c02808f9 f4a6eac0 f63d1dc0 f4d27fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4136      1          4138  4124 (NOTLB)
f4421f08 00000082 f6cad020 c0414548 00000041 f1a87000 f45b8ec0 f4421fa0 
       ac127bd6 00000041 f6cad020 0000061b ac222219 00000041 f4cf46c4 00000000 
       7fffffff f4421f64 f4421f44 c02daeed c02808f9 f45b8ec0 f46829c0 f4421fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4142      1          4143  4139 (NOTLB)
f6c33e84 00000082 f4cf4060 c0414548 00000041 0000003b f6cad530 f6c33e74 
       ac12842d 00000041 f4cf4060 000002ec ac223c65 00000041 f6cad174 081c4b90 
       7fffffff fffffff5 f6c33ec0 c02daeed f767c280 081c4000 76796a33 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4143      1          4144  4142 (NOTLB)
f4d49e84 00000082 f479ca40 c0414548 00000041 f6cad530 f767c280 f4d49e74 
       ac1287a9 00000041 f479ca40 00000119 ac22464b 00000041 f4cf41b4 081c4e80 
       7fffffff fffffff5 f4d49ec0 c02daeed f767c280 081c4000 76796cc7 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4144      1          4146  4143 (NOTLB)
f4463e84 00000082 f479c530 c0414548 00000041 00000000 f4463f58 f4463e74 
       ac128b11 00000041 f479c530 00000113 ac224ff8 00000041 f479cb94 081c5170 
       7fffffff fffffff5 f4463ec0 c02daeed f767c280 081c5000 76796f49 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
nautilus      S C0414548     0  4147      1          4149  4146 (NOTLB)
f4147e84 00000082 f6cada40 c0414548 00000041 f6cad530 f767c280 f4147e74 
       ac128eb4 00000041 f6cada40 00000126 ac225a52 00000041 f479c684 08213928 
       7fffffff fffffff5 f4147ec0 c02daeed f767c280 08213000 76797212 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
gnome-vfs-dae S C0414548     0  4138      1          4139  4136 (NOTLB)
f4475f08 00000082 f4cf4a80 c0414548 00000041 f1a86000 f45b88c0 f4475fa0 
       ac12a1df 00000041 f4cf4a80 000006f7 ac229908 00000041 f6cadb94 00000000 
       7fffffff f4475f64 f4475f44 c02daeed c02808f9 f45b88c0 f46823c0 f4475fa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-vfs-dae S C0414548     0  4139      1          4142  4138 (NOTLB)
f4d4bf08 00000082 f479c020 c0414548 00000041 f1a85000 f45b8740 f4d4bfa0 
       ac12b2a3 00000041 f479c020 0000060e ac22cf8c 00000041 f4cf4bd4 00000000 
       7fffffff f4d4bf64 f4d4bf44 c02daeed c02808f9 f45b8740 f46820c0 f4d4bfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
mapping-daemo S C04140A0     0  4146      1          4147  4144 (NOTLB)
f4135f08 00000082 f479c020 c04140a0 00000246 f5935000 f41e4e40 00000000 
       f4135f1c f4135f08 00000246 000005b1 f50290b3 00000046 f479c174 0014adad 
       f4135f1c f4135f64 f4135f44 c02dae9e f4135f1c 0014adad f46a5c40 f1e2bec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
wnck-applet   S C04140D0     0  4149      1          4151  4147 (NOTLB)
f3e3df08 00000082 f4688060 c04140d0 00000041 f1a83000 f3f75d40 f3e3dfa0 
       ea950aed 00000041 f4688060 0000081e ea969208 00000041 f46886c4 00000000 
       7fffffff f3e3df64 f3e3df44 c02daeed c02808f9 f3f75d40 f3f63800 f3e3dfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gweather-appl S C04140D0     0  4151      1          4152  4149 (NOTLB)
f391ff08 00000086 f342d020 c04140d0 00000041 f1a82000 f39cc480 00000000 
       ea9528e5 00000041 f342d020 000008cc ea96ea03 00000041 f46881b4 002d5308 
       f391ff1c f391ff64 f391ff44 c02dae9e f391ff1c 002d5308 f3a31c40 c04562f8 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gweather-appl S C0414548     0  4152      1          4153  4151 (NOTLB)
f3e2be84 00000086 f342da40 c0414548 00000041 00000000 f6a407ac f3e2be74 
       ac130e57 00000041 f342da40 00000256 ac23fd14 00000041 f4688bd4 0819c320 
       7fffffff fffffff5 f3e2bec0 c02daeed f767c4c0 0819c000 7679a461 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
gweather-appl S C0414548     0  4153      1          4155  4152 (NOTLB)
f3461e84 00000086 f342d020 c0414548 00000041 f4688060 f767c4c0 f3461e74 
       ac1311e3 00000041 f342d020 00000120 ac240737 00000041 f342db94 0819c940 
       7fffffff fffffff5 f3461ec0 c02daeed f767c4c0 0819c000 7679aaa3 00000041 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c012bdda>] futex_wait+0x11a/0x150
 [<c012c0a2>] do_futex+0x42/0xa0
 [<c012c1f0>] sys_futex+0xf0/0x100
 [<c010309f>] syscall_call+0x7/0xb
battstat-appl S C04140A0     0  4155      1          4157  4153 (NOTLB)
f34c5f08 00000082 f342d020 c04140a0 00000246 f1ece000 f3567440 00000000 
       f34c5f1c f34c5f08 00000246 00000c62 1d236663 00000047 f342d174 0014a7fb 
       f34c5f1c f34c5f64 f34c5f44 c02dae9e f34c5f1c 0014a7fb f3039200 c0455ec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
clock-applet  S C04140A0     0  4157      1          4159  4155 (NOTLB)
f3077f08 00000082 f304fa80 c04140a0 00000047 f531d000 f314a580 00000000 
       f3077f1c f3077f08 00000246 000000d1 1941933f 00000047 f304fbd4 0014a7b9 
       f3077f1c f3077f64 f3077f44 c02dae9e f3077f1c 0014a7b9 f3164940 c0455cb0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
multiload-app S C04140A0     0  4159      1          4161  4157 (NOTLB)
f3399f08 00000086 f304f570 c04140a0 00000047 f775a000 f6a9c340 00000000 
       f3399f1c f3399f08 00000246 000000af 3dc60d94 00000047 f304f6c4 0014a7b2 
       f3399f1c f3399f64 f3399f44 c02dae9e f3399f1c 0014a7b2 f31bc200 c0455c78 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
notification- S C04140D0     0  4161      1          4164  4159 (NOTLB)
f2d6bf08 00000086 f2e8ba40 c04140d0 00000041 f1e06000 f2ddb280 f2d6bfa0 
       ea959d0e 00000041 f2e8ba40 000007d0 ea983de4 00000041 f304f1b4 00000000 
       7fffffff f2d6bf64 f2d6bf44 c02daeed c02808f9 f2ddb280 f2e4c940 f2d6bfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
netloc.py     S C04140D0     0  4164      1          4167  4161 (NOTLB)
f2eadf08 00000086 f304f570 c04140d0 00000047 f1e87000 f2ac86c0 00000000 
       3dbe5f56 00000047 f304f570 000007ea 3dbe5f56 00000047 f2e8bb94 0014a7b2 
       f2eadf1c f2eadf64 f2eadf44 c02dae9e f2eadf1c 0014a7b2 f65d9b40 f3399f1c 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
wireless-appl S C04140A0     0  4167      1          4169  4164 (NOTLB)
f246bf08 00000082 f2e8b530 c04140a0 00000246 f76f8000 f257e140 00000000 
       f246bf1c f246bf08 00000246 00001652 0b1dfa15 00000047 f2e8b684 0014a7e7 
       f246bf1c f246bf64 f246bf44 c02dae9e f246bf1c 0014a7e7 f25b5340 c0455e20 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
mini_commande S C04140D0     0  4169      1          4171  4167 (NOTLB)
f268df08 00000086 f20afa80 c04140d0 00000041 f1e23000 f2780640 f268dfa0 
       ea95eeb6 00000041 f20afa80 00000688 ea9923ad 00000041 f2e8b174 00000000 
       7fffffff f268df64 f268df44 c02daeed c02808f9 f2780640 f2650b40 f268dfa0 
Call Trace:
 [<c02daeed>] schedule_timeout+0xad/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
gnome-cpufreq S C04140A0     0  4171      1                4169 (NOTLB)
f20dff08 00000082 f20afa80 c04140a0 00000047 f63d5000 f21b5a80 00000000 
       f20dff1c f20dff08 00000246 000000ac 200b5874 00000047 f20afbd4 0014a82b 
       f20dff1c f20dff64 f20dff44 c02dae9e f20dff1c 0014a82b f21b2340 f522dec0 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c0169199>] do_poll+0xa9/0xd0
 [<c016930d>] sys_poll+0x14d/0x230
 [<c010309f>] syscall_call+0x7/0xb
ipw2200/0     S C04140A0     0  4473      9                 849 (L-TLB)
f71c5f3c 00000046 f1e94a40 c04140a0 00000046 00000000 f71c4000 00000082 
       f71c5f3c 00000082 f1c8b518 000000cf 108c4b89 00000047 f1e94b94 f71c5f90 
       f71c4000 f1c8b510 f71c5fbc c0126bb5 00000000 f71c5f70 00000000 f1c8b518 
Call Trace:
 [<c0126bb5>] worker_thread+0x275/0x2a0
 [<c012ad0a>] kthread+0xba/0xc0
 [<c0101325>] kernel_thread_helper+0x5/0x10
top           S C04140D0     0  4568   3812                     (NOTLB)
f1e2beac 00000086 f6a53060 c04140d0 00000047 00000000 f1e2a000 00000000 
       102909d2 00000047 f6a53060 00019562 102909d2 00000047 f1e94174 0014ad29 
       f1e2bec0 00000001 f1e2bee8 c02dae9e f1e2bec0 0014ad29 c1bfb00c c0456050 
Call Trace:
 [<c02dae9e>] schedule_timeout+0x5e/0xb0
 [<c01689e2>] do_select+0x162/0x2c0
 [<c0168e3e>] sys_select+0x2ae/0x4c0
 [<c010309f>] syscall_call+0x7/0xb

--GvXjxJ+pjyke8COw--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
