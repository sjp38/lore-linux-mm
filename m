Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B31ABC31E5C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:36:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 750D7208C4
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:36:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="iJnOfDSp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 750D7208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 108A58E0004; Mon, 17 Jun 2019 16:36:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B85D8E0002; Mon, 17 Jun 2019 16:36:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F108B8E0004; Mon, 17 Jun 2019 16:36:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB9A28E0002
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 16:36:58 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id j22so4002990oib.7
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:36:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WUuONrlgmwtIZdvsw0S0/4Mq9T1WyA1gy6J4VLXnacI=;
        b=sXDxO2Iq4Scr9UWwYWg6zrJU4YUTPJeumESHQs0o/TzGjCn4mJbKL56U7ocxtruNNX
         iIilrB1M1gIOhLh6RA52AlS/pO4ZdjRfOM5NeGAtHHZfW/L1BgGtOEZk0k7UgCFVBOJ7
         cPrSTs5b3WYy2faA8Ezk7rDwy7DbdNmp3P9CNxF2Xpt5N9efALVCo+5ujGN8WTDWciPJ
         GLkLlCBxC1WfPcQ+Kx9S336xjwTY3sHdfB7qGDixNEZ1fw85/pTcAX4f/3ZheEVcsmhG
         RTg3CZg8twDml51rYT2EmCYM33VUhDFnfhqT197EjLf/OD3fSCj6+59J+QxGoGly59mj
         55/A==
X-Gm-Message-State: APjAAAV0MeZEUFubItiGYWl4lNJ6nKMBYWoYYGlVGowUSVqsaDgQr7yH
	9Tc8qjFG7WbMmQz2kUI8LJ9N9iMA9ImRxDe7/VJVmabs0AsVyRtwCp9rWjER7kdLGmii6itTFTs
	/wMoOMKV2RXrN+QULwkS09+rAzxKNvSiX9uJNp4fcmi3dtQ++nGHgEC7FassBRPN3Iw==
X-Received: by 2002:a9d:6194:: with SMTP id g20mr817028otk.149.1560803818425;
        Mon, 17 Jun 2019 13:36:58 -0700 (PDT)
X-Received: by 2002:a9d:6194:: with SMTP id g20mr816921otk.149.1560803816910;
        Mon, 17 Jun 2019 13:36:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560803816; cv=none;
        d=google.com; s=arc-20160816;
        b=YDue362oP1YLBgL/G8JPXLLeHnuHIvyXDEB/TiII+6M+esOY5V5Ant042u4nA3594h
         /MV7CT/svdgxFh48u6zh+mfQ3jHoj7I73FnXLBs5DSEdSA6xrRDolC7dAm/k9pxuSLPj
         K64n43y6VfSedtBhlEBfaJmM8i6VguCDPVa4ybfQaU4WV09U4laVONFSBO8+A8SBzVof
         utyLAWAdfG7laQh0k7BXDuojx7Oti54kWse0FKlP+a3gn2z1NQaijTlyFa7tznBOTrpc
         t+mSm7A3A9kmWXJBviuw9AqYn097Iw85YMPLF6XDXCMBx/7H7/2YS0BmzOpd2Oy2WOf1
         hl4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WUuONrlgmwtIZdvsw0S0/4Mq9T1WyA1gy6J4VLXnacI=;
        b=TmyAhYEoWY30ZgX0FVTpddD0DCwTaENpyMb+dZMWPpZ1wQ645xtjRHRVyO2DhdH717
         ZqiRtNB4rP1IaiC4+vsZV0zTyNaPu/IddhU0l+ISxiDIfm207tlmyWQePT7afXktyVGt
         qHF5Q4/E1jW5/NQaw4vVyFCJSOD5VdI1o98Vkuxm4nGVSEe3GYQc+sh1IWtkY13rurXk
         3igeRr4Sj7TKUEJXUu2+cnEeY4/ydoi06zCmd9ylBal2FyI74LbSxUApxs5kua1c7+aO
         LdxrLnlwOS1Jj1MqdbGBlrY/N/WkbIopCG9+zfUEViKhxZrkrpScjDeh6gHjholIMqgr
         Xttg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=iJnOfDSp;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n125sor4670819oib.155.2019.06.17.13.36.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 13:36:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=iJnOfDSp;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WUuONrlgmwtIZdvsw0S0/4Mq9T1WyA1gy6J4VLXnacI=;
        b=iJnOfDSpsfcRrkO7Z3UmtsU/3SdEZ7eTfjySEwglR4kCk3eP1rlaXEv8n0WSdyQhgA
         KaWNKrnvNbK3Ivdrsdf3WrCRENxklnMUOfkYt77DH4iUmhsBJjRM+eotXHjLnTJ0fpft
         IRATZl7xjDYDdLodZoW7pDj5e/et1XUyWXubUfGW4vRD1RKoqQhNZy2/KBjKy8cusMgh
         2woSBHrnLGC1xQF+N5ZRLi9uSQi5GRNsM2OXCHe8Pv4k1LMuUVnyUieU8WnCi9CQp/zd
         XBqL0kuZ9/hoegyaGxXD87pJJNEmxb5JL0BejjNLkP1oeIbdjPfVsh40yBVMT2gDQuUx
         ng8g==
X-Google-Smtp-Source: APXvYqyP6F9zlBzZPah8lr14kIAj+Xnb/4HPIraAg3Phba4tJ1HESSkAprhGKci8EGOWV3IPPT/MSOptYr7l5lvozUE=
X-Received: by 2002:aca:3006:: with SMTP id w6mr9263oiw.5.1560803816566; Mon,
 17 Jun 2019 13:36:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190617122733.22432-1-hch@lst.de> <20190617122733.22432-8-hch@lst.de>
 <CAPcyv4hbGfOawfafqQ-L1CMr6OMFGmnDtdgLTXrgQuPxYNHA2w@mail.gmail.com> <20190617195404.GA20275@lst.de>
In-Reply-To: <20190617195404.GA20275@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 17 Jun 2019 13:36:44 -0700
Message-ID: <CAPcyv4jhhEbLDi82gVw7GLASEtqU=U7Ty67AGwTijmzMqw8X8Q@mail.gmail.com>
Subject: Re: [PATCH 07/25] memremap: validate the pagemap type passed to devm_memremap_pages
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 12:59 PM Christoph Hellwig <hch@lst.de> wrote:
>
> On Mon, Jun 17, 2019 at 12:02:09PM -0700, Dan Williams wrote:
> > Need a lead in patch that introduces MEMORY_DEVICE_DEVDAX, otherwise:
>
> Or maybe a MEMORY_DEVICE_DEFAULT = 0 shared by fsdax and p2pdma?

I thought about that, but it seems is_pci_p2pdma_page() needs the
distinction between the 2 types.

