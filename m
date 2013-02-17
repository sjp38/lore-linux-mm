Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 53C746B0002
	for <linux-mm@kvack.org>; Sun, 17 Feb 2013 13:48:02 -0500 (EST)
Received: by mail-ve0-f180.google.com with SMTP id jx10so4229178veb.39
        for <linux-mm@kvack.org>; Sun, 17 Feb 2013 10:48:01 -0800 (PST)
MIME-Version: 1.0
Date: Sun, 17 Feb 2013 20:48:01 +0200
Message-ID: <CAO7ehpmVg=VaUe0+YAkZS4om0Fc=gS1KPmg2Sx45kR=RcKxJ_w@mail.gmail.com>
Subject: Debian Squeeze Kernel 3.2 - Warnings!
From: Maroon Ibrahim <maroon.ibrahim@gmail.com>
Content-Type: multipart/alternative; boundary=bcaec51969733fc2e804d5f00c94
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--bcaec51969733fc2e804d5f00c94
Content-Type: text/plain; charset=ISO-8859-1

Dear Sirs,

Please advise on the below...

[254456.054327] The scan_unevictable_pages sysctl/node-interface has been
disabled for lack of a legitimate use case.  If you have one, please send
an email to linux-mm@kvack.org.
[254456.073235] process `sysctl' is using deprecated sysctl (syscall)
net.ipv6.neigh.default.retrans_time; Use
net.ipv6.neigh.default.retrans_time_ms instead.
[256403.747138] swapper/0: page allocation failure: order:1, mode:0x20
[256403.747142] Pid: 0, comm: swapper/0 Not tainted 3.2.0-0.bpo.1-amd64 #1
[256403.747144] Call Trace:
[256403.747146]  <IRQ>  [<ffffffff810c1533>] ? warn_alloc_failed+0x10a/0x11d
[256403.747157]  [<ffffffff810c3407>] ? __alloc_pages_nodemask+0x6a6/0x731
[256403.747161]  [<ffffffff81097ab3>] ? handle_irq_event+0x40/0x55
[256403.747165]  [<ffffffff810f4f82>] ? kmem_getpages+0x4b/0x107
[256403.747168]  [<ffffffff810f6402>] ? fallback_alloc+0x146/0x1e1
[256403.747171]  [<ffffffff810f6bb3>] ? kmem_cache_alloc+0x7f/0xf0
[256403.747175]  [<ffffffff8129191a>] ? sk_prot_alloc+0x2b/0x125
[256403.747178]  [<ffffffff81291ae6>] ? sk_clone+0x14/0x2b2
[256403.747182]  [<ffffffff812cdedb>] ? inet_csk_clone+0x10/0x8f
[256403.747187]  [<ffffffff812e2a88>] ? tcp_create_openreq_child+0x21/0x44f
[256403.747190]  [<ffffffff812e1302>] ? tcp_v4_syn_recv_sock+0x32/0x270
[256403.747193]  [<ffffffff812e2932>] ? tcp_check_req+0x21f/0x354
[256403.747198]  [<ffffffffa02a559b>] ? nf_nat_packet+0x93/0xb2 [nf_nat]
[256403.747201]  [<ffffffff812e0dc5>] ? tcp_v4_do_rcv+0x256/0x3eb
[256403.747204]  [<ffffffff812e2349>] ? tcp_v4_rcv+0x447/0x6ee
[256403.747207]  [<ffffffff812bf68a>] ? nf_hook_slow+0x68/0xfd
[256403.747210]  [<ffffffff812c58f5>] ? T.1030+0x4f/0x4f
[256403.747213]  [<ffffffff812c5a32>] ? ip_local_deliver_finish+0x13d/0x1aa
[256403.747216]  [<ffffffff8129a770>] ? __netif_receive_skb+0x44c/0x490
[256403.747219]  [<ffffffff8129f16b>] ? netif_receive_skb+0x67/0x6d
[256403.747222]  [<ffffffff8129f66e>] ? napi_gro_receive+0x1f/0x2c
[256403.747225]  [<ffffffff8129f240>] ? napi_skb_finish+0x1c/0x31
[256403.747245]  [<ffffffffa007b9ca>] ? e1000_clean_rx_irq+0x1ea/0x29a
[e1000e]
[256403.747252]  [<ffffffffa007be84>] ? e1000_clean+0x71/0x229 [e1000e]
[256403.747259]  [<ffffffffa007bad1>] ? e1000_put_txbuf+0x57/0x69 [e1000e]
[256403.747262]  [<ffffffff8129f799>] ? net_rx_action+0xa8/0x207
[256403.747266]  [<ffffffff8106636a>] ? hrtimer_get_next_event+0x7f/0x9a
[256403.747270]  [<ffffffff8104f13a>] ? __do_softirq+0xc4/0x1a0
[256403.747272]  [<ffffffff81097a55>] ? handle_irq_event_percpu+0x166/0x184
[256403.747275]  [<ffffffff81013976>] ? read_tsc+0x5/0x16
[256403.747278]  [<ffffffff8136292c>] ? call_softirq+0x1c/0x30
[256403.747282]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[256403.747285]  [<ffffffff8104ef0a>] ? irq_exit+0x44/0xb5
[256403.747288]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[256403.747291]  [<ffffffff8135b3ee>] ? common_interrupt+0x6e/0x6e
[256403.747293]  <EOI>  [<ffffffff8102c8ec>] ? native_safe_halt+0x2/0x3
[256403.747298]  [<ffffffff8101507c>] ? default_idle+0x4b/0x84
[256403.747301]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[256403.747304]  [<ffffffff816aac3b>] ? start_kernel+0x3cc/0x3d7
[256403.747308]  [<ffffffff816aa3c8>] ? x86_64_start_kernel+0x102/0x10f
[256403.747310] Mem-Info:
[256403.747311] Node 0 DMA per-cpu:
[256403.747314] CPU    0: hi:    0, btch:   1 usd:   0
[256403.747316] CPU    1: hi:    0, btch:   1 usd:   0
[256403.747318] CPU    2: hi:    0, btch:   1 usd:   0
[256403.747319] CPU    3: hi:    0, btch:   1 usd:   0
[256403.747321] Node 0 DMA32 per-cpu:
[256403.747323] CPU    0: hi:  186, btch:  31 usd: 180
[256403.747325] CPU    1: hi:  186, btch:  31 usd: 172
[256403.747327] CPU    2: hi:  186, btch:  31 usd:  91
[256403.747329] CPU    3: hi:  186, btch:  31 usd: 112
[256403.747330] Node 0 Normal per-cpu:
[256403.747332] CPU    0: hi:  186, btch:  31 usd:  91
[256403.747333] CPU    1: hi:  186, btch:  31 usd:  42
[256403.747335] CPU    2: hi:  186, btch:  31 usd:  45
[256403.747337] CPU    3: hi:  186, btch:  31 usd: 161
[256403.747338] Node 1 Normal per-cpu:
[256403.747340] CPU    0: hi:  186, btch:  31 usd: 129
[256403.747342] CPU    1: hi:  186, btch:  31 usd: 110
[256403.747343] CPU    2: hi:  186, btch:  31 usd: 156
[256403.747345] CPU    3: hi:  186, btch:  31 usd:  60
[256403.747349] active_anon:2065981 inactive_anon:86225 isolated_anon:0
[256403.747350]  active_file:14710531 inactive_file:14759104 isolated_file:0
[256403.747351]  unevictable:0 dirty:67339 writeback:900 unstable:0
[256403.747352]  free:99046 slab_reclaimable:949775
slab_unreclaimable:276875
[256403.747353]  mapped:1848 shmem:125 pagetables:5000 bounce:0
[256403.747355] Node 0 DMA free:15896kB min:8kB low:8kB high:12kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15672kB
mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB
slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? yes
[256403.747363] lowmem_reserve[]: 0 3510 64615 64615
[256403.747366] Node 0 DMA32 free:247372kB min:2444kB low:3052kB
high:3664kB active_anon:33924kB inactive_anon:7552kB active_file:1407944kB
inactive_file:1418896kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:3595104kB mlocked:0kB dirty:10688kB
writeback:76kB mapped:88kB shmem:0kB slab_reclaimable:314152kB
slab_unreclaimable:138996kB kernel_stack:24kB pagetables:96kB unstable:0kB
bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[256403.747375] lowmem_reserve[]: 0 0 61105 61105
[256403.747378] Node 0 Normal free:53328kB min:42592kB low:53240kB
high:63888kB active_anon:3971028kB inactive_anon:165892kB
active_file:27779672kB inactive_file:27925188kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:62571520kB mlocked:0kB
dirty:137712kB writeback:1792kB mapped:3028kB shmem:120kB
slab_reclaimable:1454056kB slab_unreclaimable:905336kB kernel_stack:432kB
pagetables:9020kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
[256403.747387] lowmem_reserve[]: 0 0 0 0
[256403.747389] Node 1 Normal free:79836kB min:45056kB low:56320kB
high:67584kB active_anon:4258972kB inactive_anon:171456kB
active_file:29654508kB inactive_file:29692072kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:66191360kB mlocked:0kB
dirty:120956kB writeback:1732kB mapped:4276kB shmem:380kB
slab_reclaimable:2030892kB slab_unreclaimable:63168kB kernel_stack:1784kB
pagetables:10884kB unstable:0kB bounce:0kB writeback_tmp:0kB
pages_scanned:32 all_unreclaimable? no
[256403.747398] lowmem_reserve[]: 0 0 0 0
[256403.747401] Node 0 DMA: 0*4kB 1*8kB 1*16kB 0*32kB 2*64kB 1*128kB
1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15896kB
[256403.747408] Node 0 DMA32: 61830*4kB 22*8kB 0*16kB 0*32kB 0*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 247496kB
[256403.747415] Node 0 Normal: 12305*4kB 17*8kB 0*16kB 0*32kB 0*64kB
0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 53452kB
[256403.747421] Node 1 Normal: 18814*4kB 76*8kB 0*16kB 0*32kB 0*64kB
0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 79960kB
[256403.747428] 29469668 total pagecache pages
[256403.747430] 0 pages in swap cache
[256403.747432] Swap cache stats: add 0, delete 0, find 0/0
[256403.747433] Free swap  = 19786748kB
[256403.747434] Total swap = 19786748kB
[256403.750932] 33554416 pages RAM
[256403.750932] 478273 pages reserved
[256403.750932] 15741908 pages shared
[256403.750932] 17226574 pages non-shared
root@debian:/#


-- 
*Maroon IBRAHIM*

*E-mail:* maroon.ibrahim@gmail.com
*Mobile:* +961-3-709273
*Whatsapp:* +961-3-709273
*BB Pin:* 28192F0B
*MSN:* maroon_ibrahim@hotmail.com
*SKYPE:* maroon.ibrahim
*Beirut - Lebanon*
*
*

--bcaec51969733fc2e804d5f00c94
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Dear Sirs,<div><br></div><div>Please advise on the below..=
.</div><div><br></div><div><div>[254456.054327] The scan_unevictable_pages =
sysctl/node-interface has been disabled for lack of a legitimate use case. =
=A0If you have one, please send an email to <a href=3D"mailto:linux-mm@kvac=
k.org">linux-mm@kvack.org</a>.</div>
<div>[254456.073235] process `sysctl&#39; is using deprecated sysctl (sysca=
ll) net.ipv6.neigh.default.retrans_time; Use net.ipv6.neigh.default.retrans=
_time_ms instead.</div><div>[256403.747138] swapper/0: page allocation fail=
ure: order:1, mode:0x20</div>
<div>[256403.747142] Pid: 0, comm: swapper/0 Not tainted 3.2.0-0.bpo.1-amd6=
4 #1</div><div>[256403.747144] Call Trace:</div><div>[256403.747146] =A0&lt=
;IRQ&gt; =A0[&lt;ffffffff810c1533&gt;] ? warn_alloc_failed+0x10a/0x11d</div=
>
<div>[256403.747157] =A0[&lt;ffffffff810c3407&gt;] ? __alloc_pages_nodemask=
+0x6a6/0x731</div><div>[256403.747161] =A0[&lt;ffffffff81097ab3&gt;] ? hand=
le_irq_event+0x40/0x55</div><div>[256403.747165] =A0[&lt;ffffffff810f4f82&g=
t;] ? kmem_getpages+0x4b/0x107</div>
<div>[256403.747168] =A0[&lt;ffffffff810f6402&gt;] ? fallback_alloc+0x146/0=
x1e1</div><div>[256403.747171] =A0[&lt;ffffffff810f6bb3&gt;] ? kmem_cache_a=
lloc+0x7f/0xf0</div><div>[256403.747175] =A0[&lt;ffffffff8129191a&gt;] ? sk=
_prot_alloc+0x2b/0x125</div>
<div>[256403.747178] =A0[&lt;ffffffff81291ae6&gt;] ? sk_clone+0x14/0x2b2</d=
iv><div>[256403.747182] =A0[&lt;ffffffff812cdedb&gt;] ? inet_csk_clone+0x10=
/0x8f</div><div>[256403.747187] =A0[&lt;ffffffff812e2a88&gt;] ? tcp_create_=
openreq_child+0x21/0x44f</div>
<div>[256403.747190] =A0[&lt;ffffffff812e1302&gt;] ? tcp_v4_syn_recv_sock+0=
x32/0x270</div><div>[256403.747193] =A0[&lt;ffffffff812e2932&gt;] ? tcp_che=
ck_req+0x21f/0x354</div><div>[256403.747198] =A0[&lt;ffffffffa02a559b&gt;] =
? nf_nat_packet+0x93/0xb2 [nf_nat]</div>
<div>[256403.747201] =A0[&lt;ffffffff812e0dc5&gt;] ? tcp_v4_do_rcv+0x256/0x=
3eb</div><div>[256403.747204] =A0[&lt;ffffffff812e2349&gt;] ? tcp_v4_rcv+0x=
447/0x6ee</div><div>[256403.747207] =A0[&lt;ffffffff812bf68a&gt;] ? nf_hook=
_slow+0x68/0xfd</div>
<div>[256403.747210] =A0[&lt;ffffffff812c58f5&gt;] ? T.1030+0x4f/0x4f</div>=
<div>[256403.747213] =A0[&lt;ffffffff812c5a32&gt;] ? ip_local_deliver_finis=
h+0x13d/0x1aa</div><div>[256403.747216] =A0[&lt;ffffffff8129a770&gt;] ? __n=
etif_receive_skb+0x44c/0x490</div>
<div>[256403.747219] =A0[&lt;ffffffff8129f16b&gt;] ? netif_receive_skb+0x67=
/0x6d</div><div>[256403.747222] =A0[&lt;ffffffff8129f66e&gt;] ? napi_gro_re=
ceive+0x1f/0x2c</div><div>[256403.747225] =A0[&lt;ffffffff8129f240&gt;] ? n=
api_skb_finish+0x1c/0x31</div>
<div>[256403.747245] =A0[&lt;ffffffffa007b9ca&gt;] ? e1000_clean_rx_irq+0x1=
ea/0x29a [e1000e]</div><div>[256403.747252] =A0[&lt;ffffffffa007be84&gt;] ?=
 e1000_clean+0x71/0x229 [e1000e]</div><div>[256403.747259] =A0[&lt;ffffffff=
a007bad1&gt;] ? e1000_put_txbuf+0x57/0x69 [e1000e]</div>
<div>[256403.747262] =A0[&lt;ffffffff8129f799&gt;] ? net_rx_action+0xa8/0x2=
07</div><div>[256403.747266] =A0[&lt;ffffffff8106636a&gt;] ? hrtimer_get_ne=
xt_event+0x7f/0x9a</div><div>[256403.747270] =A0[&lt;ffffffff8104f13a&gt;] =
? __do_softirq+0xc4/0x1a0</div>
<div>[256403.747272] =A0[&lt;ffffffff81097a55&gt;] ? handle_irq_event_percp=
u+0x166/0x184</div><div>[256403.747275] =A0[&lt;ffffffff81013976&gt;] ? rea=
d_tsc+0x5/0x16</div><div>[256403.747278] =A0[&lt;ffffffff8136292c&gt;] ? ca=
ll_softirq+0x1c/0x30</div>
<div>[256403.747282] =A0[&lt;ffffffff8100f9f7&gt;] ? do_softirq+0x3f/0x79</=
div><div>[256403.747285] =A0[&lt;ffffffff8104ef0a&gt;] ? irq_exit+0x44/0xb5=
</div><div>[256403.747288] =A0[&lt;ffffffff8100f342&gt;] ? do_IRQ+0x94/0xaa=
</div>
<div>[256403.747291] =A0[&lt;ffffffff8135b3ee&gt;] ? common_interrupt+0x6e/=
0x6e</div><div>[256403.747293] =A0&lt;EOI&gt; =A0[&lt;ffffffff8102c8ec&gt;]=
 ? native_safe_halt+0x2/0x3</div><div>[256403.747298] =A0[&lt;ffffffff81015=
07c&gt;] ? default_idle+0x4b/0x84</div>
<div>[256403.747301] =A0[&lt;ffffffff8100ddcb&gt;] ? cpu_idle+0xb9/0xef</di=
v><div>[256403.747304] =A0[&lt;ffffffff816aac3b&gt;] ? start_kernel+0x3cc/0=
x3d7</div><div>[256403.747308] =A0[&lt;ffffffff816aa3c8&gt;] ? x86_64_start=
_kernel+0x102/0x10f</div>
<div>[256403.747310] Mem-Info:</div><div>[256403.747311] Node 0 DMA per-cpu=
:</div><div>[256403.747314] CPU =A0 =A00: hi: =A0 =A00, btch: =A0 1 usd: =
=A0 0</div><div>[256403.747316] CPU =A0 =A01: hi: =A0 =A00, btch: =A0 1 usd=
: =A0 0</div><div>[256403.747318] CPU =A0 =A02: hi: =A0 =A00, btch: =A0 1 u=
sd: =A0 0</div>
<div>[256403.747319] CPU =A0 =A03: hi: =A0 =A00, btch: =A0 1 usd: =A0 0</di=
v><div>[256403.747321] Node 0 DMA32 per-cpu:</div><div>[256403.747323] CPU =
=A0 =A00: hi: =A0186, btch: =A031 usd: 180</div><div>[256403.747325] CPU =
=A0 =A01: hi: =A0186, btch: =A031 usd: 172</div>
<div>[256403.747327] CPU =A0 =A02: hi: =A0186, btch: =A031 usd: =A091</div>=
<div>[256403.747329] CPU =A0 =A03: hi: =A0186, btch: =A031 usd: 112</div><d=
iv>[256403.747330] Node 0 Normal per-cpu:</div><div>[256403.747332] CPU =A0=
 =A00: hi: =A0186, btch: =A031 usd: =A091</div>
