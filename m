Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9B24C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:25:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5D64208C4
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:25:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5D64208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D8236B0005; Mon,  1 Jul 2019 04:25:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 489478E0003; Mon,  1 Jul 2019 04:25:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 378C48E0002; Mon,  1 Jul 2019 04:25:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f79.google.com (mail-wm1-f79.google.com [209.85.128.79])
	by kanga.kvack.org (Postfix) with ESMTP id 00EDB6B0005
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 04:25:20 -0400 (EDT)
Received: by mail-wm1-f79.google.com with SMTP id z202so2875540wmc.9
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 01:25:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UHzx8Da9e6MxYEmcCf+I/8D5JETsGceRmMZmkC4knEI=;
        b=dV7eEiqJvv03tfjgvQ3MQh99yLVSmDQmknbAZYDrOUJrILdeW3J8KwOXN6lBL+iBjG
         y1EVcLOU+1DOFSVBRdTshtWqrt+/c98wo3jtlVuMqyAJGwM+PX5qQK6xFMRpGd5PLZ0I
         fao8kOoPPiODz5a4ty/pW69r3AwmJdGbrixKjVaVjFMUOLF69KKhX50YSfayPoDeeDcc
         cLT6D/5pQupViXQkS8o/1OdQ9Swt6j8tsyDM/SWoPXp2ZiJd+sUkxECP8t/lcISe5OTp
         arNXj2ZI0Y32hZ1u0EUs/gEcAhVgJUFHjTmvWn7w7wD/w1gtBgqOc1tZ4MRhnTY9hMQ8
         tMvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAW3xbRuHCZl+7MhGdhpdfK7+IysHHmWd6zRFCstTID6GNQ9pN99
	HkQ1nN44uk7yTB4BxBN38d/MQQV3UbgZORIA1oF6aJvVUUe/OMWV6crIWtfIh6VLN7FfpHLcbJG
	VzSNvqrm3vHZFpW39uapbogJN/uxwZLf3po5sdsPyw3w0XyuWuGowL87zzuel4xx7oA==
X-Received: by 2002:adf:a19e:: with SMTP id u30mr12355812wru.33.1561969519536;
        Mon, 01 Jul 2019 01:25:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7iKJL1nkAKtiGNCcErp4Ye1YJyp4CTWhgOloGWef/UxRkQ+1kE1D6KBSdenHX80g3xUEy
X-Received: by 2002:adf:a19e:: with SMTP id u30mr12355748wru.33.1561969518837;
        Mon, 01 Jul 2019 01:25:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561969518; cv=none;
        d=google.com; s=arc-20160816;
        b=vX95cEvzShcNpzsHoAaAN9kqHPt/wk8GAVwZBKhE53/BwpzjOCID9LbNm+HZhBgd6X
         MSJhS0OQH9e0Bn+OmQUhfn6b1yc42DDv49lYsP2Fc75dNocPJIVjouEtKVCXmVWb5Bd1
         pRXmPXnjvJ+tKug8FgFltYike5ZMANmE1E8AqVdCeUezlDdLeJJZS0niEg4/eOWpyKBi
         wViGor4EDjbh1hORxs+veunnvDCCD7Nc2C5k46G7F6hrtMWaIlDrvXCZkdWErs59zvPQ
         8zJmOaKCEvk82RBJVd6vo/8UHCDWlJ4ZWbg7yIL+w26Hj55oRgzgxi7WodZF6z98gr7h
         0mHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UHzx8Da9e6MxYEmcCf+I/8D5JETsGceRmMZmkC4knEI=;
        b=pgS/1CwU9AYIYa7VYWCVOWTcXLZAcVlPaaI6y62WkqF2aNxR518xmANe0AZjOHIO8v
         AdQ6JgnQDv7oyjeIvinUrVYvEMJrO+uotDIxL6k0guwhj4WzNzxSbMf86pqUvH9k2qK9
         35iH5L40kkRm4X6EpB2KH3/aaClUo8QBXeUBts2qRfT43MZWwYJe8CO9N+cVDp32Nk9b
         3hU60CgsmdEPBl70+r0rS6RYVynR4BbPGWtrsoUUwUOT7Ze9rcvr5M7O+Tr0hT9JdLbY
         XPHQohvemHmylIpD+xK5p2C3UVEP5/3Gw2ycMwUrZGI44s/OkfE6GlVvNDulTlaXXwzG
         6UUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b12si3297467wrq.199.2019.07.01.01.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 01:25:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id EE0A068B20; Mon,  1 Jul 2019 10:25:17 +0200 (CEST)
Date: Mon, 1 Jul 2019 10:25:17 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: dev_pagemap related cleanups v4
Message-ID: <20190701082517.GA22461@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

And I've demonstrated that I can't send patch series..  While this
has all the right patches, it also has the extra patches already
in the hmm tree, and four extra patches I wanted to send once
this series is merged.  I'll give up for now, please use the git
url for anything serious, as it contains the right thing.

