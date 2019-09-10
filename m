Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A64C6C49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 15:22:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26344217D7
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 15:22:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="oxDIsJiC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26344217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CEAA6B0003; Tue, 10 Sep 2019 11:22:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 880396B0006; Tue, 10 Sep 2019 11:22:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76EDA6B000A; Tue, 10 Sep 2019 11:22:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0114.hostedemail.com [216.40.44.114])
	by kanga.kvack.org (Postfix) with ESMTP id 512446B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 11:22:39 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id AC45E40E0
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 15:22:38 +0000 (UTC)
X-FDA: 75919377996.11.quill89_8b6a09eeca045
X-HE-Tag: quill89_8b6a09eeca045
X-Filterd-Recvd-Size: 19160
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 15:22:37 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id j1so8460068qth.1
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:22:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=1QWZStT5ODe3srgzN6++oHDHyzozTsUuGZAyuz6wOtk=;
        b=oxDIsJiCh+9amwYfp66n5Jk1p6yOWNIFZJ7FoijCoDjDxGyXF3s0t6bjIAKFvv1kQM
         RO531JV7gfK7pYKq1FOEZx6GTKU/+hAL1qzaribyvdNco+kIqWSioznvUZTx36U7Oxu3
         2iax4yEzjpzS+1gP++kEl59twYFP0/WDfTPK0RdeBPnBsbJMgzYQSNZSfktn+xtu5iMO
         lUsM2tkxGVMeYUf8XDiplPLgHhBNp612Yh+CkV/X6Eqizq2GftKfe6zNM3Eot2FYdNKr
         JvPLAntmAZnurOufvtJ696VHnHeih+6MBqwEuTA1I5WnDvOND+UOrjM5ZY48d0tpr/7m
         hJGg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=1QWZStT5ODe3srgzN6++oHDHyzozTsUuGZAyuz6wOtk=;
        b=chmZyeu1fvwnJYnZ3yIVaEs7WVnvjUFr+m3PGWyfuO7JRkNifkBefZtR94/GOQmLgV
         fQhswzK3NXHWiIMMf3yaWA5MSWWKypBOVb5Wpz+sZDGuRD2pS+GDDkYUsP1E31iyflME
         P/1e3HtQnxXx5M0eNSfXyP3R8RV4mmh6eZz4w+Sflotb4HbVbvHC9nmVaiKHhq//CSBJ
         jkh3QHljcoanyIIz8dARdzOOpSvn1p/T9Y+87/yh9QxmEYwZ1xWeuOXaoIZ9/SeKoYg9
         LGaXf2XOq7ZqIAG7WfCf7R4epdb74Tg2BhVQWvPJB3CPuN8+r6vrzl7lBAlWuKxV6KD4
         3Gtg==
X-Gm-Message-State: APjAAAV/rvJF4WVALs/ncjL4zLYc0sFRjRvFESIb8gDoI2XuvJ/hsUVZ
	RSQ1KLT+ozA4SIjJpREBhvn6AA==
X-Google-Smtp-Source: APXvYqwSgU9foURbZLY+xXeEZGc9anAs6/UjJqx8tnplFNYDhtQTYQNXKUJhcKtO472NFPmfRD1qKg==
X-Received: by 2002:a0c:fa52:: with SMTP id k18mr17709351qvo.99.1568128956995;
        Tue, 10 Sep 2019 08:22:36 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id i4sm3147488qke.93.2019.09.10.08.22.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Sep 2019 08:22:36 -0700 (PDT)
Message-ID: <1568128954.5576.129.camel@lca.pw>
Subject: Re: page_alloc.shuffle=1 + CONFIG_PROVE_LOCKING=y = arm64 hang
From: Qian Cai <cai@lca.pw>
To: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Williams
 <dan.j.williams@intel.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  linux-arm-kernel@lists.infradead.org, Peter
 Zijlstra <peterz@infradead.org>,  Waiman Long <longman@redhat.com>, Thomas
 Gleixner <tglx@linutronix.de>
Date: Tue, 10 Sep 2019 11:22:34 -0400
In-Reply-To: <1567717680.5576.104.camel@lca.pw>
References: <1566509603.5576.10.camel@lca.pw>
	 <1567717680.5576.104.camel@lca.pw>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-09-05 at 17:08 -0400, Qian Cai wrote:
