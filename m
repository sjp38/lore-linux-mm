Return-Path: <SRS0=X77i=TF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6364C004C9
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 16:46:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6597F205F4
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 16:46:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="xIVhJ3ML"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6597F205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF77B6B0005; Sun,  5 May 2019 12:46:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA7586B0006; Sun,  5 May 2019 12:46:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBE476B0007; Sun,  5 May 2019 12:46:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCC826B0005
	for <linux-mm@kvack.org>; Sun,  5 May 2019 12:46:21 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id e5so21155982ywc.8
        for <linux-mm@kvack.org>; Sun, 05 May 2019 09:46:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=x0ZvxGqKqkQis3eWKYukVDy0+4WkHGdposYeRQupFOw=;
        b=j+a52sOY85tezcQ5HyV2VDvscdRK3kneltVlhYegUD9e3wan/TMlRF5ZTHq5wSRBai
         iktxXYnmZXJtZu1wU7VCgTsPxS2HflTfWV/4WK4ALQn8qLSXHSu0u4UeDT3zU/qknBHp
         x+JJq9FyHs3/k25O33CdOztZDPcFMG22hscNKLNrpVv39TPc7cr6Fn5VNV/koVirSg6s
         p5mLsrKTzkBaqi0YsxpRpFSZmK7A4xFijllySxfnB9IMS3txiTKLwmpbpALaXDJya7G1
         1dVpxETRGoJzbheA/1fbbeg/AQgzdaloXt2+k/Scpl8poQmhs1yBrTTShg0cWM1Ci+5g
         VxNQ==
X-Gm-Message-State: APjAAAXEXS7JXFykqMlPrPpHRVYBk5VVy5mBU+HR8r50tFQ6mXO+C0fd
	N1tErBiO0/WX1GNCyOrPq+dI2a+mWkWP9mtZ7gXUXoPXTs0HOLYTDzUA8sfF+NyUN1/viR55SMD
	vlTWyyX9BN/a/A4JzPEponmfvKKgXGhVHIivwFMy7kjs2K50ennqCBMf5t/UzVx530g==
X-Received: by 2002:a25:7dc2:: with SMTP id y185mr7862545ybc.291.1557074781526;
        Sun, 05 May 2019 09:46:21 -0700 (PDT)
X-Received: by 2002:a25:7dc2:: with SMTP id y185mr7862513ybc.291.1557074780904;
        Sun, 05 May 2019 09:46:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557074780; cv=none;
        d=google.com; s=arc-20160816;
        b=Ihsr9PNQgcauArBJvv3B07GuA9ZItPbYbb0iZuIXUDwfEYsg0WM7VydQoRwIxB4yCH
         NM+XbIBUqncXQWjKy5OP/Rm++zV4YJ8HBIUnKOFgGGIPE6Fq/Lyb4m9jeQiVDeApvK7a
         2kys2A/fVPu8zIMzQEmErL0CLQx+zO4ECms/AzUEaTvoV/1lPeKPCsc/e2wym1PfTSKq
         DCoj/3DowxL6+CoQZ0Kx12lum4RWlBd6ubwRurOF6cPjEnCaAFG9sfEYcQqTqSNio90m
         i11hbRJ0fbKgR3jT6YU2WNMVi4OxRO0ng+IukVHByHw/W1tCKV5Sc7AyJE270MIym56P
         M2Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=x0ZvxGqKqkQis3eWKYukVDy0+4WkHGdposYeRQupFOw=;
        b=VY9ERcFjVJqbCrKcwfTOZ6mBX+H0OjZFG7MWMYoIm6F0aJeIov9pWyyAsgdHqAPvBe
         L8MVWq5eibpBqKhllvOV6Fwmkb5KVfPVELiBka5CcboR4Av8yBhxh+zaQglmKP99a+Dy
         abkKU0gzBy1qJtGFfBEha7e1FX52jwGBpPsSr534CcKApIO90E6t/tC8nCAYYOKTXl25
         N5pMUqO95DaYUHfXtl9p6gYm9NejNcaIAARwcEnAhnf0j3rh4MFPHkTOktwCxuZ6uR1y
         l+T0Ess31nDQGjCOskuJIeyrrMezBNcDyOXAimIfC9n3kLMKFI781aH87Cl4fO3aoJoM
         PPqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=xIVhJ3ML;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t7sor3893916ywb.48.2019.05.05.09.46.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 05 May 2019 09:46:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=xIVhJ3ML;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=x0ZvxGqKqkQis3eWKYukVDy0+4WkHGdposYeRQupFOw=;
        b=xIVhJ3MLZE2ilPDUpTWGrclOXQUa5GWlZDrc3RalvMuJns3oV1XuBnemj2jSVzsB2i
         IaXaj4WAhc/5W6lLfkAlZkIfICx/0C64E6q7DFSEEu5gwNm2t493J415QXaJS/WXqqkg
         HAFVU39KEipINsnsZ4SWXyE9WgOKjVs2tnwVw=
