Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F67DC49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 19:49:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFB4121479
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 19:49:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="l80UtuPz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFB4121479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A6346B0005; Tue, 10 Sep 2019 15:49:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6567D6B0006; Tue, 10 Sep 2019 15:49:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 545A16B000A; Tue, 10 Sep 2019 15:49:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0033.hostedemail.com [216.40.44.33])
	by kanga.kvack.org (Postfix) with ESMTP id 20A6B6B0005
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 15:49:54 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C987B1E069
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 19:49:53 +0000 (UTC)
X-FDA: 75920051466.08.goat43_907f4a1b63a03
X-HE-Tag: goat43_907f4a1b63a03
X-Filterd-Recvd-Size: 35133
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 19:49:52 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id r5so22286149qtd.0
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:49:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=wZd3NWYbC5Zc+yFgDfxDwcaLT7xZu38A8KLVAEcbZes=;
        b=l80UtuPzatU58Ip7lJ3L5AhFuYbbwnfTHbxZ42UhMVUUMWIGwabjb+KDye/eZJcFrT
         KiRs0Qhg6Z8np9md/qSQw66ngv15lVdqUa++kYyKhjyAU0V/PmP8nWSn8gpwHJeAfUo7
         f1ZMeRxHiiTa4QKt/wQZF2eWM3ZD4gNbCxDxNV62vTTfa4EEKPRM1pMmeO3tWrmWwOtB
         suS5rzch+0JI9T+Bkmm2qWKcjuvzaT0C9VCKIhMQxnMLTAjssUu1MD6TEZpsQsqHzrKu
         koWm0qsp+FobG3RMfc+YJhSUKdR9WarVk+9qddfdi2pUsme+4fMLKLxO7RT3kDlk5/je
         4HEA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=wZd3NWYbC5Zc+yFgDfxDwcaLT7xZu38A8KLVAEcbZes=;
        b=J0Lo3/fm4WP5QJbCmogVfsFQuTF/vzYmbPPJ5I2tYSLpfKgY2rJ3fUVdFrmMykfNXj
         rbVvHK1XpwlrEGXzoTGrdgNiWpEiFciol11RRPtk0huz2pYkdFHOFowLqLr8S+qfFmI/
         PI4JDly9h3Z6RW7RF52PCt4kUuz4gHrpQtGq8tqG0wZ4lXqrrjsiDNTnRIGt58tS3ZOy
         vsipecCut0b+6o6QUozYMU0z8nP57sqxD3CP43N/9MWVdT7QvOCi9gITfgiQhtYgIXSB
         2UBnxA4XTxNhdnDNrFt0MCmkcOJX39/ygLNpkR6locb8SOZ0w3KJqc62uBSKSPODw3N2
         mTWA==
X-Gm-Message-State: APjAAAW8RVKzFQOcKxzPUch8q5QHNkE8rXuvoO30MTy5w5E29TNr568R
	6yHG2ZFF4t7n8R02BDTotKqNGg==
X-Google-Smtp-Source: APXvYqzTMKu7hQE+7c+GFRtzOqhIGmnHyB+49jbpsbymhHG0y9HidtiYX+HsxOu8raxKSWp/C24JgA==
X-Received: by 2002:a0c:88f0:: with SMTP id 45mr19918212qvo.78.1568144991596;
        Tue, 10 Sep 2019 12:49:51 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id v12sm5414184qtb.5.2019.09.10.12.49.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Sep 2019 12:49:50 -0700 (PDT)
Message-ID: <1568144988.5576.132.camel@lca.pw>
Subject: Re: page_alloc.shuffle=1 + CONFIG_PROVE_LOCKING=y = arm64 hang
From: Qian Cai <cai@lca.pw>
To: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, 
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>,
 Theodore Ts'o <tytso@mit.edu>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Williams
 <dan.j.williams@intel.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  linux-arm-kernel@lists.infradead.org, Peter
 Zijlstra <peterz@infradead.org>,  Waiman Long <longman@redhat.com>, Thomas
 Gleixner <tglx@linutronix.de>
Date: Tue, 10 Sep 2019 15:49:48 -0400
In-Reply-To: <1568128954.5576.129.camel@lca.pw>
References: <1566509603.5576.10.camel@lca.pw>
	 <1567717680.5576.104.camel@lca.pw> <1568128954.5576.129.camel@lca.pw>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-09-10 at 11:22 -0400, Qian Cai wrote:
> On Thu, 2019-09-05 at 17:08 -0400, Qian Cai wrote:
> > Another data point is if change CONFIG_DEBUG_OBJECTS_TIMERS from =3Dy=
 to =3Dn, it
