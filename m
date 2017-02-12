From: Paul Menzel <paulepanter@users.sourceforge.net>
Subject: Trying to understand OOM killer
Date: Sun, 12 Feb 2017 14:47:13 +0100
Message-ID: <1486907233.6235.29.camel@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
        boundary="=-JFbwB/ydJ+Ohi8AMSLG2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org


--=-JFbwB/ydJ+Ohi8AMSLG2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear Linux folks,


since some time, at Linux 4.8, 4.9, and 4.10-rc6, the OOM kicks in on a
8 GB machine.

```
Feb 12 08:21:50 asrocke350m1 kernel: updatedb.mlocat invoked oom-killer: gf=
p_mask=3D0x16040d0(GFP_TEMPORARY|__GFP_COMP|__GFP_NOTRACK), nodemask=3D
Feb 12 08:21:50 asrocke350m1 kernel: updatedb.mlocat cpuset=3D/ mems_allowe=
d=3D0
Feb 12 08:21:50 asrocke350m1 kernel: CPU: 1 PID: 2314 Comm: updatedb.mlocat=
 Tainted: G         C      4.10.0-rc6-686-pae #1 Debian 4.10~rc6-1~
Feb 12 08:21:50 asrocke350m1 kernel: Hardware name: ASROCK E350M1/E350M1, B=
IOS 4.5-964-gd96669e9db 02/11/2017
Feb 12 08:21:51 asrocke350m1 kernel: Call Trace:
Feb 12 08:21:51 asrocke350m1 kernel:  ? dump_stack+0x55/0x73
Feb 12 08:21:51 asrocke350m1 kernel:  ? dump_header+0x64/0x1ab
Feb 12 08:21:52 asrocke350m1 kernel:  ? ___ratelimit+0x9f/0x100
Feb 12 08:21:52 asrocke350m1 kernel:  ? oom_kill_process+0x221/0x3e0
Feb 12 08:21:52 asrocke350m1 kernel:  ? has_capability_noaudit+0x1a/0x30
Feb 12 08:21:52 asrocke350m1 kernel:  ? oom_badness.part.13+0xd7/0x150
Feb 12 08:21:52 asrocke350m1 kernel:  ? out_of_memory+0xe4/0x290
Feb 12 08:21:52 asrocke350m1 kernel:  ? __alloc_pages_nodemask+0xab8/0xbc0
Feb 12 08:21:52 asrocke350m1 kernel:  ? xfs_init_local_fork+0x8a/0xd0 [xfs]
Feb 12 08:21:52 asrocke350m1 kernel:  ? cache_grow_begin.isra.60+0x75/0x510
Feb 12 08:21:52 asrocke350m1 kernel:  ? xfs_buf_rele+0x43/0x2e0 [xfs]
Feb 12 08:21:52 asrocke350m1 kernel:  ? kmem_cache_alloc+0x1fa/0x530
Feb 12 08:21:52 asrocke350m1 kernel:  ? __d_alloc+0x23/0x180
Feb 12 08:21:52 asrocke350m1 kernel:  ? d_alloc+0x18/0x80
Feb 12 08:21:52 asrocke350m1 kernel:  ? d_alloc_parallel+0x47/0x450
Feb 12 08:21:52 asrocke350m1 kernel:  ? d_splice_alias+0x10d/0x3a0
Feb 12 08:21:53 asrocke350m1 kernel:  ? lockref_get_not_dead+0x8/0x40
Feb 12 08:21:53 asrocke350m1 kernel:  ? unlazy_walk+0xf9/0x1a0
Feb 12 08:21:53 asrocke350m1 kernel:  ? lookup_slow+0x5e/0x140
Feb 12 08:21:53 asrocke350m1 kernel:  ? walk_component+0x1b4/0x350
Feb 12 08:21:53 asrocke350m1 kernel:  ? path_lookupat+0x49/0xe0
Feb 12 08:21:53 asrocke350m1 kernel:  ? filename_lookup+0x99/0x190
Feb 12 08:21:53 asrocke350m1 kernel:  ? __check_object_size+0x9e/0x11c
Feb 12 08:21:53 asrocke350m1 kernel:  ? strncpy_from_user+0x39/0x140
Feb 12 08:21:53 asrocke350m1 kernel:  ? getname_flags+0x55/0x1a0
Feb 12 08:21:53 asrocke350m1 kernel:  ? vfs_fstatat+0x60/0xb0
Feb 12 08:21:53 asrocke350m1 kernel:  ? SyS_lstat64+0x2d/0x50
Feb 12 08:21:53 asrocke350m1 kernel:  ? sys_sync+0x9d/0xa0
Feb 12 08:21:53 asrocke350m1 kernel:  ? SyS_poll+0x6b/0x110
Feb 12 08:21:53 asrocke350m1 kernel:  ? do_fast_syscall_32+0x8a/0x150
Feb 12 08:21:53 asrocke350m1 kernel:  ? entry_SYSENTER_32+0x4e/0x7c
Feb 12 08:21:53 asrocke350m1 kernel: Mem-Info:
Feb 12 08:21:53 asrocke350m1 kernel: active_anon:119893 inactive_anon:17678=
 isolated_anon:0
                                    active_file:31461 inactive_file:219091 =
isolated_file:0
                                    unevictable:21 dirty:0 writeback:0 unst=
able:0
                                    slab_reclaimable:127609 slab_unreclaima=
ble:9519
                                    mapped:63113 shmem:6177 pagetables:1601=
 bounce:0
                                    free:1381579 free_pcp:583 free_cma:0
Feb 12 08:21:53 asrocke350m1 kernel: Node 0 active_anon:479572kB inactive_a=
non:70712kB active_file:125844kB inactive_file:876364kB unevictable
Feb 12 08:21:53 asrocke350m1 kernel: DMA free:3840kB min:788kB low:984kB hi=
gh:1180kB active_anon:0kB inactive_anon:0kB active_file:0kB inactiv
Feb 12 08:21:53 asrocke350m1 kernel: lowmem_reserve[]: 0 763 7663 7663
Feb 12 08:21:53 asrocke350m1 kernel: Normal free:38764kB min:38828kB low:48=
532kB high:58236kB active_anon:0kB inactive_anon:0kB active_file:16
Feb 12 08:21:53 asrocke350m1 kernel: lowmem_reserve[]: 0 0 55201 55201
Feb 12 08:21:53 asrocke350m1 kernel: HighMem free:5483712kB min:512kB low:8=
8240kB high:175968kB active_anon:479572kB inactive_anon:70712kB act
Feb 12 08:21:54 asrocke350m1 kernel: lowmem_reserve[]: 0 0 0 0
Feb 12 08:21:54 asrocke350m1 kernel: DMA: 0*4kB 42*8kB (UE) 69*16kB (UE) 7*=
32kB (UE) 10*64kB (UE) 2*128kB (U) 1*256kB (U) 2*512kB (U) 0*1024kB
Feb 12 08:21:54 asrocke350m1 kernel: Normal: 17*4kB (UME) 583*8kB (UME) 198=
3*16kB (UE) 72*32kB (ME) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*
Feb 12 08:21:54 asrocke350m1 kernel: HighMem: 2156*4kB (UM) 1334*8kB (UM) 2=
760*16kB (UM) 2087*32kB (UM) 1274*64kB (UM) 491*128kB (UM) 234*256k
Feb 12 08:21:54 asrocke350m1 kernel: Node 0 hugepages_total=3D0 hugepages_f=
ree=3D0 hugepages_surp=3D0 hugepages_size=3D2048kB
Feb 12 08:21:54 asrocke350m1 kernel: 256720 total pagecache pages
Feb 12 08:21:54 asrocke350m1 kernel: 0 pages in swap cache
Feb 12 08:21:54 asrocke350m1 kernel: Swap cache stats: add 0, delete 0, fin=
d 0/0
Feb 12 08:21:54 asrocke350m1 kernel: Free swap  =3D 4194300kB
Feb 12 08:21:54 asrocke350m1 kernel: Total swap =3D 4194300kB
Feb 12 08:21:54 asrocke350m1 kernel: 1994197 pages RAM
Feb 12 08:21:54 asrocke350m1 kernel: 1766457 pages HighMem/MovableOnly
Feb 12 08:21:54 asrocke350m1 kernel: 22689 pages reserved
Feb 12 08:21:54 asrocke350m1 kernel: 0 pages hwpoisoned
Feb 12 08:21:54 asrocke350m1 kernel: [ pid ]   uid  tgid total_vm      rss =
nr_ptes nr_pmds swapents oom_score_adj name
Feb 12 08:21:54 asrocke350m1 kernel: [  388]     0   388    18525     8958 =
     32       3        0             0 systemd-journal
Feb 12 08:21:54 asrocke350m1 kernel: [  416]     0   416     5467      391 =
      7       3        0             0 lvmetad
Feb 12 08:21:54 asrocke350m1 kernel: [  429]     0   429     4034     1047 =
      8       3        0         -1000 systemd-udevd
Feb 12 08:21:54 asrocke350m1 kernel: [  597]     0   597      835      573 =
      5       3        0             0 mdadm
Feb 12 08:21:54 asrocke350m1 kernel: [  825]   134   825     4244      992 =
      9       3        0             0 systemd-timesyn
Feb 12 08:21:54 asrocke350m1 kernel: [  835]     0   835     1428      935 =
      6       3        0             0 smartd
Feb 12 08:21:54 asrocke350m1 kernel: [  836]     0   836     1313      719 =
      6       3        0             0 cron
Feb 12 08:21:54 asrocke350m1 kernel: [  838]     0   838     1038      564 =
      6       3        0             0 anacron
Feb 12 08:21:54 asrocke350m1 kernel: [  840]     0   840     5883      751 =
     10       3        0             0 rsyslogd
Feb 12 08:21:54 asrocke350m1 kernel: [  846]     0   846     1108      410 =
      7       3        0             0 irexec
Feb 12 08:21:54 asrocke350m1 kernel: [  851]     0   851     9931     1654 =
     13       3        0             0 accounts-daemon
Feb 12 08:21:54 asrocke350m1 kernel: [  853]   104   853     1699     1110 =
      8       3        0          -900 dbus-daemon
Feb 12 08:21:54 asrocke350m1 kernel: [  867]   105   867     1563      814 =
      6       3        0             0 avahi-daemon
Feb 12 08:21:54 asrocke350m1 kernel: [  868]     0   868    23658     4150 =
     26       3        0             0 NetworkManager
Feb 12 08:21:54 asrocke350m1 kernel: [  869]     0   869     1128      420 =
      6       3        0             0 lircmd
Feb 12 08:21:54 asrocke350m1 kernel: [  870]     0   870      889      568 =
      5       3        0             0 atd
Feb 12 08:21:54 asrocke350m1 kernel: [  878]     0   878     1853     1147 =
      7       3        0             0 systemd-logind
Feb 12 08:21:54 asrocke350m1 kernel: [  879]     0   879    10954     2159 =
     16       3        0             0 ModemManager
Feb 12 08:21:54 asrocke350m1 kernel: [  887]     0   887      558       18 =
      5       3        0             0 minissdpd
Feb 12 08:21:54 asrocke350m1 kernel: [  893]   105   893     1563       73 =
      6       3        0             0 avahi-daemon
Feb 12 08:21:54 asrocke350m1 kernel: [  895]   129   895    11545     3234 =
     17       3        0             0 colord
Feb 12 08:21:54 asrocke350m1 kernel: [  904]     0   904     9909     1981 =
     15       3        0             0 polkitd
Feb 12 08:21:54 asrocke350m1 kernel: [  923]     0   923    94106     6465 =
     51       3        0             0 libvirtd
Feb 12 08:21:54 asrocke350m1 kernel: [  926]     0   926     2616     1283 =
      8       3        0         -1000 sshd
Feb 12 08:21:54 asrocke350m1 kernel: [  961]     0   961    10354     1870 =
     14       3        0             0 gdm3
Feb 12 08:21:54 asrocke350m1 kernel: [  973]     0   973     7965     1994 =
     13       3        0             0 gdm-session-wor
Feb 12 08:21:54 asrocke350m1 kernel: [ 1192]     0  1192     1207      758 =
      7       3        0             0 lircd
Feb 12 08:21:54 asrocke350m1 kernel: [ 1195]     0  1195     1129      431 =
      6       3        0             0 lircd-uinput
Feb 12 08:21:54 asrocke350m1 kernel: [ 1252]   122  1252     8304     7454 =
     21       3        0             0 tor
Feb 12 08:21:55 asrocke350m1 kernel: [ 1255]   101  1255     2813      702 =
      8       3        0             0 exim4
Feb 12 08:21:55 asrocke350m1 kernel: [ 1278]     0  1278     2856     1758 =
      9       3        0             0 wpa_supplicant
Feb 12 08:21:55 asrocke350m1 kernel: [ 1280]     0  1280     2117     1352 =
      8       3        0             0 apache2
Feb 12 08:21:55 asrocke350m1 kernel: [ 1288]    33  1288      811       39 =
      5       3        0             0 htcacheclean
Feb 12 08:21:55 asrocke350m1 kernel: [ 1289]   130  1289     2369     1407 =
      8       3        0             0 systemd
Feb 12 08:21:55 asrocke350m1 kernel: [ 1290]   130  1290     2745      392 =
      9       3        0             0 (sd-pam)
Feb 12 08:21:55 asrocke350m1 kernel: [ 1292]   130  1292     6945     1251 =
     10       3        0             0 gdm-wayland-ses
Feb 12 08:21:55 asrocke350m1 kernel: [ 1294]   130  1294     1590     1002 =
      7       3        0             0 dbus-daemon
Feb 12 08:21:55 asrocke350m1 kernel: [ 1311]   130  1311    19475     3265 =
     23       3        0             0 gnome-session-b
Feb 12 08:21:55 asrocke350m1 kernel: [ 1374]   130  1374   208428    26571 =
    111       3        0             0 gnome-shell
Feb 12 08:21:55 asrocke350m1 kernel: [ 1379]     0  1379    21121     2547 =
     18       3        0             0 upowerd
Feb 12 08:21:55 asrocke350m1 kernel: [ 1405]   130  1405    28029     9140 =
     46       3        0             0 Xwayland
Feb 12 08:21:55 asrocke350m1 kernel: [ 1411]   130  1411    11342     1415 =
     12       3        0             0 at-spi-bus-laun
Feb 12 08:21:55 asrocke350m1 kernel: [ 1416]   130  1416     1564      873 =
      7       3        0             0 dbus-daemon
Feb 12 08:21:55 asrocke350m1 kernel: [ 1418]   130  1418     7592     1544 =
     11       3        0             0 at-spi2-registr
Feb 12 08:21:55 asrocke350m1 kernel: [ 1425]   130  1425   222202     2441 =
     21       3        0             0 pulseaudio
Feb 12 08:21:55 asrocke350m1 kernel: [ 1440]     0  1440    11899     2862 =
     18       3        0             0 packagekitd
Feb 12 08:21:55 asrocke350m1 kernel: [ 1441]   130  1441   115081    12067 =
     68       3        0             0 gnome-settings-
Feb 12 08:21:55 asrocke350m1 kernel: [ 1480]     0  1480     7986     2033 =
     14       3        0             0 gdm-session-wor
Feb 12 08:21:55 asrocke350m1 kernel: [ 1486]  1000  1486     2369     1371 =
      8       3        0             0 systemd
Feb 12 08:21:55 asrocke350m1 kernel: [ 1487]  1000  1487     7355      402 =
     12       3        0             0 (sd-pam)
Feb 12 08:21:55 asrocke350m1 kernel: [ 1491]  1000  1491    10023     1922 =
     13       3        0             0 gnome-keyring-d
Feb 12 08:21:55 asrocke350m1 kernel: [ 1494]  1000  1494     7424     1403 =
     11       3        0             0 gdm-x-session
Feb 12 08:21:55 asrocke350m1 kernel: [ 1496]  1000  1496    33920    14489 =
     59       3        0             0 Xorg
Feb 12 08:21:55 asrocke350m1 kernel: [ 1500]  1000  1500     1589      997 =
      7       3        0             0 dbus-daemon
Feb 12 08:21:55 asrocke350m1 kernel: [ 1505]  1000  1505    14890     7121 =
     24       3        0             0 awesome
Feb 12 08:21:55 asrocke350m1 kernel: [ 1534]  1000  1534     4310     1673 =
     10       3        0             0 arbtt-capture
Feb 12 08:21:55 asrocke350m1 kernel: [ 1628]  1000  1628     1180       54 =
      6       3        0             0 ssh-agent
Feb 12 08:21:55 asrocke350m1 kernel: [ 1635]  1000  1635    11361     1459 =
     12       3        0             0 at-spi-bus-laun
Feb 12 08:21:55 asrocke350m1 kernel: [ 1640]  1000  1640     1564      873 =
      6       3        0             0 dbus-daemon
Feb 12 08:21:55 asrocke350m1 kernel: [ 1644]  1000  1644     7594     1294 =
     13       3        0             0 at-spi2-registr
Feb 12 08:21:55 asrocke350m1 kernel: [ 1646]  1000  1646    21040     8672 =
     36       3        0             0 gnome-terminal-
Feb 12 08:21:55 asrocke350m1 kernel: [ 1653]  1000  1653    10027     1331 =
     15       3        0             0 gvfsd
Feb 12 08:21:55 asrocke350m1 kernel: [ 1658]  1000  1658    13148     1359 =
     15       3        0             0 gvfsd-fuse
Feb 12 08:21:55 asrocke350m1 kernel: [ 1672]  1000  1672     1773     1222 =
      7       3        0             0 bash
Feb 12 08:21:55 asrocke350m1 kernel: [ 1681]  1000  1681    15803    13913 =
     36       3        0             0 gdb
Feb 12 08:21:55 asrocke350m1 kernel: [ 1689]  1000  1689     1759     1205 =
      6       3        0             0 bash
Feb 12 08:21:55 asrocke350m1 kernel: [ 1700]  1000  1700     1759     1211 =
      7       3        0             0 bash
Feb 12 08:21:55 asrocke350m1 kernel: [ 1713]  1000  1713    19912     7108 =
     29       3        0             0 nm-applet
Feb 12 08:21:55 asrocke350m1 kernel: [ 1724]  1000  1724    10075     1350 =
     12       3        0             0 gnome-keyring-d
Feb 12 08:21:55 asrocke350m1 kernel: [ 1730]     0  1730     2026      927 =
      7       3        0             0 dhclient
Feb 12 08:21:55 asrocke350m1 kernel: [ 1925]     0  1925      555      321 =
      5       3        0             0 run-parts
Feb 12 08:21:56 asrocke350m1 kernel: [ 2208]    33  2208     2123     1124 =
      8       3        0             0 apache2
Feb 12 08:21:56 asrocke350m1 kernel: [ 2209]    33  2209     2123      795 =
      7       3        0             0 apache2
Feb 12 08:21:56 asrocke350m1 kernel: [ 2210]    33  2210     2123      795 =
      7       3        0             0 apache2
Feb 12 08:21:57 asrocke350m1 kernel: [ 2211]    33  2211     2123      795 =
      7       3        0             0 apache2
Feb 12 08:21:58 asrocke350m1 kernel: [ 2212]    33  2212     2123      795 =
      7       3        0             0 apache2
Feb 12 08:21:59 asrocke350m1 kernel: [ 2213]    33  2213     2123      795 =
      7       3        0             0 apache2
Feb 12 08:21:59 asrocke350m1 kernel: [ 2227]     0  2227     3831     1969 =
     12       3        0             0 cupsd
Feb 12 08:21:59 asrocke350m1 kernel: [ 2308]     0  2308     1307      712 =
      6       3        0             0 mlocate
Feb 12 08:22:00 asrocke350m1 kernel: [ 2313]     0  2313     1008      160 =
      6       3        0             0 flock
Feb 12 08:22:01 asrocke350m1 kernel: [ 2314]     0  2314     1183      726 =
      7       3        0             0 updatedb.mlocat
Feb 12 08:22:01 asrocke350m1 kernel: [ 2780]  1000  2780     2559     1409 =
      8       3        0             0 ssh
Feb 12 08:22:01 asrocke350m1 kernel: [ 2789]  1000  2789     1773     1264 =
      7       3        0             0 bash
Feb 12 08:22:01 asrocke350m1 kernel: [ 2798]  1000  2798   208137    83634 =
    291       3        0             0 firefox-esr
Feb 12 08:22:01 asrocke350m1 kernel: [ 2807]  1000  2807     1760     1253 =
      7       3        0             0 bash
Feb 12 08:22:01 asrocke350m1 kernel: [ 2833]  1000  2833     3332     1638 =
     11       3        0             0 gconfd-2
Feb 12 08:22:01 asrocke350m1 kernel: [ 2883]  1000  2883     2944     2168 =
      8       3        0             0 vim
Feb 12 08:22:02 asrocke350m1 kernel: [ 2895]  1000  2895     1784     1327 =
      7       3        0             0 bash
Feb 12 08:22:03 asrocke350m1 kernel: [ 4298]  1000  4298     3444     2800 =
     10       3        0             0 debcheckout
Feb 12 08:22:03 asrocke350m1 kernel: [ 4302]  1000  4302     1898      998 =
      7       3        0             0 git
Feb 12 08:22:03 asrocke350m1 kernel: [ 4303]  1000  4303    11054     6508 =
     22       3        0             0 git-remote-http
Feb 12 08:22:04 asrocke350m1 kernel: [ 4306]  1000  4306     4232      983 =
      8       3        0             0 git
Feb 12 08:22:04 asrocke350m1 kernel: [ 4309]  1000  4309     2621     1522 =
      8       3        0             0 git
Feb 12 08:22:04 asrocke350m1 kernel: [ 4322]     0  4322     1408      829 =
      6       3        0             0 inetd
Feb 12 08:22:05 asrocke350m1 kernel: Out of memory: Kill process 2798 (fire=
fox-esr) score 27 or sacrifice child
Feb 12 08:22:05 asrocke350m1 kernel: Killed process 2798 (firefox-esr) tota=
l-vm:832548kB, anon-rss:248168kB, file-rss:86300kB, shmem-rss:68kB
Feb 12 08:22:06 asrocke350m1 kernel: perf: interrupt took too long (2505 > =
2500), lowering kernel.perf_event_max_sample_rate to 79750
```

