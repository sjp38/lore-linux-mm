Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D2D8600044
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 15:51:05 -0400 (EDT)
Received: by iwn33 with SMTP id 33so3512413iwn.14
        for <linux-mm@kvack.org>; Sun, 22 Aug 2010 12:51:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.1008220842400.8562@uplift.swm.pp.se>
References: <4C70BFF3.8030507@hardwarefreak.com>
	<alpine.DEB.1.10.1008220842400.8562@uplift.swm.pp.se>
Date: Sun, 22 Aug 2010 22:51:02 +0300
Message-ID: <AANLkTin48SJ58HvFqjrOnQBMqLcbECtqXokweV00dNgv@mail.gmail.com>
Subject: Re: 2.6.34.1 page allocation failure
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Cc: Stan Hoeppner <stan@hardwarefreak.com>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 22, 2010 at 9:47 AM, Mikael Abrahamsson <swmike@swm.pp.se> wrot=
e:
> On Sun, 22 Aug 2010, Stan Hoeppner wrote:
>
>> I'm not subscribed to lkml so please CC me in replies. =A0First post.
>
> I'm seeing similar problems on older kernels (.24 up to .32).
>
> <http://www.spinics.net/lists/linux-mm/msg07808.html>
>
> I didn't get any response at all, neither on linux-mm or lkml... Our
> problems seem very similar, but I'm running 64bit and I have 8 gigs of ra=
m.
>
> Personally I can avoid this by tuning down my TCP settings so TCP uses le=
ss
> memory, but I don't think that workaround is very good, this shouldn't
> happen. My machine also freezes up (pressing caps lock doesn't work)
> sometimes, sometimes it just logs the error.
>
>> Mobo: =A0 =A0Abit BP6, dual Celeron 366@500, i440BX chipset, 384MB PC100
>> Disk: =A0 =A0SiI 3512 PCI (sata_sil, libata), 1 x WD5000AAKS 500 GB SATA=
II
>> Kernel: =A0vanilla 2.6.34.1, 32 bit x86, SMP, Celeron pre Coppermine
>> OS: =A0 =A0 =A0Debian 5.0.5 (Stable)
>> Build: =A0 kernel configured via make menuconfig
>> =A0 =A0 =A0 =A0no modules, no initrd
>> =A0 =A0 =A0 =A0built via "make KDEB_PKGVERSION=3D"
>> =A0 =A0 =A0 =A0installed via dpkg, bootloader is LILO
>> Role: =A0 =A0headless SOHO server, run level 2, _very_ light load
>> =A0 =A0 =A0 =A0Postfix, pdns-recursor, Dovecot, Lighttpd, Roundcube, Sam=
ba
>> =A0 =A0 =A0 =A0bulk of system memory (>300MB) is consumed by buffers/cac=
he
>> Issue: =A0 AFAIK, these errors never occurred with any revisions of
>> =A0 =A0 =A0 =A02.6.26, .31, or .32. =A0After installing 2.6.34.1 I've no=
ticed
>> =A0 =A0 =A0 =A0the following errors in dmesg. =A0I see 6 of these, inclu=
ding
>> =A0 =A0 =A0 =A0two errors each for kswapd0, lighttpd, and smtpd, all not
>> =A0 =A0 =A0 =A0tainted. =A0AFAICT everything is still running fine. =A0A=
re these
>> =A0 =A0 =A0 =A0critical errors? =A0If so, how do I fix?
>>
>> kswapd0: page allocation failure. order:1, mode:0x20
>> Pid: 139, comm: kswapd0 Not tainted 2.6.34.1 #1
>> Call Trace:
>> [<c104b6b3>] ? __alloc_pages_nodemask+0x448/0x48a
>> [<c1062ffb>] ? cache_alloc_refill+0x22f/0x422
>> [<c11a9a73>] ? tcp_v4_send_check+0x6e/0xa4
>> [<c10632c3>] ? kmem_cache_alloc+0x41/0x6a
>> [<c11773a5>] ? sk_prot_alloc+0x19/0x55
>> [<c117744b>] ? sk_clone+0x16/0x1cc
>> [<c119a71d>] ? inet_csk_clone+0xf/0x80
>> [<c11ac0e3>] ? tcp_create_openreq_child+0x1a/0x3c8
>> [<c11aaf0a>] ? tcp_v4_syn_recv_sock+0x4b/0x151
>> [<c11abf9d>] ? tcp_check_req+0x209/0x335
>> [<c11aa892>] ? tcp_v4_do_rcv+0x8d/0x14d
>> [<c11aacd5>] ? tcp_v4_rcv+0x383/0x56d
>> [<c1193ba4>] ? ip_local_deliver+0x76/0xc0
>> [<c1193b10>] ? ip_rcv+0x3dc/0x3fa
>> [<c103655e>] ? ktime_get_real+0xf/0x2b
>> [<c117f8d3>] ? netif_receive_skb+0x219/0x234
>> [<c115ff46>] ? e100_poll+0x1d0/0x47e
>> [<c117fa98>] ? net_rx_action+0x58/0xf8
>> [<c102539c>] ? __do_softirq+0x78/0xe5
>> [<c102542c>] ? do_softirq+0x23/0x27
>> [<c1003955>] ? do_IRQ+0x7d/0x8e
>> [<c1002aa9>] ? common_interrupt+0x29/0x30
>> [<c1062870>] ? kmem_cache_free+0xbd/0xc5
>> [<c10fa7d1>] ? __xfs_inode_set_reclaim_tag+0x29/0x2f
>> [<c1075215>] ? destroy_inode+0x1c/0x2b
>> [<c10752ce>] ? dispose_list+0xaa/0xd0
>> [<c107548c>] ? shrink_icache_memory+0x198/0x1c5
>> [<c104f76b>] ? shrink_slab+0xda/0x12f
>> [<c104fc28>] ? kswapd+0x468/0x63b
>> [<c104dca3>] ? isolate_pages_global+0x0/0x1bc
>> [<c10304d6>] ? autoremove_wake_function+0x0/0x2d
>> [<c1018faf>] ? complete+0x28/0x36
>> [<c104f7c0>] ? kswapd+0x0/0x63b
>> [<c10301cd>] ? kthread+0x61/0x66
>> [<c103016c>] ? kthread+0x0/0x66
>> [<c1002ab6>] ? kernel_thread_helper+0x6/0x10
>> Mem-Info:
>> DMA per-cpu:
>> CPU =A0 =A00: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
>> CPU =A0 =A01: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
>> Normal per-cpu:
>> CPU =A0 =A00: hi: =A0186, btch: =A031 usd: 180
>> CPU =A0 =A01: hi: =A0186, btch: =A031 usd: =A029
>> active_anon:646 inactive_anon:4337 isolated_anon:0
>> active_file:27189 inactive_file:35957 isolated_file:0
>> unevictable:0 dirty:56 writeback:0 unstable:0
>> free:1142 slab_reclaimable:25495 slab_unreclaimable:1020
>> mapped:3116 shmem:143 pagetables:123 bounce:0
>> DMA free:1568kB min:100kB low:124kB high:148kB active_anon:0kB
>> inactive_anon:4kB active_file:5704kB inactive_file:7732kB
>> unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB
>> mlocked:0kB dirty:0kB writeback:0kB mapped:28kB shmem:0kB
>> slab_reclaimable:912kB slab_unreclaimable:52kB kernel_stack:0kB
>> pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
>> all_unreclaimable? no
>> lowmem_reserve[]: 0 365 365
>> Normal free:3000kB min:2392kB low:2988kB high:3588kB active_anon:2584kB
>> inactive_anon:17344kB active_file:103052kB inactive_file:136096kB
>> unevictable:0kB isolated(anon):0kB isolated(file):0kB present:373888kB
>> mlocked:0kB dirty:224kB writeback:0kB mapped:12436kB shmem:572kB
>> slab_reclaimable:101068kB slab_unreclaimable:4028kB kernel_stack:520kB
>> pagetables:492kB unstable:0kB bounce:0kB writeback_tmp:0kB
>> pages_scanned:0 all_unreclaimable? no
>> lowmem_reserve[]: 0 0 0
>> DMA: 391*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB
>> 0*2048kB 0*4096kB =3D 1564kB
>> Normal: 750*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
>> 0*1024kB 0*2048kB 0*4096kB =3D 3000kB
>> 63342 total pagecache pages
>> 23 pages in swap cache
>> Swap cache stats: add 159, delete 136, find 401/412
>> Free swap =A0=3D 995636kB
>> Total swap =3D 995992kB
>> 98303 pages RAM
>> 1638 pages reserved
>> 22416 pages shared
>> 76947 pages non-shared

In Stan's case, it's a order-1 GFP_ATOMIC allocation but there are
only order-0 pages available. Mel, any recent page allocator fixes in
2.6.35 or 2.6.36-rc1 that Stan/Mikael should test?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
