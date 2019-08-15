Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAA02C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:14:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 555C920656
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:14:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Nyj+GThN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 555C920656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vandrovec.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE7A46B0288; Thu, 15 Aug 2019 15:13:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D994D6B02BF; Thu, 15 Aug 2019 15:13:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C87C66B02C1; Thu, 15 Aug 2019 15:13:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id A69586B0288
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:13:59 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 2151E180AD806
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:13:59 +0000 (UTC)
X-FDA: 75825612198.14.can75_3fd6373bf181c
X-HE-Tag: can75_3fd6373bf181c
X-Filterd-Recvd-Size: 5952
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:13:58 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id go14so1118864plb.0
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:13:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:subject:to:cc:references:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=dNJeuFDzXs0rm+EMxwm6cmYOjrrNXANuIfIgIQ8YbJg=;
        b=Nyj+GThN3zZyehVt5lvY3xSjZYRcmeJvb6grL2eL2/dff25QEBk1yWfEnGoJzqwUW/
         8/CQoRbjZptIHDBG4jp62oiPJqKJMuzGUwPHOHduAQOHglRCytHCDjMdyERqD3QEDaoD
         sAuRS2tjGyXbTGJApMBGI+peWM/wk+pKQdvuWxdtj0sOuiNs43vWg6Kl1H1JCuF1YJCN
         d0d8GGACex1UXC+cVPm9LYFVBQX550QZG4fH3rI/+fxgpPGE59pJ0GeJmwe499IVAwQW
         ssb8RjLyT8I0v5PgMOxP0Oyjjw2bA21v3oHq2R92J07KFcBl1xHVJXRhuidxWtzPdz35
         ZUhQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:subject:to:cc:references:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=dNJeuFDzXs0rm+EMxwm6cmYOjrrNXANuIfIgIQ8YbJg=;
        b=aq70//ftiEbrFqYBLxalWvDWrlWjOStDQYajXCG5N+ik5rxbN9g2ICWUyZ/sSO3A+d
         m8fqeyb9C0baYtaelafnwqGT9vvpoHjYjEN+jHTa+BTfHbEahxVBfh77I+6wZH1e5qj8
         m0VGSktLfwCh9ddokXL67m1edsr+LrfXrBBPkoKQNB3DIAS6ySjkTD+zR0ZtrYRPiKGp
         uXWHa0SQK0QhDUaAMF/g4yMBPwWq9g1xquv4kyq/xJULTg2JxbD8BRknbR9ZKjXiwO59
         o7wp588kPcXHOsCSlM7XFkQWp/mU10UNZiRQ7L8Xb0rO0k1f1to3N2+D3SGk7iHoOGUN
         xZcw==
X-Gm-Message-State: APjAAAWuz8x/EN+/nDeVfG9eqSAMErHvGTdgaMFWiaLf2BHrDpD0ZEtL
	gmPcax0Ee0g9q3q8ak8wx4jJCnn6nmi8vA==
X-Google-Smtp-Source: APXvYqzpYKBvyeZPLAbcVCmGcAeC2Yc1P7WJTIR8eam1vhmJlO7dkkuFb0uf4YkXBuBn1cXsbsQQww==
X-Received: by 2002:a17:902:1e3:: with SMTP id b90mr4817605plb.82.1565896437032;
        Thu, 15 Aug 2019 12:13:57 -0700 (PDT)
Received: from [10.20.93.185] ([66.170.99.2])
        by smtp.gmail.com with ESMTPSA id e7sm3766417pfn.72.2019.08.15.12.13.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Aug 2019 12:13:56 -0700 (PDT)
From: Petr Vandrovec <petr@vandrovec.name>
Subject: Re: [Bug 204407] New: Bad page state in process Xorg
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Petr Vandrovec <petr@vandrovec.name>, Matthew Wilcox
 <willy@infradead.org>, Qian Cai <cai@lca.pw>,
 Andrew Morton <akpm@linux-foundation.org>,
 bugzilla-daemon@bugzilla.kernel.org,
 Christian Koenig <christian.koenig@amd.com>, Huang Rui <ray.huang@amd.com>,
 David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
 dri-devel@lists.freedesktop.org, linux-mm@kvack.org
References: <bug-204407-27@https.bugzilla.kernel.org/>
 <20190802132306.e945f4420bc2dcddd8d34f75@linux-foundation.org>
 <20190802203344.GD5597@bombadil.infradead.org>
 <1564780650.11067.50.camel@lca.pw>
 <20190802225939.GE5597@bombadil.infradead.org>
 <CA+i2_Dc-VrOUk8EVThwAE5HZ1-zFqONuW8Gojv+16UPsAqoM1Q@mail.gmail.com>
 <45258da8-2ce7-68c2-1ba0-84f6c0e634b1@suse.cz>
Message-ID: <0287aace-fec1-d2d1-370f-657e80477717@vandrovec.name>
Date: Thu, 15 Aug 2019 12:13:21 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:52.0) Gecko/20100101
 PostboxApp/7.0.0b3
