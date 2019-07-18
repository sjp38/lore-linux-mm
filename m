Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FC86C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:04:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D85562173E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:04:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Ygvn6fW/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D85562173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73AF96B0005; Thu, 18 Jul 2019 02:04:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6ECB76B0007; Thu, 18 Jul 2019 02:04:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58BE98E0001; Thu, 18 Jul 2019 02:04:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3960F6B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:04:03 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id j4so14773968otc.5
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 23:04:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=P1LQPeatmBO3Ls1tFC7heZrLlLB6kdfVOLBzlpUftSA=;
        b=Cq6iKHXteGKNje6HZai5B4LNheYn0/5ZvhKzJKSupkwJyMC1bKDoBmdz7UdT5cdZ4H
         KLiwBUhHR9jqmslVa2FXT1JqM2M/Xudupu6vLXYBVGZJIrhdRONRVuGS4SN/EWz0DNId
         +smcTd60MMYFG/Lw4AsKJwwOAl/fTBMlaMeomSZuUnW19Uv4+oDCSe7254ZC+kWJAwir
         coEwfU9PkT0BeViHhCM+G3Znz+Gni6XCpmdmCMd0hO8mkJ4QBCNWJ744gdJL32vNFI6u
         g2RhA5YPt2dyKS6a2veQ2VYOYic4CsGqaeCbJOONMzoiWA62nzcPU2/Q+AbnwGeYUNK5
         Xjrg==
X-Gm-Message-State: APjAAAU8/9gJhMugyqkbsVJN8j5/24lyGkWRFiGZUqV8j5d0a/3d1lt9
	cuqiv/X72e5068OLuWH3VM2ofdsfqg/2VZOj/g45VC1jKjYb2M7PVwoca9w/r8Oxr/9IqM/2SZE
	ZDYfUC6tcL6vpbYxyxgJG9Ubksj/0byMFF1MQ99dGYabuL5I94wx9Wh1F5M20xE4AAQ==
X-Received: by 2002:a05:6830:199:: with SMTP id q25mr32031777ota.79.1563429842803;
        Wed, 17 Jul 2019 23:04:02 -0700 (PDT)
X-Received: by 2002:a05:6830:199:: with SMTP id q25mr32031745ota.79.1563429842345;
        Wed, 17 Jul 2019 23:04:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563429842; cv=none;
        d=google.com; s=arc-20160816;
        b=t4CIO6ZGs6gx6dwKYkbJAoeNlx0S6f86LA3vbvvZHlfb4bIyqqYWRnlRp/3u+Q+TSE
         UhbsxcH7/nQotZzGTKu2QRD4uKYa5Z+V5Sc+ylFbJh6NdYWeOjT0pRw2SXSl4i+Jy3Ew
         Nmmxhtc5B09TvTD0IsOoilLewFax4G7SnyYUKIlTVbBx/FMxBz1jlsvWqqIrqmvZUirD
         uNzv6Aa2CJSnEGJtnH7nhkoKe/3IAnz8jAc5NHHWOQ2VLfMWvjaY2ZcGfucigPwCe3jW
         o93xJO4nlaTqXOu5qx8XL4NAgap9y23sHfoEvTGfefGBWtHNLEK4QeNJQT+/0ZKUQWgg
         ZOCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=P1LQPeatmBO3Ls1tFC7heZrLlLB6kdfVOLBzlpUftSA=;
        b=o3ZcPZk+B50+EXIbEIR/4zW0ZyOYZOh4XwICK8+nUuEV4guEYDDXhtM5jBWticqctu
         F+8CFu7AmuzG02Q2gGn9YXwVcOi5MQRFavVSY2pyiZ9rC+pF/lZQd2KBXNTK8B/dsOlH
         X0jMjT/K1LA3ujdzb6RxP5VR4Jv+bgqovj3K6phcU3eLRQS9x0mErxJoZErvFHAjJa29
         wtAMK2/TpCJwJkx1XvZmAHTSPC2ZF5jnoYZFYvEJhtboLOACFPGvhVEYcVXshymlSkzj
         Zox/HB2knyN+qLrv7wcazabWHA8i3e8DU6w69i+QSFkTvpYXnybzBLDuLr4n9c1U7JRZ
         SSpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="Ygvn6fW/";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p187sor12278580oia.145.2019.07.17.23.04.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 23:04:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="Ygvn6fW/";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=P1LQPeatmBO3Ls1tFC7heZrLlLB6kdfVOLBzlpUftSA=;
        b=Ygvn6fW/L34ez5EdLPrPysK+5BumzlK1V4WQbT4fqFL6HEi7RQKEYbZBC8wHQtaKBK
         ILhnlxGZACwRFgbtUZ/n8gwZLALJfAJNBlCNHqhWaEY03GYLxSdxkMdz6PrGX4WBbGqw
         WQrCBvhNz3srQAm1AXJ/zVHhqriAYY0Uljeb8fGVrU7SICX1/6GYYlhzvga6ITHO7GAM
         DvCTi0As46YqyAOTObm0EiWraNRaWWQrTyg9ai9ay/DtLkVl8OtsXDafDYRXVY3gzQYu
         YEyo2QDnoCpU9DfLo1fYXW2R1Zd1HAskVJKkXMxgwS6k6Q7jz5S9oHYn2q13cWDG8K5j
         IMSQ==
X-Google-Smtp-Source: APXvYqxm9xDHx6ClBG2mF8PlRAsDH+bKVgC8qhkLQmyTe0e8hYV2WfgikTfBiTzNjyPyqgMGYXqJy4PfXQiD977bIfo=
X-Received: by 2002:aca:ba02:: with SMTP id k2mr19915938oif.70.1563429841600;
 Wed, 17 Jul 2019 23:04:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190718054851.GA18376@lst.de>
In-Reply-To: <20190718054851.GA18376@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 17 Jul 2019 23:03:49 -0700
Message-ID: <CAPcyv4g=Hr4KOV1NbzPVRxSVL0TaaEPykG3GHwERjx1-SmUQog@mail.gmail.com>
Subject: Re: RFC: move kernel/memremap.c to mm/
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 10:49 PM Christoph Hellwig <hch@lst.de> wrote:
>
> Hi Dan,
>
> was there any really good reason to have memremap.c in kernel/ back
> when you started it?  It seems to be pretty much tried into the mm
> infrastructure, and I keep mistyping the path.  Would you mind a simple
> git-mv patch after -rc1 to move it to mm/ ?

No complaints from me. It ended up there because it was originally
just the common memremap implementation always built with
CONFIG_HAS_IOMEM.

Arguably we should have done this move right after commit 5981690ddb8f
("memremap: split devm_memremap_pages() and memremap()
infrastructure").

