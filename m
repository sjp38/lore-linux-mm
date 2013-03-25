Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 19CEC6B003D
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 03:42:53 -0400 (EDT)
Date: Mon, 25 Mar 2013 03:42:50 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1857580200.5734574.1364197370979.JavaMail.root@redhat.com>
In-Reply-To: <364499626.5604667.1364189870552.JavaMail.root@redhat.com>
Subject: Re: BUG at kmem_cache_alloc
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>



----- Original Message -----
> From: "CAI Qian" <caiqian@redhat.com>
> To: "David Rientjes" <rientjes@google.com>
> Cc: "linux-mm" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, "Oleg =
Nesterov" <oleg@redhat.com>
> Sent: Monday, March 25, 2013 1:37:50 PM
> Subject: Re: BUG at kmem_cache_alloc
>=20
>=20
>=20
> ----- Original Message -----
> > From: "David Rientjes" <rientjes@google.com>
> > To: "CAI Qian" <caiqian@redhat.com>
> > Cc: "linux-mm" kvack.org>, linux-kernel@vger.kernel.org, "Oleg
> > Nesterov" <oleg@redhat.com>
> > Sent: Friday, March 22, 2013 5:35:34 PM
> > Subject: Re: BUG at kmem_cache_alloc
> >=20
> > On Fri, 22 Mar 2013, CAI Qian wrote:
> >=20
> > > Starting to see those on 3.8.4 (never saw in 3.8.2) stable kernel
> > > on a few systems
> > > during LTP run,
> > >=20
> > > [11297.597242] BUG: unable to handle kernel paging request at
> > > 00000000fffffffe
> > > [11297.598022] IP: [] kmem_cache_alloc+0x68/0x1e0
> >=20
> > Is this repeatable?  Do you have CONFIG_SLAB or CONFIG_SLUB
> > enabled?
> Saw it on 2 systems so far - one HP server and one KVM guest. Still
This happened again during trinity run. Bisecting is in-progress...
CAI Qian

