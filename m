Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id DD5DC6B0044
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 18:36:14 -0400 (EDT)
Date: Sun, 5 Aug 2012 18:36:11 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: [bugzilla-daemon@bugzilla.kernel.org: [Bug 45621] New: Kernel ooops:
 BUG: unable to handle kernel paging request at 000000080000001c]
Message-ID: <20120805223611.GC6946@thunk.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="qcHopEYAB45HaUaB"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org


--qcHopEYAB45HaUaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi, I'm hoping this rings a bell with an mm developer:

	https://bugzilla.kernel.org/show_bug.cgi?id=45621

It looks like the user is reporting a OOPS which was caused by the
inode's mapping->page_tree having gotten corrupted.  The call stack
was from a write system call while the system was undergoing heavy
I/O, on a v3.4.7 kernel.

If someone could take a quick look at this, I'd really appreciate it.
Thanks!!

						- Ted

--qcHopEYAB45HaUaB
Content-Type: message/rfc822
Content-Disposition: inline

Return-Path: <linux-ext4-owner@vger.kernel.org>
Received: from po14.mit.edu ([unix socket])
	by po14.mit.edu (Cyrus v2.1.5) with LMTP; Sat, 04 Aug 2012 19:33:27 -0400
X-Sieve: CMU Sieve 2.2
Received: from mit-mailsec-scanner-6.mit.edu by po14.mit.edu (8.13.6/4.7) id q74NXRXR019702; Sat, 4 Aug 2012 19:33:27 -0400 (EDT)
Received: from mailhub-dmz-4.mit.edu ( [18.7.62.38])
	by mit-mailsec-scanner-6.mit.edu (Symantec Messaging Gateway) with SMTP id 48.5C.02090.641BD105; Sat,  4 Aug 2012 19:33:26 -0400 (EDT)
Received: from dmz-mailsec-scanner-4.mit.edu (DMZ-MAILSEC-SCANNER-4.MIT.EDU [18.9.25.15])
	by mailhub-dmz-4.mit.edu (8.13.8/8.9.2) with ESMTP id q74NXQA2000532
	for <tytso@mit.edu>; Sat, 4 Aug 2012 19:33:26 -0400
X-AuditID: 12074f11-b7fda6d00000082a-69-501db14645f3
Authentication-Results: symauth.service.identifier
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by dmz-mailsec-scanner-4.mit.edu (Symantec Messaging Gateway) with SMTP id 96.A6.02228.641BD105; Sat,  4 Aug 2012 19:33:26 -0400 (EDT)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
	id S1754196Ab2HDXdX (ORCPT <rfc822;tytso@mit.edu>);
	Sat, 4 Aug 2012 19:33:23 -0400
