Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50B7CC04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:27:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6EF221734
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:27:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="Q5Q7snqK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6EF221734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AC446B0003; Mon, 29 Apr 2019 17:27:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45B1F6B0005; Mon, 29 Apr 2019 17:27:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 371446B0007; Mon, 29 Apr 2019 17:27:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id F39796B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 17:27:57 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f7so7915342pgi.20
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:27:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:mime-version:content-transfer-encoding;
        bh=IAMUbVAFvda4HCXownDLdR3GvSTTgiu6g0S5DIrxRq0=;
        b=Ff/gmkeRDzouU5PQei4l+btXmrtYn6xQc/vyvs08Dty3QF04t9mQWk2FdbUZMuR30q
         HO6Tt/uJlNu9XgUnRt/A1Ih261ZpZZ6Th274tjhoGsGedJoLKG09rF5ycYQgVX5iK8Sk
         J743trg/Nime6Iislb0EdDiND+ws5SRkivgkQTl4/2XRLXowhkZdlw/+ag0lTt5t+46R
         MCPcHg+AGIp6gVqhlBo5AC6wMVLjN+nDJWTbERrANCvaIuOANkEmCdfUzpmIgDXqU6Sc
         ZmeRvm0kmFBtrD7dPJOc8nri0IjcZVmv3Thp3tAxV4Kan53y87abt2DjB7vE9BZPmLPe
         YCGg==
X-Gm-Message-State: APjAAAX86e/dNtOmNdeqo1VFMaRAd8/D/VSG8zX4C0ZUd6f0rOnMb8Hg
	yV7E/aI6IXD1azhHPsb6TpEVI+Vm3G4yBYpywyffEIXaGvjGwVYc2E2gEiYu9SCrjXZ2g7psd35
	wXhADs6+SOL17UnnwuBAgCNUwMuyJ7pJ6JB06yPPrreRfxLz+uMrPByRRIEaJ1Zom+A==
X-Received: by 2002:a17:902:8b86:: with SMTP id ay6mr23895350plb.4.1556573277566;
        Mon, 29 Apr 2019 14:27:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFB2+LgVpAmcaEOIUqDwO0a3hpndieK+GXcTjSkX8f6OK84JT4fC3IvvAUIUCbCx5C46eR
X-Received: by 2002:a17:902:8b86:: with SMTP id ay6mr23895295plb.4.1556573276633;
        Mon, 29 Apr 2019 14:27:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556573276; cv=none;
        d=google.com; s=arc-20160816;
        b=s89vU9YXcMU4j1lYk4g1Hzphy0KWruBHWaZIAH0ZCSKtpfV6xiwfMaq6qi4OOcqIE9
         g1+y/rrjeMNpD2abZP7woej4XOaDKF+mZpLRff2OajkqLT4RNTvB/kS4Vi5MoChyEps4
         x5oafDIWlUlRWlRx1oOZMjGHx7dRlg+TUH8d6acLIKOjPd/s2Qfu9rCSQtGtibgHNsI7
         XCHQWyjUQSUYTRrVO0HxEvgzM17pV+9pOpATVIFolegzAcMvnMeJs+byXt8Uc04oktlR
         6p6S/jfZXwbnuDZ2X9vow6oEVPnvKz1BpJeOHoGKuhrP5b59w1LjT3pekHE43frM7S8P
         nLAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:ironport-sdr:ironport-sdr:dkim-signature;
        bh=IAMUbVAFvda4HCXownDLdR3GvSTTgiu6g0S5DIrxRq0=;
        b=HdLud47cI0H6QjXgAy8Wwtu8sg1LkeBw7G+9KpSZ9R5JITt2CS3BFZ9YTtJUKOI/tA
         dZBclSvCs8ynBFlEiYlODBMlRckmPGNycp8Atd/Tnxr4WKZe74ow1NfNtZaOs6Od5oFb
         UUETRYGB62Y10fnkFQDvEadwaTNeHtOsP6RDQVv/Kj8UhXa4XsAdqcif0InEg3o3myhX
         hIkLlNKpuVH33IJJDbc4FKaVK6bsNi0OAYMKQYvha0bfot25GCksKrpjMqNaSl28e8dx
         Wx5KzmveF2MecPt3iJnNYNtJxS+jClMeQIq0L32ZsWZ++/k2yC3LHGx+PiFrM4AwX1Qw
         NKTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=Q5Q7snqK;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa3.hgst.iphmx.com (esa3.hgst.iphmx.com. [216.71.153.141])
        by mx.google.com with ESMTPS id r77si23694774pgr.140.2019.04.29.14.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 14:27:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) client-ip=216.71.153.141;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=Q5Q7snqK;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1556573276; x=1588109276;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=4UgYDqaqXewXdZpSjZRGrTp4ntBC/cMWJSLoGwmniTQ=;
  b=Q5Q7snqKEbaeJw89dT4sxNt2mTiWTVM/sEiVVSUS/MewWKkdREICJwMZ
   jaAWzH6kx51sUwQb4XA8Oapd2ULABrDiRRJ1McaP8kDM8KiFJ9SvkqEra
   EZnEkbq0veFFsqKyZwrr7t/ADeRO6r6u9Q+F1bgG+/28PMaBzKANepcmH
   6XIFMd6IX3kULrYw57ghuA2lST4q0RHHkUSJOgNzNK8V6UYM00ZfUfOJE
   Oy8MjMp4bP74B9PuGPF0QWcqIMvhziB2pX6dgpsHitpeiWkAiRG89dLv8
   39yF07q5/a8xAlmuQpGqLKKOuHUFHjj3UHHVCNrhwMa5Ift2xaGFDQfMd
   Q==;
