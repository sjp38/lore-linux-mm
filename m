Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23252C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 21:33:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87CBE2339F
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 21:33:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="PLrk8H2B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87CBE2339F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D45816B0358; Thu, 22 Aug 2019 17:33:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFA226B0359; Thu, 22 Aug 2019 17:33:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C10396B035A; Thu, 22 Aug 2019 17:33:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0250.hostedemail.com [216.40.44.250])
	by kanga.kvack.org (Postfix) with ESMTP id A06FD6B0358
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 17:33:28 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4C8126D8C
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 21:33:28 +0000 (UTC)
X-FDA: 75851365296.27.cook41_5871b05811429
X-HE-Tag: cook41_5871b05811429
X-Filterd-Recvd-Size: 6526
Received: from mail-qk1-f175.google.com (mail-qk1-f175.google.com [209.85.222.175])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 21:33:27 +0000 (UTC)
Received: by mail-qk1-f175.google.com with SMTP id d23so6542096qko.3
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:33:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:mime-version
         :content-transfer-encoding;
        bh=vxPfoC0K37mnp3V+GpCj023qxV0rNOwXkgRWVieVWW8=;
        b=PLrk8H2BymBEZahoF59hFB0vu+Rlj3dcFORH8U/VLQz5lmfldbLWbXm5lPRI6y9DaB
         jdBGob2L93ac72r5a/vhZb9zgfuo1Clq/S/LtTzt8w2WPtEnU6gy1WkFc9HR42wqI7YN
         Tq+AKWjKxwpEHbNANfdNs5d6ojZDpSNbNVIdZXUTOMG/ErQlEKVf4duJgz2baPpBTh2u
         TeFyb2MXctxh3mP0iZ1K4sL9dAYSsO4AB8wRnJ02EguJTYDH6oJG/f5g0oA1k5Uv301F
         Y6jgIPWhTtznIskycpFi+MFl7G6b/IpyAhufT1Kf6kY3Q2Zxykt4TJDaQm0MqRJ82jFW
         OzKQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:mime-version
         :content-transfer-encoding;
        bh=vxPfoC0K37mnp3V+GpCj023qxV0rNOwXkgRWVieVWW8=;
        b=mKobT+JgxbFIt0YHTDc/mMHLhM+iMdUAo6F59iRiclLcLLhRyjNzY8WKIiJta5zSim
         Q8iUGcW76POM5fRPfm3y++GMSL/WO4qNZEtN6VYgJA+8hkvbS86jWe5n+FpOHrXNA3+e
         DgorT4gtkROCPa+AGveyL/JLjtda3u+Pty5uyEoSyAud66N71sWBqCRZ4V8nMAFJrzVQ
         2/w+OF1dtW6FPiDqNVNZEI61/QIlxUU3uKaTyFYnaLjXKCpbHpVFHyq2XDUhuVd1B1j+
         U7m/SjgDo/XteM4gignwOXfir+u3FFoERp7051NRSJpD9WVebtjAJcdsG8zYJCNkm72o
         V/aA==
X-Gm-Message-State: APjAAAVwqvnXdunx90womn4ZVAoba0b7BqO/K3i6wU479qP8SsqkLtQs
	fhuh7U4frhupXb+hpdX25Fny4w==
X-Google-Smtp-Source: APXvYqw9aoi8o93EJ/4REoOn/hD2msEp2fczdUdvUxTwn60eP5eTFH72s4ltjGJlxU8gy3C+4KkWrw==
X-Received: by 2002:ae9:dfc3:: with SMTP id t186mr1144058qkf.322.1566509606883;
        Thu, 22 Aug 2019 14:33:26 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id u187sm493578qkh.110.2019.08.22.14.33.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Aug 2019 14:33:25 -0700 (PDT)
Message-ID: <1566509603.5576.10.camel@lca.pw>
Subject: page_alloc.shuffle=1 + CONFIG_PROVE_LOCKING=y = arm64 hang
From: Qian Cai <cai@lca.pw>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Peter
	Zijlstra <peterz@infradead.org>
Date: Thu, 22 Aug 2019 17:33:23 -0400
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config

Booting an arm64 ThunderX2 server with page_alloc.shuffle=3D1 [1] +
CONFIG_PROVE_LOCKING=3Dy=C2=A0results in hanging.

[1] https://lore.kernel.org/linux-mm/154899811208.3165233.176232090310651=
21886.s
tgit@dwillia2-desk3.amr.corp.intel.com/

