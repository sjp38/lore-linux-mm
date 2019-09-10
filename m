Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F097DC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 07:31:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C066321019
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 07:31:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C066321019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FC156B0003; Tue, 10 Sep 2019 03:31:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AC6B6B0006; Tue, 10 Sep 2019 03:31:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C1F76B0008; Tue, 10 Sep 2019 03:31:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0058.hostedemail.com [216.40.44.58])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB716B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 03:31:27 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id D3C238407
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:31:26 +0000 (UTC)
X-FDA: 75918190572.29.cable56_63e5ec778513b
X-HE-Tag: cable56_63e5ec778513b
X-Filterd-Recvd-Size: 2621
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:31:26 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id z67so15927201qkb.12
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 00:31:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=J4aIbTcgYnsL2jAn60izorNqL2E+CEoVtmdgC/gCJ2A=;
        b=o2YK/RefvTwSVLT8pkT/dUAVDrr+M5qRp7qcPcPfyfNreU2mdwwRCP/UTlFy+XEAPH
         H+4NtnV22bCN3wGcEfVGRU8g74PdR9UhEjyDxWg7wwWWy2pi/XuopXHk2EXsMsdx7r/2
         bx0BdSgOIjRmVgKu+Er6dyYqcQHjuPZuygbaS0B4QvOEmL2T1YDNmFKFvNyQ3yrIcBil
         KkYnXByMYRh9B5BtiACSP/OGEneGu6xlrMkrmC541/baMaKtiz+BjdaVXpkEponEJTN7
         QqM4YemconpQE0SUxKWh26pUQ3c0AbawSOsNhSBbzvz2YyrqomFYmQTsZ7CME1CmyV1D
         71gA==
X-Gm-Message-State: APjAAAWbvIaWUJXeXzdKRxcL+OKmZyEqR1vAPQ9VVVf54pmF5CMUQX0r
	/RMh9RwEtS/IlOLfauIBC1NCj9OKB5L875cUZJI=
X-Google-Smtp-Source: APXvYqzxfu9hm0NXuOKA2ZPbbiK1FbMXuncwD0ThgVH5KBnNGFfYb5fTYOiTxWRMVJbtLh9Ew4O+xiYHL4ZLpkip+vI=
X-Received: by 2002:ae9:ef8c:: with SMTP id d134mr27834191qkg.286.1568100685778;
 Tue, 10 Sep 2019 00:31:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190909204201.931830-1-arnd@arndb.de> <20190910071030.GG2063@dhcp22.suse.cz>
In-Reply-To: <20190910071030.GG2063@dhcp22.suse.cz>
From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 10 Sep 2019 09:31:09 +0200
Message-ID: <CAK8P3a2_nuy-nxYapRbkZfAa+xABGUSPekEOwTunu4G-=V2cCA@mail.gmail.com>
Subject: Re: [PATCH] mm: add dummy can_do_mlock() helper
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-rdma <linux-rdma@vger.kernel.org>, Jason Gunthorpe <jgg@mellanox.com>, 
	Bernard Metzler <bmt@zurich.ibm.com>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 9:10 AM Michal Hocko <mhocko@kernel.org> wrote:

> but IB on nonMMU? Whut? Is there any HW that actually supports this?
> Just wondering...

Probably not, but I can't think of a good reason to completely disable
it in Kconfig.
Almost everything can be built without MMU at the moment, but the subset
of things that are actually useful is hard to know.

         Arnd

