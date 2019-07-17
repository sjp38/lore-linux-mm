Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AFA0C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 16:13:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CDA22173E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 16:13:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CDA22173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE8416B0006; Wed, 17 Jul 2019 12:13:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1FC36B000A; Wed, 17 Jul 2019 12:13:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90EC16B000C; Wed, 17 Jul 2019 12:13:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4E76B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 12:13:50 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q14so14755719pff.8
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 09:13:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=1jtgDzrbJQby33P5NU1w3wG0WQ7Wn9R4y7L5vU/E5tQ=;
        b=bQ5PKZk1k6ul56uOUnzAAoOW6G00mLNSgnPXUg7AEmBgQZeI7spN+V+OIcpvR72qkr
         /lja972rrYMM5MAY0J7e0b75HhfAO0GkoFIvvF8z+rK4ToRU/j3ap3gHI/WGkLPb1M7A
         KUhLHN5VjxnWndBGsF7kkInYJqUKuonZD7IhuXC1G95klJtRpqhe8dCUNVxNhDdMuBbE
         QGsD3jgeMVjNAn9LNtxSmo256W03upcz9xE+uQZuVBR0Dz36kR+RQW1znpWCvgurKwcX
         su95GxZuUm5ph3ApppltevjrTwc7/NsJJok8N5TTUkEFmJDm2DDfpaIngsaRzXqub8Gv
         zvng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAUy244zGPbPjJTTlWP2YnIcY07rudG2k9eRa4bwnjTyI3kXoy2g
	6iDEc0QXgbnvEfWyiLZbaYh1ovBdWXEhrACHVyZ4EZRYuQdDhvDV22RVOPms1XEaxbGoGg36rj4
	kMok7njudJdCyJuh4I4bmGpS5iiDiT5ONAVoYliyZ2W7uvQmOGLQ3dIwL5aDHTsqTvw==
X-Received: by 2002:a17:902:2d01:: with SMTP id o1mr45069251plb.105.1563380030035;
        Wed, 17 Jul 2019 09:13:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzd0rGOQbM/Tx878TcDjQQNKKDEiDXICoVQnM6dAWxSLcdHtokKcuMHMKplJm3Mr2tKIal5
X-Received: by 2002:a17:902:2d01:: with SMTP id o1mr45069163plb.105.1563380029395;
        Wed, 17 Jul 2019 09:13:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563380029; cv=none;
        d=google.com; s=arc-20160816;
        b=bPAEJTHUct5CXmUd/tAqWpwk1JZLAlxOeWQszYYWW0x52ISaQCBg6kn4CeAexZ0L/a
         gCQP3MB6NagBWb/DanAV8DgNCl1ScvF5KjlGn3pHlkVxEakpvn3iPdtYI2rVa6X0hszA
         qrvdDPi50mt9+LUnO200gw2cR4Gvn/yqVadCxY2ABg+m5czg1mRU0mmM9q2ML59NPpfs
         P1U6ASeCLUF0pS5JwgaQcVpxShulKbvZXgj3I+3Snqg8k6S78Qva4jpGfg33exj26n03
         sQBYgw1F7IYttyY1f2sWuJ7YhdxTWPet9opJYs0d6xWT5+4bAZhmr05+Hug0B4Hy2ulw
         857g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=1jtgDzrbJQby33P5NU1w3wG0WQ7Wn9R4y7L5vU/E5tQ=;
        b=zlGh4f8J+oXpsthwvAE+4UJAF5pHBxRXyWNiglmS3tgLuS0fBnl2a2JVx3I2vNDr4f
         RE9R6o0HCSoXjs+NYVDXRZFLFvISR4SrF2/WNTsA/z0Prs0bsYxirEIeunGIpoR7itt4
         SUyFSSaJYU8fWSSjl5dTR5AH9tu0QFSvr0nsOQ8ysDVrgtMcy1jds+VEYR86q4U03tqP
         CHR4bjxEShfEiBHQWT6GRKrwSvFx2n5YPLJtmuv10SP4IzYLO/tZNcVh5h+u4yTQbv4k
         0QFuqpFXa42/uhmP5+Q3xBBQNMJvFTf/3DC7mZ92B6aFzbKsdN0LiCQ5TjqUEJ1AbVSR
         woxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id a25si24792602pfo.234.2019.07.17.09.13.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 09:13:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id BBF80605C121F65CC65C;
	Thu, 18 Jul 2019 00:13:46 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.439.0; Thu, 18 Jul 2019
 00:13:42 +0800
Date: Wed, 17 Jul 2019 17:13:20 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
CC: <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	"Len Brown" <lenb@kernel.org>, Jonathan Cameron <jic23@kernel.org>, "Hartmut
 Knaack" <knaack.h@gmx.de>, Lars-Peter Clausen <lars@metafoo.de>, "Peter
 Meerwald-Stadler" <pmeerw@pmeerw.net>, Peter Rosin <peda@axentia.se>, Benson
 Leung <bleung@chromium.org>, Enric Balletbo i Serra
	<enric.balletbo@collabora.com>, Guenter Roeck <groeck@chromium.org>, "Maxime
 Coquelin" <mcoquelin.stm32@gmail.com>, Alexandre Torgue
	<alexandre.torgue@st.com>, Fabrice Gasnier <fabrice.gasnier@st.com>,
	"Frederic Barrat" <fbarrat@linux.ibm.com>, Andrew Donnellan
	<ajd@linux.ibm.com>, Sebastian Reichel <sre@kernel.org>, Heikki Krogerus
	<heikki.krogerus@linux.intel.com>, Boris Ostrovsky
	<boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, "Stefano
 Stabellini" <sstabellini@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>,
	Nicolas Ferre <nicolas.ferre@microchip.com>, Alexandre Belloni
	<alexandre.belloni@bootlin.com>, Ludovic Desroches
	<ludovic.desroches@microchip.com>, Richard Cochran
	<richardcochran@gmail.com>, Jonathan Corbet <corbet@lwn.net>,
	<linux-acpi@vger.kernel.org>, <linux-iio@vger.kernel.org>,
	<linux-stm32@st-md-mailman.stormreply.com>,
	<linux-arm-kernel@lists.infradead.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-pm@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>, <linux-mm@kvack.org>,
	<netdev@vger.kernel.org>, <linux-doc@vger.kernel.org>
Subject: Re: [PATCH v4 13/15] docs: ABI: testing: make the files compatible
 with ReST output
Message-ID: <20190717171320.000035c2@huawei.com>
In-Reply-To: <88d15fa38167e3f2e73e65e1c1a1f39bca0267b4.1563365880.git.mchehab+samsung@kernel.org>
References: <cover.1563365880.git.mchehab+samsung@kernel.org>
	<88d15fa38167e3f2e73e65e1c1a1f39bca0267b4.1563365880.git.mchehab+samsung@kernel.org>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jul 2019 09:28:17 -0300
Mauro Carvalho Chehab <mchehab+samsung@kernel.org> wrote:

> Some files over there won't parse well by Sphinx.
> 
> Fix them.
> 
> Signed-off-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Hi Mauro,

Does feel like this one should perhaps have been broken up a touch!

For the IIO ones I've eyeballed it rather than testing the results

Acked-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>