...
[=C2=A0=C2=A0125.142689][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.2.auto: option mask 0x2
[=C2=A0=C2=A0125.149687][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.2.auto: ias 44-bit, oas 44-bit
(features 0x0000170d)
[=C2=A0=C2=A0125.165198][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.2.auto: allocated 524288 entries
for cmdq
[=C2=A0=C2=A0125.239425][ [=C2=A0=C2=A0125.251484][=C2=A0=C2=A0=C2=A0=C2=A0=
T1] arm-smmu-v3 arm-smmu-v3.3.auto: option
mask 0x2
[=C2=A0=C2=A0125.258233][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.3.auto: ias 44-bit, oas 44-bit
(features 0x0000170d)
[=C2=A0=C2=A0125.282750][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.3.auto: allocated 524288 entries
for cmdq
[=C2=A0=C2=A0125.320097][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.3.auto: allocated 524288 entries
for evtq
[=C2=A0=C2=A0125.332667][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.4.auto: option mask 0x2
[=C2=A0=C2=A0125.339427][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.4.auto: ias 44-bit, oas 44-bit
(features 0x0000170d)
[=C2=A0=C2=A0125.354846][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.4.auto: allocated 524288 entries
for cmdq
[=C2=A0=C2=A0125.375295][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.4.auto: allocated 524288 entries
for evtq
[=C2=A0=C2=A0125.387371][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.5.auto: option mask 0x2
[=C2=A0=C2=A0125.393955][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.5.auto: ias 44-bit, oas 44-bit
(features 0x0000170d)
[=C2=A0=C2=A0125.522605][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.5.auto: allocated 524288 entries
for cmdq
[=C2=A0=C2=A0125.543338][=C2=A0=C2=A0=C2=A0=C2=A0T1] arm-smmu-v3 arm-smmu=
-v3.5.auto: allocated 524288 entries
for evtq
[=C2=A0=C2=A0126.694742][=C2=A0=C2=A0=C2=A0=C2=A0T1] EFI Variables Facili=
ty v0.08 2004-May-17
[=C2=A0=C2=A0126.799291][=C2=A0=C2=A0=C2=A0=C2=A0T1] NET: Registered prot=
ocol family 17
[=C2=A0=C2=A0126.978632][=C2=A0=C2=A0=C2=A0=C2=A0T1] zswap: loaded using =
pool lzo/zbud
[=C2=A0=C2=A0126.989168][=C2=A0=C2=A0=C2=A0=C2=A0T1] kmemleak: Kernel mem=
ory leak detector initialized
[=C2=A0=C2=A0126.989191][ T1577] kmemleak: Automatic memory scanning thre=
ad started
[=C2=A0=C2=A0127.044079][ T1335] pcieport 0000:0f:00.0: Adding to iommu g=
roup 0
[=C2=A0=C2=A0127.388074][=C2=A0=C2=A0=C2=A0=C2=A0T1] Freeing unused kerne=
l memory: 22528K
[=C2=A0=C2=A0133.527005][=C2=A0=C2=A0=C2=A0=C2=A0T1] Checked W+X mappings=
: passed, no W+X pages found
[=C2=A0=C2=A0133.533474][=C2=A0=C2=A0=C2=A0=C2=A0T1] Run /init as init pr=
ocess
[=C2=A0=C2=A0133.727196][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: System t=
ime before build time, advancing
clock.
[=C2=A0=C2=A0134.576021][ T1587] modprobe (1587) used greatest stack dept=
h: 27056 bytes
left
[=C2=A0=C2=A0134.764026][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: systemd =
239 running in system mode. (+PAM
+AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCR=
YPT
+GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2 d=
efault-
hierarchy=3Dlegacy)
[=C2=A0=C2=A0134.799044][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Detected=
 architecture arm64.
[=C2=A0=C2=A0134.804818][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Running =
in initial RAM disk.
<...hang...>

Fix it by either set page_alloc.shuffle=3D0 or CONFIG_PROVE_LOCKING=3Dn w=
hich allow
it to continue successfully.


[=C2=A0=C2=A0121.093846][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Set host=
name to <hpe-apollo-cn99xx>.
[=C2=A0=C2=A0123.157524][=C2=A0=C2=A0=C2=A0=C2=A0T1] random: systemd: uni=
nitialized urandom read (16 bytes
read)
[=C2=A0=C2=A0123.168562][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Listenin=
g on Journal Socket.
[=C2=A0=C2=A0OK=C2=A0=C2=A0] Listening on Journal Socket.
[=C2=A0=C2=A0123.203932][=C2=A0=C2=A0=C2=A0=C2=A0T1] random: systemd: uni=
nitialized urandom read (16 bytes
read)
[=C2=A0=C2=A0123.212813][=C2=A0=C2=A0=C2=A0=C2=A0T1] systemd[1]: Listenin=
g on udev Kernel Socket.
[=C2=A0=C2=A0OK=C2=A0=C2=A0] Listening on udev Kernel Socket.
...