> > will also fix it.
> >=20
> > On Thu, 2019-08-22 at 17:33 -0400, Qian Cai wrote:
> > > https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.conf=
ig
> > >=20
> > > Booting an arm64 ThunderX2 server with page_alloc.shuffle=3D1 [1] +
> > > CONFIG_PROVE_LOCKING=3Dy=C2=A0results in hanging.
> > >=20
> > > [1] https://lore.kernel.org/linux-mm/154899811208.3165233.176232090=
31065121886.s
> > > tgit@dwillia2-desk3.amr.corp.intel.com/
> > >=20
> > > ...
> > > [=C2=A0=C2=A0125.142689][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.2.auto: option mask 0x2
> > > [=C2=A0=C2=A0125.149687][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.2.auto: ias 44-bit, oas 44-bit
> > > (features 0x0000170d)
> > > [=C2=A0=C2=A0125.165198][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.2.auto: allocated 524288 entries
> > > for cmdq
> > > [=C2=A0=C2=A0125.239425][ [=C2=A0=C2=A0125.251484][=C2=A0=C2=A0=C2=A0=
=C2=A0T1] arm-smmu-v3 arm-smmu-v3.3.auto: option
> > > mask 0x2
> > > [=C2=A0=C2=A0125.258233][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.3.auto: ias 44-bit, oas 44-bit
> > > (features 0x0000170d)
> > > [=C2=A0=C2=A0125.282750][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.3.auto: allocated 524288 entries
> > > for cmdq
> > > [=C2=A0=C2=A0125.320097][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.3.auto: allocated 524288 entries
> > > for evtq
> > > [=C2=A0=C2=A0125.332667][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.4.auto: option mask 0x2
> > > [=C2=A0=C2=A0125.339427][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.4.auto: ias 44-bit, oas 44-bit
> > > (features 0x0000170d)
> > > [=C2=A0=C2=A0125.354846][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.4.auto: allocated 524288 entries
> > > for cmdq
> > > [=C2=A0=C2=A0125.375295][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.4.auto: allocated 524288 entries
> > > for evtq
> > > [=C2=A0=C2=A0125.387371][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.5.auto: option mask 0x2
> > > [=C2=A0=C2=A0125.393955][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.5.auto: ias 44-bit, oas 44-bit
> > > (features 0x0000170d)
> > > [=C2=A0=C2=A0125.522605][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.5.auto: allocated 524288 entries
> > > for cmdq
> > > [=C2=A0=C2=A0125.543338][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 ar=
m-smmu-v3.5.auto: allocated 524288 entries
> > > for evtq
> > > [=C2=A0=C2=A0126.694742][=C2=A0=C2=A0=C2=A0=C2=A0T1] EFI Variables =
Facility v0.08 2004-May-17
> > > [=C2=A0=C2=A0126.799291][=C2=A0=C2=A0=C2=A0=C2=A0T1] NET: Registere=
d protocol family 17
> > > [=C2=A0=C2=A0126.978632][=C2=A0=C2=A0=C2=A0=C2=A0T1] zswap: loaded =
using pool lzo/zbud
> > > [=C2=A0=C2=A0126.989168][=C2=A0=C2=A0=C2=A0=C2=A0T1] kmemleak: Kern=
el memory leak detector initialized
> > > [=C2=A0=C2=A0126.989191][ T1577] kmemleak: Automatic memory scannin=
g thread started
> > > [=C2=A0=C2=A0127.044079][ T1335] pcieport 0000:0f:00.0: Adding to i=
ommu group 0
> > > [=C2=A0=C2=A0127.388074][=C2=A0=C2=A0=C2=A0=C2=A0T1] Freeing unused=
 kernel memory: 22528K
> > > [=C2=A0=C2=A0133.527005][=C2=A0=C2=A0=C2=A0=C2=A0T1] Checked W+X ma=
ppings: passed, no W+X pages found
> > > [=C2=A0=C2=A0133.533474][=C2=A0=C2=A0=C2=A0=C2=A0T1] Run /init as i=
nit process
> > > [=C2=A0=C2=A0133.727196][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Sy=
stem time before build time, advancing
> > > clock.
> > > [=C2=A0=C2=A0134.576021][ T1587] modprobe (1587) used greatest stac=
k depth: 27056 bytes
> > > left
> > > [=C2=A0=C2=A0134.764026][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: sy=
stemd 239 running in system mode. (+PAM
> > > +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETU=
P +GCRYPT
> > > +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +P=
CRE2 default-
> > > hierarchy=3Dlegacy)
> > > [=C2=A0=C2=A0134.799044][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: De=
tected architecture arm64.
> > > [=C2=A0=C2=A0134.804818][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Ru=
nning in initial RAM disk.
> > > <...hang...>
> > >=20
> > > Fix it by either set page_alloc.shuffle=3D0 or CONFIG_PROVE_LOCKING=
=3Dn which allow
> > > it to continue successfully.
> > >=20
> > >=20
> > > [=C2=A0=C2=A0121.093846][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Se=
t hostname to <hpe-apollo-cn99xx>.
> > > [=C2=A0=C2=A0123.157524][=C2=A0=C2=A0=C2=A0=C2=A0T1] random: system=
d: uninitialized urandom read (16 bytes
> > > read)
> > > [=C2=A0=C2=A0123.168562][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Li=
stening on Journal Socket.
> > > [=C2=A0=C2=A0OK=C2=A0=C2=A0] Listening on Journal Socket.
> > > [=C2=A0=C2=A0123.203932][=C2=A0=C2=A0=C2=A0=C2=A0T1] random: system=
d: uninitialized urandom read (16 bytes
> > > read)
> > > [=C2=A0=C2=A0123.212813][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Li=
stening on udev Kernel Socket.
> > > [=C2=A0=C2=A0OK=C2=A0=C2=A0] Listening on udev Kernel Socket.
> > > ...
>=20
> Not sure if the arm64 hang is just an effect of the potential console d=
eadlock
> below. The lockdep splat can be reproduced by set,
>=20
> CONFIG_DEBUG_OBJECTS_TIMER=3Dn (=3Dy will lead to the hang above)
> CONFIG_PROVE_LOCKING=3Dy
> CONFIG_SLAB_FREELIST_RANDOM=3Dy (with=C2=A0page_alloc.shuffle=3D1)
>=20
> while compiling kernels,
>=20
> [ 1078.214683][T43784] WARNING: possible circular locking dependency de=
tected
> [ 1078.221550][T43784] 5.3.0-rc7-next-20190904 #14 Not tainted
> [ 1078.227112][T43784] ------------------------------------------------=
------
> [ 1078.233976][T43784] vi/43784 is trying to acquire lock:
> [ 1078.239192][T43784] ffff008b7cff9290 (&(&zone->lock)->rlock){-.-.}, =
at:
> rmqueue_bulk.constprop.21+0xb0/0x1218
> [ 1078.249111][T43784]=C2=A0
> [ 1078.249111][T43784] but task is already holding lock:
> [ 1078.256322][T43784] ffff00938db47d40 (&(&port->lock)->rlock){-.-.}, =
at:
> pty_write+0x78/0x100
> [ 1078.264760][T43784]=C2=A0
> [ 1078.264760][T43784] which lock already depends on the new lock.
> [ 1078.264760][T43784]=C2=A0
> [ 1078.275008][T43784]=C2=A0
> [ 1078.275008][T43784] the existing dependency chain (in reverse order)=
 is:
> [ 1078.283869][T43784]=C2=A0
> [ 1078.283869][T43784] -> #3 (&(&port->lock)->rlock){-.-.}:
> [ 1078.291350][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x5c8/0xbb0
> [ 1078.296394][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x154/0x428
> [ 1078.301266][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock_irqsave+0x80/0xa0
> [ 1078.306831][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ty_port_tty_get+0x28/0x68
> [ 1078.311873][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ty_port_default_wakeup+0x20/0x40
> [ 1078.317523][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ty_port_tty_wakeup+0x38/0x48
> [ 1078.322827][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u=
art_write_wakeup+0x2c/0x50
> [ 1078.327956][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
l011_tx_chars+0x240/0x260
> [ 1078.332999][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
l011_start_tx+0x24/0xa8
> [ 1078.337868][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_uart_start+0x90/0xa0
> [ 1078.342563][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u=
art_write+0x15c/0x2c8
> [ 1078.347261][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_output_char+0x1c8/0x2b0
> [ 1078.352304][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0n=
_tty_write+0x300/0x668
> [ 1078.357087][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ty_write+0x2e8/0x430
> [ 1078.361696][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
edirected_tty_write+0xcc/0xe8
> [ 1078.367086][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_iter_write+0x228/0x270
> [ 1078.372041][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
fs_writev+0x10c/0x1c8
> [ 1078.376735][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_writev+0xdc/0x180
> [ 1078.381257][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_arm64_sys_writev+0x50/0x60
> [ 1078.386476][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e=
l0_svc_handler+0x11c/0x1f0
> [ 1078.391606][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e=
l0_svc+0x8/0xc
> [ 1078.395691][T43784]=C2=A0
> [ 1078.395691][T43784] -> #2 (&port_lock_key){-.-.}:
> [ 1078.402561][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x5c8/0xbb0
> [ 1078.407604][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x154/0x428
> [ 1078.412474][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock+0x68/0x88
> [ 1078.417343][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
l011_console_write+0x2ac/0x318
> [ 1078.422820][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
onsole_unlock+0x3c4/0x898
> [ 1078.427863][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_emit+0x2d4/0x460
> [ 1078.432732][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_default+0x48/0x58
> [ 1078.437688][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_func+0x194/0x250
> [ 1078.442557][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
rintk+0xbc/0xec
> [ 1078.446732][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
egister_console+0x4a8/0x580
> [ 1078.451947][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0u=
art_add_one_port+0x748/0x878
> [ 1078.457250][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
l011_register_port+0x98/0x128
> [ 1078.462639][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
bsa_uart_probe+0x398/0x480
> [ 1078.467772][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
latform_drv_probe+0x70/0x108
> [ 1078.473075][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
eally_probe+0x15c/0x5d8
> [ 1078.477944][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
river_probe_device+0x94/0x1d0
> [ 1078.483335][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_device_attach_driver+0x11c/0x1a8
> [ 1078.489072][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0b=
us_for_each_drv+0xf8/0x158
> [ 1078.494201][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_device_attach+0x164/0x240
> [ 1078.499331][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
evice_initial_probe+0x24/0x30
> [ 1078.504721][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0b=
us_probe_device+0xf0/0x100
> [ 1078.509850][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
evice_add+0x63c/0x960
> [ 1078.514546][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
latform_device_add+0x1ac/0x3b8
> [ 1078.520023][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
latform_device_register_full+0x1fc/0x290
> [ 1078.526373][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
cpi_create_platform_device.part.0+0x264/0x3a8
> [ 1078.533152][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
cpi_create_platform_device+0x68/0x80
> [ 1078.539150][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
cpi_default_enumeration+0x34/0x78
> [ 1078.544887][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
cpi_bus_attach+0x340/0x3b8
> [ 1078.550015][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
cpi_bus_attach+0xf8/0x3b8
> [ 1078.555057][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
cpi_bus_attach+0xf8/0x3b8
> [ 1078.560099][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
cpi_bus_attach+0xf8/0x3b8
> [ 1078.565142][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
cpi_bus_scan+0x9c/0x100
> [ 1078.570015][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
cpi_scan_init+0x16c/0x320
> [ 1078.575058][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
cpi_init+0x330/0x3b8
> [ 1078.579666][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0d=
o_one_initcall+0x158/0x7ec
> [ 1078.584797][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
ernel_init_freeable+0x9a8/0xa70
> [ 1078.590360][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
ernel_init+0x18/0x138
> [ 1078.595055][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
et_from_fork+0x10/0x1c
> [ 1078.599835][T43784]=C2=A0
> [ 1078.599835][T43784] -> #1 (console_owner){-...}:
> [ 1078.606618][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x5c8/0xbb0
> [ 1078.611661][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x154/0x428
> [ 1078.616530][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
onsole_unlock+0x298/0x898
> [ 1078.621573][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_emit+0x2d4/0x460
> [ 1078.626442][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_default+0x48/0x58
> [ 1078.631398][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
printk_func+0x194/0x250
> [ 1078.636267][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
rintk+0xbc/0xec
> [ 1078.640443][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
warn_unseeded_randomness+0xb4/0xd0
> [ 1078.646267][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0g=
et_random_u64+0x4c/0x100
> [ 1078.651224][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
dd_to_free_area_random+0x168/0x1a0
> [ 1078.657047][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0f=
ree_one_page+0x3dc/0xd08
> [ 1078.662003][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_free_pages_ok+0x490/0xd00
> [ 1078.667132][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_free_pages+0xc4/0x118
> [ 1078.671914][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_free_pages_core+0x2e8/0x428
> [ 1078.677219][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0m=
emblock_free_pages+0xa4/0xec
> [ 1078.682522][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0m=
emblock_free_all+0x264/0x330
> [ 1078.687825][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0m=
em_init+0x90/0x148
> [ 1078.692259][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s=
tart_kernel+0x368/0x684
> [ 1078.697126][T43784]=C2=A0
> [ 1078.697126][T43784] -> #0 (&(&zone->lock)->rlock){-.-.}:
> [ 1078.704604][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0c=
heck_prev_add+0x120/0x1138
> [ 1078.709733][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
alidate_chain+0x888/0x1270
> [ 1078.714863][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_lock_acquire+0x5c8/0xbb0
> [ 1078.719906][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0l=
ock_acquire+0x154/0x428
> [ 1078.724776][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
raw_spin_lock+0x68/0x88
> [ 1078.729645][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0r=
mqueue_bulk.constprop.21+0xb0/0x1218
> [ 1078.735643][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0g=
et_page_from_freelist+0x898/0x24a0
> [ 1078.741467][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_alloc_pages_nodemask+0x2a8/0x1d08
> [ 1078.747291][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
lloc_pages_current+0xb4/0x150
> [ 1078.752682][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0a=
llocate_slab+0xab8/0x2350
> [ 1078.757725][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0n=
ew_slab+0x98/0xc0
> [ 1078.762073][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
__slab_alloc+0x66c/0xa30
> [ 1078.767029][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_slab_alloc+0x68/0xc8
> [ 1078.771725][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_kmalloc+0x3d4/0x658
> [ 1078.776333][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_tty_buffer_request_room+0xd4/0x220
> [ 1078.782244][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ty_insert_flip_string_fixed_flag+0x6c/0x128
> [ 1078.788849][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0p=
ty_write+0x98/0x100
> [ 1078.793370][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0n=
_tty_write+0x2a0/0x668
> [ 1078.798152][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0t=
ty_write+0x2e8/0x430
> [ 1078.802760][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_vfs_write+0x5c/0xb0
> [ 1078.807368][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0v=
fs_write+0xf0/0x230
> [ 1078.811890][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0k=
sys_write+0xd4/0x180
> [ 1078.816498][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_=
_arm64_sys_write+0x4c/0x60
> [ 1078.821627][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e=
l0_svc_handler+0x11c/0x1f0
> [ 1078.826756][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0e=
l0_svc+0x8/0xc
> [ 1078.830842][T43784]=C2=A0
> [ 1078.830842][T43784] other info that might help us debug this:
> [ 1078.830842][T43784]=C2=A0
> [ 1078.840918][T43784] Chain exists of:
> [ 1078.840918][T43784]=C2=A0=C2=A0=C2=A0&(&zone->lock)->rlock --> &port=
_lock_key --> &(&port-
> > lock)->rlock
>=20
> [ 1078.840918][T43784]=C2=A0
> [ 1078.854731][T43784]=C2=A0=C2=A0Possible unsafe locking scenario:
> [ 1078.854731][T43784]=C2=A0
> [ 1078.862029][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0C=
PU0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0CPU1
> [ 1078.867243][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0-=
---=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0----
> [ 1078.872457][T43784]=C2=A0=C2=A0=C2=A0lock(&(&port->lock)->rlock);
> [ 1078.877238][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0lock(&p=
ort_lock_key);
> [ 1078.883929][T43784]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0lock(&(=
&port->lock)-
> > rlock);
>=20
> [ 1078.891228][T43784]=C2=A0=C2=A0=C2=A0lock(&(&zone->lock)->rlock);
> [ 1078.896010][T43784]=C2=A0
> [ 1078.896010][T43784]=C2=A0=C2=A0*** DEADLOCK ***
> [ 1078.896010][T43784]=C2=A0
> [ 1078.904004][T43784] 5 locks held by vi/43784:
> [ 1078.908351][T43784]=C2=A0=C2=A0#0: ffff000c36240890 (&tty->ldisc_sem=
){++++}, at:
> ldsem_down_read+0x44/0x50
> [ 1078.917133][T43784]=C2=A0=C2=A0#1: ffff000c36240918 (&tty->atomic_wr=
ite_lock){+.+.},
> at: tty_write_lock+0x24/0x60
> [ 1078.926521][T43784]=C2=A0=C2=A0#2: ffff000c36240aa0 (&o_tty->termios=
_rwsem/1){++++},
> at: n_tty_write+0x108/0x668
> [ 1078.935823][T43784]=C2=A0=C2=A0#3: ffffa0001e0b2360 (&ldata->output_=
lock){+.+.}, at:
> n_tty_write+0x1d0/0x668
> [ 1078.944777][T43784]=C2=A0=C2=A0#4: ffff00938db47d40 (&(&port->lock)-=
>rlock){-.-.}, at:
> pty_write+0x78/0x100
> [ 1078.953644][T43784]=C2=A0
> [ 1078.953644][T43784] stack backtrace:
> [ 1078.959382][T43784] CPU: 97 PID: 43784 Comm: vi Not tainted 5.3.0-rc=
7-next-
> 20190904 #14
> [ 1078.967376][T43784] Hardware name: HPE Apollo
> 70=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0/C01_APACHE_MB=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0, BIOS L50_5.13_1.11 06/18/2019
> [ 1078.977799][T43784] Call trace:
> [ 1078.980932][T43784]=C2=A0=C2=A0dump_backtrace+0x0/0x228
> [ 1078.985279][T43784]=C2=A0=C2=A0show_stack+0x24/0x30
> [ 1078.989282][T43784]=C2=A0=C2=A0dump_stack+0xe8/0x13c
> [ 1078.993370][T43784]=C2=A0=C2=A0print_circular_bug+0x334/0x3d8
> [ 1078.998240][T43784]=C2=A0=C2=A0check_noncircular+0x268/0x310
> [ 1079.003022][T43784]=C2=A0=C2=A0check_prev_add+0x120/0x1138
> [ 1079.007631][T43784]=C2=A0=C2=A0validate_chain+0x888/0x1270
> [ 1079.012241][T43784]=C2=A0=C2=A0__lock_acquire+0x5c8/0xbb0
> [ 1079.016763][T43784]=C2=A0=C2=A0lock_acquire+0x154/0x428
> [ 1079.021111][T43784]=C2=A0=C2=A0_raw_spin_lock+0x68/0x88
> [ 1079.025460][T43784]=C2=A0=C2=A0rmqueue_bulk.constprop.21+0xb0/0x1218
> [ 1079.030937][T43784]=C2=A0=C2=A0get_page_from_freelist+0x898/0x24a0
> [ 1079.036240][T43784]=C2=A0=C2=A0__alloc_pages_nodemask+0x2a8/0x1d08
> [ 1079.041542][T43784]=C2=A0=C2=A0alloc_pages_current+0xb4/0x150
> [ 1079.046412][T43784]=C2=A0=C2=A0allocate_slab+0xab8/0x2350
> [ 1079.050934][T43784]=C2=A0=C2=A0new_slab+0x98/0xc0
> [ 1079.054761][T43784]=C2=A0=C2=A0___slab_alloc+0x66c/0xa30
> [ 1079.059196][T43784]=C2=A0=C2=A0__slab_alloc+0x68/0xc8
> [ 1079.063371][T43784]=C2=A0=C2=A0__kmalloc+0x3d4/0x658
> [ 1079.067458][T43784]=C2=A0=C2=A0__tty_buffer_request_room+0xd4/0x220
> [ 1079.072847][T43784]=C2=A0=C2=A0tty_insert_flip_string_fixed_flag+0x6=
c/0x128
> [ 1079.078932][T43784]=C2=A0=C2=A0pty_write+0x98/0x100
> [ 1079.082932][T43784]=C2=A0=C2=A0n_tty_write+0x2a0/0x668
> [ 1079.087193][T43784]=C2=A0=C2=A0tty_write+0x2e8/0x430
> [ 1079.091280][T43784]=C2=A0=C2=A0__vfs_write+0x5c/0xb0
> [ 1079.095367][T43784]=C2=A0=C2=A0vfs_write+0xf0/0x230
> [ 1079.099368][T43784]=C2=A0=C2=A0ksys_write+0xd4/0x180
> [ 1079.103455][T43784]=C2=A0=C2=A0__arm64_sys_write+0x4c/0x60
> [ 1079.108064][T43784]=C2=A0=C2=A0el0_svc_handler+0x11c/0x1f0
> [ 1079.112672][T43784]=C2=A0=C2=A0el0_svc+0x8/0xc

Hmm, it feels like that CONFIG_SHUFFLE_PAGE_ALLOCATOR=3Dy introduces some=
 unique
locking patterns that the lockdep does not like via,

allocate_slab
  shuffle_freelist
    get_random_u32

Here is another splat with while compiling/installing a kernel,

[ 1254.443119][=C2=A0=C2=A0=C2=A0=C2=A0C2] WARNING: possible circular loc=
king dependency detected
[ 1254.450038][=C2=A0=C2=A0=C2=A0=C2=A0C2] 5.3.0-rc5-next-20190822 #1 Not=
 tainted
[ 1254.455559][=C2=A0=C2=A0=C2=A0=C2=A0C2] ------------------------------=
------------------------
[ 1254.462988][=C2=A0=C2=A0=C2=A0=C2=A0C2] swapper/2/0 is trying to acqui=
re lock:
[ 1254.468509][=C2=A0=C2=A0=C2=A0=C2=A0C2] ffffffffa2925218 (random_write=
_wait.lock){..-.}, at:
__wake_up_common_lock+0xc6/0x150
[ 1254.478154][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1254.478154][=C2=A0=C2=A0=C2=A0=C2=A0C2] but task is already holding lo=
ck:
[ 1254.485896][=C2=A0=C2=A0=C2=A0=C2=A0C2] ffff88845373fda0 (batched_entr=
opy_u32.lock){-.-.}, at:
get_random_u32+0x4c/0xe0
[ 1254.495007][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1254.495007][=C2=A0=C2=A0=C2=A0=C2=A0C2] which lock already depends on =
the new lock.
[ 1254.495007][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1254.505331][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1254.505331][=C2=A0=C2=A0=C2=A0=C2=A0C2] the existing dependency chain =
(in reverse order) is:
[ 1254.514755][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1254.514755][=C2=A0=C2=A0=C2=A0=C2=A0C2] -> #3 (batched_entropy_u32.loc=
k){-.-.}:
[ 1254.522553][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__lock_acquire+0x5b3/0xb40
[ 1254.527638][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0lock_acquire+0x126/0x280
[ 1254.533016][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0_raw_spin_lock_irqsave+0x3a/0x50
[ 1254.538624][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0get_random_u32+0x4c/0xe0
[ 1254.543539][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0allocate_slab+0x6d6/0x19c0
[ 1254.548625][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0new_slab+0x46/0x70
[ 1254.553010][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0___slab_alloc+0x58b/0x960
[ 1254.558533][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__slab_alloc+0x43/0x70
[ 1254.563269][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0kmem_cache_alloc+0x354/0x460
[ 1254.568534][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0fill_pool+0x272/0x4b0
[ 1254.573182][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__debug_object_init+0x86/0x7a0
[ 1254.578615][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0debug_object_init+0x16/0x20
[ 1254.584256][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0hrtimer_init+0x27/0x1e0
[ 1254.589079][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0init_dl_task_timer+0x20/0x40
[ 1254.594342][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__sched_fork+0x10b/0x1f0
[ 1254.599253][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0init_idle+0xac/0x520
[ 1254.603816][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0fork_idle+0x18c/0x230
[ 1254.608933][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0idle_threads_init+0xf0/0x187
[ 1254.614193][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0smp_init+0x1d/0x12d
[ 1254.618671][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0kernel_init_freeable+0x37e/0x76e
[ 1254.624282][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0kernel_init+0x11/0x12f
[ 1254.629016][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0ret_from_fork+0x27/0x50
[ 1254.634344][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1254.634344][=C2=A0=C2=A0=C2=A0=C2=A0C2] -> #2 (&rq->lock){-.-.}:
[ 1254.640831][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__lock_acquire+0x5b3/0xb40
[ 1254.645917][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0lock_acquire+0x126/0x280
[ 1254.650827][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0_raw_spin_lock+0x2f/0x40
[ 1254.655741][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0task_fork_fair+0x43/0x200
[ 1254.661213][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0sched_fork+0x29b/0x420
[ 1254.665949][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0copy_process+0xf12/0x3180
[ 1254.670947][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0_do_fork+0xef/0x950
[ 1254.675422][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0kernel_thread+0xa8/0xe0
[ 1254.680244][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0rest_init+0x28/0x311
[ 1254.685298][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0arch_call_rest_init+0xe/0x1b
[ 1254.690558][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0start_kernel+0x6eb/0x724
[ 1254.695469][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0x86_64_start_reservations+0x24/0x26
[ 1254.701339][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0x86_64_start_kernel+0xf4/0xfb
[ 1254.706689][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0secondary_startup_64+0xb6/0xc0
[ 1254.712601][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1254.712601][=C2=A0=C2=A0=C2=A0=C2=A0C2] -> #1 (&p->pi_lock){-.-.}:
[ 1254.719263][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__lock_acquire+0x5b3/0xb40
[ 1254.724349][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0lock_acquire+0x126/0x280
[ 1254.729260][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0_raw_spin_lock_irqsave+0x3a/0x50
[ 1254.735317][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0try_to_wake_up+0xad/0x1050
[ 1254.740403][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0default_wake_function+0x2f/0x40
[ 1254.745929][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0pollwake+0x10d/0x160
[ 1254.750491][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__wake_up_common+0xc4/0x2a0
[ 1254.755663][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__wake_up_common_lock+0xea/0x150
[ 1254.761756][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__wake_up+0x13/0x20
[ 1254.766230][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0account.constprop.9+0x217/0x340
[ 1254.771754][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0extract_entropy.constprop.7+0xcf/0x220
[ 1254.777886][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0_xfer_secondary_pool+0x19a/0x3d0
[ 1254.783981][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0push_to_pool+0x3e/0x230
[ 1254.788805][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0process_one_work+0x52a/0xb40
[ 1254.794064][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0worker_thread+0x63/0x5b0
[ 1254.798977][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0kthread+0x1df/0x200
[ 1254.803451][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0ret_from_fork+0x27/0x50
[ 1254.808787][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1254.808787][=C2=A0=C2=A0=C2=A0=C2=A0C2] -> #0 (random_write_wait.lock)=
{..-.}:
[ 1254.816409][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0check_prev_add+0x107/0xea0
[ 1254.821494][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0validate_chain+0x8fc/0x1200
[ 1254.826667][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__lock_acquire+0x5b3/0xb40
[ 1254.831751][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0lock_acquire+0x126/0x280
[ 1254.837189][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0_raw_spin_lock_irqsave+0x3a/0x50
[ 1254.842797][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__wake_up_common_lock+0xc6/0x150
[ 1254.848408][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__wake_up+0x13/0x20
[ 1254.852882][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0account.constprop.9+0x217/0x340
[ 1254.858988][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0extract_entropy.constprop.7+0xcf/0x220
[ 1254.865122][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0crng_reseed+0xa1/0x3f0
[ 1254.869859][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0_extract_crng+0xc3/0xd0
[ 1254.874682][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0crng_reseed+0x21b/0x3f0
[ 1254.879505][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0_extract_crng+0xc3/0xd0
[ 1254.884772][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0extract_crng+0x40/0x60
[ 1254.889507][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0get_random_u32+0xb4/0xe0
[ 1254.894417][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0allocate_slab+0x6d6/0x19c0
[ 1254.899501][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0new_slab+0x46/0x70
[ 1254.903886][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0___slab_alloc+0x58b/0x960
[ 1254.909377][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__slab_alloc+0x43/0x70
[ 1254.914112][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0kmem_cache_alloc+0x354/0x460
[ 1254.919375][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__build_skb+0x23/0x60
[ 1254.924024][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__netdev_alloc_skb+0x127/0x1e0
[ 1254.929470][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0tg3_poll_work+0x11b2/0x1f70 [tg3]
[ 1254.935654][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0tg3_poll_msix+0x67/0x330 [tg3]
[ 1254.941092][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0net_rx_action+0x24e/0x7e0
[ 1254.946089][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__do_softirq+0x123/0x767
[ 1254.951000][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0irq_exit+0xd6/0xf0
[ 1254.955385][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0do_IRQ+0xe2/0x1a0
[ 1254.960155][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0ret_from_intr+0x0/0x2a
[ 1254.964896][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0cpuidle_enter_state+0x156/0x8e0
[ 1254.970418][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0cpuidle_enter+0x41/0x70
[ 1254.975242][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0call_cpuidle+0x5e/0x90
[ 1254.979975][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0do_idle+0x333/0x370
[ 1254.984972][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0cpu_startup_entry+0x1d/0x1f
[ 1254.990148][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0start_secondary+0x290/0x330
[ 1254.995319][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0secondary_startup_64+0xb6/0xc0
[ 1255.000750][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1255.000750][=C2=A0=C2=A0=C2=A0=C2=A0C2] other info that might help us =
debug this:
[ 1255.000750][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1255.011424][=C2=A0=C2=A0=C2=A0=C2=A0C2] Chain exists of:
[ 1255.011424][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0random_write_=
wait.lock --> &rq->lock -->
batched_entropy_u32.lock
[ 1255.011424][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1255.025245][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0Possible unsafe loc=
king scenario:
[ 1255.025245][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1255.033012][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0CPU0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0CPU1
[ 1255.038270][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0----=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0----
[ 1255.043526][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0lock(batched_=
entropy_u32.lock);
[ 1255.048610][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0lock(&rq->lock);
[
1255.054918][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0lock(batched_entropy_u32.loc
k);
[ 1255.063035][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0=C2=A0lock(random_w=
rite_wait.lock);
[ 1255.067945][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1255.067945][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0*** DEADLOCK ***
[ 1255.067945][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1255.076000][=C2=A0=C2=A0=C2=A0=C2=A0C2] 1 lock held by swapper/2/0:
[ 1255.080558][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0#0: ffff88845373fda=
0 (batched_entropy_u32.lock){-.-.},
at: get_random_u32+0x4c/0xe0
[ 1255.090547][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0
[ 1255.090547][=C2=A0=C2=A0=C2=A0=C2=A0C2] stack backtrace:
[ 1255.096333][=C2=A0=C2=A0=C2=A0=C2=A0C2] CPU: 2 PID: 0 Comm: swapper/2 =
Not tainted 5.3.0-rc5-next-
20190822 #1
[ 1255.104473][=C2=A0=C2=A0=C2=A0=C2=A0C2] Hardware name: HPE ProLiant DL=
385 Gen10/ProLiant DL385
Gen10, BIOS A40 03/09/2018
[ 1255.114276][=C2=A0=C2=A0=C2=A0=C2=A0C2] Call Trace:
[ 1255.117439][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0<IRQ>
[ 1255.120169][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0dump_stack+0x86/0xc=
a
[ 1255.124205][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0print_circular_bug.=
cold.32+0x243/0x26e
[ 1255.129816][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0check_noncircular+0=
x29e/0x2e0
[ 1255.135221][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __bfs+0x238/0x380
[ 1255.139172][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? print_circular_bu=
g+0x120/0x120
[ 1255.144259][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? find_usage_forwar=
ds+0x7d/0xb0
[ 1255.149260][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0check_prev_add+0x10=
7/0xea0
[ 1255.153823][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0validate_chain+0x8f=
c/0x1200
[ 1255.159007][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? check_prev_add+0x=
ea0/0xea0
[ 1255.163743][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? check_usage_backw=
ards+0x210/0x210
[ 1255.169091][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0__lock_acquire+0x5b=
3/0xb40
[ 1255.173655][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0lock_acquire+0x126/=
0x280
[ 1255.178041][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __wake_up_common_=
lock+0xc6/0x150
[ 1255.183732][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0_raw_spin_lock_irqs=
ave+0x3a/0x50
[ 1255.188817][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __wake_up_common_=
lock+0xc6/0x150
[ 1255.194076][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0__wake_up_common_lo=
ck+0xc6/0x150
[ 1255.199163][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __wake_up_common+=
0x2a0/0x2a0
[ 1255.204078][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? rcu_read_lock_any=
_held.part.5+0x20/0x20
[ 1255.210428][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0__wake_up+0x13/0x20
[ 1255.214379][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0account.constprop.9=
+0x217/0x340
[ 1255.219377][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0extract_entropy.con=
stprop.7+0xcf/0x220
[ 1255.224987][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? crng_reseed+0xa1/=
0x3f0
[ 1255.229375][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0crng_reseed+0xa1/0x=
3f0
[ 1255.234122][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? rcu_read_lock_sch=
ed_held+0xac/0xe0
[ 1255.239556][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? check_flags.part.=
16+0x86/0x220
[ 1255.244641][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? extract_entropy.c=
onstprop.7+0x220/0x220
[ 1255.250511][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __kasan_check_rea=
d+0x11/0x20
[ 1255.255422][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? validate_chain+0x=
ab/0x1200
[ 1255.260742][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? rcu_read_lock_any=
_held.part.5+0x20/0x20
[ 1255.266616][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0_extract_crng+0xc3/=
0xd0
[ 1255.270915][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0crng_reseed+0x21b/0=
x3f0
[ 1255.275215][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? extract_entropy.c=
onstprop.7+0x220/0x220
[ 1255.281085][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __kasan_check_wri=
te+0x14/0x20
[ 1255.286517][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? do_raw_spin_lock+=
0x118/0x1d0
[ 1255.291428][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? rwlock_bug.part.0=
+0x60/0x60
[ 1255.296251][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0_extract_crng+0xc3/=
0xd0
[ 1255.300550][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0extract_crng+0x40/0=
x60
[ 1255.304763][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0get_random_u32+0xb4=
/0xe0
[ 1255.309640][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0allocate_slab+0x6d6=
/0x19c0
[ 1255.314203][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0new_slab+0x46/0x70
[ 1255.318066][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0___slab_alloc+0x58b=
/0x960
[ 1255.322539][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __build_skb+0x23/=
0x60
[ 1255.326841][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? fault_create_debu=
gfs_attr+0x140/0x140
[ 1255.333048][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __build_skb+0x23/=
0x60
[ 1255.337348][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0__slab_alloc+0x43/0=
x70
[ 1255.341559][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __slab_alloc+0x43=
/0x70
[ 1255.345944][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __build_skb+0x23/=
0x60
[ 1255.350242][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0kmem_cache_alloc+0x=
354/0x460
[ 1255.354978][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __netdev_alloc_sk=
b+0x1c6/0x1e0
[ 1255.360626][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? trace_hardirqs_on=
+0x3a/0x160
[ 1255.365535][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0__build_skb+0x23/0x=
60
[ 1255.369660][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0__netdev_alloc_skb+=
0x127/0x1e0
[ 1255.374576][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0tg3_poll_work+0x11b=
2/0x1f70 [tg3]
[ 1255.379750][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? find_held_lock+0x=
11b/0x150
[ 1255.385027][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? tg3_tx_recover+0x=
a0/0xa0 [tg3]
[ 1255.390114][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? _raw_spin_unlock_=
irqrestore+0x38/0x50
[ 1255.395809][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __kasan_check_rea=
d+0x11/0x20
[ 1255.400718][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? validate_chain+0x=
ab/0x1200
[ 1255.405455][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __wake_up_common+=
0x2a0/0x2a0
[ 1255.410761][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? mark_held_locks+0=
x34/0xb0
[ 1255.415415][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0tg3_poll_msix+0x67/=
0x330 [tg3]
[ 1255.420327][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0net_rx_action+0x24e=
/0x7e0
[ 1255.424800][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? find_held_lock+0x=
11b/0x150
[ 1255.429536][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? napi_busy_loop+0x=
600/0x600
[ 1255.434733][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? rcu_read_lock_sch=
ed_held+0xac/0xe0
[ 1255.440169][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? __do_softirq+0xed=
/0x767
[ 1255.444642][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? rcu_read_lock_any=
_held.part.5+0x20/0x20
[ 1255.450518][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? lockdep_hardirqs_=
on+0x1b0/0x2a0
[ 1255.455693][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? irq_exit+0xd6/0xf=
0
[ 1255.460280][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0__do_softirq+0x123/=
0x767
[ 1255.464668][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0irq_exit+0xd6/0xf0
[ 1255.468532][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0do_IRQ+0xe2/0x1a0
[ 1255.472308][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0common_interrupt+0x=
f/0xf
[ 1255.476694][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0</IRQ>
[ 1255.479509][=C2=A0=C2=A0=C2=A0=C2=A0C2] RIP: 0010:cpuidle_enter_state+=
0x156/0x8e0
[ 1255.485750][=C2=A0=C2=A0=C2=A0=C2=A0C2] Code: bf ff 8b 05 a4 27 2d 01 =
85 c0 0f 8f 1d 04 00 00 31
ff e8 4d ba 92 ff 80 7d d0 00 0f 85 0b 02 00 00 e8 ae c0 a7 ff fb 45 85 e=
d <0f>
88 2d 02 00 00 4d 63 fd 49 83 ff 09 0f 87 91 06 00 00 4b 8d 04
[ 1255.505335][=C2=A0=C2=A0=C2=A0=C2=A0C2] RSP: 0018:ffff888206637cf8 EFL=
AGS: 00000202 ORIG_RAX:
ffffffffffffffc8
[ 1255.514154][=C2=A0=C2=A0=C2=A0=C2=A0C2] RAX: 0000000000000000 RBX: fff=
f889f98b44008 RCX:
ffffffffa116e980
[ 1255.522033][=C2=A0=C2=A0=C2=A0=C2=A0C2] RDX: 0000000000000007 RSI: dff=
ffc0000000000 RDI:
ffff8882066287ec
[ 1255.529913][=C2=A0=C2=A0=C2=A0=C2=A0C2] RBP: ffff888206637d48 R08: fff=
ffbfff4557aee R09:
0000000000000000
[ 1255.538278][=C2=A0=C2=A0=C2=A0=C2=A0C2] R10: 0000000000000000 R11: 000=
0000000000000 R12:
ffffffffa28e8ac0
[ 1255.546158][=C2=A0=C2=A0=C2=A0=C2=A0C2] R13: 0000000000000002 R14: 000=
0012412160253 R15:
ffff889f98b4400c
[ 1255.554040][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? lockdep_hardirqs_=
on+0x1b0/0x2a0
[ 1255.559725][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? cpuidle_enter_sta=
te+0x152/0x8e0
[ 1255.564898][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0cpuidle_enter+0x41/=
0x70
[ 1255.569196][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0call_cpuidle+0x5e/0=
x90
[ 1255.573408][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0do_idle+0x333/0x370
[ 1255.577358][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? complete+0x51/0x6=
0
[ 1255.581394][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? arch_cpu_idle_exi=
t+0x40/0x40
[ 1255.586777][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? complete+0x51/0x6=
0
[ 1255.590814][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0cpu_startup_entry+0=
x1d/0x1f
[ 1255.595461][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0start_secondary+0x2=
90/0x330
[ 1255.600111][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0? set_cpu_sibling_m=
ap+0x18f0/0x18f0
[ 1255.605460][=C2=A0=C2=A0=C2=A0=C2=A0C2]=C2=A0=C2=A0secondary_startup_6=
4+0xb6/0xc0

