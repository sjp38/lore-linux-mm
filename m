Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 919FFC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 06:02:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 594C8217F4
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 06:02:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="zSXgYL75"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 594C8217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E02A96B0003; Mon,  5 Aug 2019 02:02:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB2AF6B0005; Mon,  5 Aug 2019 02:02:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA1ED6B0006; Mon,  5 Aug 2019 02:02:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 939AA6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 02:02:27 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g126so5498990pgc.22
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 23:02:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ClH+zW21dk5gLrAKA0gBdWl3t95WY2+GG9YnQOikIlE=;
        b=q8apYFvIyPTJpu9fOMh81612lhVpgy2bXsxlGWzgsHkJMS4YQ88g7gpwEE+Hj4Yq+o
         REA47WQUgRyLxpIGgfRO/0/EE3ZPnjyr+80oWnqBXKl7779GXVLVn7QkKO7MCF0uPAVA
         TteiROETqv5gV03o9LP+EDvPY93rvdIPsdlDJ3RD2kXGAxI84+Nz4BDzhGbYksUUYWzk
         ljso3kDbVYrWmvZ6691fi3x4vcByis+yeTRwYBWNUexcvfTh9tpnIQvJVCnlyVboSwXV
         5gOAGOFv1hTg/bHevAWo5ABVzYFF1KLGvf+awDagCDewcNtrYuIVEGa0BK6HsnM5yPsy
         HvBQ==
X-Gm-Message-State: APjAAAUI0EaiTgzVDhrs8jNVC0bKN5LAzh08gnpnnslhJMrLOvoeyML0
	SQZtUrVvSbhUslmsweFfxCEPqU5ZU9KmDqYvqMjeT7cAky1xQyGZ28n6RqVtLcmRBgYCzHs9vou
	XlquyUNKPVzJL2r5my6PAoEUq4Kfqxy5pBx9kbdmh8+Q3uhKbzbPIsLfqE6oZHyFTKA==
X-Received: by 2002:a17:90a:9f0b:: with SMTP id n11mr16055874pjp.98.1564984946970;
        Sun, 04 Aug 2019 23:02:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7+qYTP2/isVGepCnLbFFiFyy4Xqn/nW3q68RT4DhHOCWMe0ySz1Gq9GVocbRd1owx2VBx
X-Received: by 2002:a17:90a:9f0b:: with SMTP id n11mr16055822pjp.98.1564984946242;
        Sun, 04 Aug 2019 23:02:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564984946; cv=none;
        d=google.com; s=arc-20160816;
        b=SRN19mb0aomN45VEMynJMCcAoVCpMcBWwS9gIGZl3ixNh47WljGlMPPAQSXhqQd3vC
         ngHRHuSsHBNNVK3tSGQb3FDTLFRDdOy+MlAxo9Ok+i52cMzXu4pyE1vyyvxPOd07UciE
         8OcMA7hNmTD0qvZ439rKvWNtL+gj8zz7Z5sJTSwRsetzK5BbuKsmlqiXpYG17iCX9cK2
         gU+8z+h7NMZb6FJANSYvaAVYM1b/hfDc568iBqvP5Ym6KeZpYpECM0gDaePrrTmpX+TI
         loVGATOy8dR0e+HaDX3nZjnkVRCX0DEtC3nhOWVOqBjNwgF9o28AVLQnxfkRs3uh6d0X
         tgGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ClH+zW21dk5gLrAKA0gBdWl3t95WY2+GG9YnQOikIlE=;
        b=GLw2IHo+GPGo2gjFdmuhKtb8DxR1rzFAKISYLoE2kbkouwGZ0sETomLJGt6jNchpzp
         +NjB4vHcIQxFTJRDwul9qJ2Ijgsq9NK0dfh1CT5vaR0bdDRFQI2FERPeJEhfB7hEV25W
         SAQwXniK7i4iqwHy+qcLsP+WX/nxG2GyFyMh2zGEOkZvjgOi1Gbyl/Xw07GaZyk0UTfe
         7G46THjjI3S9AEm0Q1GgCXtNOgp/LjkXKZ061Fkq72BjlcUJb3WXjWpU5JcbUhfQRhAc
         /tSu2p7YVx8pSzdsvU4adCtryK0T0/vZlK1bf+eaWPQI9iZaPsYXPQBxPxzlHnqgUUX+
         nejQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zSXgYL75;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d14si9410764pgm.346.2019.08.04.23.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 23:02:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zSXgYL75;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4B36B206C1;
	Mon,  5 Aug 2019 06:02:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564984945;
	bh=yQX7YAlJ45FZwBgTl9rdH0N9X0UpxWT3t+wfvZobwSM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=zSXgYL75mNTG7YL12V8C5eDoiC89Hf9Kaiia7s6JjkSUHCF3x6/Ak018i3ohQQ3O1
	 C+6GAAKghAvtLBKxUDxhRUd0DUmvkM7dGI43mf/Q1DPFk7szO3cfjFWxrD2gdHXb7D
	 6dlcetc0SFH7Yf9LWrJm/9N7xnUQ/WeVSCP7gH38=
Date: Mon, 5 Aug 2019 08:02:23 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Ajay Kaher <akaher@vmware.com>
Cc: aarcange@redhat.com, jannh@google.com, oleg@redhat.com,
	peterx@redhat.com, rppt@linux.ibm.com, jgg@mellanox.com,
	mhocko@suse.com, srinidhir@vmware.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, amakhalov@vmware.com, sean.hefty@intel.com,
	srivatsa@csail.mit.edu, srivatsab@vmware.com,
	devel@driverdev.osuosl.org, linux-rdma@vger.kernel.org,
	bvikas@vmware.com, dledford@redhat.com, riandrews@android.com,
	hal.rosenstock@gmail.com, vsirnapalli@vmware.com,
	leonro@mellanox.com, jglisse@redhat.com, viro@zeniv.linux.org.uk,
	yishaih@mellanox.com, matanb@mellanox.com, stable@vger.kernel.org,
	arve@android.com, linux-fsdevel@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	mike.kravetz@oracle.com
Subject: Re: [PATCH v6 0/3] [v4.9.y] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Message-ID: <20190805060223.GA4947@kroah.com>
References: <1564891168-30016-1-git-send-email-akaher@vmware.com>
 <1564891168-30016-4-git-send-email-akaher@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1564891168-30016-4-git-send-email-akaher@vmware.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 04, 2019 at 09:29:28AM +0530, Ajay Kaher wrote:
> coredump: fix race condition between mmget_not_zero()/get_task_mm()
> and core dumping
> 
> [PATCH v5 1/3]:
> Backporting of commit 04f5866e41fb70690e28397487d8bd8eea7d712a upstream.
> 
> [PATCH v5 2/3]:
> Extension of commit 04f5866e41fb to fix the race condition between
> get_task_mm() and core dumping for IB->mlx4 and IB->mlx5 drivers.
> 
> [PATCH v5 3/3]
> Backporting of commit 59ea6d06cfa9247b586a695c21f94afa7183af74 upstream.
> 
> [diff from v5]:
> - Recreated [PATCH v6 1/3], to solve patch apply error.

Now queued up, let's see what breaks :)

thanks,

greg k-h

