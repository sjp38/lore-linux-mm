Return-Path: <SRS0=dGUi=PF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96030C43387
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 22:03:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C986217F9
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 22:03:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NVEja3Ro"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C986217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EB0E8E0051; Fri, 28 Dec 2018 17:03:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 976218E0001; Fri, 28 Dec 2018 17:03:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F0008E0051; Fri, 28 Dec 2018 17:03:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 46E0B8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 17:03:57 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id c128so26571707itc.0
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 14:03:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6fzHwK98sX37hAnQJREDQvp3zZRSlcUJzOYI17XILO4=;
        b=PMQbA7jx2m7hZUW79TLfcnsQmcmL9JGy1xmB38JXcD7p9TwIYAzxGcT/rLhYPg5GhG
         xLqZAjPjLkNr4eiWdkuP38sgCr6+RV6D78HUpJtOgHHODDd+xWcoponRSZX5bNbOUf/D
         heriw+ctMsp0e8zZ7zVyb2jYDbT9Pl5Yd45lTkQX/qRrLJAG9hboefRHyUL2Qy86+sRX
         tLWLxyCz3dhSdlsN4tKlcSjOPyFKzBdv03xhTr3UaaAXOcUsSmxz/hDhfCGQsKYbEn97
         bcU3+Dg0jfFnsB3vfI6S6ojHLecryCTrbX+eJepndc85fNv7lkAVTz1sifsD1ps41SPf
         bI/A==
X-Gm-Message-State: AA+aEWYICd+gNhS7RsG9szDH1/nEkxHY/kl1FOZG093x9lSievWtgQJF
	PENWpmF6WfA2A7UYbVC35r3YXbAwmtmQtCMdsjDugZbN7gLxrU4TXVLC3mT+smvpNJ8/icHGe6j
	OKdYdpMipuk+CF9Nvrvg1AiAIpx9C7SzOiLsR1vxeML0wkhcJdgRTto3KbP3C6kzP3VYqgenj/I
	4AZ6JRWssP4Z86LHfD8fPmYyOttD8Ps7wORET2TigDiEMwDfru+uZPtcWuHBfTnYh+K109g9hcs
	f1ZIi7RPzJWBR4gGAZ+1rab6cBuLa51O2X/JfB1rH2TU+WbLPiNV3Qg4eFUmQk6EmEwKAuAgRws
	QqmA7RAYdJxwZuaat1UEDwrrro1izX3i2fM0gcFuPDFKnlHmh8wncNi0Cj4DoNNLMg+QtxTdmzV
	M
X-Received: by 2002:a24:f2c1:: with SMTP id j184mr18219592ith.35.1546034636988;
        Fri, 28 Dec 2018 14:03:56 -0800 (PST)
