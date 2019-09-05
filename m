Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92B6BC43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:08:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C1DC20820
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:08:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="RE1kQcFx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C1DC20820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F00F46B0005; Thu,  5 Sep 2019 17:08:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED7DA6B0007; Thu,  5 Sep 2019 17:08:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DED236B0008; Thu,  5 Sep 2019 17:08:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id B8C226B0005
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:08:03 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 518FF45AB
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:08:03 +0000 (UTC)
X-FDA: 75902104446.29.start65_635e250f4054e
X-HE-Tag: start65_635e250f4054e
X-Filterd-Recvd-Size: 7041
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:08:02 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id a13so4654100qtj.1
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 14:08:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=HvoJM9sMGq5xI3RwMvugcMXuusxVFzNWPQZRfU0rEf8=;
        b=RE1kQcFxWLO+aub3BJU/i/hazoxxbNU/KRFZj4Yf4mDb4K8zmul3vWp/RDVVFMnCaV
         QX7/TnC7DuZWGLudP8Vwi+KwuJBCSIwq9urMjeXsLuP8SZWja6CfE7N8GK2kQx7f/BCu
         iAVspylz/WJ1PGnD/M1oDkyUKErs8+PtG8mdpd0mxQefo3dPEcIgsnJvD3ryXtj/LB9r
         IN0zb+7LzqSvm9a2uSNuUnZ932xeKnGAccrllI9cX+YSR+nlBkR5aQMj6lO2Pa6n9n51
         /AUIzWhaVCT5TeZcRUkT7uLoxe9JASdBGMnKn3LJ6O9CSsJvlEywBPIqtAoEGHRFAz69
         TiIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=HvoJM9sMGq5xI3RwMvugcMXuusxVFzNWPQZRfU0rEf8=;
        b=tpdoI5r5mo2JUvlAiOfwoHMBC9WFvOexl3if/JZz8U/1KQaftezoic0ADGhQNfs0eZ
         1FH+O8NiDDRJaoIJXbLZHmVE7h0SIcw1PwX8TFxfPjLd43P2J80VZe6nNw91zwnhXEsH
         /zh1QpuW50rOfrB8mMR2Rg0vSYePNGYzieU4KY/qxtJFhNL2WdmsO+NkrAVKL2UKl3+W
         snStwVeZrjRgP/pt1hG3nV5HZJbblfOrvSNWgFcck3SdRicWs2aLdwsyx4T/u4zhEJU1
         cAdbZjCnZvQLPYUURK0gDgCxKHmR1s5IFlCE4TipirfwtN1HL2EE5JgZiYeV8mHXXZRH
         5Syw==
X-Gm-Message-State: APjAAAWpoBEFrXPXXY9wkq2n8X8KE8XJJKf7Dc/Is6Nnwl3mkD+lcCvE
	z0JwythKM2pb6I2/N+HgoaefTQ==
X-Google-Smtp-Source: APXvYqxY2ypIf1XfIoVNJF4qwIapFtfKnB7Ak69TdLWw2rUBh9E7c/fsOawf0Iylhmq8cCiBqn8CyA==
X-Received: by 2002:a05:6214:16cb:: with SMTP id d11mr3355475qvz.241.1567717682191;
        Thu, 05 Sep 2019 14:08:02 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id k11sm1510843qtp.26.2019.09.05.14.08.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Sep 2019 14:08:01 -0700 (PDT)
Message-ID: <1567717680.5576.104.camel@lca.pw>
Subject: Re: page_alloc.shuffle=1 + CONFIG_PROVE_LOCKING=y = arm64 hang
From: Qian Cai <cai@lca.pw>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, 
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Peter
 Zijlstra <peterz@infradead.org>, Waiman Long <longman@redhat.com>, Thomas
 Gleixner <tglx@linutronix.de>
Date: Thu, 05 Sep 2019 17:08:00 -0400
In-Reply-To: <1566509603.5576.10.camel@lca.pw>
References: <1566509603.5576.10.camel@lca.pw>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Another data point is if change CONFIG_DEBUG_OBJECTS_TIMERS from =3Dy to =
=3Dn, it
will also fix it.