X-IronPort-AV: E=Sophos;i="5.60,411,1549900800"; 
   d="scan'208";a="112062152"
Received: from h199-255-45-14.hgst.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 30 Apr 2019 05:27:56 +0800
IronPort-SDR: AfXtqHxFPIEjiM/DNhVrI1HBCeUOA/Rn3H73FN59UoQKElJ5cehz3P8SXnQ6Ry3aAjLwVKtTI4
 g/FiVTlEKydB8EgV6USnGg4HY50UCKXrBSSUuOc2XSxGacHLTrwU/OEw7wl7k5zotju5xrLNJv
 8+g/A1CYus3HaPxVvoTBpHmZi6RwIqFhWLyBrSy2I+L1WM/8rYyRP3WpeMe+/+NR18qYOnF9qI
 CpjICWfKxRCtOnMurBjL1sZNeOWhq6kbJvtpry50tCa+ZtoPDn2wIAdsTM1pKRib3SNIijm/x3
 jsDD0BZnyrLJdqmJbPx83VPq
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep01.wdc.com with ESMTP; 29 Apr 2019 14:04:18 -0700
IronPort-SDR: L5YyWUfO1v3iSC0YLTmHGxOo0u8t1/ovWfGcPfXKWdd9zxyno6Wrw7LIYVTLxdypRM/NEMoO0n
 8flKqWEx5OXEU9UPpxTCSIOJ03DdKzYi6Csd/polE4HvD78O/iXdro9jhukq4E8cJwuOvkbUZr
 fWcXQT/T5B+EOBGIfPXu+DydO38MQaREAnKH5WurpdXSeZOxvBpzzV9Ux2B7n/Jge+vygrGCSO
 rT1kBqVqV7h7/H5TcI59TFOh6Wue39RytkiOck9YEBu+zF9WfhwZR1YdgLE5Xuby32fChh+60G
 374=
Received: from jedi-01.sdcorp.global.sandisk.com (HELO jedi-01.int.fusionio.com) ([10.11.143.218])
  by uls-op-cesaip02.wdc.com with ESMTP; 29 Apr 2019 14:27:56 -0700
From: Atish Patra <atish.patra@wdc.com>
To: linux-kernel@vger.kernel.org
Cc: Atish Patra <atish.patra@wdc.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anup Patel <anup@brainfault.org>,
	Borislav Petkov <bp@alien8.de>,
	Changbin Du <changbin.du@intel.com>,
	Gary Guo <gary@garyguo.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	linux-mm@kvack.org,
	linux-riscv@lists.infradead.org,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Palmer Dabbelt <palmer@sifive.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	x86@kernel.org (maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)),
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v3 0/3] TLB flush counters
Date: Mon, 29 Apr 2019 14:27:47 -0700
Message-Id: <20190429212750.26165-1-atish.patra@wdc.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The RISC-V patch (2/3) is based on Gary's TLB flush patch series

https://patchwork.kernel.org/project/linux-riscv/list/?series=97315

The x86 kconfig fix patch(1/3) can be applied separately.

Chnages from v2->v3:
1. Fixed typos and commit text formatting.

Changes from v1->v2:
1. Move the arch specific config option to a common one as it touches
   generic code.
2. Introduced another config that architectures can select to enable
   tlbflush option.

Atish Patra (3):
x86: Move DEBUG_TLBFLUSH option.
RISC-V: Enable TLBFLUSH counters for debug kernel.
RISC-V: Update tlb flush counters

arch/riscv/Kconfig                |  1 +
arch/riscv/include/asm/tlbflush.h |  5 +++++
arch/riscv/mm/tlbflush.c          | 12 ++++++++++++
arch/x86/Kconfig                  |  1 +
arch/x86/Kconfig.debug            | 19 -------------------
mm/Kconfig.debug                  | 13 +++++++++++++
6 files changed, 32 insertions(+), 19 deletions(-)

--
2.21.0

