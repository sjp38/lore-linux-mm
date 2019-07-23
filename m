Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 679A3C7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 15:36:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3565E21734
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 15:36:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3565E21734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B518A8E0008; Tue, 23 Jul 2019 11:36:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B02478E0005; Tue, 23 Jul 2019 11:36:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F2328E0008; Tue, 23 Jul 2019 11:36:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 514A78E0005
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 11:36:50 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id s18so20933392wru.16
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 08:36:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=frxfWSpefKxGEUFD2kmnWKrXpcu24CFEk0ZgQ6qgIQ8=;
        b=BQKqyCX273epImkWMMOoS6XXCmfPP2b4dkg+tBPcJnHSNWrBNKGpHiNUYRDDiaSbo/
         s6nglq/xU5CG0u2BuZf/BxsWpAZBA4yLY/oyQf9ff1S6dBqwYWHWaEZaca5d1i17+wAj
         YTcg4+c3LpvDVVvq/VLTZwXfAkIg12YcslpxLonc1MvTjpY8AQPZgG+i9xllER3U+BLy
         wX6FHGXEvPU5/TQgVEh+bexOcBQzKkcSihW3XSU6XF89ZmOEZr8fE/ZA9qB92tnKaKzI
         VIMwwjaEISCb943uBR3BCZLnkZc90DBLyxixYKQZtXIG7eVWCj3YeL1pMXrv33fTrWuh
         rAsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVOOUjrYWQqMFRZxq7WWejyPBHzL7S4qlFSCbU5PvO5JbjCE/uR
	xr0HB4hbyzk0ud6k6BPUozUaX0bowYCJ9ThpoOkG83omGbluWEY1ErUu99r5pijJ248wdMzkTDZ
	9gu4ZCU+krhbAU76NoBFYTzY3UMaFhv2CzXTgtG3N4ZkrIL5P3vvyH8xwf6Iwyfp8yA==
X-Received: by 2002:a05:6000:12c2:: with SMTP id l2mr52272205wrx.65.1563896209130;
        Tue, 23 Jul 2019 08:36:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz13YqVO0kN83dXgk4/DyLnsshUbJ9YmQWVeWLM4AmKYLbcZZifQJFBrBPlxB7gdwQC3APr
X-Received: by 2002:a05:6000:12c2:: with SMTP id l2mr52271835wrx.65.1563896202537;
        Tue, 23 Jul 2019 08:36:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563896202; cv=none;
        d=google.com; s=arc-20160816;
        b=wxKRabqm2379FHTZOs4mAl6fLXYZKWd5iUKN9fQQJtJMm0Kge078dytvWJ21+or3NC
         nlim7nvFd0l+5lMDYn2tsesTghW/jPt9sH35/4JSMhDF75IxW2h0O/d8mQEW9J/Tg/Qn
         PTvntJPA0ESDF2gzhgCHPVpdO6iEinykx1ewJfLp3bn5OFH4onpSBZXiXEXFFT3TxDdc
         yq+jEUObvJGWecLXPSU57MEfKrC2U3dbYG8WK9l80F7xUEhy2igPlZ5RwSD2SXI9IOwQ
         0Fb/j9WRy5jJBlUT4BJGTktJSbwKK/a3JEwnMa18fFUYFQ68/85ao3Obpk9+mi8aHjcT
         uAmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=frxfWSpefKxGEUFD2kmnWKrXpcu24CFEk0ZgQ6qgIQ8=;
        b=jeBgXzmc+gI8lisZeZhuK9w8VgSATAyvLlFJ+Ezqvge+k/hly9SwCs5gWJZvT4IrgB
         kOEpeUlI8n/HgfsD3FEJLByNy2YGUGn/jpS3SWfRZJSNCvCYrQ8ksgK84Kze9UPkKRfk
         JMBi1kKe9utbfCNfQuHPun16xwdi/3Ja2mcqH8kE1vkq/jwORvzdk87QfzcIiyGcfce5
         VZQYnOBw8l8XsKyzqKyNikUeO8c40kNknQYj9nEDk13NsKAxK8qkec+wKkJRuRDvudQ7
         6D/ftMb8mI7BwSJ8TUGFAIqCZDZWx7zgCaUaSvXH6HnyXJPgtWnrzbFASUQXtUEsWs3V
         9L+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c9si35021924wmc.24.2019.07.23.08.36.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 08:36:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id A348468B02; Tue, 23 Jul 2019 17:36:40 +0200 (CEST)
Date: Tue, 23 Jul 2019 17:36:40 +0200
From: Christoph Hellwig <hch@lst.de>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	=?iso-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>, Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jens Axboe <axboe@kernel.dk>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>, Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>, netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/3] mm/gup: introduce __put_user_pages()
Message-ID: <20190723153640.GB720@lst.de>
References: <20190722223415.13269-1-jhubbard@nvidia.com> <20190722223415.13269-2-jhubbard@nvidia.com> <20190723055359.GC17148@lst.de> <8ab4899c-ec12-a713-cac2-d951fff2a347@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8ab4899c-ec12-a713-cac2-d951fff2a347@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 11:33:32PM -0700, John Hubbard wrote:
> I'm seeing about 18 places where set_page_dirty() is used, in the call site
> conversions so far, and about 20 places where set_page_dirty_lock() is
> used. So without knowing how many of the former (if any) represent bugs,
> you can see why the proposal here supports both DIRTY and DIRTY_LOCK.

Well, it should be fairly easy to audit.  set_page_dirty() is only
safe if we are dealing with a file backed page where we have reference
on the inode it hangs off.  Which should basically be never or almost
never.

