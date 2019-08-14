Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96C64C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:38:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5855C2084F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:38:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="AYAIVD0c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5855C2084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5D986B0003; Wed, 14 Aug 2019 10:38:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE6E56B0005; Wed, 14 Aug 2019 10:38:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAD226B0007; Wed, 14 Aug 2019 10:38:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0174.hostedemail.com [216.40.44.174])
	by kanga.kvack.org (Postfix) with ESMTP id 84B336B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:38:26 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 32365181AC9B4
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:38:26 +0000 (UTC)
X-FDA: 75821289012.28.tree34_4995841b83427
X-HE-Tag: tree34_4995841b83427
X-Filterd-Recvd-Size: 5074
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:38:25 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id m2so8860742qki.12
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:38:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Pp4tqIbXmYyBlHaHJ6wJs4nbzU9Gp3XXZ3Zm7nORqME=;
        b=AYAIVD0csWZP407Q0TfbSDzE9TUok+VfHNMgfbLQgdKlARnbLo3fDhKMabmY/Awgll
         Hhtbo90XKPM60dK/pmLV+Iqg7807C9zGFFItr83iVttkHI/2g5uIa6x05qljsqP823e2
         v02Di9HYKhtbUcvxHXh3tYpok42bfu0gnKzdgj+ssPwssAauK8j3TpsBoij3+3thxxpa
         l2qaNAC2ID8OqJwXjah8Qae/CYsk+goiY9t6IPF0DG5NmY6GHzf5SUk7A3bwItN9hXt3
         3yAY0ciz9AhhBa9VYqR4xilg51blvz4/ysO9Vaph++Z0BmL7MLU9OquHbV8NedCHxwVE
         /j1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Pp4tqIbXmYyBlHaHJ6wJs4nbzU9Gp3XXZ3Zm7nORqME=;
        b=PCv8ME+7q7uTQ1678GZ3hNk6RKTY9djxIGwAquTzrCMrQZFTudmbhDijAUP4Yb1AdT
         6wQ/HnL9/nQcRTHJy0ROBS2UhCgACijzcAyMYbX0z/qcy138pHOAquzeNiBtJYRAl9ab
         uI0nkmmwSDgKv5xupf6qWKmDxxzDz4+w8ZHQwjCUPndiduWY/5iNGN4UlQZ1ohI+GC1p
         T4ZQa9L9jsQDPjdxcVh7YDlFuq74UVuRNhBIcjfV4i5Z2bVO+d2vmy1pkRk3B45eU+QD
         tdETc1ozkF1EbuT8qxb7URQFZYP8BeXqnKg1gc53CS03ESxsDm4QomDPXLO4Ho5y/vyV
         M1oQ==
X-Gm-Message-State: APjAAAUK5ldJXJG9zCFXx1G1yqRangtkRgDje7c/JVLs/TTuZB4bkzqP
	J6MeocrvNXNycNRGH6MDec2Xqg==
X-Google-Smtp-Source: APXvYqyqU59CduhnbFOIV0vHiB1VIrZjdOwZYn3CQevH5E60ZzbhQf5j1Mqo4eer68+Kw6rWtq31KQ==
X-Received: by 2002:a37:805:: with SMTP id 5mr27330973qki.351.1565793504908;
        Wed, 14 Aug 2019 07:38:24 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id z1sm56536966qkg.103.2019.08.14.07.38.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Aug 2019 07:38:24 -0700 (PDT)
Message-ID: <1565793502.8572.22.camel@lca.pw>
Subject: Re: [rgushchin:fix_vmstats 21/221]
 include/asm-generic/5level-fixup.h:14:18: error: unknown type name 'pgd_t';
 did you mean 'pid_t'?
From: Qian Cai <cai@lca.pw>
To: Roman Gushchin <guro@fb.com>
Cc: kbuild test robot <lkp@intel.com>, "kbuild-all@01.org"
 <kbuild-all@01.org>,  Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton
 <akpm@linux-foundation.org>, Linux Memory Management List
 <linux-mm@kvack.org>
Date: Wed, 14 Aug 2019 10:38:22 -0400
In-Reply-To: <20190814004548.GA18813@tower.DHCP.thefacebook.com>
References: <201908131117.SThHOrZO%lkp@intel.com>
	 <1565707945.8572.10.camel@lca.pw>
	 <20190814004548.GA18813@tower.DHCP.thefacebook.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-08-14 at 00:45 +0000, Roman Gushchin wrote:
> On Tue, Aug 13, 2019 at 10:52:25AM -0400, Qian Cai wrote:
> > On Tue, 2019-08-13 at 11:33 +0800, kbuild test robot wrote:
> > > tree:=C2=A0=C2=A0=C2=A0https://github.com/rgushchin/linux.git fix_v=
mstats
> > > head:=C2=A0=C2=A0=C2=A04ec858b5201ae067607e82706b36588631c1b990
> > > commit: 938dda772d9d05074bfe1baa0dc18873fbf4fedb [21/221] include/a=
sm-
> > > generic/5level-fixup.h: fix variable 'p4d' set but not used
> > > config: parisc-c3000_defconfig (attached as .config)
> > > compiler: hppa-linux-gcc (GCC) 7.4.0
> > > reproduce:
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0wget https://urldef=
ense.proofpoint.com/v2/url?u=3Dhttps-3A__raw.gith
> > > ubusercontent.com_intel_lkp-
> > > 2Dtests_master_sbin_mak&d=3DDwIFaQ&c=3D5VD0RTtNlTh3ycd41b3MUw&r=3Dj=
JYgtDM7QT-W-
> > > Fz_d29HYQ&m=3DTOir6b4wrmTSQpeaAQcpcHZUk9uWkTRUOJaNgbh4m-
> > > o&s=3D0IeTTEfMlxl9cDI9YAz2Zji8QaiE8B29qreDUnvID5E&e=3D=C2=A0
> > > e.cross -O ~/bin/make.cross
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0chmod +x ~/bin/make=
.cross
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0git checkout 938dda=
772d9d05074bfe1baa0dc18873fbf4fedb
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0# save the attached=
 .config to linux build tree
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0GCC_VERSION=3D7.4.0=
 make.cross ARCH=3Dparisc=C2=A0
> >=20
> > I am unable to reproduce this on today's linux-next tree. What's poin=
t of
> > testing this particular personal git tree/branch?
>=20
> I'm using it to test my patches before sending them to public mailing l=
ists.
> It really helps with reducing the number of trivial issues and upstream
> iterations as a consequence. And not only trivial...
>=20
> If there is a way to prevent notifying anyone but me, please, let me kn=
ow,
> I'm happy to do it.

That would be great. Otherwise, I'll just ignore reports like this in the=
 future
until it can also proves that the reproducible on the mainline or linux-n=
ext.