MIME-Version: 1.0
In-Reply-To: <45258da8-2ce7-68c2-1ba0-84f6c0e634b1@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Vlastimil=C2=A0Babka=C2=A0wrote=C2=A0on=C2=A08/15/2019=C2=A07:32=C2=A0AM:
>
> Does=C2=A0the=C2=A0issue=C2=A0still=C2=A0happen=C2=A0with=C2=A0rc4?=C2=A0=
Could=C2=A0you=C2=A0apply=C2=A0the=C2=A03=C2=A0attached
> patches=C2=A0(work=C2=A0in=C2=A0progress),=C2=A0configure-enable=C2=A0C=
ONFIG_DEBUG_PAGEALLOC=C2=A0and
> CONFIG_PAGE_OWNER=C2=A0and=C2=A0boot=C2=A0kernel=C2=A0with=C2=A0debug_p=
agealloc=3Don=C2=A0page_owner=3Don
> parameters?=C2=A0That=C2=A0should=C2=A0print=C2=A0stacktraces=C2=A0of=C2=
=A0allocation=C2=A0and=C2=A0first
> freeing=C2=A0(assuming=C2=A0this=C2=A0is=C2=A0a=C2=A0double=C2=A0free).

Unfortunately -rc4 does not find any my SATA disks due to some=20
misunderstanding between AHCI driver and HPT642L adapter (there is no=20
device=C2=A007:00.1,=C2=A0HPT=C2=A0is=C2=A0single-function=C2=A0device=C2=
=A0at=C2=A007:00.0):

[=C2=A0=C2=A0=C2=A018.003015]=C2=A0scsi=C2=A0host6:=C2=A0ahci
[=C2=A0=C2=A0=C2=A018.006605]=C2=A0DMAR:=C2=A0DRHD:=C2=A0handling=C2=A0fa=
ult=C2=A0status=C2=A0reg=C2=A02
[=C2=A0=C2=A0 18.006619] DMAR: [DMA Write] Request device [07:00.1] fault=
 addr=20
fffe0000=C2=A0[fault=C2=A0reason=C2=A002]=C2=A0Present=C2=A0bit=C2=A0in=C2=
=A0context=C2=A0entry=C2=A0is=C2=A0clear
[=C2=A0=C2=A0=C2=A018.076616]=C2=A0DMAR:=C2=A0DRHD:=C2=A0handling=C2=A0fa=
ult=C2=A0status=C2=A0reg=C2=A0102
[=C2=A0=C2=A0 18.085910] DMAR: [DMA Write] Request device [07:00.1] fault=
 addr=20
fffa0000=C2=A0[fault=C2=A0reason=C2=A002]=C2=A0Present=C2=A0bit=C2=A0in=C2=
=A0context=C2=A0entry=C2=A0is=C2=A0clear
[=C2=A0=C2=A0=C2=A018.100989]=C2=A0DMAR:=C2=A0DRHD:=C2=A0handling=C2=A0fa=
ult=C2=A0status=C2=A0reg=C2=A0202
[=C2=A0=C2=A0 18.110985] DMAR: [DMA Write] Request device [07:00.1] fault=
 addr=20
fffe0000=C2=A0[fault=C2=A0reason=C2=A002]=C2=A0Present=C2=A0bit=C2=A0in=C2=
=A0context=C2=A0entry=C2=A0is=C2=A0clear

With iommu=3Doff disks are visible, but USB keyboard (and other USB=20
devices)=C2=A0does=C2=A0not=C2=A0work:

[=C2=A0=C2=A0 18.174802] ehci-pci 0000:00:1a.0: swiotlb buffer is full (s=
z: 8=20
bytes),=C2=A0total=C2=A00=C2=A0(slots),=C2=A0used=C2=A00=C2=A0(slots)
[=C2=A0=C2=A0 18.174804] ehci-pci 0000:00:1a.0: overflow 0x0000000ffdc75a=
e8+8 of=20
DMA=C2=A0mask=C2=A0ffffffff=C2=A0bus=C2=A0mask=C2=A00
[=C2=A0=C2=A0 18.174815] WARNING: CPU: 2 PID: 508 at kernel/dma/direct.c:=
35=20
report_addr+0x2e/0x50
[=C2=A0=C2=A0=C2=A018.174816]=C2=A0Modules=C2=A0linked=C2=A0in:
[=C2=A0=C2=A0 18.174818] CPU: 2 PID: 508 Comm: kworker/2:1 Tainted: G=20
 =C2=A0=C2=A0T=C2=A05.3.0-rc4-64-00058-gd717b092e0b2=C2=A0#77
[=C2=A0=C2=A0 18.174819] Hardware name: Dell Inc. Precision T3610/09M8Y8,=
 BIOS A16=20
02/05/2018
[=C2=A0=C2=A0=C2=A018.174822]=C2=A0Workqueue:=C2=A0usb_hub_wq=C2=A0hub_ev=
ent

I'll=C2=A0try=C2=A0to=C2=A0find=C2=A0-rc4=C2=A0configuration=C2=A0that=C2=
=A0has=C2=A0enabled=C2=A0debugging=C2=A0and=C2=A0can=C2=A0boot.=20


Petr


