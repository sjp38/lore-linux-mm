Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA78CC76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:54:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7E532238E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:54:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7E532238E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B5786B0007; Tue, 23 Jul 2019 01:54:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 566DD8E0003; Tue, 23 Jul 2019 01:54:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42EFA8E0001; Tue, 23 Jul 2019 01:54:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id E88B36B0007
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:54:03 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id i6so20185122wre.1
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:54:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8WRK6h6Cnn/rOW/4+Tb5umxeSX9AyCd6rpz5lA82//Q=;
        b=gFQWqYRi6DKGSVZV3ZpbeT1ObaMRDz+izN7ei46TWI3FB0guprbglfRlw2YuYVTw9g
         OxaKrisLaSNY7Sd2rENcga15O48mBaaJOCSOw51ekuVTGiuP02pNyMqTJzW/hANhCWAo
         Bk+oyfyrGZVLubXOj8vylRnY5UI7y17tyR3slKCv2VrNNMc9FWfiZ7cKPZDcNl/K9jQp
         m3B3/ST4NCH8ncs+/QyrCX+3vn8MMqFfonFpBEkwMv5Efzq5DVFUogRVXdq7q2zqIzUA
         14Q+SwmNnMlxqqaP9z5iauAH2CK5z0MiF+7q3oYhpIbHAOrMkLY80+tu50tiyHEdxKfS
         WjWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXRUPW1igh4T+RVfbywxP9SzizATdsLv++XZ6LKt+3qjY7T/CDk
	dp14qYn/fhv28/zC8oRjYQrCPCQ8tXR/eDkxPWBb8YXL+vWFEoBL6uEVrii2RmpPxZJlDFEzMLE
	uKqnUsQ6hbuslcIgOgfpvT285buoChtJ4kisUSlrhPz+XSgRFWFRqaGHI1RCC9Yq69A==
X-Received: by 2002:a5d:4e8a:: with SMTP id e10mr82929409wru.26.1563861243498;
        Mon, 22 Jul 2019 22:54:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztFZ16ZbN3MVBUgD6DBgmFyUGPbVtke/UW/TI/xZ3V+7+lFT4BmlQy4/nNseBzoH7hPTZ6
X-Received: by 2002:a5d:4e8a:: with SMTP id e10mr82929368wru.26.1563861242929;
        Mon, 22 Jul 2019 22:54:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563861242; cv=none;
        d=google.com; s=arc-20160816;
        b=T+Y1lTLBBCmwqkZPKAvGTqGh66iedXG6ocF6Yce4RpPYq1bL2BmyKEHR3PNy+5EmTH
         +7Z7HsBj/a4BAi7+Kwb6Rf9D7p2sH2ayUxXCp//p9viOjxDaq5Djm8RH0VZZ1Vz+nv3A
         li2b5YWep0RhWxDulwupNEHduJl5CQEH+vDRMEOz9OXaDL24UaTnRxYSXXzWguUtYjFi
         WZ8FEcUQLAYkN6DLiWD6iqy2KAbs+CpMRxzRyU+1M3wvU19YIDVdy9W3wZ8gI9g9WL7u
         miLz3CJUPfwNs7SpK2akOa/fBGi6ldh3trGDQeisVuUIJ/ikn716Gt+HAUmN8E5yKnzD
         MJWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8WRK6h6Cnn/rOW/4+Tb5umxeSX9AyCd6rpz5lA82//Q=;
        b=msz5fhi6u0TjaWAY1KN9xdLq3r9GAhwhhlAlOLy3oYb9Y+zp4Az8VuE+9YdGKafu4n
         UBg3lDQVfpCfm8LttIxuSpMRQdJSp54crPAXdwYWv91ex8wvV3iZ8KBXDqEt8c4s8t1m
         Ic7GjxeFT/g1hktczqtFlEAvjxHrX4OIU3JNHABsMoWzFKpjvWKZC8Ml0dBKzJQPx+YV
         GtkMGOsQMM7iaY0FGr2PsWy4qFSewKUrbX1dwjzCeOAHRo6TZpHucKUj/ftJcDfwilDz
         2nxuzGfie96lRhH+U/+e5YIuquVLGNO4jxbMZ1CcLrbhGqUHt2p/MvITgt6h1iTxiNUo
         gk5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id w10si36804364wro.157.2019.07.22.22.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 22:54:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 3D38F68B20; Tue, 23 Jul 2019 07:53:59 +0200 (CEST)
Date: Tue, 23 Jul 2019 07:53:59 +0200
From: Christoph Hellwig <hch@lst.de>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	=?iso-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
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
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 1/3] mm/gup: introduce __put_user_pages()
Message-ID: <20190723055359.GC17148@lst.de>
References: <20190722223415.13269-1-jhubbard@nvidia.com> <20190722223415.13269-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722223415.13269-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 03:34:13PM -0700, john.hubbard@gmail.com wrote:
> +enum pup_flags_t {
> +	PUP_FLAGS_CLEAN		= 0,
> +	PUP_FLAGS_DIRTY		= 1,
> +	PUP_FLAGS_LOCK		= 2,
> +	PUP_FLAGS_DIRTY_LOCK	= 3,
> +};

Well, the enum defeats the ease of just being able to pass a boolean
expression to the function, which would simplify a lot of the caller,
so if we need to support the !locked version I'd rather see that as
a separate helper.

But do we actually have callers where not using the _lock version is
not a bug?  set_page_dirty makes sense in the context of a file systems
that have a reference to the inode the page hangs off, but that is
(almost?) never the case for get_user_pages.