X-Received: by 2002:a24:f2c1:: with SMTP id j184mr18219529ith.35.1546034634967;
        Fri, 28 Dec 2018 14:03:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546034634; cv=none;
        d=google.com; s=arc-20160816;
        b=BFWvizl/G0b+8TQgHSqfysvWOr+Zb2HVdkaf9tB9fd31E3CIsRgv0Mnx8MfgAvydEm
         /e6iONPNi2Twew8EoVBrGjJxw6oNYjVEeSpWZLj0Uy9t35hM1Q/6re+J9B0P9ReJHdth
         76bL1d/DOI6dNJe87X8K7FTYQNnhBvTDO5dnxPry8kQT4nX+3ZsSvR3GEqRNO+3MB55U
         Op2+uHteTiXTfhEYntFaw9zBdvgH8j+yAOaFsn6Kwx/483lJpeGCYJPWOwhlI538wNCH
         g6jUGRpzeyPlWRdxbKWu8e53FMUqjQfsaCnVdn0HEO5ahkYLa2oKmrDanFuUPVYA9VB4
         C3gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6fzHwK98sX37hAnQJREDQvp3zZRSlcUJzOYI17XILO4=;
        b=al1oJmS3eD9lPu7sZujxh/h5ISiv2Sl+gCYUGnmu/I5SUxd1r9JE4sD1le5ovAA1z+
         CEk7wotMLkXCnW3ke7VYdO6ruGc02BUxrv5fIKs/jmENZUgWiKqz/FcdNgszoyjMjd0W
         UMvPl/Ax93B/kza4K9mMjT4tIPbghI1Op+rbI1TUiTzvMjDBPfdy2Cp3NlQrHPXkqdpR
         mswbzd17Hfqs7QO4XswOcteu2vIgz9frQzWqyAvXn6cmMW60TGHFQMK+RnQMVPtEuC+S
         myTA3jxGEWoSM+wkuKqzJDyN2PRYAey32g8dNWjM98B+2m9oFc3ys08vUBkjt16z44iU
         69DQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NVEja3Ro;
       spf=pass (google.com: domain of wonderfly@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=wonderfly@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x13sor4137665ion.71.2018.12.28.14.03.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 14:03:54 -0800 (PST)
Received-SPF: pass (google.com: domain of wonderfly@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NVEja3Ro;
       spf=pass (google.com: domain of wonderfly@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=wonderfly@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6fzHwK98sX37hAnQJREDQvp3zZRSlcUJzOYI17XILO4=;
        b=NVEja3RomOrde2tB466VH+FfCyKrAKfaBkvdPJF9vvVu7Qwmz745eoLXo9tpmf8Ad8
         nHdH2QCZeFVT6l6yFuLI7TpH+mtShS/0GN/FTJsYDi5B6JdAlU3F0G5t0fCDYsltVxLJ
         6stjDNnAFqWjlASmGJnqMPXFzzyb6OcU9MDwYLDdMBfStGpj9Q2Gde1H4dp4FrAY9eJi
         GyngC9pNibzqRAlubz6AbhymJmy4/xYoKLPSyHRa5vEYMRuFzqEVEgOLQU7/cfZ0k3V5
         5xTk5YGfFkg4pCTK+saUziE2FRDuv7SDBYtZITCVrv+jLmt71Y9C1sxBedop6cRkG1if
         rZkw==
X-Google-Smtp-Source: ALg8bN5Hx10Td7ucjaXGREFWt42aJWDQ6WwqFhbwo6QzVNwxOomZHTJ2pv++zsQK04/BKNAtMbdJm1TBt5urGNcJ1q8=
X-Received: by 2002:a5d:890c:: with SMTP id b12mr5529501ion.196.1546034633563;
 Fri, 28 Dec 2018 14:03:53 -0800 (PST)
MIME-Version: 1.0
References: <20181022100952.GA1147@jagdpanzerIV> <CAJmjG2-c4e_1999n0OV5B9ABG9rF6n=myThjgX+Ms1R-vc3z+A@mail.gmail.com>
 <20181109064740.GE599@jagdpanzerIV> <CAJmjG28Q8pEpr67LC+Un8m+Qii58FTd1esp6Zc47TnMsw50QEw@mail.gmail.com>
 <20181212052126.GF431@jagdpanzerIV> <CAJmjG29a7Fax5ZW5Q+W+-1xPEXVUqdrMYwoUpSwL1Msiso6gtw@mail.gmail.com>
 <20181212062841.GI431@jagdpanzerIV> <20181212064841.GB2746@sasha-vm>
 <20181212081034.GA32687@jagdpanzerIV> <20181228001651.GA514@jagdpanzerIV> <20181228082749.GA28315@kroah.com>
In-Reply-To: <20181228082749.GA28315@kroah.com>
From: Daniel Wang <wonderfly@google.com>
Date: Fri, 28 Dec 2018 16:03:36 -0600
Message-ID:
 <CAJmjG2_U3fJKsZ4FgF+ihyoNUxxQ+d79Gh-eMZJ_6pHr+Bn0CA@mail.gmail.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
To: Greg KH <greg@kroah.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sasha Levin <sashal@kernel.org>, 
	Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, 
	Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, 
	byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, 
	jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, 
	pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, 
	Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, 
	Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, 
	Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256;
	boundary="000000000000372ddc057e1c3dbb"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181228220336.BKYynbCG-vUE8aCnnmCkghXppQYUFZ8Im5DhD-SP0Ok@z>

--000000000000372ddc057e1c3dbb
Content-Type: text/plain; charset="UTF-8"

Thanks. I was able to confirm that commit c7c3f05e341a9a2bd alone
fixed the problem for me. As expected, all 16 CPUs' stacktrace was
printed, before a final panic stack dump and a successful reboot.

[   24.035044] Hogging a CPU now
[   48.200258] watchdog: BUG: soft lockup - CPU#3 stuck for 22s! [lockme:1102]
[   48.207371] Modules linked in: lockme(O) ipt_MASQUERADE
nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 xt_addrtype nf_nat
br_netfilter ip6table_filter ip6_tables aesni_intel aes_x86_64
crypto_simd cryptd glue_helper
[   48.226613] CPU: 3 PID: 1102 Comm: lockme Tainted: G           O
4.14.79 #33
[   48.234057] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.243388] task: ffffa3da1bd70000 task.stack: ffffc04e077e0000
[   48.249425] RIP: 0010:hog_thread+0x13/0x1000 [lockme]
[   48.255197] RSP: 0018:ffffc04e077e3f10 EFLAGS: 00000282 ORIG_RAX:
ffffffffffffff10
[   48.262879] RAX: 0000000000000011 RBX: ffffa3da362ffa80 RCX: 0000000000000000
[   48.270131] RDX: ffffa3da432dd740 RSI: ffffa3da432d54f8 RDI: ffffa3da432d54f8
[   48.277382] RBP: ffffc04e077e3f48 R08: 0000000000000030 R09: 0000000000000000
[   48.284629] R10: 0000000000000358 R11: 0000000000000000 R12: ffffa3da33f7c940
[   48.291881] R13: ffffc04e079b7c58 R14: 0000000000000000 R15: ffffa3da362ffac8
[   48.299134] FS:  0000000000000000(0000) GS:ffffa3da432c0000(0000)
knlGS:0000000000000000
[   48.307338] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.313200] CR2: 00007f0142c77e5d CR3: 0000000b10e12002 CR4: 00000000003606a0
[   48.320455] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.327705] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.334955] Call Trace:
[   48.337534]  kthread+0x127/0x160
[   48.340878]  ? 0xffffffffc04bc000
[   48.344315]  ? kthread_create_on_node+0x40/0x40
[   48.348962]  ret_from_fork+0x35/0x40
[   48.352655] Code: <eb> fe 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00
[   48.360712] Sending NMI from CPU 3 to CPUs 0-2,4-15:
[   48.365891] NMI backtrace for cpu 5
[   48.365892] CPU: 5 PID: 963 Comm: dd Tainted: G           O    4.14.79 #33
[   48.365892] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.365893] task: ffffa3da2e769c80 task.stack: ffffc04e072dc000
[   48.365894] RIP: 0010:chacha20_block+0x203/0x350
[   48.365894] RSP: 0018:ffffc04e072dfd08 EFLAGS: 00000086
[   48.365895] RAX: 00000000430aa37c RBX: 000000008849a559 RCX: 000000001e380d02
[   48.365896] RDX: 00000000f37255aa RSI: 00000000430aa37c RDI: 00000000d39ce109
[   48.365896] RBP: 00000000242dad92 R08: 00000000942a2b36 R09: 000000006df44375
[   48.365897] R10: 000000007f47d158 R11: 0000000080fde9af R12: 0000000092e47c5e
[   48.365897] R13: 00000000ed09aada R14: 00000000c6fd956d R15: 000000001bb4deeb
[   48.365898] FS:  00007f074a4a6700(0000) GS:ffffa3da43340000(0000)
knlGS:0000000000000000
[   48.365899] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.365899] CR2: 000055a35c5b0520 CR3: 0000000edc900003 CR4: 00000000003606a0
[   48.365900] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.365900] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.365900] Call Trace:
[   48.365901]  _extract_crng+0xdb/0x130
[   48.365901]  crng_backtrack_protect+0xb3/0xc0
[   48.365902]  urandom_read+0x13b/0x2c0
[   48.365902]  vfs_read+0xad/0x170
[   48.365903]  SyS_read+0x4b/0xa0
[   48.365903]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.365904]  do_syscall_64+0x70/0x200
[   48.365904]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.365904] RIP: 0033:0x7f0749e7c410
[   48.365905] RSP: 002b:00007ffd69532b18 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.365906] RAX: ffffffffffffffda RBX: 0000000000024ab3 RCX: 00007f0749e7c410
[   48.365906] RDX: 0000000000000400 RSI: 000055e440267000 RDI: 0000000000000000
[   48.365907] RBP: 00007ffd69532b40 R08: 0000000000000000 R09: 000000000000000d
[   48.365907] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.365908] R13: 00007f074a4a6690 R14: 0000000000000400 R15: 000055e440267000
[   48.365908] Code: c0 10 31 f0 01 d3 89 74 24 08 41 89 c7 8b 44 24
0c 41 31 dc 41 c1 c4 0c 46 8d 0c 1f 45 89 eb 41 c1 c7 0c 44 01 c0 45
31 cb 89 c6 <89> e8 41 c1 c3 08 89 74 24 0c 31 f0 41 8d 34 0c 8b 4c 24
10 c1
[   48.365921] NMI backtrace for cpu 13
[   48.365923] CPU: 13 PID: 967 Comm: dd Tainted: G           O    4.14.79 #33
[   48.365924] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.365924] task: ffffa3da1c8b0000 task.stack: ffffc04e07798000
[   48.365925] RIP: 0010:native_queued_spin_lock_slowpath+0xce/0x1b0
[   48.365925] RSP: 0018:ffffc04e0779bda8 EFLAGS: 00000002
[   48.365926] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: 0000000000000000
[   48.365926] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.365927] RBP: ffffc04e0779bdd8 R08: 000000005afce914 R09: 00000000e446e58a
[   48.365927] R10: 000000004789081f R11: 000000001fb8dc14 R12: ffffc04e0779be30
[   48.365928] R13: ffffffffadecd3c8 R14: ffffc04e0779be30 R15: 0000000000000040
[   48.365928] FS:  00007f79835ff700(0000) GS:ffffa3da43540000(0000)
knlGS:0000000000000000
[   48.365929] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.365929] CR2: 00007ff20c75d140 CR3: 0000000edc928004 CR4: 00000000003606a0
[   48.365929] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.365930] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.365930] Call Trace:
[   48.365931]  do_raw_spin_lock+0xa0/0xb0
[   48.365931]  _raw_spin_lock_irqsave+0x20/0x26
[   48.365932]  _extract_crng+0x52/0x130
[   48.365932]  urandom_read+0xf9/0x2c0
[   48.365932]  vfs_read+0xad/0x170
[   48.365933]  SyS_read+0x4b/0xa0
[   48.365933]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.365934]  do_syscall_64+0x70/0x200
[   48.365934]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.365934] RIP: 0033:0x7f7982fd5410
[   48.365935] RSP: 002b:00007ffc84173ec8 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.365936] RAX: ffffffffffffffda RBX: 0000000000022155 RCX: 00007f7982fd5410
[   48.365936] RDX: 0000000000000400 RSI: 0000560209655000 RDI: 0000000000000000
[   48.365936] RBP: 00007ffc84173ef0 R08: 0000000000000000 R09: 000000000000000d
[   48.365937] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.365937] R13: 00007f79835ff690 R14: 0000000000000400 R15: 0000560209655000
[   48.365938] Code: 75 2e be 01 00 00 00 f0 0f b1 37 85 c0 75 21 65
ff 0d 93 ce f7 52 5d c3 f3 90 8b 37 81 fe 00 01 00 00 74 f4 e9 64 ff
ff ff f3 90 <e9> 3d ff ff ff 8d 71 01 c1 e2 10 c1 e6 12 09 d6 89 f0 c1
e8 10
[   48.365953] NMI backtrace for cpu 9
[   48.365953] CPU: 9 PID: 974 Comm: dd Tainted: G           O    4.14.79 #33
[   48.365954] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.365954] task: ffffa3da1e310e40 task.stack: ffffc04e077a0000
[   48.365955] RIP: 0010:native_queued_spin_lock_slowpath+0xce/0x1b0
[   48.365955] RSP: 0018:ffffc04e077a3da8 EFLAGS: 00000002
[   48.365956] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: 0000000000000000
[   48.365956] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.365957] RBP: ffffc04e077a3dd8 R08: 00000000c4612c74 R09: 00000000b23896fe
[   48.365957] R10: 0000000081037022 R11: 0000000022fc570d R12: ffffc04e077a3e30
[   48.365957] R13: ffffffffadecd3c8 R14: ffffc04e077a3e30 R15: 0000000000000040
[   48.365958] FS:  00007f758a7fe700(0000) GS:ffffa3da43440000(0000)
knlGS:0000000000000000
[   48.365958] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.365959] CR2: 000055a35e272620 CR3: 0000000edca6e002 CR4: 00000000003606a0
[   48.365959] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.365959] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.365960] Call Trace:
[   48.365960]  do_raw_spin_lock+0xa0/0xb0
[   48.365960]  _raw_spin_lock_irqsave+0x20/0x26
[   48.365961]  _extract_crng+0x52/0x130
[   48.365961]  urandom_read+0xf9/0x2c0
[   48.365961]  vfs_read+0xad/0x170
[   48.365962]  SyS_read+0x4b/0xa0
[   48.365962]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.365962]  do_syscall_64+0x70/0x200
[   48.365963]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.365963] RIP: 0033:0x7f758a1d4410
[   48.365963] RSP: 002b:00007fffde09c978 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.365964] RAX: ffffffffffffffda RBX: 0000000000022850 RCX: 00007f758a1d4410
[   48.365965] RDX: 0000000000000400 RSI: 000055abdd543000 RDI: 0000000000000000
[   48.365965] RBP: 00007fffde09c9a0 R08: 0000000000000000 R09: 000000000000000d
[   48.365965] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.365966] R13: 00007f758a7fe690 R14: 0000000000000400 R15: 000055abdd543000
[   48.365966] Code: 75 2e be 01 00 00 00 f0 0f b1 37 85 c0 75 21 65
ff 0d 93 ce f7 52 5d c3 f3 90 8b 37 81 fe 00 01 00 00 74 f4 e9 64 ff
ff ff f3 90 <e9> 3d ff ff ff 8d 71 01 c1 e2 10 c1 e6 12 09 d6 89 f0 c1
e8 10
[   48.365979] NMI backtrace for cpu 11
[   48.365980] CPU: 11 PID: 979 Comm: dd Tainted: G           O    4.14.79 #33
[   48.365980] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.365981] task: ffffa3da1c932ac0 task.stack: ffffc04e077c8000
[   48.365981] RIP: 0010:native_queued_spin_lock_slowpath+0xce/0x1b0
[   48.365982] RSP: 0018:ffffc04e077cbda8 EFLAGS: 00000002
[   48.365982] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: ffffc04e077cbef0
[   48.365983] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.365983] RBP: ffffc04e077cbdd8 R08: 0000000000000000 R09: 0000000000000000
[   48.365984] R10: 0000000000000000 R11: 0000000000000000 R12: ffffc04e077cbe30
[   48.365984] R13: ffffffffadecd3c8 R14: ffffc04e077cbe30 R15: 0000000000000040
[   48.365985] FS:  00007f8747be2700(0000) GS:ffffa3da434c0000(0000)
knlGS:0000000000000000
[   48.365985] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.365986] CR2: 000055de0b60635c CR3: 0000000edca70001 CR4: 00000000003606a0
[   48.365986] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.365986] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.365987] Call Trace:
[   48.365987]  do_raw_spin_lock+0xa0/0xb0
[   48.365987]  _raw_spin_lock_irqsave+0x20/0x26
[   48.365988]  _extract_crng+0x52/0x130
[   48.365988]  urandom_read+0xf9/0x2c0
[   48.365988]  vfs_read+0xad/0x170
[   48.365989]  SyS_read+0x4b/0xa0
[   48.365989]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.365989]  do_syscall_64+0x70/0x200
[   48.365990]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.365990] RIP: 0033:0x7f87475b8410
[   48.365990] RSP: 002b:00007fff13681918 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.365991] RAX: ffffffffffffffda RBX: 000000000001cf65 RCX: 00007f87475b8410
[   48.365992] RDX: 0000000000000400 RSI: 0000561a3760c000 RDI: 0000000000000000
[   48.365992] RBP: 00007fff13681940 R08: 0000000000000000 R09: 000000000000000d
[   48.365992] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.365993] R13: 00007f8747be2690 R14: 0000000000000400 R15: 0000561a3760c000
[   48.365993] Code: 75 2e be 01 00 00 00 f0 0f b1 37 85 c0 75 21 65
ff 0d 93 ce f7 52 5d c3 f3 90 8b 37 81 fe 00 01 00 00 74 f4 e9 64 ff
ff ff f3 90 <e9> 3d ff ff ff 8d 71 01 c1 e2 10 c1 e6 12 09 d6 89 f0 c1
e8 10
[   48.366007] NMI backtrace for cpu 6
[   48.366008] CPU: 6 PID: 960 Comm: dd Tainted: G           O    4.14.79 #33
[   48.366009] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.366009] task: ffffa3da2c1c8e40 task.stack: ffffc04e07428000
[   48.366009] RIP: 0010:native_queued_spin_lock_slowpath+0xce/0x1b0
[   48.366010] RSP: 0018:ffffc04e0742bda8 EFLAGS: 00000002
[   48.366011] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: 0000000000000000
[   48.366011] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.366011] RBP: ffffc04e0742bdd8 R08: 00000000a3d78655 R09: 000000001654483e
[   48.366012] R10: 0000000010c7e4a4 R11: 00000000abedc2d0 R12: ffffc04e0742be30
[   48.366012] R13: ffffffffadecd3c8 R14: ffffc04e0742be30 R15: 0000000000000040
[   48.366013] FS:  00007fe757e41700(0000) GS:ffffa3da43380000(0000)
knlGS:0000000000000000
[   48.366013] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.366013] CR2: 000055a35e25613c CR3: 0000000ede082004 CR4: 00000000003606a0
[   48.366014] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.366014] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.366014] Call Trace:
[   48.366015]  do_raw_spin_lock+0xa0/0xb0
[   48.366015]  _raw_spin_lock_irqsave+0x20/0x26
[   48.366015]  _extract_crng+0x52/0x130
[   48.366016]  urandom_read+0xf9/0x2c0
[   48.366016]  vfs_read+0xad/0x170
[   48.366016]  SyS_read+0x4b/0xa0
[   48.366017]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.366017]  do_syscall_64+0x70/0x200
[   48.366017]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.366018] RIP: 0033:0x7fe757817410
[   48.366018] RSP: 002b:00007fff37fd8518 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.366019] RAX: ffffffffffffffda RBX: 000000000002baaf RCX: 00007fe757817410
[   48.366019] RDX: 0000000000000400 RSI: 000055cd666e2000 RDI: 0000000000000000
[   48.366020] RBP: 00007fff37fd8540 R08: 0000000000000000 R09: 000000000000000d
[   48.366020] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.366020] R13: 00007fe757e41690 R14: 0000000000000400 R15: 000055cd666e2000
[   48.366021] Code: 75 2e be 01 00 00 00 f0 0f b1 37 85 c0 75 21 65
ff 0d 93 ce f7 52 5d c3 f3 90 8b 37 81 fe 00 01 00 00 74 f4 e9 64 ff
ff ff f3 90 <e9> 3d ff ff ff 8d 71 0[   48.366034] NMI backtrace for
cpu 14
[   48.366035] CPU: 14 PID: 962 Comm: dd Tainted: G           O    4.14.79 #33
[   48.366035] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.366036] task: ffffa3da1e3a0e40 task.stack: ffffc04e076c0000
[   48.366036] RIP: 0010:native_queued_spin_lock_slowpath+0xce/0x1b0
[   48.366036] RSP: 0018:ffffc04e076c3da8 EFLAGS: 00000002
[   48.366037] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: 0000000000000000
[   48.366037] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.366038] RBP: ffffc04e076c3dd8 R08: 000000002f43f57e R09: 0000000072c41751
[   48.366038] R10: 0000000066350959 R11: 00000000f3ffe87e R12: ffffc04e076c3e30
[   48.366038] R13: ffffffffadecd3c8 R14: ffffc04e076c3e30 R15: 0000000000000040
[   48.366039] FS:  00007f016e063700(0000) GS:ffffa3da43580000(0000)
knlGS:0000000000000000
[   48.366039] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.366040] CR2: 0000562d8b3d63fa CR3: 0000000edc88a002 CR4: 00000000003606a0
[   48.366040] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.366040] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.366041] Call Trace:
[   48.366041]  do_raw_spin_lock+0xa0/0xb0
[   48.366041]  _raw_spin_lock_irqsave+0x20/0x26
[   48.366042]  _extract_crng+0x52/0x130
[   48.366042]  urandom_read+0xf9/0x2c0
[   48.366042]  vfs_read+0xad/0x170
[   48.366043]  SyS_read+0x4b/0xa0
[   48.366043]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.366044]  do_syscall_64+0x70/0x200
[   48.366044]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.366044] RIP: 0033:0x7f016da39410
[   48.366045] RSP: 002b:00007ffc2c45a3d8 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.366046] RAX: ffffffffffffffda RBX: 0000000000029ee7 RCX: 00007f016da39410
[   48.366046] RDX: 0000000000000400 RSI: 0000558176fbc000 RDI: 0000000000000000
[   48.366046] RBP: 00007ffc2c45a400 R08: 0000000000000000 R09: 000000000000000d
[   48.366047] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.366047] R13: 00007f016e063690 R14: 0000000000000400 R15: 0000558176fbc000
[   48.366048] Code: 75 2e be 01 00 00 00 f0 0f b1 37 85 c0 75 21 65
ff 0d 93 ce f7 52 5d c3 f3 90 8b 37 81 fe 00 01 00 00 74 f4 e9 64 ff
ff ff f3 90 <e9> 3d ff ff ff 8d 71 01 c1 e2 10 c1 e6 12 09 d6 89 f0 c1
e8 10
[   48.366062] NMI backtrace for cpu 12
[   48.366062] CPU: 12 PID: 958 Comm: dd Tainted: G           O    4.14.79 #33
[   48.366063] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.366063] task: ffffa3da2caeaac0 task.stack: ffffc04e07930000
[   48.366064] RIP: 0010:native_queued_spin_lock_slowpath+0xce/0x1b0
[   48.366064] RSP: 0018:ffffc04e07933da8 EFLAGS: 00000002
[   48.366065] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: 0000000000000000
[   48.366065] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.366066] RBP: ffffc04e07933dd8 R08: 00000000944dcd42 R09: 000000000f07d125
[   48.366066] R10: 000000001e88050f R11: 000000005909c042 R12: ffffc04e07933e30
[   48.366067] R13: ffffffffadecd3c8 R14: ffffc04e07933e30 R15: 0000000000000040
[   48.366067] FS:  00007fa18e75f700(0000) GS:ffffa3da43500000(0000)
knlGS:0000000000000000
[   48.366067] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.366068] CR2: 00007f4254fd62d0 CR3: 0000000ede3e6006 CR4: 00000000003606a0
[   48.366068] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.366069] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.366069] Call Trace:
[   48.366069]  do_raw_spin_lock+0xa0/0xb0
[   48.366070]  _raw_spin_lock_irqsave+0x20/0x26
[   48.366070]  _extract_crng+0x52/0x130
[   48.366070]  urandom_read+0xf9/0x2c0
[   48.366071]  vfs_read+0xad/0x170
[   48.366071]  SyS_read+0x4b/0xa0
[   48.366071]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.366072]  do_syscall_64+0x70/0x200
[   48.366072]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.366072] RIP: 0033:0x7fa18e135410
[   48.366073] RSP: 002b:00007ffcf4ceb518 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.366074] RAX: ffffffffffffffda RBX: 000000000002861a RCX: 00007fa18e135410
[   48.366074] RDX: 0000000000000400 RSI: 000055ef19030000 RDI: 0000000000000000
[   48.366074] RBP: 00007ffcf4ceb540 R08: 0000000000000000 R09: 000000000000000d
[   48.366075] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.366075] R13: 00007fa18e75f690 R14: 0000000000000400 R15: 000055ef19030000
[   48.366075] Code: 75 2e be 01 00 00 00 f0 0f b1 37 85 c0 75 21 65
ff 0d 93 ce f7 52 5d c3 f3 90 8b 37 81 fe 00 01 00 00 74 f4 e9 64 ff
ff ff f3 90 <e9> 3d ff ff ff 8d 71 01 c1 e2 10 c1 e6 12 09 d6 89 f0 c1
e8 10
[   48.366089] NMI backtrace for cpu 10
[   48.366090] CPU: 10 PID: 970 Comm: dd Tainted: G           O    4.14.79 #33
[   48.366090] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.366091] task: ffffa3da1e2b9c80 task.stack: ffffc04e07648000
[   48.366091] RIP: 0010:native_queued_spin_lock_slowpath+0xce/0x1b0
[   48.366091] RSP: 0018:ffffc04e0764bda8 EFLAGS: 00000002
[   48.366092] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: 0000000000000000
[   48.366093] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.366093] RBP: ffffc04e0764bdd8 R08: 000000005ff6e80a R09: 00000000488cc97c
[   48.366093] R10: 0000000049a24741 R11: 000000003c8a7f14 R12: ffffc04e0764be30
[   48.366094] R13: ffffffffadecd3c8 R14: ffffc04e0764be30 R15: 0000000000000040
[   48.366094] FS:  00007fce45b0a700(0000) GS:ffffa3da43480000(0000)
knlGS:0000000000000000
[   48.366095] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.366095] CR2: 000055a39aef4938 CR3: 0000000edc924001 CR4: 00000000003606a0
[   48.366095] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.366096] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.366096] Call Trace:
[   48.366096]  do_raw_spin_lock+0xa0/0xb0
[   48.366097]  _raw_spin_lock_irqsave+0x20/0x26
[   48.366097]  _extract_crng+0x52/0x130
[   48.366097]  urandom_read+0xf9/0x2c0
[   48.366098]  vfs_read+0xad/0x170
[   48.366098]  SyS_read+0x4b/0xa0
[   48.366098]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.366099]  do_syscall_64+0x70/0x200
[   48.366099]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.366099] RIP: 0033:0x7fce454e0410
[   48.366100] RSP: 002b:00007ffc04eebd58 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.366101] RAX: ffffffffffffffda RBX: 0000000000025a27 RCX: 00007fce454e0410
[   48.366101] RDX: 0000000000000400 RSI: 000055cb94ecc000 RDI: 0000000000000000
[   48.366101] RBP: 00007ffc04eebd80 R08: 0000000000000000 R09: 000000000000000d
[   48.366102] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.366102] R13: 00007fce45b0a690 R14: 0000000000000400 R15: 000055cb94ecc000
[   48.366102] Code: 75 2e be 01 00 00 00 f0 0f b1 37 85 c0 75 21 65
ff 0d 93 ce f7 52 5d c3 f3 90 8b 37 81 fe 00 01 00 00 74 f4 e9 64 ff
ff ff f3 90 <e9> 3d ff ff ff 8d 71 01 c1 e2 10 c1 e6 12 09 d6 89 f0 c1
e8 10
[   48.366116] NMI backtrace for cpu 7
[   48.366117] CPU: 7 PID: 956 Comm: dd Tainted: G           O    4.14.79 #33
[   48.366117] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.366118] task: ffffa3da1e3a0000 task.stack: ffffc04e07778000
[   48.366118] RIP: 0010:native_queued_spin_lock_slowpath+0xce/0x1b0
[   48.366118] RSP: 0018:ffffc04e0777bda8 EFLAGS: 00000002
[   48.366119] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: 0000000000000000
[   48.366120] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.366120] RBP: ffffc04e0777bdd8 R08: 0000000087f524c7 R09: 00000000130c71f1
[   48.366121] R10: 00000000a72ccfc7 R11: 00000000900b6142 R12: ffffc04e0777be30
[   48.366121] R13: ffffffffadecd3c8 R14: ffffc04e0777be30 R15: 0000000000000040
[   48.366122] FS:  00007f5312a09700(0000) GS:ffffa3da433c0000(0000)
knlGS:0000000000000000
[   48.366122] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.366123] CR2: 00007fdd9d09aba0 CR3: 0000000ee16f6004 CR4: 00000000003606a0
[   48.366123] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.366123] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.366124] Call Trace:
[   48.366124]  do_raw_spin_lock+0xa0/0xb0
[   48.366124]  _raw_spin_lock_irqsave+0x20/0x26
[   48.366125]  _extract_crng+0x52/0x130
[   48.366125]  urandom_read+0xf9/0x2c0
[   48.366125]  vfs_read+0xad/0x170
[   48.366126]  SyS_read+0x4b/0xa0
[   48.366126]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.366126]  do_syscall_64+0x70/0x200
[   48.366127]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.366127] RIP: 0033:0x7f53123df410
[   48.366127] RSP: 002b:00007ffd5c3163d8 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.366128] RAX: ffffffffffffffda RBX: 00000000000267bd RCX: 00007f53123df410
[   48.366128] RDX: 0000000000000400 RSI: 0000562641ec2000 RDI: 0000000000000000
[   48.366129] RBP: 00007ffd5c316400 R08: 0000000000000000 R09: 000000000000000d
[   48.366129] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.366130] R13: 00007f5312a09690 R14: 0000000000000400 R15: 0000562641ec2000
[   48.366130] Code: 75 2e be 01 00 00 00 f0 0f b1 37 85 c0 75 21 65
ff 0d 93 ce f7 52 5d c3 f3 90 8b 37 81 fe 00 01 00 00 74 f4 e9 64 ff
ff ff f3 90 <e9> 3d ff ff ff 8d 71 01 c1 e2 10 c1 e6 12 09 d6 89 f0 c1
e8 10
[   48.366143] NMI backtrace for cpu 15
[   48.366144] CPU: 15 PID: 968 Comm: dd Tainted: G           O    4.14.79 #33
[   48.366144] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.366144] task: ffffa3da2caeb900 task.stack: ffffc04e07758000
[   48.366145] RIP: 0010:native_queued_spin_lock_slowpath+0xce/0x1b0
[   48.366145] RSP: 0018:ffffc04e0775bda8 EFLAGS: 00000002
[   48.366146] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: 0000000000000000
[   48.366146] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.366147] RBP: ffffc04e0775bdd8 R08: 000000000cedf674 R09: 000000001205cfdd
[   48.366147] R10: 00000000a2a512e0 R11: 00000000171b5795 R12: ffffc04e0775be30
[   48.366147] R13: ffffffffadecd3c8 R14: ffffc04e0775be30 R15: 0000000000000040
[   48.366148] FS:  00007fc929c81700(0000) GS:ffffa3da435c0000(0000)
knlGS:0000000000000000
[   48.366148] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.366148] CR2: 00007f73a627b750 CR3: 0000000ee40b4001 CR4: 00000000003606a0
[   48.366149] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.366149] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.366149] Call Trace:
[   48.366150]  do_raw_spin_lock+0xa0/0xb0
[   48.366150]  _raw_spin_lock_irqsave+0x20/0x26
[   48.366150]  _extract_crng+0x52/0x130
[   48.366151]  urandom_read+0xf9/0x2c0
[   48.366151]  vfs_read+0xad/0x170
[   48.366151]  SyS_read+0x4b/0xa0
[   48.366152]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.366152]  do_syscall_64+0x70/0x200
[   48.366152]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.366153] RIP: 0033:0x7fc929657410
[   48.366153] RSP: 002b:00007ffe58971538 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.366154] RAX: ffffffffffffffda RBX: 0000000000023d40 RCX: 00007fc929657410
[   48.366154] RDX: 0000000000000400 RSI: 000055cc31cf3000 RDI: 0000000000000000
[   48.366154] RBP: 00007ffe58971560 R08: 0000000000000000 R09: 000000000000000d
[   48.366155] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.366155] R13: 00007fc929c81690 R14: 0000000000000400 R15: 000055cc31cf3000
[   48.366156] Code: 75 2e be 01 00 00 00 f0 0f b1 37 85 c0 75 21 65
ff 0d 93 ce f7 52 5d c3 f3 90 8b 37 81 fe 00 01 00 00 74 f4 e9 64 ff
ff ff f3 90 <e9> 3d ff ff ff 8d 71 01 c1 e2 10 c1 e6 12 09 d6 89 f0 c1
e8 10
[   48.366169] NMI backtrace for cpu 4
[   48.366170] CPU: 4 PID: 953 Comm: dd Tainted: G           O    4.14.79 #33
[   48.366170] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.366171] task: ffffa3da1e288000 task.stack: ffffc04e076f8000
[   48.366171] RIP: 0010:native_queued_spin_lock_slowpath+0x12/0x1b0
[   48.366172] RSP: 0018:ffffc04e076fbda8 EFLAGS: 00000002
[   48.366172] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: 0000000000000000
[   48.366173] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.366173] RBP: ffffc04e076fbdd8 R08: 0000000073a95a12 R09: 0000000050c6526e
[   48.366174] R10: 00000000854d712d R11: 000000007bbf968d R12: ffffc04e076fbe30
[   48.366174] R13: ffffffffadecd3c8 R14: ffffc04e076fbe30 R15: 0000000000000040
[   48.366175] FS:  00007fcd2ba98700(0000) GS:ffffa3da43300000(0000)
knlGS:0000000000000000
[   48.366175] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.366175] CR2: 00007f364c1f08c0 CR3: 0000000ede396001 CR4: 00000000003606a0
[   48.366176] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.366176] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.366176] Call Trace:
[   48.366177]  do_raw_spin_lock+0xa0/0xb0
[   48.366177]  _raw_spin_lock_irqsave+0x20/0x26
[   48.366177]  _extract_crng+0x52/0x130
[   48.366178]  urandom_read+0xf9/0x2c0
[   48.366178]  vfs_read+0xad/0x170
[   48.366178]  SyS_read+0x4b/0xa0
[   48.366179]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.366179]  do_syscall_64+0x70/0x200
[   48.366180]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.366180] RIP: 0033:0x7fcd2b46e410
[   48.366180] RSP: 002b:00007ffc41e60388 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.366181] RAX: ffffffffffffffda RBX: 000000000002b1a8 RCX: 00007fcd2b46e410
[   48.366182] RDX: 0000000000000400 RSI: 000055f8d658e000 RDI: 0000000000000000
[   48.366182] RBP: 00007ffc41e603b0 R08: 0000000000000000 R09: 000000000000000d
[   48.366182] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.366183] R13: 00007fcd2ba98690 R14: 0000000000000400 R15: 000055f8d658e000
[   48.366183] Code: 44 24 08 c6 03 01 48 8b 2c 24 48 c7 00 00 00 00
00 e9 29 fe ff ff 0f 1f 00 0f 1f 44 00 00 55 0f 1f 44 00 00 ba 01 00
00 00 8b 07 <85> c0 0f 85 b2 00 00 00 f0 0f b1 17 85 c0 75 ee 5d c3 81
fe 00
[   48.366197] NMI backtrace for cpu 1
[   48.366197] CPU: 1 PID: 972 Comm: dd Tainted: G           O    4.14.79 #33
[   48.366198] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.366198] task: ffffa3da2e76aac0 task.stack: ffffc04e07788000
[   48.366199] RIP: 0010:native_queued_spin_lock_slowpath+0x12/0x1b0
[   48.366199] RSP: 0018:ffffc04e0778bda8 EFLAGS: 00000002
[   48.366200] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: ffffc04e0778bef0
[   48.366200] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.366201] RBP: ffffc04e0778bdd8 R08: 0000000000000000 R09: 0000000000000000
[   48.366201] R10: 0000000000000000 R11: 0000000000000000 R12: ffffc04e0778be30
[   48.366201] R13: ffffffffadecd3c8 R14: ffffc04e0778be30 R15: 0000000000000040
[   48.366202] FS:  00007fcb41458700(0000) GS:ffffa3da43240000(0000)
knlGS:0000000000000000
[   48.366202] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.366203] CR2: 000055a35e25613c CR3: 0000000edc9ca005 CR4: 00000000003606a0
[   48.366203] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.366203] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.366204] Call Trace:
[   48.366204]  do_raw_spin_lock+0xa0/0xb0
[   48.366204]  _raw_spin_lock_irqsave+0x20/0x26
[   48.366205]  _extract_crng+0x52/0x130
[   48.366205]  urandom_read+0xf9/0x2c0
[   48.366205]  vfs_read+0xad/0x170
[   48.366206]  SyS_read+0x4b/0xa0
[   48.366206]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.366206]  do_syscall_64+0x70/0x200
[   48.366207]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.366207] RIP: 0033:0x7fcb40e2e410
[   48.366207] RSP: 002b:00007ffdd2b5d348 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.366208] RAX: ffffffffffffffda RBX: 0000000000025648 RCX: 00007fcb40e2e410
[   48.366208] RDX: 0000000000000400 RSI: 000055b7a0519000 RDI: 0000000000000000
[   48.366209] RBP: 00007ffdd2b5d370 R08: 0000000000000000 R09: 000000000000000d
[   48.366209] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.366209] R13: 00007fcb41458690 R14: 0000000000000400 R15: 000055b7a0519000
[   48.366210] Code: 44 24 08 c6 03 01 48 8b 2c 24 48 c7 00 00 00 00
00 e9 29 fe ff ff 0f 1f 00 0f 1f 44 00 00 55 0f 1f 44 00 00 ba 01 00
00 00 8b 07 <85> c0 0f 85 b2 00 00 00 f0 0f b1 17 85 c0 75 ee 5d c3 81
fe 00
[   48.366223] NMI backtrace for cpu 2
[   48.366223] CPU: 2 PID: 952 Comm: dd Tainted: G           O    4.14.79 #33
[   48.366224] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.366224] task: ffffa3da1e2b8000 task.stack: ffffc04e077e8000
[   48.366224] RIP: 0010:native_queued_spin_lock_slowpath+0x12/0x1b0
[   48.366225] RSP: 0018:ffffc04e077ebda8 EFLAGS: 00000002
[   48.366226] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: 0000000000000000
[   48.366226] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.366226] RBP: ffffc04e077ebdd8 R08: 0000000043cef058 R09: 00000000cfa81335
[   48.366227] R10: 000000003ab03ada R11: 00000000a26a1af1 R12: ffffc04e077ebe30
[   48.366227] R13: ffffffffadecd3c8 R14: ffffc04e077ebe30 R15: 0000000000000040
[   48.366227] FS:  00007f24d6c90700(0000) GS:ffffa3da43280000(0000)
knlGS:0000000000000000
[   48.366228] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.366228] CR2: 0000555a040f73fa CR3: 0000000ef31c6005 CR4: 00000000003606a0
[   48.366228] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.366229] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.366229] Call Trace:
[   48.366229]  do_raw_spin_lock+0xa0/0xb0
[   48.366230]  _raw_spin_lock_irqsave+0x20/0x26
[   48.366230]  _extract_crng+0x52/0x130
[   48.366231]  urandom_read+0xf9/0x2c0
[   48.366231]  vfs_read+0xad/0x170
[   48.366231]  SyS_read+0x4b/0xa0
[   48.366232]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.366232]  do_syscall_64+0x70/0x200
[   48.366233]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.366233] RIP: 0033:0x7f24d6666410
[   48.366233] RSP: 002b:00007ffc09334398 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.366234] RAX: ffffffffffffffda RBX: 0000000000025b40 RCX: 00007f24d6666410
[   48.366235] RDX: 0000000000000400 RSI: 000055ac9bc9e000 RDI: 0000000000000000
[   48.366235] RBP: 00007ffc093343c0 R08: 0000000000000000 R09: 000000000000000d
[   48.366235] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.366236] R13: 00007f24d6c90690 R14: 0000000000000400 R15: 000055ac9bc9e000
[   48.366236] Code: 44 24 08 c6 03 01 48 8b 2c 24 48 c7 00 00 00 00
00 e9 29 fe ff ff 0f 1f 00 0f 1f 44 00 00 55 0f 1f 44 00 00 ba 01 00
00 00 8b 07 <85> c0 0f 85 b2 00 00 00 f0 0f b1 17 85 c0 75 ee 5d c3 81
fe 00
[   48.366257] NMI backtrace for cpu 8
[   48.366258] CPU: 8 PID: 978 Comm: dd Tainted: G           O    4.14.79 #33
[   48.366259] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.366259] task: ffffa3da1e311c80 task.stack: ffffc04e077c0000
[   48.366260] RIP: 0010:native_queued_spin_lock_slowpath+0xce/0x1b0
[   48.366260] RSP: 0018:ffffc04e077c3da8 EFLAGS: 00000002
[   48.366261] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: 0000000000000000
[   48.366262] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.366262] RBP: ffffc04e077c3dd8 R08: 000000009f7f8ef3 R09: 0000000048862586
[   48.366263] R10: 00000000c997070d R11: 00000000fe1ab98c R12: ffffc04e077c3e30
[   48.366263] R13: ffffffffadecd3c8 R14: ffffc04e077c3e30 R15: 0000000000000040
[   48.366264] FS:  00007fdb118b0700(0000) GS:ffffa3da43400000(0000)
knlGS:0000000000000000
[   48.366264] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.366265] CR2: 000055de0cdbcac0 CR3: 0000000edca4c006 CR4: 00000000003606a0
[   48.366265] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.366266] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.366266] Call Trace:
[   48.366266]  do_raw_spin_lock+0xa0/0xb0
[   48.366267]  _raw_spin_lock_irqsave+0x20/0x26
[   48.366267]  _extract_crng+0x52/0x130
[   48.366267]  urandom_read+0xf9/0x2c0
[   48.366268]  vfs_read+0xad/0x170
[   48.366268]  SyS_read+0x4b/0xa0
[   48.366269]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.366269]  do_syscall_64+0x70/0x200
[   48.366269]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.366270] RIP: 0033:0x7fdb11286410
[   48.366270] RSP: 002b:00007ffdbddda708 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.366271] RAX: ffffffffffffffda RBX: 000000000002658b RCX: 00007fdb11286410
[   48.366271] RDX: 0000000000000400 RSI: 00005637eee18000 RDI: 0000000000000000
[   48.366272] RBP: 00007ffdbddda730 R08: 0000000000000000 R09: 000000000000000d
[   48.366272] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.366273] R13: 00007fdb118b0690 R14: 0000000000000400 R15: 00005637eee18000
[   48.366273] Code: 75 2e be 01 00 00 00 f0 0f b1 37 85 c0 75 21 65
ff 0d 93 ce f7 52 5d c3 f3 90 8b 37 81 fe 00 01 00 00 74 f4 e9 64 ff
ff ff f3 90 <e9> 3d ff ff ff 8d 71 01 c1 e2 10 c1 e6 12 09 d6 89 f0 c1
e8 10
[   48.366287] NMI backtrace for cpu 0
[   48.366288] CPU: 0 PID: 950 Comm: dd Tainted: G           O    4.14.79 #33
[   48.366289] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.366289] task: ffffa3da1e310000 task.stack: ffffc04e076e8000
[   48.366290] RIP: 0010:native_queued_spin_lock_slowpath+0x12/0x1b0
[   48.366290] RSP: 0018:ffffc04e076ebda8 EFLAGS: 00000002
[   48.366291] RAX: 0000000000000001 RBX: ffffffffadecd3c8 RCX: 0000000000000000
[   48.366292] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffffadecd3c8
[   48.366292] RBP: ffffc04e076ebdd8 R08: 00000000173ee25a R09: 00000000307066a7
[   48.366293] R10: 000000007bb0d182 R11: 0000000075da0cf3 R12: ffffc04e076ebe30
[   48.366293] R13: ffffffffadecd3c8 R14: ffffc04e076ebe30 R15: 0000000000000040
[   48.366294] FS:  00007f75e9e55700(0000) GS:ffffa3da43200000(0000)
knlGS:0000000000000000
[   48.366294] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.366295] CR2: 000000c420dd4000 CR3: 0000000ede370005 CR4: 00000000003606b0
[   48.366295] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   48.366295] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   48.366296] Call Trace:
[   48.366296]  do_raw_spin_lock+0xa0/0xb0
[   48.366296]  _raw_spin_lock_irqsave+0x20/0x26
[   48.366297]  _extract_crng+0x52/0x130
[   48.366297]  urandom_read+0xf9/0x2c0
[   48.366297]  vfs_read+0xad/0x170
[   48.366298]  SyS_read+0x4b/0xa0
[   48.366298]  ? __audit_syscall_exit+0x21e/0x2c0
[   48.366298]  do_syscall_64+0x70/0x200
[   48.366299]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[   48.366299] RIP: 0033:0x7f75e982b410
[   48.366299] RSP: 002b:00007ffd3f4b76c8 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   48.366300] RAX: ffffffffffffffda RBX: 0000000000029034 RCX: 00007f75e982b410
[   48.366301] RDX: 0000000000000400 RSI: 000055da49bec000 RDI: 0000000000000000
[   48.366301] RBP: 00007ffd3f4b76f0 R08: 0000000000000000 R09: 000000000000000d
[   48.366301] R10: fffffffffffff000 R11: 0000000000000246 R12: 0000000000000000
[   48.366302] R13: 00007f75e9e55690 R14: 0000000000000400 R15: 000055da49bec000
[   48.366302] Code: 44 24 08 c6 03 01 48 8b 2c 24 48 c7 00 00 00 00
00 e9 29 fe ff ff 0f 1f 00 0f 1f 44 00 00 55 0f 1f 44 00 00 ba 01 00
00 00 8b 07 <85> c0 0f 85 b2 00 00 00 f0 0f b1 17 85 c0 75 ee 5d c3 81
fe 00
[   48.366857] Kernel panic - not syncing: softlockup: hung tasks
[   48.366858] CPU: 3 PID: 1102 Comm: lockme Tainted: G           O L
4.14.79 #33
[   48.366859] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   48.366860] Call Trace:
[   48.366862]  <IRQ>
[   48.366864]  dump_stack+0x63/0x82
[   48.366868]  panic+0xd6/0x22d
[   48.366871]  ? cpumask_next+0x1a/0x20
[   48.366874]  watchdog_timer_fn+0x22b/0x240
[   48.366876]  ? watchdog+0x30/0x30
[   48.366879]  __hrtimer_run_queues+0xed/0x240
[   48.366881]  hrtimer_interrupt+0xac/0x1b0
[   48.366884]  smp_apic_timer_interrupt+0x70/0x140
[   48.366886]  apic_timer_interrupt+0x7d/0x90
[   48.366887]  </IRQ>
[   48.366890] RIP: 0010:hog_thread+0x13/0x1000 [lockme]
[   48.366890] RSP: 0018:ffffc04e077e3f10 EFLAGS: 00000282 ORIG_RAX:
ffffffffffffff10
[   48.366892] RAX: 0000000000000011 RBX: ffffa3da362ffa80 RCX: 0000000000000000
[   48.366893] RDX: ffffa3da432dd740 RSI: ffffa3da432d54f8 RDI: ffffa3da432d54f8
[   48.366893] RBP: ffffc04e077e3f48 R08: 0000000000000030 R09: 0000000000000000
[   48.366894] R10: 0000000000000358 R11: 0000000000000000 R12: ffffa3da33f7c940
[   48.366895] R13: ffffc04e079b7c58 R14: 0000000000000000 R15: ffffa3da362ffac8
[   48.366898]  kthread+0x127/0x160
[   48.366899]  ? 0xffffffffc04bc000
[   48.366900]  ? kthread_create_on_node+0x40/0x40
[   48.366902]  ret_from_fork+0x35/0x40
[   49.433843] Shutting down cpus with NMI
[   49.434570] Kernel Offset: 0x2c000000 from 0xffffffff81000000
(relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[   51.728081] ACPI MEMORY or I/O RESET_REG.
SeaBIOS (version 1.8.2-20181112_143635-google)
Total RAM Size = 0x0000000f00000000 = 61440 MiB
CPUs found: 16     Max CPUs supported: 16
found virtio-scsi at 0:3
virtio-scsi vendor='Google' product='PersistentDisk' rev='1' type=0 removable=0
virtio-scsi blksize=512 sectors=14680064 = 7168 MiB
drive 0x000f2c60: PCHS=0/0/0 translation=lba LCHS=913/255/63 s=14680064
Booting from Hard Disk 0...
<abbreviated>

On Fri, Dec 28, 2018 at 2:27 AM Greg KH <greg@kroah.com> wrote:
>
> On Fri, Dec 28, 2018 at 09:16:51AM +0900, Sergey Senozhatsky wrote:
> > On (12/12/18 17:10), Sergey Senozhatsky wrote:
> > > And there will be another -stable backport request in a week or so.
> >
> > The remaining one:
> >
> > commit c7c3f05e341a9a2bd
>
> Now queued up, thanks.
>
> greg k-h



-- 
Best,
Daniel

--000000000000372ddc057e1c3dbb
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIIS7QYJKoZIhvcNAQcCoIIS3jCCEtoCAQExDzANBglghkgBZQMEAgEFADALBgkqhkiG9w0BBwGg
ghBTMIIEXDCCA0SgAwIBAgIOSBtqDm4P/739RPqw/wcwDQYJKoZIhvcNAQELBQAwZDELMAkGA1UE
BhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExOjA4BgNVBAMTMUdsb2JhbFNpZ24gUGVy
c29uYWxTaWduIFBhcnRuZXJzIENBIC0gU0hBMjU2IC0gRzIwHhcNMTYwNjE1MDAwMDAwWhcNMjEw
NjE1MDAwMDAwWjBMMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEiMCAG
A1UEAxMZR2xvYmFsU2lnbiBIViBTL01JTUUgQ0EgMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBALR23lKtjlZW/17kthzYcMHHKFgywfc4vLIjfq42NmMWbXkNUabIgS8KX4PnIFsTlD6F
GO2fqnsTygvYPFBSMX4OCFtJXoikP2CQlEvO7WooyE94tqmqD+w0YtyP2IB5j4KvOIeNv1Gbnnes
BIUWLFxs1ERvYDhmk+OrvW7Vd8ZfpRJj71Rb+QQsUpkyTySaqALXnyztTDp1L5d1bABJN/bJbEU3
Hf5FLrANmognIu+Npty6GrA6p3yKELzTsilOFmYNWg7L838NS2JbFOndl+ce89gM36CW7vyhszi6
6LqqzJL8MsmkP53GGhf11YMP9EkmawYouMDP/PwQYhIiUO0CAwEAAaOCASIwggEeMA4GA1UdDwEB
/wQEAwIBBjAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwEgYDVR0TAQH/BAgwBgEB/wIB
ADAdBgNVHQ4EFgQUyzgSsMeZwHiSjLMhleb0JmLA4D8wHwYDVR0jBBgwFoAUJiSSix/TRK+xsBtt
r+500ox4AAMwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9n
c3BlcnNvbmFsc2lnbnB0bnJzc2hhMmcyLmNybDBMBgNVHSAERTBDMEEGCSsGAQQBoDIBKDA0MDIG
CCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5LzANBgkqhkiG
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
QAYIKwYBBQUHMAKGNGh0dHA6Ly9zZWN1cmUuZ2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzaHZzbWlt
ZWNhMS5jcnQwHQYDVR0OBBYEFHC1FT3LO6BpGtdIXSM5FWFPgFO+MB8GA1UdIwQYMBaAFMs4ErDH
mcB4koyzIZXm9CZiwOA/MEwGA1UdIARFMEMwQQYJKwYBBAGgMgEoMDQwMgYIKwYBBQUHAgEWJmh0
dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMDsGA1UdHwQ0MDIwMKAuoCyGKmh0
dHA6Ly9jcmwuZ2xvYmFsc2lnbi5jb20vZ3NodnNtaW1lY2ExLmNybDAOBgNVHQ8BAf8EBAMCBaAw
HQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMA0GCSqGSIb3DQEBCwUAA4IBAQAp7ulGi+yb
H6Go2/IGeuxY5v6bGG9OgxOivBTos3k5ZBoWJt7BxDTYOLkA5gNLvh2tqsJVUJI5hQXwB4FFK0bI
/YuPUDxQxj9F2DBF6Mrgnclj5XLK3y9N5khy5/Ullth3jbDQ1dmyHQISh4olPbqtnHnWiUb6Mhf6
I3UgrUAhzwFXOlZSk57FgvAZ9472grnkSI8aW1mZp1gf5BNYEVb6y/e1hxlNeZbtIa0vvWDm+tK1
ENfcc+LgRCL4gqiu3v3MEyXXeq/eH/iibrGhissORpiy+nMuWzsTGYOkRRn9RtyEmJAh48WUKCt3
SR4lOce76r8Fd1Dg0XA0lCCwrFRzMYICXjCCAloCAQEwXDBMMQswCQYDVQQGEwJCRTEZMBcGA1UE
ChMQR2xvYmFsU2lnbiBudi1zYTEiMCAGA1UEAxMZR2xvYmFsU2lnbiBIViBTL01JTUUgQ0EgMQIM
IxVzVdM/KCmBJokVMA0GCWCGSAFlAwQCAQUAoIHUMC8GCSqGSIb3DQEJBDEiBCBCBjASDGO7YWrP
zB2I4T2KRhJ+KznmGVFeKIT5vGz7FjAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3
DQEJBTEPFw0xODEyMjgyMjAzNTRaMGkGCSqGSIb3DQEJDzFcMFowCwYJYIZIAWUDBAEqMAsGCWCG
SAFlAwQBFjALBglghkgBZQMEAQIwCgYIKoZIhvcNAwcwCwYJKoZIhvcNAQEKMAsGCSqGSIb3DQEB
BzALBglghkgBZQMEAgEwDQYJKoZIhvcNAQEBBQAEggEAWLYPUu7khseBZ8wMd5CGn/UVFLtuqXDN
LUymlfqMmuPfpL/9mwiuXCcxFiBEkxAc/5GUeHFDKmofAnP3L8JMF/d61BxWwFgSYDnYAfkMffqH
mSsMcvka1TGqDPhsPKPaHL/NknroKZioOizCKVrdIxCYdsqprHlaDwttgEwxwhgDGE7YXmqenaQg
1rweNPr2cnsTE7+FTLDPWrTUWdD00eOwgosBpSh7D/XJ3uH3pewnij0xsfKaeDl+z6ZqfZXXTV53
yhrmtx+lLAVZYJ7RZBHhOHMmCo8+4Iwu0V/IMUt80pC+ZOS5LUf5tsWa+fYiCKc2T7uLv2PWmd/9
rOcLLw==
--000000000000372ddc057e1c3dbb--

