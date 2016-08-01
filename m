Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8EA6B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 05:08:27 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v184so240790006qkc.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 02:08:27 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id u32si19448105qtb.52.2016.08.01.02.08.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 02:08:26 -0700 (PDT)
Received: by mail-qk0-x233.google.com with SMTP id v123so7057201qkh.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 02:08:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2f8a65db-e5a8-75f0-8c08-daa41e1cd3ba@mejor.pl>
References: <2f8a65db-e5a8-75f0-8c08-daa41e1cd3ba@mejor.pl>
From: Vitaly Wool <vitaly.wool@konsulko.com>
Date: Mon, 1 Aug 2016 11:08:25 +0200
Message-ID: <CAM4kBBLsK99PXaCa8Po3huOyGx+qHTrq3Vgsh+FoqqRaMLv-vQ@mail.gmail.com>
Subject: Re: Choosing z3fold allocator in zswap gives WARNING: CPU: 0 PID:
 5140 at mm/zswap.c:503 __zswap_pool_current+0x56/0x60
Content-Type: multipart/alternative; boundary=001a11490c5862a8cd0538fef14c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marcin_Miros=C5=82aw?= <marcin@mejor.pl>
Cc: Linux-MM <linux-mm@kvack.org>

--001a11490c5862a8cd0538fef14c
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Marcin,

Den 1 aug. 2016 11:04 fm skrev "Marcin Miros=C5=82aw" <marcin@mejor.pl>:
>
> Hi!
> I'm testing kernel-git
> (git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git , at
> 07f00f06ba9a5533d6650d46d3e938f6cbeee97e ) because I noticed strange OOM
> behavior in kernel 4.7.0. As for now I can't reproduce problems with
> OOM, probably it's fixed now.
> But now I wanted to try z3fold with zswap. When I did `echo z3fold >
> /sys/module/zswap/parameters/zpool` I got trace from dmesg:

Could you please give more info on how to reproduce this?

~vitaly