> Another data point is if change CONFIG_DEBUG_OBJECTS_TIMERS from =3Dy t=
o =3Dn, it
> will also fix it.
>=20
> On Thu, 2019-08-22 at 17:33 -0400, Qian Cai wrote:
> > https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config
> >=20
> > Booting an arm64 ThunderX2 server with page_alloc.shuffle=3D1 [1] +
> > CONFIG_PROVE_LOCKING=3Dy=C2=A0results in hanging.
> >=20
> > [1] https://lore.kernel.org/linux-mm/154899811208.3165233.17623209031=
065121886.s
> > tgit@dwillia2-desk3.amr.corp.intel.com/
> >=20
> > ...
> > [=C2=A0=C2=A0125.142689][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.2.auto: option mask 0x2
> > [=C2=A0=C2=A0125.149687][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.2.auto: ias 44-bit, oas 44-bit
> > (features 0x0000170d)
> > [=C2=A0=C2=A0125.165198][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.2.auto: allocated 524288 entries
> > for cmdq
> > [=C2=A0=C2=A0125.239425][ [=C2=A0=C2=A0125.251484][=C2=A0=C2=A0=C2=A0=
=C2=A0T1] arm-smmu-v3 arm-smmu-v3.3.auto: option
> > mask 0x2
> > [=C2=A0=C2=A0125.258233][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.3.auto: ias 44-bit, oas 44-bit
> > (features 0x0000170d)
> > [=C2=A0=C2=A0125.282750][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.3.auto: allocated 524288 entries
> > for cmdq
> > [=C2=A0=C2=A0125.320097][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.3.auto: allocated 524288 entries
> > for evtq
> > [=C2=A0=C2=A0125.332667][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.4.auto: option mask 0x2
> > [=C2=A0=C2=A0125.339427][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.4.auto: ias 44-bit, oas 44-bit
> > (features 0x0000170d)
> > [=C2=A0=C2=A0125.354846][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.4.auto: allocated 524288 entries
> > for cmdq
> > [=C2=A0=C2=A0125.375295][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.4.auto: allocated 524288 entries
> > for evtq
> > [=C2=A0=C2=A0125.387371][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.5.auto: option mask 0x2
> > [=C2=A0=C2=A0125.393955][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.5.auto: ias 44-bit, oas 44-bit
> > (features 0x0000170d)
> > [=C2=A0=C2=A0125.522605][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.5.auto: allocated 524288 entries
> > for cmdq
> > [=C2=A0=C2=A0125.543338][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-=
smmu-v3.5.auto: allocated 524288 entries
> > for evtq
> > [=C2=A0=C2=A0126.694742][=C2=A0=C2=A0=C2=A0=C2=A0T1] EFI Variables Fa=
cility v0.08 2004-May-17
> > [=C2=A0=C2=A0126.799291][=C2=A0=C2=A0=C2=A0=C2=A0T1] NET: Registered =
protocol family 17
> > [=C2=A0=C2=A0126.978632][=C2=A0=C2=A0=C2=A0=C2=A0T1] zswap: loaded us=
ing pool lzo/zbud
> > [=C2=A0=C2=A0126.989168][=C2=A0=C2=A0=C2=A0=C2=A0T1] kmemleak: Kernel=
 memory leak detector initialized
> > [=C2=A0=C2=A0126.989191][ T1577] kmemleak: Automatic memory scanning =
thread started
> > [=C2=A0=C2=A0127.044079][ T1335] pcieport 0000:0f:00.0: Adding to iom=
mu group 0
> > [=C2=A0=C2=A0127.388074][=C2=A0=C2=A0=C2=A0=C2=A0T1] Freeing unused k=
ernel memory: 22528K
> > [=C2=A0=C2=A0133.527005][=C2=A0=C2=A0=C2=A0=C2=A0T1] Checked W+X mapp=
ings: passed, no W+X pages found
> > [=C2=A0=C2=A0133.533474][=C2=A0=C2=A0=C2=A0=C2=A0T1] Run /init as ini=
t process
> > [=C2=A0=C2=A0133.727196][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Syst=
em time before build time, advancing
> > clock.
> > [=C2=A0=C2=A0134.576021][ T1587] modprobe (1587) used greatest stack =
depth: 27056 bytes
> > left
> > [=C2=A0=C2=A0134.764026][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: syst=
emd 239 running in system mode. (+PAM
> > +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP =
+GCRYPT
> > +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCR=
E2 default-
> > hierarchy=3Dlegacy)
> > [=C2=A0=C2=A0134.799044][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Dete=
cted architecture arm64.
> > [=C2=A0=C2=A0134.804818][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Runn=
ing in initial RAM disk.
> > <...hang...>
> >=20
> > Fix it by either set page_alloc.shuffle=3D0 or CONFIG_PROVE_LOCKING=3D=
n which allow
> > it to continue successfully.
> >=20
> >=20
> > [=C2=A0=C2=A0121.093846][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Set =
hostname to <hpe-apollo-cn99xx>.
> > [=C2=A0=C2=A0123.157524][=C2=A0=C2=A0=C2=A0=C2=A0T1] random: systemd:=
 uninitialized urandom read (16 bytes
> > read)
> > [=C2=A0=C2=A0123.168562][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: List=
ening on Journal Socket.
> > [=C2=A0=C2=A0OK=C2=A0=C2=A0] Listening on Journal Socket.
> > [=C2=A0=C2=A0123.203932][=C2=A0=C2=A0=C2=A0=C2=A0T1] random: systemd:=
 uninitialized urandom read (16 bytes
> > read)
> > [=C2=A0=C2=A0123.212813][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: List=
ening on udev Kernel Socket.
> > [=C2=A0=C2=A0OK=C2=A0=C2=A0] Listening on udev Kernel Socket.
> > ...

Not sure if the arm64 hang is just an effect of the potential console dea=
dlock
below. The lockdep splat can be reproduced by set,

CONFIG_DEBUG_OBJECTS_TIMER=3Dn (=3Dy will lead to the hang above)
CONFIG_PROVE_LOCKING=3Dy
CONFIG_SLAB_FREELIST_RANDOM=3Dy (with=C2=A0page_alloc.shuffle=3D1)

while compiling kernels,

[ 1078.214683][T43784] WARNING: possible circular locking dependency dete=
cted
[ 1078.221550][T43784] 5.3.0-rc7-next-20190904 #14 Not tainted
[ 1078.227112][T43784] --------------------------------------------------=
----
[ 1078.233976][T43784] vi/43784 is trying to acquire lock:
[ 1078.239192][T43784] ffff008b7cff9290 (&(&zone->lock)->rlock){-.-.}, at=
:
rmqueue_bulk.constprop.21+0xb0/0x1218
[ 1078.249111][T43784]=C2=A0
[ 1078.249111][T43784] but task is already holding lock:
[ 1078.256322][T43784] ffff00938db47d40 (&(&port->lock)->rlock){-.-.}, at=
:
pty_write+0x78/0x100
[ 1078.264760][T43784]=C2=A0
[ 1078.264760][T43784] which lock already depends on the new lock.
[ 1078.264760][T43784]=C2=A0
[ 1078.275008][T43784]=C2=A0
[ 1078.275008][T43784] the existing dependency chain (in reverse order) i=
s:
[ 1078.283869][T43784]=C2=A0
[ 1078.283869][T43784] -> #3 (&(&port->lock)->rlock){-.-.}:
[ 1078.291350][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__l=
ock_acquire+0x5c8/0xbb0
[ 1078.296394][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0loc=
k_acquire+0x154/0x428
[ 1078.301266][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_ra=
w_spin_lock_irqsave+0x80/0xa0
[ 1078.306831][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0tty=
_port_tty_get+0x28/0x68
[ 1078.311873][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0tty=
_port_default_wakeup+0x20/0x40
[ 1078.317523][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0tty=
_port_tty_wakeup+0x38/0x48
[ 1078.322827][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0uar=
t_write_wakeup+0x2c/0x50
[ 1078.327956][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pl0=
11_tx_chars+0x240/0x260
[ 1078.332999][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pl0=
11_start_tx+0x24/0xa8
[ 1078.337868][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__u=
art_start+0x90/0xa0
[ 1078.342563][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0uar=
t_write+0x15c/0x2c8
[ 1078.347261][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0do_=
output_char+0x1c8/0x2b0
[ 1078.352304][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0n_t=
ty_write+0x300/0x668
[ 1078.357087][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0tty=
_write+0x2e8/0x430
[ 1078.361696][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0red=
irected_tty_write+0xcc/0xe8
[ 1078.367086][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0do_=
iter_write+0x228/0x270
[ 1078.372041][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0vfs=
_writev+0x10c/0x1c8
[ 1078.376735][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0do_=
writev+0xdc/0x180
[ 1078.381257][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__a=
rm64_sys_writev+0x50/0x60
[ 1078.386476][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0el0=
_svc_handler+0x11c/0x1f0
[ 1078.391606][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0el0=
_svc+0x8/0xc
[ 1078.395691][T43784]=C2=A0
[ 1078.395691][T43784] -> #2 (&port_lock_key){-.-.}:
[ 1078.402561][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__l=
ock_acquire+0x5c8/0xbb0
[ 1078.407604][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0loc=
k_acquire+0x154/0x428
[ 1078.412474][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_ra=
w_spin_lock+0x68/0x88
[ 1078.417343][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pl0=
11_console_write+0x2ac/0x318
[ 1078.422820][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0con=
sole_unlock+0x3c4/0x898
[ 1078.427863][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0vpr=
intk_emit+0x2d4/0x460
[ 1078.432732][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0vpr=
intk_default+0x48/0x58
[ 1078.437688][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0vpr=
intk_func+0x194/0x250
[ 1078.442557][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pri=
ntk+0xbc/0xec
[ 1078.446732][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0reg=
ister_console+0x4a8/0x580
[ 1078.451947][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0uar=
t_add_one_port+0x748/0x878
[ 1078.457250][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pl0=
11_register_port+0x98/0x128
[ 1078.462639][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0sbs=
a_uart_probe+0x398/0x480
[ 1078.467772][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pla=
tform_drv_probe+0x70/0x108
[ 1078.473075][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0rea=
lly_probe+0x15c/0x5d8
[ 1078.477944][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0dri=
ver_probe_device+0x94/0x1d0
[ 1078.483335][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__d=
evice_attach_driver+0x11c/0x1a8
[ 1078.489072][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0bus=
_for_each_drv+0xf8/0x158
[ 1078.494201][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__d=
evice_attach+0x164/0x240
[ 1078.499331][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0dev=
ice_initial_probe+0x24/0x30
[ 1078.504721][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0bus=
_probe_device+0xf0/0x100
[ 1078.509850][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0dev=
ice_add+0x63c/0x960
[ 1078.514546][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pla=
tform_device_add+0x1ac/0x3b8
[ 1078.520023][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pla=
tform_device_register_full+0x1fc/0x290
[ 1078.526373][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0acp=
i_create_platform_device.part.0+0x264/0x3a8
[ 1078.533152][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0acp=
i_create_platform_device+0x68/0x80
[ 1078.539150][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0acp=
i_default_enumeration+0x34/0x78
[ 1078.544887][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0acp=
i_bus_attach+0x340/0x3b8
[ 1078.550015][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0acp=
i_bus_attach+0xf8/0x3b8
[ 1078.555057][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0acp=
i_bus_attach+0xf8/0x3b8
[ 1078.560099][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0acp=
i_bus_attach+0xf8/0x3b8
[ 1078.565142][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0acp=
i_bus_scan+0x9c/0x100
[ 1078.570015][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0acp=
i_scan_init+0x16c/0x320
[ 1078.575058][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0acp=
i_init+0x330/0x3b8
[ 1078.579666][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0do_=
one_initcall+0x158/0x7ec
[ 1078.584797][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0ker=
nel_init_freeable+0x9a8/0xa70
[ 1078.590360][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0ker=
nel_init+0x18/0x138
[ 1078.595055][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0ret=
_from_fork+0x10/0x1c
[ 1078.599835][T43784]=C2=A0
[ 1078.599835][T43784] -> #1 (console_owner){-...}:
[ 1078.606618][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__l=
ock_acquire+0x5c8/0xbb0
[ 1078.611661][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0loc=
k_acquire+0x154/0x428
[ 1078.616530][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0con=
sole_unlock+0x298/0x898
[ 1078.621573][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0vpr=
intk_emit+0x2d4/0x460
[ 1078.626442][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0vpr=
intk_default+0x48/0x58
[ 1078.631398][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0vpr=
intk_func+0x194/0x250
[ 1078.636267][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pri=
ntk+0xbc/0xec
[ 1078.640443][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_wa=
rn_unseeded_randomness+0xb4/0xd0
[ 1078.646267][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0get=
_random_u64+0x4c/0x100
[ 1078.651224][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0add=
_to_free_area_random+0x168/0x1a0
[ 1078.657047][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0fre=
e_one_page+0x3dc/0xd08
[ 1078.662003][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__f=
ree_pages_ok+0x490/0xd00
[ 1078.667132][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__f=
ree_pages+0xc4/0x118
[ 1078.671914][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__f=
ree_pages_core+0x2e8/0x428
[ 1078.677219][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mem=
block_free_pages+0xa4/0xec
[ 1078.682522][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mem=
block_free_all+0x264/0x330
[ 1078.687825][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mem=
_init+0x90/0x148
[ 1078.692259][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0sta=
rt_kernel+0x368/0x684
[ 1078.697126][T43784]=C2=A0
[ 1078.697126][T43784] -> #0 (&(&zone->lock)->rlock){-.-.}:
[ 1078.704604][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0che=
ck_prev_add+0x120/0x1138
[ 1078.709733][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0val=
idate_chain+0x888/0x1270
[ 1078.714863][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__l=
ock_acquire+0x5c8/0xbb0
[ 1078.719906][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0loc=
k_acquire+0x154/0x428
[ 1078.724776][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_ra=
w_spin_lock+0x68/0x88
[ 1078.729645][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0rmq=
ueue_bulk.constprop.21+0xb0/0x1218
[ 1078.735643][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0get=
_page_from_freelist+0x898/0x24a0
[ 1078.741467][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__a=
lloc_pages_nodemask+0x2a8/0x1d08
[ 1078.747291][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0all=
oc_pages_current+0xb4/0x150
[ 1078.752682][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0all=
ocate_slab+0xab8/0x2350
[ 1078.757725][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0new=
_slab+0x98/0xc0
[ 1078.762073][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0___=
slab_alloc+0x66c/0xa30
[ 1078.767029][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__s=
lab_alloc+0x68/0xc8
[ 1078.771725][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__k=
malloc+0x3d4/0x658
[ 1078.776333][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__t=
ty_buffer_request_room+0xd4/0x220
[ 1078.782244][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0tty=
_insert_flip_string_fixed_flag+0x6c/0x128
[ 1078.788849][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pty=
_write+0x98/0x100
[ 1078.793370][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0n_t=
ty_write+0x2a0/0x668
[ 1078.798152][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0tty=
_write+0x2e8/0x430
[ 1078.802760][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__v=
fs_write+0x5c/0xb0
[ 1078.807368][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0vfs=
_write+0xf0/0x230
[ 1078.811890][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0ksy=
s_write+0xd4/0x180
[ 1078.816498][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__a=
rm64_sys_write+0x4c/0x60
[ 1078.821627][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0el0=
_svc_handler+0x11c/0x1f0
[ 1078.826756][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0el0=
_svc+0x8/0xc
[ 1078.830842][T43784]=C2=A0
[ 1078.830842][T43784] other info that might help us debug this:
[ 1078.830842][T43784]=C2=A0
[ 1078.840918][T43784] Chain exists of:
[ 1078.840918][T43784]=C2=A0=C2=A0=C2=A0&(&zone->lock)->rlock --> &port_l=
ock_key --> &(&port-
>lock)->rlock
[ 1078.840918][T43784]=C2=A0
[ 1078.854731][T43784]=C2=A0=C2=A0Possible unsafe locking scenario:
[ 1078.854731][T43784]=C2=A0
[ 1078.862029][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0CPU=
0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0CPU1
[ 1078.867243][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0---=
-=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0----
[ 1078.872457][T43784]=C2=A0=C2=A0=C2=A0lock(&(&port->lock)->rlock);
[ 1078.877238][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0lock(&p=
ort_lock_key);
[ 1078.883929][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0lock(&(=
&port->lock)-
>rlock);
[ 1078.891228][T43784]=C2=A0=C2=A0=C2=A0lock(&(&zone->lock)->rlock);
[ 1078.896010][T43784]=C2=A0
[ 1078.896010][T43784]=C2=A0=C2=A0*** DEADLOCK ***
[ 1078.896010][T43784]=C2=A0
[ 1078.904004][T43784] 5 locks held by vi/43784:
[ 1078.908351][T43784]=C2=A0=C2=A0#0: ffff000c36240890 (&tty->ldisc_sem){=
++++}, at:
ldsem_down_read+0x44/0x50
[ 1078.917133][T43784]=C2=A0=C2=A0#1: ffff000c36240918 (&tty->atomic_writ=
e_lock){+.+.},
at: tty_write_lock+0x24/0x60
[ 1078.926521][T43784]=C2=A0=C2=A0#2: ffff000c36240aa0 (&o_tty->termios_r=
wsem/1){++++},
at: n_tty_write+0x108/0x668
[ 1078.935823][T43784]=C2=A0=C2=A0#3: ffffa0001e0b2360 (&ldata->output_lo=
ck){+.+.}, at:
n_tty_write+0x1d0/0x668
[ 1078.944777][T43784]=C2=A0=C2=A0#4: ffff00938db47d40 (&(&port->lock)->r=
lock){-.-.}, at:
pty_write+0x78/0x100
[ 1078.953644][T43784]=C2=A0
[ 1078.953644][T43784] stack backtrace:
[ 1078.959382][T43784] CPU: 97 PID: 43784 Comm: vi Not tainted 5.3.0-rc7-=
next-
20190904 #14
[ 1078.967376][T43784] Hardware name: HPE Apollo
70=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0/C01_APACHE_MB=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
, BIOS L50_5.13_1.11 06/18/2019
[ 1078.977799][T43784] Call trace:
[ 1078.980932][T43784]=C2=A0=C2=A0dump_backtrace+0x0/0x228
[ 1078.985279][T43784]=C2=A0=C2=A0show_stack+0x24/0x30
[ 1078.989282][T43784]=C2=A0=C2=A0dump_stack+0xe8/0x13c
[ 1078.993370][T43784]=C2=A0=C2=A0print_circular_bug+0x334/0x3d8
[ 1078.998240][T43784]=C2=A0=C2=A0check_noncircular+0x268/0x310
[ 1079.003022][T43784]=C2=A0=C2=A0check_prev_add+0x120/0x1138
[ 1079.007631][T43784]=C2=A0=C2=A0validate_chain+0x888/0x1270
[ 1079.012241][T43784]=C2=A0=C2=A0__lock_acquire+0x5c8/0xbb0
[ 1079.016763][T43784]=C2=A0=C2=A0lock_acquire+0x154/0x428
[ 1079.021111][T43784]=C2=A0=C2=A0_raw_spin_lock+0x68/0x88
[ 1079.025460][T43784]=C2=A0=C2=A0rmqueue_bulk.constprop.21+0xb0/0x1218
[ 1079.030937][T43784]=C2=A0=C2=A0get_page_from_freelist+0x898/0x24a0
[ 1079.036240][T43784]=C2=A0=C2=A0__alloc_pages_nodemask+0x2a8/0x1d08
[ 1079.041542][T43784]=C2=A0=C2=A0alloc_pages_current+0xb4/0x150
[ 1079.046412][T43784]=C2=A0=C2=A0allocate_slab+0xab8/0x2350
[ 1079.050934][T43784]=C2=A0=C2=A0new_slab+0x98/0xc0
[ 1079.054761][T43784]=C2=A0=C2=A0___slab_alloc+0x66c/0xa30
[ 1079.059196][T43784]=C2=A0=C2=A0__slab_alloc+0x68/0xc8
[ 1079.063371][T43784]=C2=A0=C2=A0__kmalloc+0x3d4/0x658
[ 1079.067458][T43784]=C2=A0=C2=A0__tty_buffer_request_room+0xd4/0x220
[ 1079.072847][T43784]=C2=A0=C2=A0tty_insert_flip_string_fixed_flag+0x6c/=
0x128
[ 1079.078932][T43784]=C2=A0=C2=A0pty_write+0x98/0x100
[ 1079.082932][T43784]=C2=A0=C2=A0n_tty_write+0x2a0/0x668
[ 1079.087193][T43784]=C2=A0=C2=A0tty_write+0x2e8/0x430
[ 1079.091280][T43784]=C2=A0=C2=A0__vfs_write+0x5c/0xb0
[ 1079.095367][T43784]=C2=A0=C2=A0vfs_write+0xf0/0x230
[ 1079.099368][T43784]=C2=A0=C2=A0ksys_write+0xd4/0x180
[ 1079.103455][T43784]=C2=A0=C2=A0__arm64_sys_write+0x4c/0x60
[ 1079.108064][T43784]=C2=A0=C2=A0el0_svc_handler+0x11c/0x1f0
[ 1079.112672][T43784]=C2=A0=C2=A0el0_svc+0x8/0xc

