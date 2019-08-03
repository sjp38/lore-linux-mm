Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1093BC32750
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 07:06:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8DCA21783
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 07:06:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="EvBQbY6t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8DCA21783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8636B6B0005; Sat,  3 Aug 2019 03:06:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 812C06B0006; Sat,  3 Aug 2019 03:06:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 665C86B0008; Sat,  3 Aug 2019 03:06:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 26BF06B0005
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 03:06:53 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i26so49646382pfo.22
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 00:06:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wbm4Y6V8n+e+3N5dJtqUjpfdjqX0+3X0WdI/7+Cx4X8=;
        b=sGTfoCiE+998tnrJPtvwTsRSSmhheTbqVhzTcECZe3UBh8pB6lRY1NKK/FDhbAYZ1L
         Q4RpgPWRNYrpZrNZ4gqCcry+SOwbQ0nAhkNEEq8NgmIzGYZsXyaj7E7p5BsvKEqCWmLi
         h36djXGfsmnKPyb3D64NJgiq9/ZuftGJS/fDP49VXt1HULkfQb7JxbnPvO33wihgg0zD
         R9Aa0LQgZ07kS7P/PGwiK0n3xMb/SvISmZKpFfYHIrt2f5ZiYcJkxCXyUXpcWSME4Rde
         ZiKE/SOfTSzGAr/6xaSEenLx7QiFHDbsKMCv0Q+2k1DywinJd36b8j+F9Cnzjtr7ROTZ
         vPHA==
X-Gm-Message-State: APjAAAW5SRKNYJ9FY8JyquxJfegtmW+H0KlNO1/zNkReKh8Grm3u3Xy9
	vAH/Hl/GVEi+vAdjlqdDzOQC+fgF2+JIHnXVperR3LnZV+6vqgw09ikTsvY1zurg7ajhzExFNKJ
	pim3fvW0MIsQUa7YtxbwHz3ZYGCf9ptkUwrwoTC4uvC8pvL6/0rG4M9QYAH6Dn0JCUg==
X-Received: by 2002:a17:902:4501:: with SMTP id m1mr6418958pld.264.1564816012829;
        Sat, 03 Aug 2019 00:06:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHOQOK7Ly9S5+Q4K874Q2tyxapQSuxJKtRA7IOGDSCvOnBZiJhQOj/aM1PvhItQZHST4SY
X-Received: by 2002:a17:902:4501:: with SMTP id m1mr6418923pld.264.1564816012230;
        Sat, 03 Aug 2019 00:06:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564816012; cv=none;
        d=google.com; s=arc-20160816;
        b=FVfilvfcrQ21fJ3mLEKJNMVoEOZG71lTZeCKDltFUaBErB7z15fDG5/4I7jW6qUjiI
         Lk5g4Hqhd6k8xjiqqmjN/DiBxaRd0zy1J23oNQaiOfavdoe9/rNyatyZmmi1wEcI0yd7
         mVfOWBhQ7zE4GPYjqGIV4100+rbl8v9fv94inc3MgHRvUbRhHkiq8MCw8r3+36MuWjmM
         kxQmmh/alOycbdV2i1NboQiFXDfsrWS7sQSiV+hcyEkR71wcl9lVM1bH1VzrNrSxsE5S
         xusEmU1kQP4C8sAJ9rNqZ36B+wTyXVIjE9LBUniShLhG9iCbd+C1D8bLjorKFKXP6zxz
         wmpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wbm4Y6V8n+e+3N5dJtqUjpfdjqX0+3X0WdI/7+Cx4X8=;
        b=cuEAB9OT3kM/4uCXR1NYgpzWENJROg53wku/i1X6pHqJE+u3d8wfbt/Hy9f3nFuQWf
         mXOcozPoumILjFpB9iUlQMyeK9i2Rv80ja3tQO1R6IGIm2lRQfL1ghydwz3s0TYACdi+
         SYfJIrhy7iNm8fJgxqTbSApxo6+J5gdi85EMSOKmq5c5pBgHiMmV+f16TRI0rjyM8Io7
         PecUePaQhtBOnxrL5iyK6LPK2Ahtakk/IH2igIgN2BRFBlrEzF5VHvesXqh6U6Xzmc1r
         acvrub94IIaHCwCyXuihlTqUADfSHd9pfVWX1zGN6vlk36DY4U4TNjbqK3tYxS539JuF
         3QaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=EvBQbY6t;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a19si43337849pgw.234.2019.08.03.00.06.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Aug 2019 00:06:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=EvBQbY6t;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 756402173E;
	Sat,  3 Aug 2019 07:06:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564816011;
	bh=fAm+JJVlEEdZsZEnQU6VmG7AlISaD9fVfUjXl/e9MGA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=EvBQbY6tUIAsZP4MFxGmLRqZJjlnz59fmNMbvE0jfno1B+JXE+PNryIyzSAnXbr8N
	 +lgw4Y3y5zL8NJKrLYjFHjBcr6/6qlTB3yc6rbylv5fVS7aSSqYd41B1eBmWwcN4jJ
	 e48QvmU3i/Btia6YyxF5rYYxbA6/qQXbJH8nGzR0=
Date: Sat, 3 Aug 2019 09:06:40 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fbdev@vger.kernel.org,
	Jan Kara <jack@suse.cz>, kvm@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Dave Chinner <david@fromorbit.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, sparclinux@vger.kernel.org,
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
	rds-devel@oss.oracle.com, linux-rdma@vger.kernel.org,
	x86@kernel.org, amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>, xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org, linux-media@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	"Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>,
	John Hubbard <jhubbard@nvidia.com>, intel-gfx@lists.freedesktop.org,
	linux-block@vger.kernel.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-rpi-kernel@lists.infradead.org,
	Dan Williams <dan.j.williams@intel.com>,
	linux-arm-kernel@lists.infradead.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-xfs@vger.kernel.org, linux-crypto@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Frank Haverkamp <haver@linux.vnet.ibm.com>
Subject: Re: [PATCH 10/34] genwqe: convert put_page() to put_user_page*()
Message-ID: <20190803070640.GB2508@kroah.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-11-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802022005.5117-11-jhubbard@nvidia.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 07:19:41PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> This changes the release code slightly, because each page slot in the
> page_list[] array is no longer checked for NULL. However, that check
> was wrong anyway, because the get_user_pages() pattern of usage here
> never allowed for NULL entries within a range of pinned pages.
> 
> Cc: Frank Haverkamp <haver@linux.vnet.ibm.com>
> Cc: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  drivers/misc/genwqe/card_utils.c | 17 +++--------------
>  1 file changed, 3 insertions(+), 14 deletions(-)

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

