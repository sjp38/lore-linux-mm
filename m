Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F3A8C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 09:36:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2606320665
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 09:36:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="yKBR09lR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2606320665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C73CE8E0005; Tue, 30 Jul 2019 05:36:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFD998E0001; Tue, 30 Jul 2019 05:36:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC5898E0005; Tue, 30 Jul 2019 05:36:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 835F08E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 05:36:09 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k20so40211718pgg.15
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 02:36:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LtK0QokkgoTJFQdUYjV/Zz1SbLz9j29LgAK8gpHpfwA=;
        b=i9f7bok4dgVq4fI/r/FVlFB2ZOV2DgcOrhxqAM2JjxqQfNPEKYVvziUSwBgoVZe704
         c8xLcnM3YGMdEZuhHFB5slUcak5CNlpalxdujZw9kb4AqOROAG3zP056c0qTLT/temzz
         Yc2eTdxiHOiPg+yIqhiD111tAMWOpl5UHF7n5uLXe0rCyKjPyEWeTiL1PgoDb1PRPnGU
         b3664/0+yy9Kcq1HfuiqX8kfnD/eQwskzu3DLeISLoNA/gtI+WLNJWEtcHZPo5cFS5px
         Z8IEM+X5I4xcuwzBkq3/Ayi7u6uRCrMs6X61RMVnVmickWCXXZIS7Ynq4ZWWZEkdu/wJ
         Jr0Q==
X-Gm-Message-State: APjAAAXO8sv2p9KeYKfvhmE92c0LUazRZEGjL1DqCuR3Qql+wutH/UUQ
	8rsGiD+fM2p/DZTrMXzMQed89n+KTVH2Z5hP+/2Xy+lVrcZRoPPnnKVQJavCqmH77kEgtSaIUAq
	WY+1zWJ2euDKaY44IU+xMxWuldGuJQJtAW1XOJ6/Luw1L5KsEa7KiZ4cxjyuyW4iboQ==
X-Received: by 2002:a17:902:7288:: with SMTP id d8mr30595549pll.133.1564479369187;
        Tue, 30 Jul 2019 02:36:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyydguEl0cwggSkzwr//6qaGTvfX7Ww8s1lM1XamKD3NBZaqMa2uctfW+RZU4HmNwOrdVl6
X-Received: by 2002:a17:902:7288:: with SMTP id d8mr30595503pll.133.1564479368658;
        Tue, 30 Jul 2019 02:36:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564479368; cv=none;
        d=google.com; s=arc-20160816;
        b=vsRzZIvUJ5l21MCWmVXeqt7BlVcpyAfS8trymN1VQ94LJ7v/TArOfa8im2FEHDXXLj
         zPFKK5R9h9mjPLPyXfNcq/mwGJ3iOksey7k5G5bshAjs44uM16zpc2vC2AqFTJaF6SCs
         NbmwQ8UuGZG6zVBKQpy/F4YIicm5sX8GF3ICEeIC+uM1ZrRxxTu5z0PuwsEYDCTz7bKm
         6C9TGPHFfLL+7cx+SQuKTicfuVxCkMJBru+pCFZK+QA+RviBuBtnwYMeEk9RzZ1sJGfB
         KHVzFkZyElfjRbz4I4qE7gg3xV8ST7TCll4I2KLsQFMBCjv2P4luoRlQ7N2ezBW+eu43
         fwLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LtK0QokkgoTJFQdUYjV/Zz1SbLz9j29LgAK8gpHpfwA=;
        b=L2fobDXpYp0CgEPcp8WP9PUtBBe9DPvongJpUzl/39GUWM0EqdkUwJ2HJLjhXcwEW3
         Q4tUiUESRMlKtAuMJ2iT2I41bVaMK6e3mYyj3if50ec2Ve4IGRcP37SlrVhlWNHis+GR
         5hdtuUylg5C2fOn5zN4KOdRtu6a7pYPL93HLVc4m0DYpqhD+SXXKRRV1OQ0K5i5AbmlU
         L/7M0MLjnXdcIUGP8mXuWwE/wEbzN4xmtlPyuiQw4ok8AHJnzg9EC4wipbffVEXjdrJl
         OXS9hvgzZPrxApr7eYorKK88LWOCsObctj601KTK0dEevAB5MLaaAOuDvDvt5+s+1L9v
         jrvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yKBR09lR;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c4si30018960pfn.71.2019.07.30.02.36.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 02:36:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yKBR09lR;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D8EC820665;
	Tue, 30 Jul 2019 09:36:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564479368;
	bh=LtK0QokkgoTJFQdUYjV/Zz1SbLz9j29LgAK8gpHpfwA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=yKBR09lRo6LmJGhQH2qUhOlfyCfidX+msWyCgzer5fjJe+3pEJNN9NJi3GpSBt7QA
	 uMXxUydOtqI56KdD1v9UjS9UBrs6hizJxU4qOdHy3yoLnJzW02CNEYb3YkPG2f+7l0
	 UiOCsKUprxlKMT0imfSNZdVCV4Jk6sWBhm3iB4bo=
Date: Tue, 30 Jul 2019 11:36:06 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: Matt.Sickler@daktronics.com, devel@driverdev.osuosl.org,
	John Hubbard <jhubbard@nvidia.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH v4] staging: kpc2000: Convert
 put_page to put_user_page*()
Message-ID: <20190730093606.GA15402@kroah.com>
References: <20190730092843.GA5150@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730092843.GA5150@bharath12345-Inspiron-5559>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 02:58:44PM +0530, Bharath Vedartham wrote:
> put_page() to put_user_page*()

What does this mean?