<div>[256403.747333] CPU =A0 =A01: hi: =A0186, btch: =A031 usd: =A042</div>=
<div>[256403.747335] CPU =A0 =A02: hi: =A0186, btch: =A031 usd: =A045</div>=
<div>[256403.747337] CPU =A0 =A03: hi: =A0186, btch: =A031 usd: 161</div><d=
iv>[256403.747338] Node 1 Normal per-cpu:</div>
<div>[256403.747340] CPU =A0 =A00: hi: =A0186, btch: =A031 usd: 129</div><d=
iv>[256403.747342] CPU =A0 =A01: hi: =A0186, btch: =A031 usd: 110</div><div=
>[256403.747343] CPU =A0 =A02: hi: =A0186, btch: =A031 usd: 156</div><div>[=
256403.747345] CPU =A0 =A03: hi: =A0186, btch: =A031 usd: =A060</div>
<div>[256403.747349] active_anon:2065981 inactive_anon:86225 isolated_anon:=
0</div><div>[256403.747350] =A0active_file:14710531 inactive_file:14759104 =
isolated_file:0</div><div>[256403.747351] =A0unevictable:0 dirty:67339 writ=
eback:900 unstable:0</div>
<div>[256403.747352] =A0free:99046 slab_reclaimable:949775 slab_unreclaimab=
le:276875</div><div>[256403.747353] =A0mapped:1848 shmem:125 pagetables:500=
0 bounce:0</div><div>[256403.747355] Node 0 DMA free:15896kB min:8kB low:8k=
B high:12kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file=
:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15672kB =
mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0=
kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB boun=
ce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes</div>
<div>[256403.747363] lowmem_reserve[]: 0 3510 64615 64615</div><div>[256403=
.747366] Node 0 DMA32 free:247372kB min:2444kB low:3052kB high:3664kB activ=
e_anon:33924kB inactive_anon:7552kB active_file:1407944kB inactive_file:141=
8896kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:359510=
4kB mlocked:0kB dirty:10688kB writeback:76kB mapped:88kB shmem:0kB slab_rec=
laimable:314152kB slab_unreclaimable:138996kB kernel_stack:24kB pagetables:=
96kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclai=
mable? no</div>
<div>[256403.747375] lowmem_reserve[]: 0 0 61105 61105</div><div>[256403.74=
7378] Node 0 Normal free:53328kB min:42592kB low:53240kB high:63888kB activ=
e_anon:3971028kB inactive_anon:165892kB active_file:27779672kB inactive_fil=
e:27925188kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:=
62571520kB mlocked:0kB dirty:137712kB writeback:1792kB mapped:3028kB shmem:=
120kB slab_reclaimable:1454056kB slab_unreclaimable:905336kB kernel_stack:4=
32kB pagetables:9020kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scan=
ned:0 all_unreclaimable? no</div>
<div>[256403.747387] lowmem_reserve[]: 0 0 0 0</div><div>[256403.747389] No=
de 1 Normal free:79836kB min:45056kB low:56320kB high:67584kB active_anon:4=
258972kB inactive_anon:171456kB active_file:29654508kB inactive_file:296920=
72kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:66191360=
kB mlocked:0kB dirty:120956kB writeback:1732kB mapped:4276kB shmem:380kB sl=
ab_reclaimable:2030892kB slab_unreclaimable:63168kB kernel_stack:1784kB pag=
etables:10884kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:32 =
all_unreclaimable? no</div>
<div>[256403.747398] lowmem_reserve[]: 0 0 0 0</div><div>[256403.747401] No=
de 0 DMA: 0*4kB 1*8kB 1*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB=
 1*2048kB 3*4096kB =3D 15896kB</div><div>[256403.747408] Node 0 DMA32: 6183=
