Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 446A96B00DD
	for <linux-mm@kvack.org>; Sat, 26 Oct 2013 08:46:25 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so5218674pad.2
        for <linux-mm@kvack.org>; Sat, 26 Oct 2013 05:46:24 -0700 (PDT)
Received: from psmtp.com ([74.125.245.112])
        by mx.google.com with SMTP id vs7si6953559pbc.265.2013.10.26.05.46.22
        for <linux-mm@kvack.org>;
        Sat, 26 Oct 2013 05:46:24 -0700 (PDT)
Message-ID: <526BB98B.4070207@alibaba-inc.com>
Date: Sat, 26 Oct 2013 20:46:03 +0800
From: =?UTF-8?B?5ZCr6bub?= <handai.szj@alibaba-inc.com>
MIME-Version: 1.0
Subject: Re: RIP: mem_cgroup_move_account+0xf4/0x290
References: <20131025161555.GA4398@plex.lan> <20131026033936.GA14971@cmpxchg.org>
In-Reply-To: <20131026033936.GA14971@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Flavio Leitner <fbl@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@taobao.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/26/2013 11:39 AM, Johannes Weiner wrote:
> On Fri, Oct 25, 2013 at 02:15:55PM -0200, Flavio Leitner wrote:
>> While playing with guests and net-next kernel, I've triggered
>> this with some frequency.  Even Fedora 19 kernel reproduces.
>>
>> It it a known issue?
>>
>> Thanks,
>> fbl
>>
>> [ 6790.349763] kvm: zapping shadow pages for mmio generation wraparoun=
d
>> [ 6792.283879] kvm: zapping shadow pages for mmio generation wraparoun=
d
>> [ 7535.654438] perf samples too long (2719 > 2500), lowering kernel.pe=
rf_event_max_sample_rate to 50000
>> [ 7535.665948] INFO: NMI handler (perf_event_nmi_handler) took too lon=
g to run: 11.560 msecs
>> [ 7691.048392] virbr0: port 1(vnet0) entered disabled state
>> [ 7691.056281] device vnet0 left promiscuous mode
>> [ 7691.061674] virbr0: port 1(vnet0) entered disabled state
>> [ 7691.163363] BUG: unable to handle kernel paging request at 000060fb=
c0002a20
>> [ 7691.171145] IP: [<ffffffff8119dcb4>] mem_cgroup_move_account+0xf4/0=
x290
>> [ 7691.178574] PGD 0
>> [ 7691.181042] Oops: 0000 [#1] SMP
>> [ 7691.184761] Modules linked in: vhost_net vhost macvtap macvlan tun =
veth openvswitch xt_CHECKSUM nf_conntrack_netbios_ns nf_conntrack_broadca=
st ipt_MASQUERADE ip6t_REJECT xt_conntrack ebtable_nat ebtable_broute bri=
dge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_def=
rag_ipv6 nf_nat_ipv6 vxlan ip_tunnel gre libcrc32c ip6table_mangle ip6tab=
le_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntr=
ack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle ip=
table_security iptable_raw coretemp kvm_intel snd_hda_codec_realtek snd_h=
da_intel nfsd snd_hda_codec kvm auth_rpcgss nfs_acl snd_hwdep lockd snd_s=
eq snd_seq_device snd_pcm e1000e snd_page_alloc sunrpc snd_timer crc32c_i=
ntel i7core_edac bnx2 shpchp ptp snd iTCO_wdt joydev pps_core iTCO_vendor=
_support pcspkr soundcore microcode serio_raw lpc_ich edac_core mfd_core =
i2c_i801 acpi_cpufreq hid_logitech_dj nouveau ata_generic pata_acpi video=
 i2c_algo_bit drm_kms_helper ttm drm mxm_wmi i2c_core pata_marvell wmi [l=
ast unloaded: openvswitch]
>> [ 7691.285989] CPU: 1 PID: 14 Comm: kworker/1:0 Tainted: G          I =
 3.12.0-rc6-01188-gb45bd46 #1
>> [ 7691.295779] Hardware name:                  /DX58SO, BIOS SOX5810J.=
86A.5599.2012.0529.2218 05/29/2012
>> [ 7691.306066] Workqueue: events css_killed_work_fn
>> [ 7691.311303] task: ffff880429555dc0 ti: ffff88042957a000 task.ti: ff=
ff88042957a000
>> [ 7691.319673] RIP: 0010:[<ffffffff8119dcb4>]  [<ffffffff8119dcb4>] me=
m_cgroup_move_account+0xf4/0x290
>> [ 7691.329728] RSP: 0018:ffff88042957bcc8  EFLAGS: 00010002
>> [ 7691.335747] RAX: 0000000000000246 RBX: ffff88042b17bc30 RCX: 000000=
0000000004
>> [ 7691.343720] RDX: ffff880424cd6000 RSI: 000060fbc0002a08 RDI: ffff88=
0424cd622c
>> [ 7691.351735] RBP: ffff88042957bd20 R08: ffff880424cd4000 R09: 000000=
0000000001
>> [ 7691.359751] R10: 0000000000000001 R11: 0000000000000001 R12: ffffea=
00103ef0c0
>> [ 7691.367745] R13: ffff880424cd6000 R14: 0000000000000000 R15: ffff88=
0424cd622c
>> [ 7691.375738] FS:  0000000000000000(0000) GS:ffff88043fc20000(0000) k=
nlGS:0000000000000000
>> [ 7691.384755] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [ 7691.391238] CR2: 000060fbc0002a20 CR3: 0000000001c0c000 CR4: 000000=
00000027e0
>> [ 7691.399235] Stack:
>> [ 7691.401672]  ffff88042957bce8 ffff88042957bce8 ffffffff81312b6d fff=
f880424cd4000
>> [ 7691.409968]  ffff880400000001 ffff880424cd6000 ffffea00103ef0c0 fff=
f880424cd0430
>> [ 7691.418264]  ffff88042b17bc30 ffffea00103ef0e0 ffff880424cd6000 fff=
f88042957bda8
>> [ 7691.426578] Call Trace:
>> [ 7691.429513]  [<ffffffff81312b6d>] ? list_del+0xd/0x30
>> [ 7691.435250]  [<ffffffff8119f5e7>] mem_cgroup_reparent_charges+0x247=
/0x460
>> [ 7691.442874]  [<ffffffff8119f9af>] mem_cgroup_css_offline+0xaf/0x1b0=

>> [ 7691.449942]  [<ffffffff810da877>] offline_css+0x27/0x50
>> [ 7691.455874]  [<ffffffff810dcf8d>] css_killed_work_fn+0x2d/0xa0
>> [ 7691.462466]  [<ffffffff810821f5>] process_one_work+0x175/0x430
>> [ 7691.469041]  [<ffffffff81082e1b>] worker_thread+0x11b/0x3a0
>> [ 7691.475345]  [<ffffffff81082d00>] ? rescuer_thread+0x340/0x340
>> [ 7691.481919]  [<ffffffff81089860>] kthread+0xc0/0xd0
>> [ 7691.487478]  [<ffffffff810897a0>] ? insert_kthread_work+0x40/0x40
>> [ 7691.494352]  [<ffffffff8166ea3c>] ret_from_fork+0x7c/0xb0
>> [ 7691.500464]  [<ffffffff810897a0>] ? insert_kthread_work+0x40/0x40
>> [ 7691.507335] Code: 85 f6 48 8b 55 d0 44 8b 4d c8 4c 8b 45 c0 0f 85 b=
3 00 00 00 41 8b 4c 24 18 85 c9 0f 88 a6 00 00 00 48 8b b2 30 02 00 00 45=
 89 ca <4c> 39 56 18 0f 8c 36 01 00 00 44 89 c9 f7 d9 89 cf 65 48 01 7e
> This is
>
> All code
> =3D=3D=3D=3D=3D=3D=3D=3D
>     0:   85 f6                   test   %esi,%esi
>     2:   48 8b 55 d0             mov    -0x30(%rbp),%rdx
>     6:   44 8b 4d c8             mov    -0x38(%rbp),%r9d
>     a:   4c 8b 45 c0             mov    -0x40(%rbp),%r8
>     e:   0f 85 b3 00 00 00       jne    0xc7
>    14:   41 8b 4c 24 18          mov    0x18(%r12),%ecx
>    19:   85 c9                   test   %ecx,%ecx
>    1b:   0f 88 a6 00 00 00       js     0xc7
>    21:   48 8b b2 30 02 00 00    mov    0x230(%rdx),%rsi
>    28:   45 89 ca                mov    %r9d,%r10d
>    2b:*  4c 39 56 18             cmp    %r10,0x18(%rsi)          <-- tr=
apping instruction
>    2f:   0f 8c 36 01 00 00       jl     0x16b
>    35:   44 89 c9                mov    %r9d,%ecx
>    38:   f7 d9                   neg    %ecx
>    3a:   89 cf                   mov    %ecx,%edi
>    3c:   65                      gs
>    3d:   48                      rex.W
>    3e:   01                      .byte 0x1
>    3f:   7e                      .byte 0x7e
>
> which corresponds to
>
> 	WARN_ON_ONCE(from->stat->count[idx] < nr_pages);
>
> Humm.  from->stat is a percpu pointer...  This patch should fix it:
>
> ---
>  From 4e9fe9d7e8502eab1c8bb4761de838f61cd4a8e0 Mon Sep 17 00:00:00 2001=

> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Fri, 25 Oct 2013 23:23:31 -0400
> Subject: [patch] mm: memcg: fix percpu variable access crash
>
> 3ea67d06e467 ("memcg: add per cgroup writeback pages accounting")
> added a WARN_ON_ONCE() to sanity check the page statistics counter
> when moving charges.  Unfortunately, it dereferences the percpu
> counter directly, which may result in a crash like this:
>
> [ 7691.163363] BUG: unable to handle kernel paging request at 000060fbc=
0002a20
> [ 7691.171145] IP: [<ffffffff8119dcb4>] mem_cgroup_move_account+0xf4/0x=
290
> [ 7691.178574] PGD 0
> [ 7691.181042] Oops: 0000 [#1] SMP
> [...]
> [ 7691.285989] CPU: 1 PID: 14 Comm: kworker/1:0 Tainted: G          I  =
3.12.0-rc6-01188-gb45bd46 #1
> [ 7691.295779] Hardware name:                  /DX58SO, BIOS SOX5810J.8=
6A.5599.2012.0529.2218 05/29/2012
> [ 7691.306066] Workqueue: events css_killed_work_fn
> [ 7691.311303] task: ffff880429555dc0 ti: ffff88042957a000 task.ti: fff=
f88042957a000
> [ 7691.319673] RIP: 0010:[<ffffffff8119dcb4>]  [<ffffffff8119dcb4>] mem=
_cgroup_move_account+0xf4/0x290
> [ 7691.329728] RSP: 0018:ffff88042957bcc8  EFLAGS: 00010002
> [ 7691.335747] RAX: 0000000000000246 RBX: ffff88042b17bc30 RCX: 0000000=
000000004
> [ 7691.343720] RDX: ffff880424cd6000 RSI: 000060fbc0002a08 RDI: ffff880=
424cd622c
> [ 7691.351735] RBP: ffff88042957bd20 R08: ffff880424cd4000 R09: 0000000=
000000001
> [ 7691.359751] R10: 0000000000000001 R11: 0000000000000001 R12: ffffea0=
0103ef0c0
> [ 7691.367745] R13: ffff880424cd6000 R14: 0000000000000000 R15: ffff880=
424cd622c
> [ 7691.375738] FS:  0000000000000000(0000) GS:ffff88043fc20000(0000) kn=
lGS:0000000000000000
> [ 7691.384755] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 7691.391238] CR2: 000060fbc0002a20 CR3: 0000000001c0c000 CR4: 0000000=
0000027e0
> [ 7691.399235] Stack:
> [ 7691.401672]  ffff88042957bce8 ffff88042957bce8 ffffffff81312b6d ffff=
880424cd4000
> [ 7691.409968]  ffff880400000001 ffff880424cd6000 ffffea00103ef0c0 ffff=
880424cd0430
> [ 7691.418264]  ffff88042b17bc30 ffffea00103ef0e0 ffff880424cd6000 ffff=
88042957bda8
> [ 7691.426578] Call Trace:
> [ 7691.429513]  [<ffffffff81312b6d>] ? list_del+0xd/0x30
> [ 7691.435250]  [<ffffffff8119f5e7>] mem_cgroup_reparent_charges+0x247/=
0x460
> [ 7691.442874]  [<ffffffff8119f9af>] mem_cgroup_css_offline+0xaf/0x1b0
> [ 7691.449942]  [<ffffffff810da877>] offline_css+0x27/0x50
> [ 7691.455874]  [<ffffffff810dcf8d>] css_killed_work_fn+0x2d/0xa0
> [ 7691.462466]  [<ffffffff810821f5>] process_one_work+0x175/0x430
> [ 7691.469041]  [<ffffffff81082e1b>] worker_thread+0x11b/0x3a0
> [ 7691.475345]  [<ffffffff81082d00>] ? rescuer_thread+0x340/0x340
> [ 7691.481919]  [<ffffffff81089860>] kthread+0xc0/0xd0
> [ 7691.487478]  [<ffffffff810897a0>] ? insert_kthread_work+0x40/0x40
> [ 7691.494352]  [<ffffffff8166ea3c>] ret_from_fork+0x7c/0xb0
> [ 7691.500464]  [<ffffffff810897a0>] ? insert_kthread_work+0x40/0x40
> [ 7691.507335] Code: 85 f6 48 8b 55 d0 44 8b 4d c8 4c 8b 45 c0 0f 85 b3=
 00 00 00 41 8b 4c 24 18
> 85 c9 0f 88 a6 00 00 00 48 8b b2 30 02 00 00 45 89 ca <4c> 39 56 18 0f =
8c 36 01 00 00 44 89 c9
> f7 d9 89 cf 65 48 01 7e
> [ 7691.528638] RIP  [<ffffffff8119dcb4>] mem_cgroup_move_account+0xf4/0=
x290
>
> Add the required __this_cpu_read().

Sorry for my mistake and thanks for the fix up, it looks good to me.

Reviewed-by: Sha Zhengju <handai.szj@taobao.com>


Thanks,
Sha
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>   mm/memcontrol.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4097a78..a4864b6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3773,7 +3773,7 @@ void mem_cgroup_move_account_page_stat(struct mem=
_cgroup *from,
>   {
>   	/* Update stat data for mem_cgroup */
>   	preempt_disable();
> -	WARN_ON_ONCE(from->stat->count[idx] < nr_pages);
> +	WARN_ON_ONCE(__this_cpu_read(from->stat->count[idx]) < nr_pages);
>   	__this_cpu_add(from->stat->count[idx], -nr_pages);
>   	__this_cpu_add(to->stat->count[idx], nr_pages);
>   	preempt_enable();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
