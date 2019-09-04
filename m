Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F1F3C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:37:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A02720870
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:37:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="hiesufd9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A02720870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C208D6B0003; Wed,  4 Sep 2019 10:37:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD0D96B0006; Wed,  4 Sep 2019 10:37:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE7096B0007; Wed,  4 Sep 2019 10:37:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0084.hostedemail.com [216.40.44.84])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1796B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:37:08 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 288AD87E6
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:37:08 +0000 (UTC)
X-FDA: 75897490536.28.sound66_7870dc3928e1f
X-HE-Tag: sound66_7870dc3928e1f
X-Filterd-Recvd-Size: 4785
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:37:07 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id y26so24679916qto.4
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 07:37:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=d0VTPW60ciEzDbSTuQuRbRvDT6v3yNxk5P0Eu/d/VEY=;
        b=hiesufd9dof37ty41zVV23FsDbb6EdAGKoci12L+sx2fwRtB7zuTMNJNGKxb5jCwz9
         DHzP8baEkLMKZv0R+vOxPlQHHayCkkRabTRxE9tGv8GBrtCggPbrv9ZneGvLVdciye0W
         oKJ2yS/yMcGJtYnDMEcxkcx3yEjhGETyZ9MZu7+djjYmUlzMqVrfPpacFQSd9195K0Yk
         mzKwBohACfM1r3cNGvit0KpTACzAZaRlCp8vck6+4Czvy9UzZGxwoDAUW1UE9QTSacTp
         1v9NfrdGanfNnPILfIvtEzagXy8O4LjEy7mQ3Bfk9PNhEOIwk3xsV5QiVUDi0i3zAIKi
         FSkA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=d0VTPW60ciEzDbSTuQuRbRvDT6v3yNxk5P0Eu/d/VEY=;
        b=ely8yvh322NX4v3aIjJ6KtW1TKsCsCjL62jiWalOx/IN6wtuBIsOhlifjVyAxgNk7N
         rC7UOr845o6eQ8Rt/oWT1RSV5UbY2oGBJI5oU/sGVKEYGamlN8Iol56ivJ30W9so7eb7
         0oZW/NQ7CKqVCcv6P1ig0xOh4/QQs7R5yTDVbUYSdGdL0km3zVJNNA59gKiMam2/N6jj
         e50PioNFi+C6r5w0SJbPhkIf4ycqCaSaGntRFE+dxQJ46OXvILD8qg6SfSacQXLXxpF4
         /A6ZO/S1ITcLi/sRpli+S8M4oO1Gw0OpiKx6sKbtaTE5kymHM9R9JTJZjvMXKo82CzUO
         moCA==
X-Gm-Message-State: APjAAAXKDcTG9TWE62OyA9iZjP+2hS+q7d6TuMrwBoQ8sxL423dS21tI
	I0CogI9BvviTfBmqq16rM0vwlg==
X-Google-Smtp-Source: APXvYqydJPB93Rq3tw9fCKkC0CyDiSk4cXDU16sZXbMdZsRfW6glWdDAFI3nQyAxZg890Jq23AVzJQ==
X-Received: by 2002:a0c:c15d:: with SMTP id i29mr18468496qvh.5.1567607826937;
        Wed, 04 Sep 2019 07:37:06 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id x5sm4919859qkn.102.2019.09.04.07.37.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Sep 2019 07:37:06 -0700 (PDT)
Message-ID: <1567607824.5576.77.camel@lca.pw>
Subject: Re: [PATCH 1/2] mm/kasan: dump alloc/free stack for page allocator
From: Qian Cai <cai@lca.pw>
To: Walter Wu <walter-zh.wu@mediatek.com>, Andrey Konovalov
	 <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
 <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Matthias Brugger
 <matthias.bgg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Martin
 Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
 kasan-dev <kasan-dev@googlegroups.com>,  Linux Memory Management List
 <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM
 <linux-arm-kernel@lists.infradead.org>, linux-mediatek@lists.infradead.org,
  wsd_upstream@mediatek.com
Date: Wed, 04 Sep 2019 10:37:04 -0400
In-Reply-To: <1567606591.32522.21.camel@mtksdccf07>
References: <20190904065133.20268-1-walter-zh.wu@mediatek.com>
	 <CAAeHK+wyvLF8=DdEczHLzNXuP+oC0CEhoPmp_LHSKVNyAiRGLQ@mail.gmail.com>
	 <1567606591.32522.21.camel@mtksdccf07>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-09-04 at 22:16 +0800, Walter Wu wrote:
> On Wed, 2019-09-04 at 15:44 +0200, Andrey Konovalov wrote:
> > On Wed, Sep 4, 2019 at 8:51 AM Walter Wu <walter-zh.wu@mediatek.com> =
wrote:
> > > +config KASAN_DUMP_PAGE
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0bool "Dump the page last=
 stack information"
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0depends on KASAN && PAGE=
_OWNER
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0help
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0By default, =
KASAN doesn't record alloc/free stack for page
> > > allocator.
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0It is diffic=
ult to fix up page use-after-free issue.
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0This feature=
 depends on page owner to record the last stack of
> > > page.
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0It is very h=
elpful for solving the page use-after-free or out-
> > > of-bound.
> >=20
> > I'm not sure if we need a separate config for this. Is there any
> > reason to not have this enabled by default?
>=20
> PAGE_OWNER need some memory usage, it is not allowed to enable by
> default in low RAM device. so I create new feature option and the perso=
n
> who wants to use it to enable it.

Or you can try to look into reducing the memory footprint of PAGE_OWNER t=
o fit
your needs. It does not always need to be that way.

