Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7244C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 23:29:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88F922175B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 23:29:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Cs1ROxeH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88F922175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 275C18E00A2; Tue,  5 Feb 2019 18:29:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 224238E009C; Tue,  5 Feb 2019 18:29:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 114058E00A2; Tue,  5 Feb 2019 18:29:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BDDF48E009C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 18:29:39 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a18so3299139pga.16
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 15:29:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=I0VnCRP5jiFduQj8D/MbOP8ep/SRYuZGku4WskzpxtU=;
        b=dCZaKP+G54fLSFli9lBTqbvN8ZPy4EdL8a2gy6dxOCe/QTUZ3TS246Hv9Lhh0zGyy0
         m5JsMY5e4YwbFfq4U6WIXw2TAk11vEkF0f2xrX3dV7GfpDRvKLqoofi/ZzbXytOmAzUU
         ZT/thQ/21f90BIWaxK3NRkeLcti6HGXSsOvRNSxbXoSQbatdgfMCcmrR++idmOe4m1XP
         F/1Q6E/kOKK5KD8oPmDQ/GN+LaHdbvaBerKEG7qGuzMb7QOY7NmijuBA/SFhsAM32/ZM
         +QSx7TTelU0fGgtN8dh+pJCHFCYXjfbg3T2i1bGJoOfEuSGkWYhFoQGQDPpg/BlLFq7w
         c+7w==
X-Gm-Message-State: AHQUAuYIB1tEHtL4kSxj8d5Rp03FSnYZQcLwDHcInw8I2Eh8mKnaFCLU
	zgdJ+OQS2h3K1JNm0DVA7hgR53G8uX1K7B6IE71J+/BJ3gs/cByguWA0HEmD9IMFMCd2gOOMy0A
	GV/f4SXlEA9Pug5/O91nev457YZmSpJLC8q6hrHrmH598yu639rxDSmTFd0NHKOFw9A==
X-Received: by 2002:a17:902:b489:: with SMTP id y9mr7749078plr.193.1549409379395;
        Tue, 05 Feb 2019 15:29:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZY3rz3AA7Dr9FJAao4sM9+OC8mIcCBZG/0pun7RKayFPmHB/Nrk7VpsChmc803RkQOL5Zj
X-Received: by 2002:a17:902:b489:: with SMTP id y9mr7749030plr.193.1549409378585;
        Tue, 05 Feb 2019 15:29:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549409378; cv=none;
        d=google.com; s=arc-20160816;
        b=OeJFlsAnKmTcd6rRSKYty7M1f6fqUOoMSZO10vEJfuVCu+pqZopsjH0UKxCC5+ZtLr
         rzqZjunC3DZMFplP71F0FKRtyYJtpZxonh55kslPl/MDQwmgToF2H7baa1W7i8/b+I2g
         7w0UZ1Zw5ymsfb1kOw7UCVF8wqZk6AArGXnzijmLnAaEcB7qagZvworPG0kAHJNMplMI
         GIc+ttwX1rB/lKwHNPFb/e186VoP4XY0DiZp6X8p60/afc2GtUnrGs03tobg0wCGZYAS
         kxr8jF4Bn8rnJ3deiBZQv2pIhat97h9PkGejT74WxkWrvadFibpEdnGNxvg5hjBVKyPH
         t7VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=I0VnCRP5jiFduQj8D/MbOP8ep/SRYuZGku4WskzpxtU=;
        b=zEiM/YP7TlvJFy34WtpRc6IHzzhfRYHbdiFr5q/Ji3RY6RsHMfN1gjl9/b+ti5XET7
         GNrbk0/KIX7bixZBpDVTqNBQpNaHwzs483h/hfDbqV3AVr+5qBfQQ/nXvuQtmn/cFZgM
         ZLk1ZWOEHLijaW2+z3P2SzJbe5+/+qynlWMmrqyfdebfmojY0OFjYfRhaBtSNOpPB6Lx
         +3VXx105xebiNg3c0i+KIoIQsO98sc2v8p/0wc0jwWAmAhWRvNYuLIzqlKYctEz2h9Yf
         b2J741tgvvcbBu98Rav3b9IbY/yJTt4ugmpsr36SKnFfpN04STavXFFSLLI1I95kTBDk
         UjTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Cs1ROxeH;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w189si1458311pfb.151.2019.02.05.15.29.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Feb 2019 15:29:38 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Cs1ROxeH;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=I0VnCRP5jiFduQj8D/MbOP8ep/SRYuZGku4WskzpxtU=; b=Cs1ROxeHj8syb2GDBPqv2AqBm
	vdYd8KDnYJz4OG56cfEVrS0VyITza77z/M1M+zZvB1u1WEKK4mVXlkN0R+XjJ464gAc7GvkKrBy3X
	7ZVWo3o2nZo7TjDe3F8suUnOA++rjceXEZvAeFnlkmUJHea61fRaDb565cFxQzSoVO0o+FAViHAkk
	9RSHaEGpqJAMtNG13hmqmja6KPnpZhzKgyM0JE3KdS7BB11ASZ8VScDYkrJep04hN5NEvcnAg1MYu
	jxj74FaU3Xw4A9Bj5S2spfP8icKMbKtYyT7zZEhZw00+DOBJDk21Fiwd1gGXQm7oTvRwUwM0wQZFz
	nqP7DhgGg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grA9o-0002Yd-22; Tue, 05 Feb 2019 23:29:36 +0000
Date: Tue, 5 Feb 2019 15:29:35 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH v10 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
Message-ID: <20190205232935.GL21860@bombadil.infradead.org>
References: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154899811738.3165233.12325692939590944259.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190205140415.544ae2876ee44e6edb8ca743@linux-foundation.org>
 <CAGXu5jJJQq358_H=xAcf=17WixnFx-P6HqTuv8uQn2zGgNg3Fw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJJQq358_H=xAcf=17WixnFx-P6HqTuv8uQn2zGgNg3Fw@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2019 at 11:11:06PM +0000, Kees Cook wrote:
> FWIW, distros have enabled it by default for a while. Here's Ubuntu,
> for example:
> 
> and Fedora too:

Also Debian:

$ grep SLAB_FREELIST /boot/config-4.19.0-1-amd64
CONFIG_SLAB_FREELIST_RANDOM=y
CONFIG_SLAB_FREELIST_HARDENED=y

linux (4.15.4-1) unstable; urgency=medium
  * Switch to SLUB as kernel allocator. (Closes: #862718)
    - Enable SLUB_DEBUG, SLAB_FREELIST_HARDENED except on armel/marvell.
      (Closes: #883069)

