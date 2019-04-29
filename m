Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE57CC46470
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:44:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97A1C215EA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:44:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97A1C215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 370F76B0007; Mon, 29 Apr 2019 15:44:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 320906B000A; Mon, 29 Apr 2019 15:44:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 237306B000C; Mon, 29 Apr 2019 15:44:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1FFF6B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 15:44:19 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id x6so467240wmb.2
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:44:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=y48vc/AJN2iVM7q6FIyzUKax737xnfPzHfJzfrP35W0=;
        b=TswXz/UbkRtR8LrGfYKD2ZNIGlZKFWFqcRK7lVpvpBsSjy6aXMUTchtyHyBGT7O/MW
         xwql8Q3GzZEEJQJPvSaYLKYX4oHpe3ubzWINdhcr/3Mlcwz43B3tHsIfekXXKVICUtbz
         rgW7UOZfztgCQcYgyVIY02RvREXWeSs2dfMv3y8s0dOcNbp0UMaoXePoB8NfIJ0bdWXr
         ZofEEDpVsFOA1wP9yMW4GCrfPB7WHOCiAwxwADguKZ71Jk++dZX0uxMfHUYS30oOyLbV
         za/8ix2KnfJ23CSWTxQvLBH/oDctISI1zqV8bJXD5BqZvIEmfvYP/T4eU1KtG1Xx4FrM
         /RXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWb/H4IPZR4zXXRFadk6nwQDxuNpstzwWOrI7Glgx2U8sxW3RSz
	NQUUu3t5lKmaNbZxnhj9x1n2kLlw2fkn7F4rsfiLRPIcRuEuX1kJdckv++Cr+KP8lwGROj/ndPE
	cOh6T1aboRVcRjuSZvrk8PDk/iVvdTobmyJMiuG4Xud0u473RjVMbgfzw8I/9MC2mRw==
X-Received: by 2002:adf:b64e:: with SMTP id i14mr19741978wre.72.1556567059474;
        Mon, 29 Apr 2019 12:44:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywWzM2bxsABJ2Vdqn2rTP6Vzp2j5UTHUipeQeC7fAV1tVaZCy3w9f+gmfVoYKbab4PulDD
X-Received: by 2002:adf:b64e:: with SMTP id i14mr19741957wre.72.1556567058870;
        Mon, 29 Apr 2019 12:44:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556567058; cv=none;
        d=google.com; s=arc-20160816;
        b=0AusqFRohn5u4Sd8Fbds0CYuX2mHOg9Wb8FlDyjj5RuJx31nphZkamW45S5GspNk0h
         EuYD756/Xdgv5YPtsW2HNjWZZyDouNc8ddUSRbQbsju0pv/ErAT+hy65BlnhnZ04L5sD
         JowY0k084aB49Leu44sVkWm7Zjspjytl+LcJGZ83pSKbmjy3Xo47amckNua32eFS0jSm
         p7r4kgSsADgFHPSI+3ZZBtjl+Ro5Rf7qN2t5QEqyeANcyQ1p/sMtuCHe09ofrPTvu9ht
         lSKCJu47yEhx6JgbIAMiURULCUX89UjKXmxVkkVEavu+eh233kxxS9aw5yuRlxkg8lFy
         qx5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=y48vc/AJN2iVM7q6FIyzUKax737xnfPzHfJzfrP35W0=;
        b=OKpspkdUUk34DbBx0snIRdnePcodQDEf9ka1hr1xgaX3HRCYLcERm3vJFgW0UxzMl3
         BQFegbNuVtZA7N3uN2AnfN1dFqlUE2FrhTyTRA6445MnOj40YkcFpYEB+2LP+b5RGTyf
         vDE36gN9mCulfaVjG/2iWgy4XBvhNESM/LwdnHo5yKpdr1HE+nAq0S7gRwWhSsQwG9S9
         kn2zQ192Yv6ZVAKKVw5AI1tvoIMD/0OkhyQ2ZSNgd9VNL1C2PY64z9JiMYHOOm4eGtHe
         QGKpNc6R9S57eO4o7VcjtWpB9yRno3xTMtNK2DDlhwhOo87BI/vZG/0cbdj9Anv98/PG
         xJ7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id z18si4336868wru.429.2019.04.29.12.44.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 12:44:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 60A8068AFE; Mon, 29 Apr 2019 21:44:03 +0200 (CEST)
Date: Mon, 29 Apr 2019 21:44:03 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
	Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v6 3/4] iomap: Add a page_prepare callback
Message-ID: <20190429194403.GC6138@lst.de>
References: <20190429163239.4874-1-agruenba@redhat.com> <20190429163239.4874-3-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429163239.4874-3-agruenba@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> +static int gfs2_iomap_page_prepare(struct inode *inode, loff_t pos,
> +				   unsigned len, struct iomap *iomap)
> +{
> +	return 0;
> +}

Now that we check for each callback there is no need to add a dummy
one in this patch.

But given that that won't change the end result:

Reviewed-by: Christoph Hellwig <hch@lst.de>