The sum of the RSS values is 312,260. According to the article [1], one
page is 4 KB in size. That make it less then 1.3 GB.

```
$ more /proc/meminfo=C2=A0# after OOM run
MemTotal:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A07886032 kB
MemFree:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01613032 kB
MemAvailable:=C2=A0=C2=A0=C2=A0=C2=A04510132 kB
Buffers:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0160536 =
kB
Cached:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A03103908 =
kB
SwapCached:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A00 kB
Active:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A04004748 =
kB
Inactive:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01629624 kB
Active(anon):=C2=A0=C2=A0=C2=A0=C2=A02255340 kB
Inactive(anon):=C2=A0=C2=A0=C2=A0158560 kB
Active(file):=C2=A0=C2=A0=C2=A0=C2=A01749408 kB
Inactive(file):=C2=A0=C2=A01471064 kB
Unevictable:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0232 kB
Mlocked:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0232 kB
HighTotal:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A07065828 kB
HighFree:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01555764 kB
LowTotal:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0820204 kB
LowFree:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A05=
7268 kB
SwapTotal:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A04194300 kB
SwapFree:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A04194300 kB
Dirty:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A012 kB
Writeback:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A00 kB
AnonPages:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02370220 kB
Mapped:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A041=
9968 kB
Shmem:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A043972 kB
Slab:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0460304 kB
SReclaimable:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0423320 kB
SUnreclaim:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A036984 kB
KernelStack:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A04224 kB
PageTables:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A014580 kB
NFS_Unstable:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 =
kB
Bounce:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 kB
WritebackTmp:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 =
kB
CommitLimit:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A08137316 kB
Committed_AS:=C2=A0=C2=A0=C2=A0=C2=A05379296 kB
VmallocTotal:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0122880 kB
VmallocUsed:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A00 kB
VmallocChunk:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 =
kB
HardwareCorrupted:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 kB
AnonHugePages:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 kB
ShmemHugePages:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 kB
ShmemPmdMapped:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 kB
HugePages_Total:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
HugePages_Free:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
HugePages_Rsvd:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
HugePages_Surp:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00
Hugepagesize:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02048 kB
DirectMap4k:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A010232 kB
DirectMap2M:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0901120 kB
```

So I wonder, why the OOM killer kicked in at all.

Hints and insight is appreciated.


Thanks,

Paul


[1] http://careers.directi.com/display/tu/Understanding+and+optimizing+Memo=
ry+utilization
--=-JFbwB/ydJ+Ohi8AMSLG2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iF0EABECAB0WIQQ8+w9d414FAVARIpk9fVorbA4dWAUCWKBnYQAKCRA9fVorbA4d
WN1QAJ9nFPeIzITYOvYcE6jlw9QuyRC5LgCfToTlmD5ogNSCCx7jcyvOR3oFWJg=
=GFai
-----END PGP SIGNATURE-----

--=-JFbwB/ydJ+Ohi8AMSLG2--