0*4kB 22*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB=
 0*4096kB =3D 247496kB</div>
<div>[256403.747415] Node 0 Normal: 12305*4kB 17*8kB 0*16kB 0*32kB 0*64kB 0=
*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB =3D 53452kB</div><div>[25=
6403.747421] Node 1 Normal: 18814*4kB 76*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0=
*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB =3D 79960kB</div>
<div>[256403.747428] 29469668 total pagecache pages</div><div>[256403.74743=
0] 0 pages in swap cache</div><div>[256403.747432] Swap cache stats: add 0,=
 delete 0, find 0/0</div><div>[256403.747433] Free swap =A0=3D 19786748kB</=
div>
<div>[256403.747434] Total swap =3D 19786748kB</div><div>[256403.750932] 33=
554416 pages RAM</div><div>[256403.750932] 478273 pages reserved</div><div>=
[256403.750932] 15741908 pages shared</div><div>[256403.750932] 17226574 pa=
ges non-shared</div>
<div>root@debian:/#</div><div><br></div><div><br></div>-- <br><div dir=3D"l=
tr"><font color=3D"#0b5394" face=3D"courier new, monospace"><b>Maroon IBRAH=
IM</b></font><div><font color=3D"#0b5394" face=3D"courier new, monospace"><=
br></font></div>
<div><font color=3D"#0b5394" face=3D"courier new, monospace"><b>E-mail:</b>=
 <a href=3D"mailto:maroon.ibrahim@gmail.com" target=3D"_blank">maroon.ibrah=