Received: from mail.kernel.org ([198.145.19.201]:50026 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754151Ab2HDXdW (ORCPT <rfc822;linux-ext4@vger.kernel.org>);
	Sat, 4 Aug 2012 19:33:22 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id BB7FE201FD
	for <linux-ext4@vger.kernel.org>; Sat,  4 Aug 2012 23:33:20 +0000 (UTC)
Received: from bugzilla.kernel.org (unknown [198.145.19.217])
	by mail.kernel.org (Postfix) with ESMTP id B58DF201FE
	for <linux-ext4@vger.kernel.org>; Sat,  4 Aug 2012 23:33:18 +0000 (UTC)
Received: by bugzilla.kernel.org (Postfix, from userid 1000)
	id 13A6911FC6C; Sat,  4 Aug 2012 23:33:18 +0000 (UTC)
From: bugzilla-daemon@bugzilla.kernel.org
To: linux-ext4@vger.kernel.org
Subject: [Bug 45621] New: Kernel ooops: BUG: unable to handle kernel paging
 request at 000000080000001c
X-Bugzilla-Reason: None
X-Bugzilla-Type: newchanged
X-Bugzilla-Watch-Reason: AssignedTo fs_ext4@kernel-bugs.osdl.org
X-Bugzilla-Product: File System
X-Bugzilla-Component: ext4
X-Bugzilla-Keywords: 
X-Bugzilla-Severity: normal
X-Bugzilla-Who: markus.doits@googlemail.com
X-Bugzilla-Status: NEW
X-Bugzilla-Priority: P1
X-Bugzilla-Assigned-To: fs_ext4@kernel-bugs.osdl.org
X-Bugzilla-Target-Milestone: ---
X-Bugzilla-Changed-Fields: 
Message-ID: <bug-45621-13602@https.bugzilla.kernel.org/>
Auto-Submitted: auto-generated
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
Date: Sat,  4 Aug 2012 23:33:18 +0000 (UTC)
X-Spam-Status: No, score=-1.1 required=5.0 tests=BAYES_00,RDNS_NONE,
	UNPARSEABLE_RELAY autolearn=no version=3.3.1
X-Spam-Checker-Version: SpamAssassin 3.3.1 (2010-03-16) on mail.kernel.org
X-Virus-Scanned: ClamAV using ClamSMTP
Sender: linux-ext4-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-ext4.vger.kernel.org>
X-Mailing-List: linux-ext4@vger.kernel.org
X-Brightmail-Tracker: H4sIAAAAAAAAA01SXUxSYRj2g+PhSJw8IMoXRTbWKptQOisuHHNrVhdt2FWri+qkR2EDdOcg
	w260slLLzX7W0pCa1kUlaWlDa5W5zCAUtWl/2oWzVmSby9xSKjqHT6q75/2e533en+8lxAo/
	riYYl4Nh7bRVi0sxhcS4TrfjjqZgc/fXXMOJMwuSPLDrWLBfXAD2S3OLGKvFybCbjIek5htz
	brxscoPrlPcpVgV82jpAEJDKgW8XTHUgiYdpcPh9Oy5gBfUQwJA3uw5IeTwO4NDtdxgS5cD6
	xd6YCFDZ8MFQOBGJAgD2tNeJUeABsMY/J0FBmE93z4tQ0M0Hrz1iVOQxgLeiDMIO2Dp2OuaL
	Uxmw9fyZWD0ltRqGJ7yx9xTKAps/RHDUtwr+/rUStbQSPnj5U4RwHvw43oQjnA6P3vMtYTWc
	ab2/hFNhe0sEj+e6J2qWcjPhlaEOLL6LkR73ElbBa88eAVR2C5wcNCG4Bs56pHGX4c5AooBJ
	ygB7W2ZEaEHp8LTvSaySmB/qhC8iQRo59DdOYw0go+k/quk/6ioQ3QQam8Whs9EWK8cU6rhC
	2m5nWN1WPf+qZ4rK74LY75vk3eDb6Oo+QBFAKyMPr11VoEiknVyFrQ+sIETaVPKTV1OgWH64
	tKjCTHPmg2y5leH6ACTEWiW5kM5zZBFdcYRhS+OUniCoX489A4CafhMaAGrMXmpntJA0dvBi
	OcuUMK5ii5U/wXiCiEgSDGW8oUvQkFwZbeMsJYgPAB0xuDj9DihiRmoVuUcQUYLIXG7/6yNc
	c2U0Gh0FGnUKCRISEhSyMoblx/3Hj1R3bZ8CcuKzRIFLRYydUqPuwkDFj59COgVnmcXu+Fud
	vz5+C0rSuFUtNOag/1HqKtAyO+x5aPBfDyd/uZzlpL5fqcpXLsseq321fof7R+iycaxwXBow
	dfa0BqPV+4Znb0R2Vubjydh8R47jXK3hpLVftuVsbqatUfVCj13wK9uCh0JsV3CooWY+LyPN
	TU/MHK89bjow9fT6xernTf2v99Yvb27bfR5EJ7NObestbr6kxTgznbVRzHL0H8xDZtfcAwAA
X-Brightmail-Tracker: H4sIAAAAAAAAA+NgFrrHJsWRWlGSWpSXmKPExsVysWWLs67bRtkAg2MHZC1ae36yOzB6NJ05
	yhzAGMVlk5Kak1mWWqRvl8CVsfLzHLaCuxoV7WuPsDQwblfqYuTkkBAwkej9dYANxGYUMJLY
	fe4VK0RcTOLCvfVAcS4OIYFTjBI713cxQzjzGCU6Tn5mh3BeMUqcm/OVCcLZAeTcmMcM0i8k
	sJ9RYvX/VAi7RGLx1W6wHWwCmhLXZ9wGqxERkJN48+UjO4gtLJApMffpb6AaDqDd4hL//kpD
	nCEtsfvyHyYI20Hi2bVZbBC2vETj1u1QtpTEm8W7oGxRifWLfrPB9M650wHVqy3xamMTO8xr
	F3fOYYGwxSWWHNvHCAuK+Xv/skCcoCDxYR4XzJgLm0+BQ4VXwELiwKI3TJDQkpM4OuEp2Ehm
	oK9at/9mh6gRlDg58wnYeBagtee6u6DWFks8b1oOdY6XxMIfl9knMKrOQtI+C0n7AkamVYyy
	KblVurmJmTnFqcm6xcmJeXmpRbomermZJXqpKaWbGIHRL8Qpyb+D8dtBpUOMAhyMSjy8ySoy
	AUKsiWXFlbmHGCU5mJREeV+slQ0Q4kvKT6nMSCzOiC8qzUktPsQowcGsJML7Ux4ox5uSWFmV
	WpQPk5LmYFES572actNfSCA9sSQ1OzW1ILUIJsvEwX6IUY+DQ+Dv/nnHGQWe3Dx/nFGKJS8/
	L1VJgrdtA9A8waLU9NSKtMycEmRdnCCCC2QxD9BiC5BC3uKCxNzizHSIolOMuhxnfz25zSgE
	Nk1KnDcQpEgApCijNA9uGCjZ1/////8So6yUMC8jAwODEA/QfcBgQciDssUrRnFgkAjz2oBM
	4cnMK4HbBEy2wJAR4bUzkwI5oiQRISXVwKi0Pv3np/CVoQsm/p200bDkjm2v6jn7YJ5OdSfp
	dIdMeSv76PJsNqNbwqeu7qkRCahb+zBiyiKp2Skv2bpX8H7+5Ph39Zsjrcrua5/cXqPblBu6
	c//9S9b+oh2fOWLPCt4RDd6dbdzxOy9hr0BRyAX2+YK/fig7ROzxfj/jxVL7k/8z2zdOO6DE
	UpyRaKjFXFScCABx0rTG8QMAAA==

https://bugzilla.kernel.org/show_bug.cgi?id=45621

           Summary: Kernel ooops: BUG: unable to handle kernel paging
                    request at 000000080000001c
           Product: File System
           Version: 2.5
    Kernel Version: 3.4.7
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: ext4
        AssignedTo: fs_ext4@kernel-bugs.osdl.org
        ReportedBy: markus.doits@googlemail.com
        Regression: No


During heavy io on my ext4 filesystems, I sometimes get this oops:


[10645.902287] BUG: unable to handle kernel paging request at 000000080000001c
[10645.902881] IP: [<ffffffff8110c4d1>] find_get_page+0x41/0xa0
[10645.903359] PGD 1e21cb067 PUD 0 
[10645.903638] Oops: 0000 [#1] PREEMPT SMP 
[10645.903986] CPU 1 
[10645.904147] Modules linked in: md5 aes_x86_64 aes_generic xts gf128mul
dm_crypt dm_mod usb_storage uas nfsd exportfs tun w83627ehf hwmon_vid
iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_conntrack ip_tables x_tables rc_dib0700_rc5 dvb_usb_dib0700
dib3000mc dib8000 dib0070 dib7000m dib7000p dibx000_common dib0090 dvb_usb
dvb_core microcode i915 iTCO_wdt i2c_algo_bit drm_kms_helper intel_agp
iTCO_vendor_support drm psmouse ghash_clmulni_intel mei(C) evdev atl1c rc_core
intel_gtt pcspkr serio_raw i2c_i801 i2c_core acpi_cpufreq mperf processor
cryptd coretemp crc32c_intel video button loop fuse nfs nfs_acl lockd
auth_rpcgss sunrpc fscache ext4 crc16 jbd2 mbcache sd_mod ahci libahci ehci_hcd
xhci_hcd libata scsi_mod usbcore usb_common
[10645.910482] 
[10645.910602] Pid: 2958, comm: rsync Tainted: G         C   3.4.7-1-ARCH #1 To
Be Filled By O.E.M. To Be Filled By O.E.M./H61M/U3S3
[10645.911595] RIP: 0010:[<ffffffff8110c4d1>]  [<ffffffff8110c4d1>]
find_get_page+0x41/0xa0
[10645.912276] RSP: 0018:ffff8801fe1eba28  EFLAGS: 00010246
[10645.912713] RAX: ffff880100ad1198 RBX: 0000000800000000 RCX:
00000000fffffffa
[10645.913303] RDX: 0000000000000001 RSI: ffff880100ad1198 RDI:
0000000000000000
[10645.913893] RBP: ffff8801fe1eba48 R08: 0000000800000000 R09:
ffff880100ad0f88
[10645.914481] R10: ffffffffa0188e00 R11: 0000000000000000 R12:
ffff88008a307058
[10645.915071] R13: 00000000000084bf R14: 000000000102005a R15:
0000000000000050
[10645.915663] FS:  00007f8c4d7f4700(0000) GS:ffff88021f280000(0000)
knlGS:0000000000000000
[10645.916333] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[10645.916807] CR2: 000000080000001c CR3: 00000001d296a000 CR4:
00000000000407e0
[10645.917393] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[10645.917985] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[10645.918574] Process rsync (pid: 2958, threadinfo ffff8801fe1ea000, task
ffff880211fcafa0)
[10645.919250] Stack:
[10645.919413]  ffff8801fe1eba48 ffff88008a307050 00000000000084bf
00000000000084bf
[10645.920059]  ffff8801fe1eba78 ffffffff8110c6d6 ffff8801fe1eba68
ffffffffa00558d3
[10645.920702]  0000000000000004 ffff88008a307050 ffff8801fe1ebac8
ffffffff8110cdf2
[10645.921344] Call Trace:
[10645.942181]  [<ffffffff8110c6d6>] find_lock_page+0x26/0x80
[10645.963412]  [<ffffffffa00558d3>] ? jbd2_journal_start+0x13/0x20 [jbd2]
[10645.984833]  [<ffffffff8110cdf2>] grab_cache_page_write_begin+0x72/0x100
[10645.984853]  [<ffffffffa0149bf0>] ext4_da_write_begin+0xa0/0x230 [ext4]
[10645.984858]  [<ffffffffa014c47d>] ? ext4_da_write_end+0xad/0x390 [ext4]
[10645.984861]  [<ffffffff8110be74>] generic_file_buffered_write+0x124/0x2b0
[10645.984864]  [<ffffffff8110da4a>] __generic_file_aio_write+0x22a/0x440
[10645.984868]  [<ffffffff8146775e>] ? __mutex_lock_slowpath+0x24e/0x340
[10645.984871]  [<ffffffff8110dcd1>] generic_file_aio_write+0x71/0xe0
[10645.984876]  [<ffffffffa014334f>] ext4_file_write+0xaf/0x260 [ext4]
[10645.984879]  [<ffffffff8116e286>] do_sync_write+0xe6/0x120
[10645.984883]  [<ffffffff811f8a9c>] ? security_file_permission+0x2c/0xb0
[10645.984885]  [<ffffffff8116e871>] ? rw_verify_area+0x61/0xf0
[10645.984887]  [<ffffffff8116eb88>] vfs_write+0xa8/0x180
[10645.984888]  [<ffffffff8116eeca>] sys_write+0x4a/0xa0
[10645.984891]  [<ffffffff8146aaa9>] system_call_fastpath+0x16/0x1b
[10645.984892] Code: 89 f5 4c 8d 63 08 e8 3f 8e fc ff 4c 89 ee 4c 89 e7 e8 f4
77 13 00 48 85 c0 48 89 c6 74 44 48 8b 18 48 85 db 74 22 f6 c3 03 75 3f <8b> 53
1c 85 d2 74 d9 8d 7a 01 89 d0 f0 0f b1 7b 1c 39 c2 75 26 
[10645.984908] RIP  [<ffffffff8110c4d1>] find_get_page+0x41/0xa0
[10645.984910]  RSP <ffff8801fe1eba28>
[10645.984911] CR2: 000000080000001c
[10646.075497] ---[ end trace 9841da8b9a0cb390 ]---

Using archlinux stable.

Anything else I can do to hunt this bug down?

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are watching the assignee of the bug.
--
To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

--qcHopEYAB45HaUaB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
