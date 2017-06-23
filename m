Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1F726B02F4
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 23:27:23 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y141so13594677qka.13
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 20:27:23 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2607:b400:92:8400:0:33:fb76:806e])
        by mx.google.com with ESMTPS id p66si2965527qka.166.2017.06.22.20.27.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 20:27:22 -0700 (PDT)
Received: from mr2.cc.vt.edu (mail.ipv6.vt.edu [IPv6:2607:b400:92:9:0:9d:8fcb:4116])
	by omr2.cc.vt.edu (8.14.4/8.14.4) with ESMTP id v5N3RMXS023219
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 23:27:22 -0400
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by mr2.cc.vt.edu (8.14.7/8.14.7) with ESMTP id v5N3RG0m004316
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 23:27:22 -0400
Received: by mail-qk0-f199.google.com with SMTP id u126so13659165qka.9
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 20:27:22 -0700 (PDT)
From: valdis.kletnieks@vt.edu
Subject: next-20170620 BUG in do_page_fault / do_huge_pmd_wp_page
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1498188418_9806P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 22 Jun 2017 23:26:58 -0400
Message-ID: <20815.1498188418@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

--==_Exmh_1498188418_9806P
Content-Type: text/plain; charset=us-ascii

Saw this at boot of next-20170620.  Not sure how I managed to hit 4 BUG in a row...

Looked in 'git log -- mm/' but not seeing anything blatantly obvious.

This ringing any bells?  I'm not in a position to recreate or bisect this until
the weekend.

[  315.409076] BUG: Bad rss-counter state mm:ffff8a223deb4640 idx:0 val:-512
[  315.412889] BUG: Bad rss-counter state mm:ffff8a223deb4640 idx:1 val:512
[  315.416694] BUG: non-zero nr_ptes on freeing mm: 1
[  315.436098] BUG: Bad page state in process gdm  pfn:3e8400
[  315.439802] page:ffffe8af0fa10000 count:-1 mapcount:0 mapping:          (null) index:0x1
[  315.443264] flags: 0x4000000000000000()
[  315.446715] raw: 4000000000000000 0000000000000000 0000000000000001 ffffffffffffffff
[  315.450181] raw: dead000000000100 dead000000000200 0000000000000000 0000000000000000
[  315.453628] page dumped because: nonzero _count
[  315.457023] Modules linked in: ts_bm nf_log_ipv4 xt_string nf_log_ipv6 nf_log_common xt_LOG sunrpc vfat fat brcmsmac cordic brcmutil dell
_wmi x86_pkg_temp_thermal crct10dif_pclmul dell_laptop crc32_pclmul crc32c_intel dell_smbios ghash_clmulni_intel dell_smm_hwmon cryptd bcma
mei_wdt dell_smo8800 dell_rbtn sch_fq tcp_bbr
[  315.457116] CPU: 3 PID: 6684 Comm: gdm Not tainted 4.12.0-rc6-next-20170620 #506
[  315.457119] Hardware name: Dell Inc. Latitude E6530/07Y85M, BIOS A19 01/04/2017
[  315.457122] Call Trace:
[  315.457131]  dump_stack+0x83/0xd1
[  315.457141]  bad_page+0x10c/0x1b0
[  315.457151]  check_new_page_bad+0x12e/0x180
[  315.457159]  get_page_from_freelist+0x756/0x1840
[  315.457170]  ? native_sched_clock+0x80/0xf0
[  315.457184]  ? find_held_lock+0x38/0x160
[  315.457194]  __alloc_pages_nodemask+0x145/0x5a0
[  315.457211]  do_huge_pmd_wp_page+0x58d/0x1380
[  315.457217]  ? cyc2ns_read_begin+0x82/0xb0
[  315.457224]  ? cyc2ns_read_end+0x22/0x40
[  315.457229]  ? native_sched_clock+0x80/0xf0
[  315.457236]  ? native_sched_clock+0x80/0xf0
[  315.457247]  __handle_mm_fault+0x831/0x14e0
[  315.457253]  ? sched_clock_cpu+0x1b/0x1e0
[  315.457273]  handle_mm_fault+0x23c/0x6f0
[  315.457283]  __do_page_fault+0x460/0x950
[  315.457298]  do_page_fault+0xc/0x10
[  315.457305]  page_fault+0x22/0x30
[  315.457310] RIP: 0033:0x7fe15390e5c1
[  315.457314] RSP: 002b:00007ffd2acdca30 EFLAGS: 00010202
[  315.457320] RAX: 0000000000000000 RBX: 00007ffd2acdca50 RCX: 0000000000000000
[  315.457324] RDX: 0000000000801000 RSI: 00007fe14bfff9c0 RDI: 00007fe14b7fec10
[  315.457328] RBP: 00007ffd2acdcac0 R08: 00007fe14b7fed10 R09: 00007fe153b22030
[  315.457331] R10: 00007fe155346900 R11: 0000000000000202 R12: 0000000000000000
[  315.457335] R13: 0000000000000000 R14: 0000000000000001 R15: 00007fe155413000
[  315.457354] Disabling lock debugging due to kernel taint




--==_Exmh_1498188418_9806P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Comment: Exmh version 2.8.0 04/21/2017

iQEVAwUBWUyKgo0DS38y7CIcAQKsjgf/SeEk9/waypDalu6gJGpUu9rGFcMJOs9S
e87cgP8wuoDnpYrNgVTpj6OoD3cGk0a/aQOdSYW3oBGIQklDtrtfaFVjiqtMUHPp
5/O2m4LwcVhqeGLDJ0dKpniAtjrlAsGKsMh0jg8TA9RhTID37shv+bquBoo7HMqV
/WOLSAW5VY6GCF6GSScv5Lrauy9OgPUb7BET4C2OXmCu1VU8IXiy+mwE7K4WfE57
IwcWs/J2TDPeAb68h8jzzK2/3OWvZeM3mHe+TkdqqgMyMGw2IjDwlnPasyvUNPaL
ChfNE6OuWKaUIjKM4ImfNxWT0d4SJJtFKNj93E7LSMrJP4bJV46KAg==
=UXAj
-----END PGP SIGNATURE-----

--==_Exmh_1498188418_9806P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
