Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28E75C43444
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 16:47:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCDBB20869
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 16:47:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="hXbJyKN9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCDBB20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 142CF8E0002; Thu, 20 Dec 2018 11:47:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F0A88E0001; Thu, 20 Dec 2018 11:47:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0061D8E0002; Thu, 20 Dec 2018 11:47:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id C8A078E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:47:52 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id t13so1610890otk.4
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:47:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sI7bwHbYAijeaUBXeZ6PRDz4NTwZhRzWaAh7mcZwI5I=;
        b=kcbxXGB8i2CCzMLKxl8BFPFui+3UiZGbAArzkPLZVr7R/8saW6/j7rZxTtt9EhfiJQ
         FFuE/Oxh1xHoWNDhlDpxKJEFHzgHEEXuuV2qIPMjDi3z5P9fWrDvLNEdlwa6EdPKarGu
         SGPd6gF+xvRgkYfGFdMbLjwVnnWuLXSpSOitEMMxBWvEPSqswhMv92PoOcXWRiso2HgC
         OsJ0XSDLJKhf8h/Owu/wVgfNmMf5HEA3tOF39VoBAqyWwMt123iOpuCTo5+WxK+qNwwJ
         1ehzdaGyXQlbNJz7lrEIOEB9prBZuwHQgWSi5UloefuSGe6RtApAvTiUz8CTscL/bWTH
         d8Mw==
X-Gm-Message-State: AA+aEWb9qK1QIqdOAsjH/3qb8COYTUtQ5DP6vfb1n+06X02vmtFc7B+M
	n+7zltZgVqoeLOVhnReL2WgEVrCpw15ZR5V3yh6iolNXzTCx9FdFxQhG4sGAlvMrIrh5PvU4hfj
	ZLO9SliP6J5QspuR/nmZ9P5SMtGgKM3Xwmx/bDHm9JOEmZX7Zw2Ee6TemCHP+C/zpqMKKhUt10A
	dCfkviCI9iyLVOd6PZLOiiZESF2Ot7/K3dpdHX7t97QcEplxbKBVk0qQHcju4MoaapES/yzS4IU
	6WZ0LHnIGGW5Fvgq1ULQaNhGAuA6KMZV8a0GtiIOUKpYjmjSF6pyJkV3wym1+cl6FzJwLGXI8PO
	lCQpafNcVAt/ViEMtTO6nNmSLYtdWMsAoVveu6nybqmETKam9Gk4ICJVzEOB8Fxur6Qm4PjWi26
	I
X-Received: by 2002:a54:4114:: with SMTP id l20mr3025077oic.110.1545324472347;
        Thu, 20 Dec 2018 08:47:52 -0800 (PST)
X-Received: by 2002:a54:4114:: with SMTP id l20mr3025053oic.110.1545324471637;
        Thu, 20 Dec 2018 08:47:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545324471; cv=none;
        d=google.com; s=arc-20160816;
        b=vcNbB34D0fdbu4iNSVmPmQt31KUbLSHygnJWDKPLSNzi5FMd3v0ImcENWD5rOkRTTB
         +eAWsHuFKJBsmm91NWC1MfneJn5P4lccGuNrNtUXOk6hgLYHS3/J9rBtuae8vhlUcgLw
         EpoODk0B9th0ePGnZPjvgpc0MNrC4IkA6isYboLk5Wbz7AWouJAbM4sYtCwmJYCFKO+g
         mXudh+Sup8yYfX8+JxrUDSdQypE7HvjitC2SosjeN2+mjc6D+kW+yTsqV2rYA8k0+wPU
         6NVm93ZMzQQdoohHo2nctKuXM1nejZRDyV7Ui+8whGuzR8A+4gCyKedpfhYVaduACY6Z
         gvXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sI7bwHbYAijeaUBXeZ6PRDz4NTwZhRzWaAh7mcZwI5I=;
        b=CcpvMrzNzP39tvACyecE2jzYyYkf38Ot5CtDREKX9YufEy641828yH/rN8fNn1QJH5
         myNlXxuef4OueQx/mBz6HsBqRV5DeIS7mRG4Q3n9fhwFexIT+B/vpVJm91fJY8S95/Am
         rV173VfidU1MwmTC3X+pOlbhk3aOkuC3lo1xkA52scmS5oWctOTQlQrexsEPYEjS0c/N
         bkrDcq8eo7g9kjr9Hf7zD9/fY6cxT1SDBh9N+KFx0oSNmZGMg6+2dfIUlqgdKLa/FWCx
         Kcnx+4C/2AvDXqo2NOpMS0YYkBNfSJgW82KXCIVwpiOBweXARg5c0S75miImrbkbPMV/
         BW2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=hXbJyKN9;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 66sor2966515oid.172.2018.12.20.08.47.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 08:47:51 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=hXbJyKN9;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sI7bwHbYAijeaUBXeZ6PRDz4NTwZhRzWaAh7mcZwI5I=;
        b=hXbJyKN9glTdOJX5WLb85KxgBftkNyVc+ecemjGFcYqV3PZU4nChGkCfblEAUxvi82
         JnekDX5STu/0bbhwMLC8T9XM/s9s5gKNmzhVz12BrVPHnitbVL+rDog9A2Wbrswaf2+s
         2NsCBTdfCUFkLN+TPJnjzSV2Q2cVVWdxPuuQKLZHCUWxzHZJFembSuN9TjFObVpbpPL4
         csoPF01LlGuMFx3/0DtDKjDKYa6ZeTqz3vETCXUgstROJv1ehXeq1o05LT+9if+QRnYh
         zQ+KumwbzX+6K/5xiM2Zaz96n6DiCD4rig4FqOu/iRPkd7EKlviMESsvwP9TBPfgpyas
         hSnQ==
X-Google-Smtp-Source: AFSGD/UsVdLYgb28HPXi1k9t2yBinuvAuN2uAnk6NO1MPTD/rMq3iYwlMqn3/8qlSeNYzc7HJlSjuHCABOD/Qbae16I=
X-Received: by 2002:aca:b804:: with SMTP id i4mr2753790oif.280.1545324471176;
 Thu, 20 Dec 2018 08:47:51 -0800 (PST)
MIME-Version: 1.0
References: <20170817000548.32038-1-jglisse@redhat.com> <20170817000548.32038-8-jglisse@redhat.com>
 <CAA9_cmeag7n4yeiP6pYZSz80KyxqfwbsXJCWvyNE4PSaxCKA3A@mail.gmail.com> <20181220161538.GA3963@redhat.com>
In-Reply-To: <20181220161538.GA3963@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 20 Dec 2018 08:47:39 -0800
Message-ID:
 <CAPcyv4ipg7smdCZTLeEogKdsKJGrCpaDKaghbTjrM8wkZDaoSw@mail.gmail.com>
Subject: Re: [HMM-v25 07/19] mm/ZONE_DEVICE: new type of ZONE_DEVICE for
 unaddressable memory v5
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, 
	Balbir Singh <bsingharora@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220164739.je3q-g0pbW2mE780f-fgLQkx7M7RJzDO3HsQvzK-RFU@z>

On Thu, Dec 20, 2018 at 8:15 AM Jerome Glisse <jglisse@redhat.com> wrote:
[..]
> > Rather than try to figure out how to forward declare pmd_t, how about
> > just move dev_page_fault_t out of the generic dev_pagemap and into the
> > HMM specific container structure? This should be straightfoward on top
> > of the recent refactor.
>
> Fine with me.

I was hoping you would reply with a patch. I'll take a look...

