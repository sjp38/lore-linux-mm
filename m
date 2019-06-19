Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FA99C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:41:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E23362084A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:41:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E23362084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 645B66B0003; Wed, 19 Jun 2019 05:41:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CFB48E0002; Wed, 19 Jun 2019 05:41:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E5228E0001; Wed, 19 Jun 2019 05:41:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B42C6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:41:04 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id p16so987046wmi.8
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:41:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8te5AUm/e+y0EY8xlC6EOGjgiIdhy0QN+js1aEqEyao=;
        b=eu0SPFSPOdWR535gNWXusx9kO8jitkVD9yxCljiezyMq8lqXj9Hd8ei7hHSwaR7fub
         iM3HCUoGLSgAd8EGkiAXXutelMKvIaC8jGGdxTic/ZuVFCsp5Hdd9/t0tsWM/MDKMSIB
         5N2aQaOFvsixref9TwSJKEuldz0pwK7K4MYEsPEzNYyuGbrXk31enVKIfSNscHP/Gifk
         /BYYT/tCQNDukeeqsJM+XKc+bUt5nJc7BMGsG7Off5OhRlmEWVjn61XRmvQZK46XnNWu
         QCdgg1a3//RjVKJUZobmY5DtU5LoTMY/APz1SojfONck4b2Y6n8H9+CFvyxDI0ljJ3DM
         w1Gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWdW4RcoUCDKp2WHzuJ0vtFP2lJaMjXW+yAXrzBRSG3lfof8epy
	j+6r33JGLsLOdMOJBXVqq2viKSETIeguZGy+qdrFNoSE/YmBfnkwc7m3tV+L9PgLU+tg1/OKpZ5
	zIHdWvLMDQiR/BntK+E03g6XqUPI7Nr8WhweR9yjoKVXkjztxE8WsPVZywzawakUnjA==
X-Received: by 2002:a7b:ce95:: with SMTP id q21mr7531120wmj.65.1560937263682;
        Wed, 19 Jun 2019 02:41:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrJf6Hk0xwEOCmE0wI8OLiWYjj6z/9FKhS8MKwvGUEgMQ1fIS4sjJcs1JT+sZgZdAvAlwP
X-Received: by 2002:a7b:ce95:: with SMTP id q21mr7531072wmj.65.1560937262821;
        Wed, 19 Jun 2019 02:41:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560937262; cv=none;
        d=google.com; s=arc-20160816;
        b=qn8J862bTP4Eiv6FbP+A8YXWQM1nqItlNBuVrQazy6jqFJR6sEK+IyW2eTextMSYA3
         CRzN/jKIfbqvA+FolJ3WRlwj+oKZjzgTXfBwDOcrT8xkSvYLgnDo3RvtbPyl2XqAMPX/
         vmD2Z2j7gzKVjYGOSfCEx9eUi65rkRWE9yzE2gc6Obiu1IZfejfGWS595iai7BM/DZLH
         2WLa0pSyJld7Umbi7XCcng+wHmwwTdx2xKnWt4H8r6Mo2MXcsv6X9Rp7G4uFj9Sd/MDy
         v4rDD9utN2qrgmU2LGAjX+q6KUqNkoqjWo8LxSPhYiMu3dg0St5K7kw+JHdo6s4Sfl8L
         av+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8te5AUm/e+y0EY8xlC6EOGjgiIdhy0QN+js1aEqEyao=;
        b=bkAnz9O09QxrulxJGw38CLbB+YfvMTFVSnWiqAVVYby4/7lkr0IMT2G0rCTNh3rqBK
         K4Jo3GDfpuBWHPVg/1NMBAvUSZhFOhW4J/BxKVy8Ke+4xvvVGvbWvLg4O3xvTmxGHWbp
         0uQc7JX2TD0huzrWRSGDYDq3Ku8U6ma5cn5kfYPcDvfJcSzGdZ6ePlVZrIQZ5nbRRYeV
         +OyNGLNXTg/X0AlTr+wQuQL7WP07PdOmDx0Uolxj6znoVN0iReNEaWDF3qp9idtfwnbm
         tNOB8trlkBqsszgNBAUc/5ay2sIyDpCzEPRIFLvIpzlTrNzaVkhkEQdjgtOtztUdj9IH
         Yp7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c10si13938187wrv.311.2019.06.19.02.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 02:41:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 5F43068B05; Wed, 19 Jun 2019 11:40:33 +0200 (CEST)
Date: Wed, 19 Jun 2019 11:40:32 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: dev_pagemap related cleanups v2
Message-ID: <20190619094032.GA8928@lst.de>
References: <20190617122733.22432-1-hch@lst.de> <CAPcyv4hBUJB2RxkDqHkfEGCupDdXfQSrEJmAdhLFwnDOwt8Lig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hBUJB2RxkDqHkfEGCupDdXfQSrEJmAdhLFwnDOwt8Lig@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 12:47:10PM -0700, Dan Williams wrote:
> > Git tree:
> >
> >     git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup.2
> >
> > Gitweb:
> >
> >     http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-devmem-cleanup.2

> 
> Attached is my incremental fixups on top of this series, with those
> integrated you can add:

I've folded your incremental bits in and pushed out a new
hmm-devmem-cleanup.3 to the repo above.  Let me know if I didn't mess
up anything else.  I'll wait for a few more comments and Jason's
planned rebase of the hmm branch before reposting.

