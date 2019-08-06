Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8CB0C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:33:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76F84206A2
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:33:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SzqphmH9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76F84206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F5566B0010; Tue,  6 Aug 2019 04:33:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07EA46B0266; Tue,  6 Aug 2019 04:33:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E88816B0269; Tue,  6 Aug 2019 04:33:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id C79AE6B0010
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:33:53 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id l186so37527719vke.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:33:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=L3laO+k8rafvoIENNnOkb7QDUkGKtpfBuwQzQEPVcpk=;
        b=Q3VMR6e4LvuOCMwoL7BXLeQ7N1ViEBZjTJ0xyh4deQGj7QtJrHPFbBXO7fKTDvuxjH
         E4HN85apjMsoR/5jAgv0IB0QftHA7ifMqGZ8JpFMJ6owM5drL7emSrO9lHlU/njW8tfG
         01DFl64ud66bJKexvntLflu3bjQLxfU+6ZBtbkVknNlUzHib4DqF9eKNf6z2R2w7rK/L
         SEQqSugDyLg6jAPql78lHxJ8YTWHI51bQvFrZEDERvfElkIHsnVNDz85VQvftV5eXzkM
         zJexrrlMWXZ7sbFs2JLdUfmOBblijstSHAsPWyNfaqHC++1N2f5UwxG5JYi91KUWuL/P
         pOjg==
X-Gm-Message-State: APjAAAUEAfS3r5/+BE0b0+ds+XVVfEvlLocMXMSd0n5HpIXw47wgZ0TI
	2bdC6OXRFxVU3e3InSITJiLLznw87xWRE+Chpkhin30gz3Li+QdZ+8BcT4WTByo86tAcCb67SzX
	8zl/Z4dXW+pKkyVrRImFnuWCkf9H6qwHzuJl+mC3QReaEtpPX6TYNLBlZJC6778QwTQ==
X-Received: by 2002:ab0:4744:: with SMTP id i4mr1529882uac.63.1565080433432;
        Tue, 06 Aug 2019 01:33:53 -0700 (PDT)
X-Received: by 2002:ab0:4744:: with SMTP id i4mr1529854uac.63.1565080432941;
        Tue, 06 Aug 2019 01:33:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565080432; cv=none;
        d=google.com; s=arc-20160816;
        b=zdHpyp9BrQbZT+4ajtFW1cAcv08cTEvL5YY2wk21bX2eRvnpyHhc1RGtKVQ5eFh5U+
         T7yJYUqzvXd7xZmBLU7IvmMLuXd6z4TRnG5JqpQtIJgFMtJnh6wqgxWPnA15MtDW5SVZ
         nmejgHBElTRJf2sP+f8YgJStEFrXBRgfGXFK6ljnNgyOGvMrnREB46pRz8bKT2gyRSnf
         nFNMM/55QoK7sRNRhTOZ/AS+p0kxgI/nZHiP77N8zqtWaZrjT026N2abciW9w42mmdZE
         hMydBMzJQRwDnHJEzr9NFmz2+98j9AviLnYFoUxODf7kVw2p3eerhkCQT8MFbYFm/1bo
         koRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=L3laO+k8rafvoIENNnOkb7QDUkGKtpfBuwQzQEPVcpk=;
        b=tXL6v0/bPThyxPtmVTIIgLmL3E4rLjb51GNZMVjmjIAnmH+E8vHJixmAbKI0HYm2ep
         AMPFxPCovi/RaRS+9ygFZi7GM0syAU5rP9Crpg9jIncm0XUe8uTghYZFp29vZm+qTVML
         2Oxmi7bKlqpjFT4y2/exh88LqUqSS0krduXjztCBoQo2oltQszcjCHbXD2h7NDyOEpqi
         K49+RjxlLDgAbBc/5Rl7vfGNXuITYCO3OO6xVvavxpoMil6le72Tg8ZxQCqrVOMY1h+u
         BM6bvKoYx9nAzGYfkk1f2nSm5OdRLLvmHHdQtuwD1EKy/ZY7+qFeydaB0LGXk42NO8va
         Rf2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SzqphmH9;
       spf=pass (google.com: domain of oded.gabbay@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oded.gabbay@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n27sor42703300vsj.45.2019.08.06.01.33.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 01:33:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of oded.gabbay@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SzqphmH9;
       spf=pass (google.com: domain of oded.gabbay@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oded.gabbay@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=L3laO+k8rafvoIENNnOkb7QDUkGKtpfBuwQzQEPVcpk=;
        b=SzqphmH9Xcr/8QNjmRCurEieXSoyqucXzM/i0jQtfbn7fCyXLgcnseGNHc6O2zl0H8
         lcXNVaaPPFwrjISof3c2HskBLmzDayr30vm+Qic8693HY+xSJZSrxgebQJ66vpu9D/Eq
         vQkLuOeWxkEuWjQUPFyc/vmh3iGJQgTI2NTzHt5n2Zxk6utihlQvgJuoPQh/WsEFNuYY
         tpX2Vz3PLkto6LaLhBGh7VJXzWoigJWHVsrd09RKw7dK7au28CNsw1fRB6UcV4P62b5V
         ln+954kRxd9UlqSh7T3eMX/xRSj1iLKCZOI/4sDOi2f4lKvulstRs6VTYv3pBuqxzkrE
         4vtg==
X-Google-Smtp-Source: APXvYqxKu72JAW2RGZxe7DiW01lI2DmuzDe2HpznDq1juAM1vrYh+aMD/Tbtq+3dWIh9uqqTzDYnPm88keMhsQByGds=
X-Received: by 2002:a67:e3d5:: with SMTP id k21mr1519155vsm.172.1565080432608;
 Tue, 06 Aug 2019 01:33:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190802200705.GA10110@ziepe.ca> <c59ebe8b-9b18-24b8-b02c-8ccaa7df4dc9@amd.com>
 <20190806073105.GA20575@infradead.org>
In-Reply-To: <20190806073105.GA20575@infradead.org>
From: Oded Gabbay <oded.gabbay@gmail.com>
Date: Tue, 6 Aug 2019 11:33:26 +0300
Message-ID: <CAFCwf10aRHeXuOg+5o6=VgzM1dhFQde=b0jZSmgF4DfibYcp_A@mail.gmail.com>
Subject: Re: [PATCH hmm] drm/amdkfd: fix a use after free race with
 mmu_notififer unregister
To: Christoph Hellwig <hch@infradead.org>
Cc: "Kuehling, Felix" <Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, Ben Goz <ben.goz@amd.com>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 10:31 AM Christoph Hellwig <hch@infradead.org> wrote:
>
> Btw, who maintains amkfd these days?  MAINTAINERS still lists
> Oded, but he seems to have moved on to Habanalabs and maintains that
> drivers now while not having any action on amdkfd for over a year.

I've sent a patch to update the MAINTAINERS file a month ago to
dri-devel and Dave
(https://lists.freedesktop.org/archives/dri-devel/2019-July/225272.html)

Thanks,
Oded

Oded