[ 9236.418633] BUG: unable to handle kernel paging request at 0000000000010=
000=20
[ 9236.420033] IP: [<ffffffff8118a008>] kmem_cache_alloc+0x68/0x200=20
[ 9236.421405] PGD 147308067 PUD 149456067 PMD 0 =20
[ 9236.422476] Oops: 0000 [#1] SMP =20
[ 9236.423182] Modules linked in: tun(F+) cmtp(F) kernelcapi(F) hidp(F) rfc=
omm(F) bnep(F) l2tp_ppp(F) l2tp_netlink(F) l2tp_core(F) ipt_ULOG(F) scsi_tr=
ansport_iscsi(F) af_802154(F) rds(F) af_key(F) pppoe(F) pppox(F) ppp_generi=
c(F) slhc(F) nfc(F) atm(F) ip6table_filter(F) ip6_tables(F) iptable_filter(=
F) ip_tables(F) btrfs(F) zlib_deflate(F) vfat(F) fat(F) nfs_layout_nfsv41_f=
iles(F) nfsv4(F) auth_rpcgss(F) nfsv3(F) nfs_acl(F) nfsv2(F) nfs(F) lockd(F=
) sunrpc(F) fscache(F) nfnetlink_log(F) nfnetlink(F) bluetooth(F) rfkill(F)=
 arc4(F) md4(F) nls_utf8(F) cifs(F) dns_resolver(F) nf_tproxy_core(F) nls_k=
oi8_u(F) nls_cp932(F) ts_kmp(F) sctp(F) fuse(F) sg(F) kvm_amd(F) kvm(F) amd=
64_edac_mod(F) edac_mce_amd(F) bnx2x(F) serio_raw(F) edac_core(F) netxen_ni=
c(F) mdio(F) k10temp(F) microcode(F) i2c_piix4(F) ipmi_si(F) ipmi_msghandle=
r(F) shpchp(F) hpwdt(F) hpilo(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F=
) radeon(F) i2c_algo_bit(F) drm_kms_helper(F) sata_svw(F) ttm(F) libata(F) =
drm(F) i2c_core(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last=
 unloaded: ipt_REJECT]=20
[ 9236.444373] CPU 3 =20
[ 9236.444885] Pid: 3495, comm: modprobe Tainted: GF       W    3.8.4 #1 HP=
 ProLiant BL495c G5  =20
[ 9236.446808] RIP: 0010:[<ffffffff8118a008>]  [<ffffffff8118a008>] kmem_ca=
che_alloc+0x68/0x200=20
[ 9236.448757] RSP: 0018:ffff8801206c3c88  EFLAGS: 00010246=20
[ 9236.449946] RAX: 0000000000000000 RBX: 000000000000000f RCX: 00000000000=
00124=20
[ 9236.451531] RDX: 000000000002c644 RSI: 00000000000080d0 RDI: ffff88014b0=
40c00=20
[ 9236.453123] RBP: ffff8801206c3cd8 R08: 0000000000017690 R09: ffffffff812=
15c94=20
[ 9236.454735] R10: 0000000000004380 R11: 0000000000000001 R12: 00000000000=
10000=20
[ 9236.456373] R13: 00000000000080d0 R14: ffff88014b040c00 R15: ffff88014b0=
40c00=20
[ 9236.457993] FS:  00007f92ce2d5740(0000) GS:ffff88014fd80000(0000) knlGS:=
00000000f75546c0=20
[ 9236.459803] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b=20
[ 9236.461081] CR2: 0000000000010000 CR3: 00000001360c9000 CR4: 00000000000=
007e0=20
[ 9236.462682] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000=20
[ 9236.464279] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400=20
[ 9236.465875] Process modprobe (pid: 3495, threadinfo ffff8801206c2000, ta=
sk ffff8801463065c0)=20
[ 9236.467747] Stack:=20
[ 9236.468260]  ffff8801206c3ca8 ffffffff812156c5 ffffffff81215c94 ffffffff=
812156c5=20
[ 9236.469903]  ffff8801495405ae 000000000000000f 0000000000000002 ffff8800=
a2862d10=20
[ 9236.471569]  0000000000000000 0000000000008124 ffff8801206c3d28 ffffffff=
81215c94=20
[ 9236.473315] Call Trace:=20
[ 9236.473862]  [<ffffffff812156c5>] ? sysfs_link_sibling+0xb5/0xe0=20
[ 9236.475216]  [<ffffffff81215c94>] ? sysfs_new_dirent+0x54/0x110=20
[ 9236.476571]  [<ffffffff812156c5>] ? sysfs_link_sibling+0xb5/0xe0=20
[ 9236.477970]  [<ffffffff81215c94>] sysfs_new_dirent+0x54/0x110=20
[ 9236.479253]  [<ffffffff81215ebc>] ? sysfs_add_one+0x2c/0x100=20
[ 9236.480548]  [<ffffffff8121517b>] sysfs_add_file_mode+0x6b/0xe0=20
[ 9236.481889]  [<ffffffff81217f70>] internal_create_group+0xd0/0x230=20
[ 9236.483288]  [<ffffffff81218103>] sysfs_create_group+0x13/0x20=20
[ 9236.484613]  [<ffffffff810c90dc>] load_module+0x138c/0x1660=20
[ 9236.485865]  [<ffffffff8131abe0>] ? ddebug_proc_open+0xc0/0xc0=20
[ 9236.487174]  [<ffffffff810c9487>] sys_init_module+0xd7/0x120=20
[ 9236.488498]  [<ffffffff8161f7d9>] system_call_fastpath+0x16/0x1b=20
[ 9236.489797] Code: 90 4d 89 fe 4d 8b 06 65 4c 03 04 25 c8 db 00 00 49 8b =
50 08 4d 8b 20 4d 85 e4 0f 84 1c 01 00 00 49 63 46 20 4d 8b 06 41 f6 c0 0f =
<49> 8b 1c 04 0f 85 46 01 00 00 48 8d 4a 01 4c 89 e0 65 49 0f c7 =20
[ 9236.494164] RIP  [<ffffffff8118a008>] kmem_cache_alloc+0x68/0x200=20
[ 9236.495550]  RSP <ffff8801206c3c88>=20
[ 9236.496287] CR2: 0000000000010000=20
[ 9236.513347] ---[ end trace 3567090873e2c5de ]---=20
[watchdog] 9407744 iterations. [F:8626700 S:781126]=20
[ 9237.335465] BUG: unable to handle kernel paging request at 0000000000010=
000=20
[ 9237.336924] IP: [<ffffffff8118a008>] kmem_cache_alloc+0x68/0x200=20
[ 9237.338280] PGD 1489d8067 PUD 1489da067 PMD 0 =20
[ 9237.339197] Oops: 0000 [#2] SMP =20
[ 9237.339945] Modules linked in: tun(F+) cmtp(F) kernelcapi(F) hidp(F) rfc=
omm(F) bnep(F) l2tp_ppp(F) l2tp_netlink(F) l2tp_core(F) ipt_ULOG(F) scsi_tr=
ansport_iscsi(F) af_802154(F) rds(F) af_key(F) pppoe(F) pppox(F) ppp_generi=
c(F) slhc(F) nfc(F) atm(F) ip6table_filter(F) ip6_tables(F) iptable_filter(=
F) ip_tables(F) btrfs(F) zlib_deflate(F) vfat(F) fat(F) nfs_layout_nfsv41_f=
iles(F) nfsv4(F) auth_rpcgss(F) nfsv3(F) nfs_acl(F) nfsv2(F) nfs(F) lockd(F=
) sunrpc(F) fscache(F) nfnetlink_log(F) nfnetlink(F) bluetooth(F) rfkill(F)=
 arc4(F) md4(F) nls_utf8(F) cifs(F) dns_resolver(F) nf_tproxy_core(F) nls_k=
oi8_u(F) nls_cp932(F) ts_kmp(F) sctp(F) fuse(F) sg(F) kvm_amd(F) kvm(F) amd=
64_edac_mod(F) edac_mce_amd(F) bnx2x(F) serio_raw(F) edac_core(F) netxen_ni=
c(F) mdio(F) k10temp(F) microcode(F) i2c_piix4(F) ipmi_si(F) ipmi_msghandle=
r(F) shpchp(F) hpwdt(F) hpilo(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F=
) radeon(F) i2c_algo_bit(F) drm_kms_helper(F) sata_svw(F) ttm(F) libata(F) =
drm(F) i2c_core(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last=
 unloaded: ipt_REJECT]=20
[ 9237.361067] CPU 3 =20
[ 9237.361512] Pid: 4191, comm: rhts-test-runne Tainted: GF     D W    3.8.=
4 #1 HP ProLiant BL495c G5  =20
[ 9237.363861] RIP: 0010:[<ffffffff8118a008>]  [<ffffffff8118a008>] kmem_ca=
che_alloc+0x68/0x200=20
[ 9237.365823] RSP: 0018:ffff8801208d9dc0  EFLAGS: 00010246=20
[ 9237.367069] RAX: 0000000000000000 RBX: ffff8801463065c0 RCX: 00000000000=
00000=20
[ 9237.368381] RDX: 000000000002c644 RSI: 00000000000080d0 RDI: ffff88014b0=
40c00=20
[ 9237.369678] RBP: ffff8801208d9e10 R08: 0000000000017690 R09: ffffffff810=
fe6e2=20
[ 9237.370967] R10: 0000000000000000 R11: ffffffffffffffe2 R12: 00000000000=
10000=20
[ 9237.372213] R13: 00000000000080d0 R14: ffff88014b040c00 R15: ffff88014b0=
40c00=20
[ 9237.373498] FS:  00007fc53f905740(0000) GS:ffff88014fd80000(0000) knlGS:=
00000000f75546c0=20
[ 9237.374947] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b=20
[ 9237.376071] CR2: 0000000000010000 CR3: 000000010817d000 CR4: 00000000000=
007e0=20
[ 9237.377370] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000=20
[ 9237.378652] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400=20
[ 9237.379950] Process rhts-test-runne (pid: 4191, threadinfo ffff8801208d8=
000, task ffff880146898000)=20
[ 9237.381520] Stack:=20
[ 9237.381913]  ffff8801208d9dd0 ffffffff8129aea6 ffffffff810fe6e2 ffffffff=
8108d29f=20
[ 9237.383499]  0000000001200011 ffff8801463065c0 0000000000000000 00007fc5=
3f905a10=20
[ 9237.385169]  0000000000000000 ffff8801463065c0 ffff8801208d9e30 ffffffff=
810fe6e2=20
[ 9237.386871] Call Trace:=20
[ 9237.387484]  [<ffffffff8129aea6>] ? security_prepare_creds+0x16/0x20=20
[ 9237.388905]  [<ffffffff810fe6e2>] ? __delayacct_tsk_init+0x22/0x40=20
[ 9237.390303]  [<ffffffff8108d29f>] ? prepare_creds+0xdf/0x190=20
[ 9237.391592]  [<ffffffff810fe6e2>] __delayacct_tsk_init+0x22/0x40=20
[ 9237.392936]  [<ffffffff810605df>] copy_process.part.25+0x31f/0x13f0=20
[ 9237.394297]  [<ffffffff8129abd6>] ? security_file_alloc+0x16/0x20=20
[ 9237.395677]  [<ffffffff811be652>] ? __alloc_fd+0x42/0x110=20
[ 9237.396905]  [<ffffffff810617a9>] do_fork+0xa9/0x350=20
[ 9237.398102]  [<ffffffff811be750>] ? get_unused_fd_flags+0x30/0x40=20
[ 9237.399466]  [<ffffffff811be78e>] ? __fd_install+0x2e/0x60=20
[ 9237.400731]  [<ffffffff81061ad6>] sys_clone+0x16/0x20=20
[ 9237.401866]  [<ffffffff8161fb39>] stub_clone+0x69/0x90=20
[ 9237.403050]  [<ffffffff8161f7d9>] ? system_call_fastpath+0x16/0x1b=20
[ 9237.404441] Code: 90 4d 89 fe 4d 8b 06 65 4c 03 04 25 c8 db 00 00 49 8b =
50 08 4d 8b 20 4d 85 e4 0f 84 1c 01 00 00 49 63 46 20 4d 8b 06 41 f6 c0 0f =
<49> 8b 1c 04 0f 85 46 01 00 00 48 8d 4a 01 4c 89 e0 65 49 0f c7 =20
[ 9237.408602] RIP  [<ffffffff8118a008>] kmem_cache_alloc+0x68/0x200=20
[ 9237.410080]  RSP <ffff8801208d9dc0>=20
[ 9237.410862] CR2: 0000000000010000=20
[ 9237.411687] ---[ end trace 3567090873e2c5df ]---=20
2013-03-25 03:10:52,681 rhts_task task_exited: INFO task_exited([Failure in=
stance: Traceback (failure with no frames): <class 'twisted.internet.error.=
ProcessTerminated'>: A process has ended with a probable error condition: p=
rocess ended with exit code 137.=20
])=20
2013-03-25 03:10:52,710 rhts_task on_exit: INFO quitting...=20
2013-03-25 03:10:52,716 rhts_task task_ended: INFO task_ended([Failure inst=
ance: Traceback (failure with no frames): <class 'twisted.internet.error.Pr=
ocessTerminated'>: A process has ended with a probable error condition: pro=
cess ended with exit code 137.=20
])=20
[ 9237.541330] BUG: unable to handle kernel paging request at 0000000000010=
000=20
[ 9237.542719] IP: [<ffffffff8118a008>] kmem_cache_alloc+0x68/0x200=20
[ 9237.544095] PGD 133477067 PUD 148e5b067 PMD 0 =20
[ 9237.545166] Oops: 0000 [#3] SMP =20
[ 9237.545868] Modules linked in: tun(F+) cmtp(F) kernelcapi(F) hidp(F     =
                                                                           =
                                                ppoe(F) pppox(F) ppp_generi=
c(F) slhc(F) nfc(F) atm(F) ip6table_filter(F) ip6_tables(F) iptable_filter(=
F) ip_tables(F) btrfs(F) zlib_deflate(F) vfat(F) fat(F) nfs_layout_nfsv41_f=
iles(F) nfsv4(F) auth_rpcgss(F) nfsv3(F) nfs_acl(F) nfsv2(F) nfs(F) lockd(F=
) sunrpc(F) fscache(F) nfnetlink_log(F) nfnetlink(F) bluetooth(F) rfkill(F)=
 arc4(F) md4(F) nls_utf8(F) cifs(F) dns_resolver(F) nf_tproxy_core(F) nls_k=
oi8_u(F) nls_cp932(F) ts_kmp(F) sctp(F) fuse(F) sg(F) kvm_amd(F) kvm(F) amd=
64_edac_mod(F) edac_mce_amd(F) bnx2x(F) serio_raw(F) edac_core(F) netxen_ni=
c(F) mdio(F) k10temp(F) microcode(F) i2c_piix4(F) ipmi_si(F) ipmi_msghandle=
r(F) shpchp(F) hpwdt(F) hpilo(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F=
) radeon(F) i2c_algo_bit(F) drm_kms_helper(F) sata_svw(F) ttm(F) libata(F) =
drm(F) i2c_core(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last=
 unloaded: ipt_REJECT]=20
[ 9237.567229] CPU 3 =20
[ 9237.567676] Pid: 3508, comm: kworker/u:0 Tainted: GF     D W    3.8.4 #1=
 HP ProLiant BL495c G5  =20
[ 9237.569270] RIP: 0010:[<ffffffff8118a008>]  [<ffffffff8118a008>] kmem_ca=
che_alloc+0x68/0x200=20
[ 9237.570846] RSP: 0000:ffff880146cc3d98  EFLAGS: 00010246=20
[ 9237.571992] RAX: 0000000000000000 RBX: ffff880146304c50 RCX: 00000000000=
00000=20
[ 9237.573580] RDX: 000000000002c644 RSI: 00000000000080d0 RDI: ffff88014b0=
40c00=20
[ 9237.575195] RBP: ffff880146cc3de8 R08: 0000000000017690 R09: ffffffff810=
fe6e2=20
[ 9237.576854] R10: ffff88014b001308 R11: ffffffffffffffe2 R12: 00000000000=
10000=20
[ 9237.578440] R13: 00000000000080d0 R14: ffff88014b040c00 R15: ffff88014b0=
40c00=20
[ 9237.580063] FS:  00007f11cf46f740(0000) GS:ffff88014fd80000(0000) knlGS:=
00000000f75546c0=20
[ 9237.581853] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b=20
[ 9237.583140] CR2: 0000000000010000 CR3: 0000000141ad5000 CR4: 00000000000=
007e0=20
[ 9237.584740] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000=20
[ 9237.586319] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400=20
[ 9237.587939] Process kworker/u:0 (pid: 3508, threadinfo ffff880146cc2000,=
 task ffff8801322ab2e0)=20
[ 9237.589905] Stack:=20
[ 9237.590333]  ffff880146cc3da8 ffffffff8129aea6 ffffffff810fe6e2 ffffffff=
8108d29f=20
[ 9237.592093]  0000000000800111 ffff880146304c50 0000000000000000 00000000=
00000000=20
[ 9237.593748]  0000000000000000 ffff880146304c50 ffff880146cc3e08 ffffffff=
810fe6e2=20
[ 9237.595407] Call Trace:=20
[ 9237.596021]  [<ffffffff8129aea6>] ? security_prepare_creds+0x16/0x20=20
[ 9237.597139]  [<ffffffff810fe6e2>] ? __delayacct_tsk_init+0x22/0x40=20
[ 9237.598256]  [<ffffffff8108d29f>] ? prepare_creds+0xdf/0x190=20
[ 9237.599344]  [<ffffffff810fe6e2>] __delayacct_tsk_init+0x22/0x40=20
[ 9237.600433]  [<ffffffff810605df>] copy_process.part.25+0x31f/0x13f0=20
[ 9237.601573]  [<ffffffff8107cf40>] ? proc_cap_handler+0x1b0/0x1b0=20
[ 9237.602623]  [<ffffffff810617a9>] do_fork+0xa9/0x350=20
[ 9237.603512]  [<ffffffff81061a76>] kernel_thread+0x26/0x30=20
[ 9237.604495]  [<ffffffff8107c738>] wait_for_helper+0x68/0xa0=20
[ 9237.605516]  [<ffffffff81096387>] ? schedule_tail+0x27/0xb0=20
[ 9237.606526]  [<ffffffff8107c6d0>] ? __call_usermodehelper+0xb0/0xb0=20
[ 9237.607674]  [<ffffffff8161f72c>] ret_from_fork+0x7c/0xb0=20
[ 9237.608706]  [<ffffffff8107c6d0>] ? __call_usermodehelper+0xb0/0xb0=20
[ 9237.619523] Code: 90 4d 89 fe 4d 8b 06 65 4c 03 04 25 c8 db 00 00 49 8b =
50 08 4d 8b 20 4d 85 e4 0f 84 1c 01 00 00 49 63 46 20 4d 8b 06 41 f6 c0 0f =
<49> 8b 1c 04 0f 85 46 01 00 00 48 8d 4a 01 4c 89 e0 65 49 0f c7 =20
[ 9237.648837] RIP  [<ffffffff8118a008>] kmem_cache_alloc+0x68/0x200=20
[ 9237.650087]  RSP <ffff880146cc3d98>=20
[ 9237.650832] CR2: 0000000000010000=20
[ 9237.666224] ---[ end trace 3567090873e2c5e0 ]---=20
[watchdog] 9465269 iterations. [F:8684132 S:781220]=20
[ 9238.441169] BUG: unable to handle kernel paging request at 0000000000010=
000=20
[ 9238.443191] IP: [<ffffffff8118a008>] kmem_cache_alloc+0x68/0x200=20
[ 9238.444509] PGD 129a98067 PUD 1363ef067 PMD 0 =20
[ 9238.445574] Oops: 0000 [#4] SMP =20
[ 9238.446286] Modules linked in: tun(F+) cmtp(F) kernelcapi(F) hidp(F) rfc=
omm(F) bnep(F) l2tp_ppp(F) l2tp_netlink(F) l2tp_core(F) ipt_ULOG(F) scsi_tr=
ansport_iscsi(F) af_802154(F) rds(F) af_key(F) pppoe(F) pppox(F) ppp_generi=
c(F) slhc(F) nfc(F) atm(F) ip6table_filter(F) ip6_tables(F) iptable_filter(=
F) ip_tables(F) btrfs(F) zlib_deflate(F) vfat(F) fat(F) nfs_layout_nfsv41_f=
iles(F) nfsv4(F) auth_rpcgss(F) nfsv3(F) nfs_acl(F) nfsv2(F) nfs(F) lockd(F=
) sunrpc(F) fscache(F) nfnetlink_log(F) nfnetlink(F) bluetooth(F) rfkill(F)=
 arc4(F) md4(F) nls_utf8(F) cifs(F) dns_resolver(F) nf_tproxy_core(F) nls_k=
oi8_u(F) nls_cp932(F) ts_kmp(F) sctp(F) fuse(F) sg(F) kvm_amd(F) kvm(F) amd=
64_edac_mod(F) edac_mce_amd(F) bnx2x(F) serio_raw(F) edac_core(F) netxen_ni=
c(F) mdio(F) k10temp(F) microcode(F) i2c_piix4(F) ipmi_si(F) ipmi_msghandle=
r(F) shpchp(F) hpwdt(F) hpilo(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F=
) radeon(F) i2c_algo_bit(F) drm_kms_helper(F) sata_svw(F) ttm(F) libata(F) =
drm(F) i2c_core(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last=
 unloaded: ipt_REJECT]=20
[ 9238.467980] CPU 3 =20
[ 9238.468382] Pid: 27728, comm: kworker/u:0 Tainted: GF     D W    3.8.4 #=
1 HP ProLiant BL495c G5  =20
[ 9238.470307] RIP: 0010:[<ffffffff8118a008>]  [<ffffffff8118a008>] kmem_ca=
che_alloc+0x68/0x200=20
[ 9238.471832] RSP: 0018:ffff8800a326bc38  EFLAGS: 00010246=20
[ 9238.472807] RAX: 0000000000000000 RBX: ffff880146301970 RCX: 00000000000=
00000=20
[ 9238.474105] RDX: 000000000002c644 RSI: 00000000000080d0 RDI: ffff88014b0=
40c00=20
[ 9238.475447] RBP: ffff8800a326bc88 R08: 0000000000017690 R09: ffffffff810=
fe6e2=20
[ 9238.476730] R10: ffffffffffffffff R11: ffffffffffffffe2 R12: 00000000000=
10000=20
[ 9238.478034] R13: 00000000000080d0 R14: ffff88014b040c00 R15: ffff88014b0=
40c00=20
[ 9238.479330] FS:  00007f00036a3740(0000) GS:ffff88014fd80000(0000) knlGS:=
00000000f75546c0=20
[ 9238.480773] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b=20
[ 9238.481823] CR2: 0000000000010000 CR3: 0000000135563000 CR4: 00000000000=
007e0=20
[ 9238.483124] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000=20
[ 9238.484411] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400=20
[ 9238.485734] Process kworker/u:0 (pid: 27728, threadinfo ffff8800a326a000=
, task ffff8801321ee5c0)=20
[ 9238.487310] Stack:=20
[ 9238.487722]  ffff8800a326bc48 ffffffff8129aea6 ffffffff810fe6e2 ffffffff=
8108d29f=20
[ 9238.489162]  0000000000800711 ffff880146301970 0000000000000000 00000000=
00000000=20
[ 9238.490800]  0000000000000000 ffff880146301970 ffff8800a326bca8 ffffffff=
810fe6e2=20
[ 9238.492409] Call Trace:=20
[ 9238.492985]  [<ffffffff8129aea6>] ? security_prepare_creds+0x16/0x20=20
[ 9238.494412]  [<ffffffff810fe6e2>] ? __delayacct_tsk_init+0x22/0x40=20
[ 9238.495854]  [<ffffffff8108d29f>] ? prepare_creds+0xdf/0x190=20
[ 9238.497133]  [<ffffffff810fe6e2>] __delayacct_tsk_init+0x22/0x40=20
[ 9238.498488]  [<ffffffff810605df>] copy_process.part.25+0x31f/0x13f0=20
[ 9238.499895]  [<ffffffff8107c6d0>] ? __call_usermodehelper+0xb0/0xb0=20
[ 9238.501307]  [<ffffffff810617a9>] do_fork+0xa9/0x350=20
[ 9238.502432]  [<ffffffff8101358e>] ? __switch_to+0x13e/0x4a0=20
[ 9238.503698]  [<ffffffff8110ad65>] ? tracing_is_on+0x15/0x30=20
[ 9238.504962]  [<ffffffff81061a76>] kernel_thread+0x26/0x30=20
[ 9238.506246]  [<ffffffff8107c69c>] __call_usermodehelper+0x7c/0xb0=20
[ 9238.507595]  [<ffffffff8107e5b4>] process_one_work+0x164/0x490=20
[ 9238.508912]  [<ffffffff81080c3e>] worker_thread+0x15e/0x450=20
[ 9238.510173]  [<ffffffff81080ae0>] ? busy_worker_rebind_fn+0x110/0x110=20
[ 9238.511605]  [<ffffffff81085f80>] kthread+0xc0/0xd0=20
[ 9238.512719]  [<ffffffff81085ec0>] ? kthread_create_on_node+0x120/0x120=
=20
[ 9238.514200]  [<ffffffff8161f72c>] ret_from_fork+0x7c/0xb0=20
[ 9238.515423]  [<ffffffff81085ec0>] ? kthread_create_on_node+0x120/0x120=
=20
[ 9238.516909] Code: 90 4d 89 fe 4d 8b 06 65 4c 03 04 25 c8 db 00 00 49 8b =
50 08 4d 8b 20 4d 85 e4 0f 84 1c 01 00 00 49 63 46 20 4d 8b 06 41 f6 c0 0f =
<49> 8b 1c 04 0f 85 46 01 00 00 48 8d 4a 01 4c 89 e0 65 49 0f c7 =20
[ 9238.521164] RIP  [<ffffffff8118a008>] kmem_cache_alloc+0x68/0x200=20
[ 9238.522547]  RSP <ffff8800a326bc38>=20
[ 9238.523367] CR2: 0000000000010000=20
[ 9238.524218] ---[ end trace 3567090873e2c5e1 ]---=20
[ 9238.525360] BUG: unable to handle kernel paging request at fffffffffffff=
fd8=20
[ 9238.526891] IP: [<ffffffff81086370>] kthread_data+0x10/0x20=20
[ 9238.528114] PGD 18f8067 PUD 18f9067 PMD 0 =20
[ 9238.529096] Oops: 0000 [#5] SMP =20
[ 9238.529780] Modules linked in: tun(F+) cmtp(F) kernelcapi(F) hidp(F) rfc=
omm(F) bnep(F) l2tp_ppp(F) l2tp_netlink(F) l2tp_core(F) ipt_ULOG(F) scsi_tr=
ansport_iscsi(F) af_802154(F) rds(F) af_key(F) pppoe(F) pppox(F) ppp_generi=
c(F) slhc(F) nfc(F) atm(F) ip6table_filter(F) ip6_tables(F) iptable_filter(=
F) ip_tables(F) btrfs(F) zlib_deflate(F) vfat(F) fat(F) nfs_layout_nfsv41_f=
iles(F) nfsv4(F) auth_rpcgss(F) nfsv3(F) nfs_acl(F) nfsv2(F) nfs(F) lockd(F=
) sunrpc(F) fscache(F) nfnetlink_log(F) nfnetlink(F) bluetooth(F) rfkill(F)=
 arc4(F) md4(F) nls_utf8(F) cifs(F) dns_resolver(F) nf_tproxy_core(F) nls_k=
oi8_u(F) nls_cp932(F) ts_kmp(F) sctp(F) fuse(F) sg(F) kvm_amd(F) kvm(F) amd=
64_edac_mod(F) edac_mce_amd(F) bnx2x(F) serio_raw(F) edac_core(F) netxen_ni=
c(F) mdio(F) k10temp(F) microcode(F) i2c_piix4(F) ipmi_si(F) ipmi_msghandle=
r(F) shpchp(F) hpwdt(F) hpilo(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F=
) radeon(F) i2c_algo_bit(F) drm_kms_helper(F) sata_svw(F) ttm(F) libata(F) =
drm(F) i2c_core(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last=
 unloaded: ipt_REJECT]=20
[ 9238.549662] CPU 3 =20
[ 9238.549997] Pid: 27728, comm: kworker/u:0 Tainted: GF     D W    3.8.4 #=
1 HP ProLiant BL495c G5  =20
[ 9238.551600] RIP: 0010:[<ffffffff81086370>]  [<ffffffff81086370>] kthread=
_data+0x10/0x20=20
[ 9238.553155] RSP: 0018:ffff8800a326b828  EFLAGS: 00010092=20
[ 9238.554136] RAX: 0000000000000000 RBX: 0000000000000003 RCX: 00000000000=
0000d=20
[ 9238.555426] RDX: 0000000000000004 RSI: 0000000000000003 RDI: ffff8801321=
ee5c0=20
[ 9238.556724] RBP: ffff8800a326b828 R08: ffff8801321ee630 R09: 00000000000=
0010b=20
[ 9238.558025] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88014fd=
94180=20
[ 9238.559317] R13: 0000000000000003 R14: ffff8801321ee5b0 R15: ffff8801321=
ee5c0=20
[ 9238.560598] FS:  00007f00036a3740(0000) GS:ffff88014fd80000(0000) knlGS:=
00000000f75546c0=20
[ 9238.562074] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b=20
[ 9238.563162] CR2: ffffffffffffffd8 CR3: 0000000135563000 CR4: 00000000000=
007e0=20
[ 9238.564448] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000=20
[ 9238.565729] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400=20
[ 9238.567030] Process kworker/u:0 (pid: 27728, threadinfo ffff8800a326a000=
, task ffff8801321ee5c0)=20
[ 9238.568600] Stack:=20
[ 9238.569023]  ffff8800a326b848 ffffffff81081775 ffff8800a326b848 ffff8801=
321eeb90=20
[ 9238.570483]  ffff8800a326b8b8 ffffffff81615af2 ffff8801321ee5c0 ffff8800=
a326bfd8=20
[ 9238.572187]  ffff8800a326bfd8 ffff8800a326bfd8 ffff8801321ee5c0 ffff8801=
321ee5c0=20
[ 9238.583863] Call Trace:=20
[ 9238.584293]  [<ffffffff81081775>] wq_worker_sleeping+0x15/0xc0=20
[ 9238.590261]  [<ffffffff81615af2>] __schedule+0x5c2/0x7b0=20
[ 9238.591244]  [<ffffffff81616009>] schedule+0x29/0x70=20
[ 9238.602045]  [<ffffffff810684df>] do_exit+0x6af/0x9f0=20
[ 9238.603146]  [<ffffffff816183ae>] oops_end+0x9e/0xe0=20
[ 9238.604304]  [<ffffffff8160acbd>] no_context+0x253/0x27e=20
[ 9238.614916]  [<ffffffff810b4e6c>] ? ktime_get_ts+0x4c/0xf0=20
[ 9238.616189]  [<ffffffff8160aea8>] __bad_area_nosemaphore+0x1c0/0x1df=20
[ 9238.627046]  [<ffffffff81310811>] ? list_del+0x11/0x40=20
[ 9238.628185]  [<ffffffff8160aeda>] bad_area_nosemaphore+0x13/0x15=20
[ 9238.638969]  [<ffffffff8161b04e>] __do_page_fault+0x38e/0x4d0=20
[ 9238.644921]  [<ffffffff8119cef1>] ? mem_cgroup_bad_page_check+0x21/0x30=
=20
[ 9238.651155]  [<ffffffff812fbe59>] ? cpumask_next_and+0x29/0x50=20
[ 9238.662141]  [<ffffffff8161b19e>] do_page_fault+0xe/0x10=20
[ 9238.663318]  [<ffffffff816177d8>] page_fault+0x28/0x30=20
[ 9238.668961]  [<ffffffff810fe6e2>] ? __delayacct_tsk_init+0x22/0x40=20
[ 9238.680192]  [<ffffffff8118a008>] ? kmem_cache_alloc+0x68/0x200=20
[ 9238.691111]  [<ffffffff81189fd5>] ? kmem_cache_alloc+0x35/0x200=20
[ 9238.692393]  [<ffffffff8129aea6>] ? security_prepare_creds+0x16/0x20=20
[ 9238.703313]  [<ffffffff810fe6e2>] ? __delayacct_tsk_init+0x22/0x40=20
[ 9238.704694]  [<ffffffff8108d29f>] ? prepare_creds+0xdf/0x190=20
[ 9238.715769]  [<ffffffff810fe6e2>] __delayacct_tsk_init+0x22/0x40=20
[ 9238.716857]  [<ffffffff810605df>] copy_process.part.25+0x31f/0x13f0=20
[ 9238.727647]  [<ffffffff8107c6d0>] ? __call_usermodehelper+0xb0/0xb0=20
[ 9238.729076]  [<ffffffff810617a9>] do_fork+0xa9/0x350=20
[ 9238.739650]  [<ffffffff8101358e>] ? __switch_to+0x13e/0x4a0=20
[ 9238.740659]  [<ffffffff8110ad65>] ? tracing_is_on+0x15/0x30=20
[ 9238.751661]  [<ffffffff81061a76>] kernel_thread+0x26/0x30=20
[ 9238.752639]  [<ffffffff8107c69c>] __call_usermodehelper+0x7c/0xb0=20
[ 9238.763691]  [<ffffffff8107e5b4>] process_one_work+0x164/0x490=20
[ 9238.764993]  [<ffffffff81080c3e>] worker_thread+0x15e/0x450=20
[ 9238.775749]  [<ffffffff81080ae0>] ? busy_worker_rebind_fn+0x110/0x110=20
[ 9238.786726]  [<ffffffff81085f80>] kthread+0xc0/0xd0=20
[ 9238.787811]  [<ffffffff81085ec0>] ? kthread_create_on_node+0x120/0x120=
=20
[ 9238.798777]  [<ffffffff8161f72c>] ret_from_fork+0x7c/0xb0=20
[ 9238.799887]  [<ffffffff81085ec0>] ? kthread_create_on_node+0x120/0x120=
=20
[ 9238.810874] Code: 00 48 89 e5 5d 48 8b 40 c8 48 c1 e8 02 83 e0 01 c3 66 =
2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 48 8b 87 78 05 00 00 55 48 89 e5 =
<48> 8b 40 d8 5d c3 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 =20
[ 9238.824739] RIP  [<ffffffff81086370>] kthread_data+0x10/0x20=20
[ 9238.835318]  RSP <ffff8800a326b828>=20
[ 9238.836050] CR2: ffffffffffffffd8=20
[ 9238.836704] ---[ end trace 3567090873e2c5e2 ]---=20
[ 9238.847352] Fixing recursive fault but reboot is needed!=20
[ 9251.888205] bnx2x 0000:03:00.0 ksdev0: MDC/MDIO access timeout=20
[ 9251.911020] bnx2x 0000:03:00.0 ksdev0: NIC Link is Down=20
[ 9270.036495] Kernel panic - not syncing: Watchdog detected hard LOCKUP on=
 cpu 0=20
[ 9271.140360] Shutting down cpus with NMI=20
[ 9271.141082] drm_kms_helper: panic occurred, switching back to text conso=
le =20
> trying to reproduce. Used CONFIG_SLUB=3Dy.
> CAI Qian
> >=20
> > > [11297.598022] PGD 7b9eb067 PUD 0
> > > [11297.598022] Oops: 0000 [#2] SMP
> > > [11297.598022] Modules linked in: cmtp kernelcapi bnep
> > > scsi_transport_iscsi rfcomm l2tp_ppp l2tp_netlink l2tp_core hidp
> > > ipt_ULOG af_key nfc rds pppoe pppox ppp_generic slhc af_802154
> > > atm
> > > ip6table_filter ip6_tables iptable_filter ip_tables btrfs
> > > zlib_deflate vfat fat nfs_layout_nfsv41_files nfsv4 auth_rpcgss
> > > nfsv3 nfs_acl nfsv2 nfs lockd sunrpc fscache nfnetlink_log
> > > nfnetlink bluetooth rfkill arc4 md4 nls_utf8 cifs dns_resolver
> > > nf_tproxy_core nls_koi8_u nls_cp932 ts_kmp sctp sg kvm_amd kvm
> > > virtio_balloon i2c_piix4 pcspkr xfs libcrc32c ata_generic
> > > pata_acpi cirrus drm_kms_helper ttm ata_piix virtio_net drm
> > > libata
> > > virtio_blk i2c_core floppy dm_mirror dm_region_hash dm_log dm_mod
> > > [last unloaded: ipt_REJECT]
> > > [11297.598022] CPU 1
> > > [11297.598022] Pid: 14134, comm: ltp-pan Tainted: G      D
> > >      3.8.4+ #1 Bochs Bochs
> > > [11297.598022] RIP: 0010:[]  [] kmem_cache_alloc+0x68/0x1e0
> > > [11297.598022] RSP: 0018:ffff8800447dbdd0  EFLAGS: 00010246
> > > [11297.598022] RAX: 0000000000000000 RBX: ffff88007c169970 RCX:
> > > 00000000018acdcd
> > > [11297.598022] RDX: 000000000006c104 RSI: 00000000000080d0 RDI:
> > > ffff88007d04ac00
> > > [11297.598022] RBP: ffff8800447dbe10 R08: 0000000000017620 R09:
> > > ffffffff810fe2e2
> > > [11297.598022] R10: 0000000000000000 R11: 0000000000000000 R12:
> > > 00000000fffffffe
> > > [11297.598022] R13: 00000000000080d0 R14: ffff88007d04ac00 R15:
> > > ffff88007d04ac00
> > > [11297.598022] FS:  00007f09c29b4740(0000)
> > > GS:ffff88007fd00000(0000) knlGS:00000000f74d86c0
> > > [11297.598022] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > [11297.598022] CR2: 00000000fffffffe CR3: 0000000037213000 CR4:
> > > 00000000000006e0
> > > [11297.598022] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> > > 0000000000000000
> > > [11297.598022] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> > > 0000000000000400
> > > [11297.598022] Process ltp-pan (pid: 14134, threadinfo
> > > ffff8800447da000, task ffff8800551ab2e0)
> > > [11297.598022] Stack:
> > > [11297.598022]  ffffffff810fe2e2 ffffffff8108cf0f
> > > 0000000001200011
> > > ffff88007c169970
> > > [11297.598022]  0000000000000000 00007f09c29b4a10
> > > 0000000000000000
> > > ffff88007c169970
> > > [11297.598022]  ffff8800447dbe30 ffffffff810fe2e2
> > > 0000000000000000
> > > 0000000001200011
> > > [11297.598022] Call Trace:
> > > [11297.598022]  [] ? __delayacct_tsk_init+0x22/0x40
> > > [11297.598022]  [] ? prepare_creds+0xdf/0x190
> > > [11297.598022]  [] __delayacct_tsk_init+0x22/0x40
> > > [11297.598022]  [] copy_process.part.25+0x31f/0x13f0
> > > [11297.598022]  [] do_fork+0xa9/0x350
> > > [11297.598022]  [] sys_clone+0x16/0x20
> > > [11297.598022]  [] stub_clone+0x69/0x90
> > > [11297.598022]  [] ? system_call_fastpath+0x16/0x1b
> > > [11297.598022] Code: 90 4d 89 fe 4d 8b 06 65 4c 03 04 25 c8 db 00
> > > 00 49 8b 50 08 4d 8b 20 4d 85 e4 0f 84 2b 01 00 00 49 63 46 20 4d
> > > 8b 06 41 f6 c0 0f <49> 8b 1c 04 0f 85 55 01 00 00 48 8d 4a 01 4c
> > > 89 e0 65 49 0f c7
> > > [11297.598022] RIP  [] kmem_cache_alloc+0x68/0x1e0
> > > [11297.598022]  RSP
> > > [11297.598022] CR2: 00000000fffffffe
> > > [11297.727799] ---[ end trace 037bde72f23b34d2 ]---
> > >=20
> > > Never saw this in mainline but only something like this wondering
> > > could be related
> > > (that kmem_cache_alloc also in the trace).
> > >=20
> >=20
> > These are unrelated.
> >=20
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: href=3Dmailto:"dont@kvack.org"> email@kvack.org
> >=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