im@gmail.com</a></font></div><div><font color=3D"#0b5394" face=3D"courier n=
ew, monospace"><b>Mobile:</b> +961-3-709273</font></div>
<div><font face=3D"courier new, monospace"><font color=3D"#0b5394"><b>Whats=
app:</b>=A0</font><span style=3D"color:rgb(11,83,148)">+961-3-709273</span>=
</font></div><div><span style=3D"color:rgb(11,83,148)"><font face=3D"courie=
r new, monospace"><b>BB Pin:</b>=A028192F0B</font></span></div>
<div><font color=3D"#0b5394" face=3D"courier new, monospace"><b>MSN:</b> <a=
 href=3D"mailto:maroon_ibrahim@hotmail.com" target=3D"_blank">maroon_ibrahi=
m@hotmail.com</a></font></div><div><font color=3D"#0b5394" face=3D"courier =
new, monospace"><b>SKYPE:</b> maroon.ibrahim</font></div>
<div><span style=3D"color:rgb(11,83,148)"><b><font face=3D"courier new, mon=
ospace">Beirut - Lebanon</font></b></span></div><div><font color=3D"#0b5394=
" face=3D"verdana, sans-serif"><b><br></b></font><div><br></div></div></div=
>
</div></div>

--bcaec51969733fc2e804d5f00c94--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