>
> [  429.722411] ------------[ cut here ]------------
> [  429.723476] WARNING: CPU: 0 PID: 5140 at mm/zswap.c:503
> __zswap_pool_current+0x56/0x60
> [  429.725161] Modules linked in: z3fold tun algif_skcipher af_alg
> dm_crypt netconsole xt_policy ipt_REJECT nf_reject_ipv4 xt_TARPIT(OE)
> xt_NFLOG ip_set_hash_ip ip_set_hash_net xt_SYSRQ(OE) xt_multiport
> nfnetlink_queue sit ip_tunnel tunnel4 xt_set ip_set iptable_filter
> xt_nat xt_comment xt_length iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4
> nf_nat_ipv4 nf_nat iptable_mangle xt_CT iptable_raw ip_tables
> nf_conntrack_ipv6 nf_defrag_ipv6 ip6t_rt xt_conntrack nf_conntrack
> ip6table_filter ip6table_mangle ip6_tables ipv6 xfs libcrc32c btrfs xor
> zlib_deflate raid6_pq tcp_diag inet_diag aesni_intel aes_x86_64
> glue_helper lrw gf128mul ablk_helper cryptd button virtio_net
> virtio_balloon crc32c_intel
> [  429.738937] CPU: 0 PID: 5140 Comm: bash Tainted: G           OE
> 4.7.0+ #4
> [  429.739880] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
> [  429.740048]  0000000000000286 000000002ea2eeca ffff8ecca91efcd8
> ffffffffad255d43
> [  429.740048]  0000000000000000 0000000000000000 ffff8ecca91efd18
> ffffffffad04c997
> [  429.740048]  000001f700000003 ffffffffad9b8a58 ffff8eccbd162b58
> 0000000000000000
> [  429.740048] Call Trace:
> [  429.740048]  [<ffffffffad255d43>] dump_stack+0x63/0x90
> [  429.740048]  [<ffffffffad04c997>] __warn+0xc7/0xf0
> [  429.740048]  [<ffffffffad04cac8>] warn_slowpath_null+0x18/0x20
> [  429.740048]  [<ffffffffad1250c6>] __zswap_pool_current+0x56/0x60
> [  429.740048]  [<ffffffffad1250e3>] zswap_pool_current+0x13/0x20
> [  429.740048]  [<ffffffffad125efb>] __zswap_param_set+0x1db/0x2f0
> [  429.740048]  [<ffffffffad126042>] zswap_zpool_param_set+0x12/0x20
> [  429.740048]  [<ffffffffad06645f>] param_attr_store+0x5f/0xc0
> [  429.740048]  [<ffffffffad065b69>] module_attr_store+0x19/0x30
> [  429.740048]  [<ffffffffad1b0b02>] sysfs_kf_write+0x32/0x40
> [  429.740048]  [<ffffffffad1b0663>] kernfs_fop_write+0x113/0x190
> [  429.740048]  [<ffffffffad13fc52>] __vfs_write+0x32/0x150
> [  429.740048]  [<ffffffffad15f0ae>] ? __fd_install+0x2e/0xe0
> [  429.740048]  [<ffffffffad15ef11>] ? __alloc_fd+0x41/0x180
> [  429.740048]  [<ffffffffad0838dd>] ? percpu_down_read+0xd/0x50
> [  429.740048]  [<ffffffffad140d33>] vfs_write+0xb3/0x1a0
> [  429.740048]  [<ffffffffad13db81>] ? filp_close+0x51/0x70
> [  429.740048]  [<ffffffffad142140>] SyS_write+0x50/0xc0
> [  429.740048]  [<ffffffffad413836>] entry_SYSCALL_64_fastpath+0x1e/0xa8
> [  429.764069] ---[ end trace ff7835fbf4d983b9 ]---
>
>
> Second issue:
> Since 4.7.0 up to now I've got strange problem with starting BIND (dns).
> It can't start, throws:
> 2016-08-01T10:42:21.449188+02:00 jowisz named[3730]: listening on IPv4
> interface eth0, 81.4.122.249#53
> 2016-08-01T10:42:21.449412+02:00 jowisz named[3730]: could not listen on
> UDP socket: out of memory
> 2016-08-01T10:42:21.449455+02:00 jowisz named[3730]: creating IPv4
> interface eth0 failed; interface ignored
> 2016-08-01T10:42:21.449514+02:00 jowisz named[3730]: not listening on
> any interfaces
> 2016-08-01T10:42:21.449670+02:00 jowisz named[3730]: generating session
> key for dynamic DNS
> 2016-08-01T10:42:21.449910+02:00 jowisz named[3730]: sizing zone task
> pool based on 69 zones
> 2016-08-01T10:42:21.450094+02:00 jowisz named[3730]: dns_master_load:
> out of memory
> 2016-08-01T10:42:21.450668+02:00 jowisz named[3730]: could not configure
> root hints from 'named.cache': out of memory
> 2016-08-01T10:42:21.451236+02:00 jowisz named[3730]: additionally
> listening on IPv4 interface eth0, 81.4.122.249#53
> 2016-08-01T10:42:21.451298+02:00 jowisz named[3730]: could not listen on
> UDP socket: out of memory
> 2016-08-01T10:42:21.451342+02:00 jowisz named[3730]: creating IPv4
> interface eth0 failed; interface ignored
> 2016-08-01T10:42:21.451479+02:00 jowisz named[3730]: loading
> configuration: out of memory
> 2016-08-01T10:42:21.451515+02:00 jowisz named[3730]: exiting (due to
> fatal error)
>
> strace shows:
> [pid 26247] sendto(3, "<29>Aug  1 11:02:23 named[26230]"..., 80,
> MSG_NOSIGNAL, NULL, 0) =3D 80
> [pid 26247] mprotect(0x7f8828051000, 8192, PROT_READ|PROT_WRITE) =3D -1
> ENOMEM (Cannot allocate memory)
> [pid 26247] mmap(NULL, 134217728, PROT_NONE,
> MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE, -1, 0) =3D 0x7f8820000000
> [pid 26247] munmap(0x7f8824000000, 67108864) =3D 0
> [pid 26247] mprotect(0x7f8820000000, 143360, PROT_READ|PROT_WRITE) =3D -1
> ENOMEM (Cannot allocate memory)
> [pid 26247] munmap(0x7f8820000000, 67108864) =3D 0
> [pid 26247] mmap(NULL, 12288, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D -1 ENOMEM (Cannot allocate memory)
> [pid 26247] mprotect(0x7f8828051000, 8192, PROT_READ|PROT_WRITE) =3D -1
> ENOMEM (Cannot allocate memory)
> [pid 26247] mmap(0x7f8824000000, 67108864, PROT_NONE,
> MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE, -1, 0) =3D 0x7f8824000000
> [pid 26247] mprotect(0x7f8824000000, 143360, PROT_READ|PROT_WRITE) =3D -1
> ENOMEM (Cannot allocate memory)
> [pid 26247] munmap(0x7f8824000000, 67108864) =3D 0
>
>
> Thanks,
> Marcin

--001a11490c5862a8cd0538fef14c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">Hi Marcin, </p>
<p dir=3D"ltr">Den 1 aug. 2016 11:04 fm skrev &quot;Marcin Miros=C5=82aw&qu=
ot; &lt;<a href=3D"mailto:marcin@mejor.pl">marcin@mejor.pl</a>&gt;:<br>
&gt;<br>
&gt; Hi!<br>
&gt; I&#39;m testing kernel-git<br>
&gt; (git://<a href=3D"http://git.kernel.org/pub/scm/linux/kernel/git/torva=
lds/linux.git">git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git</=
a> , at<br>
&gt; 07f00f06ba9a5533d6650d46d3e938f6cbeee97e ) because I noticed strange O=
OM<br>
&gt; behavior in kernel 4.7.0. As for now I can&#39;t reproduce problems wi=
th<br>
&gt; OOM, probably it&#39;s fixed now.<br>
&gt; But now I wanted to try z3fold with zswap. When I did `echo z3fold &gt=
;<br>
&gt; /sys/module/zswap/parameters/zpool` I got trace from dmesg:</p>
<p dir=3D"ltr">Could you please give more info on how to reproduce this? </=
p>
<p dir=3D"ltr">~vitaly</p>
<p dir=3D"ltr">&gt;<br>
&gt; [=C2=A0 429.722411] ------------[ cut here ]------------<br>
&gt; [=C2=A0 429.723476] WARNING: CPU: 0 PID: 5140 at mm/zswap.c:503<br>
&gt; __zswap_pool_current+0x56/0x60<br>
&gt; [=C2=A0 429.725161] Modules linked in: z3fold tun algif_skcipher af_al=
g<br>
&gt; dm_crypt netconsole xt_policy ipt_REJECT nf_reject_ipv4 xt_TARPIT(OE)<=
br>
&gt; xt_NFLOG ip_set_hash_ip ip_set_hash_net xt_SYSRQ(OE) xt_multiport<br>
&gt; nfnetlink_queue sit ip_tunnel tunnel4 xt_set ip_set iptable_filter<br>
&gt; xt_nat xt_comment xt_length iptable_nat nf_conntrack_ipv4 nf_defrag_ip=
v4<br>
&gt; nf_nat_ipv4 nf_nat iptable_mangle xt_CT iptable_raw ip_tables<br>
&gt; nf_conntrack_ipv6 nf_defrag_ipv6 ip6t_rt xt_conntrack nf_conntrack<br>
&gt; ip6table_filter ip6table_mangle ip6_tables ipv6 xfs libcrc32c btrfs xo=
r<br>
&gt; zlib_deflate raid6_pq tcp_diag inet_diag aesni_intel aes_x86_64<br>
&gt; glue_helper lrw gf128mul ablk_helper cryptd button virtio_net<br>
&gt; virtio_balloon crc32c_intel<br>
&gt; [=C2=A0 429.738937] CPU: 0 PID: 5140 Comm: bash Tainted: G=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0OE<br>
&gt; 4.7.0+ #4<br>
&gt; [=C2=A0 429.739880] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007<=
br>
&gt; [=C2=A0 429.740048]=C2=A0 0000000000000286 000000002ea2eeca ffff8ecca9=
1efcd8<br>
&gt; ffffffffad255d43<br>
&gt; [=C2=A0 429.740048]=C2=A0 0000000000000000 0000000000000000 ffff8ecca9=
1efd18<br>
&gt; ffffffffad04c997<br>
&gt; [=C2=A0 429.740048]=C2=A0 000001f700000003 ffffffffad9b8a58 ffff8eccbd=
162b58<br>
&gt; 0000000000000000<br>
&gt; [=C2=A0 429.740048] Call Trace:<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad255d43&gt;] dump_stack+0x63/0=
x90<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad04c997&gt;] __warn+0xc7/0xf0<=
br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad04cac8&gt;] warn_slowpath_nul=
l+0x18/0x20<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad1250c6&gt;] __zswap_pool_curr=
ent+0x56/0x60<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad1250e3&gt;] zswap_pool_curren=
t+0x13/0x20<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad125efb&gt;] __zswap_param_set=
+0x1db/0x2f0<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad126042&gt;] zswap_zpool_param=
_set+0x12/0x20<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad06645f&gt;] param_attr_store+=
0x5f/0xc0<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad065b69&gt;] module_attr_store=
+0x19/0x30<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad1b0b02&gt;] sysfs_kf_write+0x=
32/0x40<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad1b0663&gt;] kernfs_fop_write+=
0x113/0x190<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad13fc52&gt;] __vfs_write+0x32/=
0x150<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad15f0ae&gt;] ? __fd_install+0x=
2e/0xe0<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad15ef11&gt;] ? __alloc_fd+0x41=
/0x180<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad0838dd&gt;] ? percpu_down_rea=
d+0xd/0x50<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad140d33&gt;] vfs_write+0xb3/0x=
1a0<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad13db81&gt;] ? filp_close+0x51=
/0x70<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad142140&gt;] SyS_write+0x50/0x=
c0<br>
&gt; [=C2=A0 429.740048]=C2=A0 [&lt;ffffffffad413836&gt;] entry_SYSCALL_64_=
fastpath+0x1e/0xa8<br>
&gt; [=C2=A0 429.764069] ---[ end trace ff7835fbf4d983b9 ]---<br>
&gt;<br>
&gt;<br>
&gt; Second issue:<br>
&gt; Since 4.7.0 up to now I&#39;ve got strange problem with starting BIND =
(dns).<br>
&gt; It can&#39;t start, throws:<br>
&gt; 2016-08-01T10:42:21.449188+02:00 jowisz named[3730]: listening on IPv4=
<br>
&gt; interface eth0, 81.4.122.249#53<br>
&gt; 2016-08-01T10:42:21.449412+02:00 jowisz named[3730]: could not listen =
on<br>
&gt; UDP socket: out of memory<br>
&gt; 2016-08-01T10:42:21.449455+02:00 jowisz named[3730]: creating IPv4<br>
&gt; interface eth0 failed; interface ignored<br>
&gt; 2016-08-01T10:42:21.449514+02:00 jowisz named[3730]: not listening on<=
br>
&gt; any interfaces<br>
&gt; 2016-08-01T10:42:21.449670+02:00 jowisz named[3730]: generating sessio=
n<br>
&gt; key for dynamic DNS<br>
&gt; 2016-08-01T10:42:21.449910+02:00 jowisz named[3730]: sizing zone task<=
br>
&gt; pool based on 69 zones<br>
&gt; 2016-08-01T10:42:21.450094+02:00 jowisz named[3730]: dns_master_load:<=
br>
&gt; out of memory<br>
&gt; 2016-08-01T10:42:21.450668+02:00 jowisz named[3730]: could not configu=
re<br>
&gt; root hints from &#39;named.cache&#39;: out of memory<br>
&gt; 2016-08-01T10:42:21.451236+02:00 jowisz named[3730]: additionally<br>
&gt; listening on IPv4 interface eth0, 81.4.122.249#53<br>
&gt; 2016-08-01T10:42:21.451298+02:00 jowisz named[3730]: could not listen =
on<br>
&gt; UDP socket: out of memory<br>
&gt; 2016-08-01T10:42:21.451342+02:00 jowisz named[3730]: creating IPv4<br>
&gt; interface eth0 failed; interface ignored<br>
&gt; 2016-08-01T10:42:21.451479+02:00 jowisz named[3730]: loading<br>
&gt; configuration: out of memory<br>
&gt; 2016-08-01T10:42:21.451515+02:00 jowisz named[3730]: exiting (due to<b=
r>
&gt; fatal error)<br>
&gt;<br>
&gt; strace shows:<br>
&gt; [pid 26247] sendto(3, &quot;&lt;29&gt;Aug=C2=A0 1 11:02:23 named[26230=
]&quot;..., 80,<br>
&gt; MSG_NOSIGNAL, NULL, 0) =3D 80<br>
&gt; [pid 26247] mprotect(0x7f8828051000, 8192, PROT_READ|PROT_WRITE) =3D -=
1<br>
&gt; ENOMEM (Cannot allocate memory)<br>
&gt; [pid 26247] mmap(NULL, 134217728, PROT_NONE,<br>
&gt; MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE, -1, 0) =3D 0x7f8820000000<br>
&gt; [pid 26247] munmap(0x7f8824000000, 67108864) =3D 0<br>
&gt; [pid 26247] mprotect(0x7f8820000000, 143360, PROT_READ|PROT_WRITE) =3D=
 -1<br>
&gt; ENOMEM (Cannot allocate memory)<br>
&gt; [pid 26247] munmap(0x7f8820000000, 67108864) =3D 0<br>
&gt; [pid 26247] mmap(NULL, 12288, PROT_READ|PROT_WRITE,<br>
&gt; MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D -1 ENOMEM (Cannot allocate memor=
y)<br>
&gt; [pid 26247] mprotect(0x7f8828051000, 8192, PROT_READ|PROT_WRITE) =3D -=
1<br>
&gt; ENOMEM (Cannot allocate memory)<br>
&gt; [pid 26247] mmap(0x7f8824000000, 67108864, PROT_NONE,<br>
&gt; MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE, -1, 0) =3D 0x7f8824000000<br>
&gt; [pid 26247] mprotect(0x7f8824000000, 143360, PROT_READ|PROT_WRITE) =3D=
 -1<br>
&gt; ENOMEM (Cannot allocate memory)<br>
&gt; [pid 26247] munmap(0x7f8824000000, 67108864) =3D 0<br>
&gt;<br>
&gt;<br>
&gt; Thanks,<br>
&gt; Marcin<br></p>

--001a11490c5862a8cd0538fef14c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