X-Google-Smtp-Source: APXvYqybXNSwDNcFaB8gd59q1/W0RHGbNpaxJftPOFeS7R/uocxtpki3475mBso+BoU9TxvSbEqMCw==
X-Received: by 2002:a81:9286:: with SMTP id j128mr13469693ywg.97.1557074780306;
        Sun, 05 May 2019 09:46:20 -0700 (PDT)
Received: from localhost (adsl-173-228-226-134.prtc.net. [173.228.226.134])
        by smtp.gmail.com with ESMTPSA id 202sm2517705ywt.72.2019.05.05.09.46.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 05 May 2019 09:46:19 -0700 (PDT)
Date: Sun, 5 May 2019 12:46:19 -0400
From: Chris Down <chris@chrisdown.name>
To: Leon Romanovsky <leon@kernel.org>
Cc: Kenny Ho <y2kenny@gmail.com>, "Welty, Brian" <brian.welty@intel.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Parav Pandit <parav@mellanox.com>, David Airlie <airlied@linux.ie>,
	intel-gfx@lists.freedesktop.org,
	J??r??me Glisse <jglisse@redhat.com>,
	dri-devel@lists.freedesktop.org, Michal Hocko <mhocko@kernel.org>,
	linux-mm@kvack.org, Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	cgroups@vger.kernel.org,
	Christian K??nig <christian.koenig@amd.com>,
	RDMA mailing list <linux-rdma@vger.kernel.org>, kenny.ho@amd.com,
	Harish.Kasiviswanathan@amd.com, daniel@ffwll.ch
Subject: Re: [RFC PATCH 0/5] cgroup support for GPU devices
Message-ID: <20190505164619.GA59027@chrisdown.name>
References: <20190501140438.9506-1-brian.welty@intel.com>
 <20190502083433.GP7676@mtr-leonro.mtl.com>
 <CAOWid-cYknxeTQvP9vQf3-i3Cpux+bs7uBs7_o-YMFjVCo19bg@mail.gmail.com>
 <bb001de0-e4e5-6b3f-7ced-9d0fb329635b@intel.com>
 <20190505071436.GD6938@mtr-leonro.mtl.com>
 <CAOWid-di8kcC2bYKq1KJo+rWfVjwQ13mcVRjaBjhFRzTO=c16Q@mail.gmail.com>
 <20190505160506.GF6938@mtr-leonro.mtl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190505160506.GF6938@mtr-leonro.mtl.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Leon Romanovsky writes:
>First group (programmers) is using special API [1] through libibverbs [2]
>without any notion of cgroups or any limitations. Second group (sysadmins)
>is less interested in application specifics and for them "device memory" means
>"memory" and not "rdma, nic specific, internal memory".

I'd suggest otherwise, based on historic precedent -- sysadmins are typically 
very opinionated about operation of the memory subsystem (hence the endless 
discussions about swap, caching behaviour, etc).

Especially in this case, these types of memory operate fundamentally 
differently and have significantly different performance and availability 
characteristics. That's not something that can be trivially abstracted over 
without non-trivial drawbacks.