On Thu, 2019-08-22 at 17:33 -0400, Qian Cai wrote:
> https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config
>=20
> Booting an arm64 ThunderX2 server with page_alloc.shuffle=3D1 [1] +
> CONFIG_PROVE_LOCKING=3Dy=C2=A0results in hanging.
>=20
> [1] https://lore.kernel.org/linux-mm/154899811208.3165233.1762320903106=
5121886.s
> tgit@dwillia2-desk3.amr.corp.intel.com/
>=20
> ...
> [=C2=A0=C2=A0125.142689][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.2.auto: option mask 0x2
> [=C2=A0=C2=A0125.149687][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.2.auto: ias 44-bit, oas 44-bit
> (features 0x0000170d)
> [=C2=A0=C2=A0125.165198][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.2.auto: allocated 524288 entries
> for cmdq
> [=C2=A0=C2=A0125.239425][ [=C2=A0=C2=A0125.251484][=C2=A0=C2=A0=C2=A0=C2=
=A0T1] arm-smmu-v3 arm-smmu-v3.3.auto: option
> mask 0x2
> [=C2=A0=C2=A0125.258233][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.3.auto: ias 44-bit, oas 44-bit
> (features 0x0000170d)
> [=C2=A0=C2=A0125.282750][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.3.auto: allocated 524288 entries
> for cmdq
> [=C2=A0=C2=A0125.320097][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.3.auto: allocated 524288 entries
> for evtq
> [=C2=A0=C2=A0125.332667][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.4.auto: option mask 0x2
> [=C2=A0=C2=A0125.339427][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.4.auto: ias 44-bit, oas 44-bit
> (features 0x0000170d)
> [=C2=A0=C2=A0125.354846][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.4.auto: allocated 524288 entries
> for cmdq
> [=C2=A0=C2=A0125.375295][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.4.auto: allocated 524288 entries
> for evtq
> [=C2=A0=C2=A0125.387371][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.5.auto: option mask 0x2
> [=C2=A0=C2=A0125.393955][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.5.auto: ias 44-bit, oas 44-bit
> (features 0x0000170d)
> [=C2=A0=C2=A0125.522605][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.5.auto: allocated 524288 entries
> for cmdq
> [=C2=A0=C2=A0125.543338][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-sm=
mu-v3.5.auto: allocated 524288 entries
> for evtq
> [=C2=A0=C2=A0126.694742][=C2=A0=C2=A0=C2=A0=C2=A0T1] EFI Variables Faci=
lity v0.08 2004-May-17
> [=C2=A0=C2=A0126.799291][=C2=A0=C2=A0=C2=A0=C2=A0T1] NET: Registered pr=
otocol family 17
> [=C2=A0=C2=A0126.978632][=C2=A0=C2=A0=C2=A0=C2=A0T1] zswap: loaded usin=
g pool lzo/zbud
> [=C2=A0=C2=A0126.989168][=C2=A0=C2=A0=C2=A0=C2=A0T1] kmemleak: Kernel m=
emory leak detector initialized
> [=C2=A0=C2=A0126.989191][ T1577] kmemleak: Automatic memory scanning th=
read started
> [=C2=A0=C2=A0127.044079][ T1335] pcieport 0000:0f:00.0: Adding to iommu=
 group 0
> [=C2=A0=C2=A0127.388074][=C2=A0=C2=A0=C2=A0=C2=A0T1] Freeing unused ker=
nel memory: 22528K
> [=C2=A0=C2=A0133.527005][=C2=A0=C2=A0=C2=A0=C2=A0T1] Checked W+X mappin=
gs: passed, no W+X pages found
> [=C2=A0=C2=A0133.533474][=C2=A0=C2=A0=C2=A0=C2=A0T1] Run /init as init =
process
> [=C2=A0=C2=A0133.727196][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: System=
 time before build time, advancing
> clock.
> [=C2=A0=C2=A0134.576021][ T1587] modprobe (1587) used greatest stack de=
pth: 27056 bytes
> left
> [=C2=A0=C2=A0134.764026][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: system=
d 239 running in system mode. (+PAM
> +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +G=
CRYPT
> +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2=
 default-
> hierarchy=3Dlegacy)
> [=C2=A0=C2=A0134.799044][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Detect=
ed architecture arm64.
> [=C2=A0=C2=A0134.804818][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Runnin=
g in initial RAM disk.
> <...hang...>
>=20
> Fix it by either set page_alloc.shuffle=3D0 or CONFIG_PROVE_LOCKING=3Dn=
 which allow
> it to continue successfully.
>=20
>=20
> [=C2=A0=C2=A0121.093846][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Set ho=
stname to <hpe-apollo-cn99xx>.
> [=C2=A0=C2=A0123.157524][=C2=A0=C2=A0=C2=A0=C2=A0T1] random: systemd: u=
ninitialized urandom read (16 bytes
> read)
> [=C2=A0=C2=A0123.168562][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Listen=
ing on Journal Socket.
> [=C2=A0=C2=A0OK=C2=A0=C2=A0] Listening on Journal Socket.
> [=C2=A0=C2=A0123.203932][=C2=A0=C2=A0=C2=A0=C2=A0T1] random: systemd: u=
ninitialized urandom read (16 bytes
> read)
> [=C2=A0=C2=A0123.212813][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Listen=
ing on udev Kernel Socket.
> [=C2=A0=C2=A0OK=C2=A0=C2=A0] Listening on udev Kernel Socket.
> ...

