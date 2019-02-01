Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBE35C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 07:44:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E8C620869
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 07:44:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E8C620869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7B6C8E0002; Fri,  1 Feb 2019 02:44:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E29B88E0001; Fri,  1 Feb 2019 02:44:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF2AE8E0002; Fri,  1 Feb 2019 02:44:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF828E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 02:44:01 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id e17so1932206wrw.13
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 23:44:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=awK+GUAseTO0Gg0C2WGVsytn14gnXFDxU5KxYk4SwX0=;
        b=YAwfvP51rW1sfyJkB0ie7JgHDnRO8cD30TQiMX8QJmYDOvdCrBFla6hpY6Pzz9PVMw
         npQpTLUDpUxypj9HNPfdu3clpU8FURQZzl+TwId/9A3sySd7Yid42K4p27Y5Hb9ZMCrC
         mExRqPOtDeBpxiBSlIWz7Pdhhi5DFwCqmGRTBj/7CuLjzAzJf6YHRFnV891f3fZrel2Z
         Gjen8yukWLL47UW9WUGNCfacDzOT2h94hTZuQUYOOiMUZgsmL6vKtFvepCBPaeYNqOZa
         OIqLjEK8Mk85eTcHz/yYTIV4SVTnEk1JWx77C/6LBZ0AjK3NJ9I/ztdgYFrpX4J5QIgz
         nFtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AJcUukfWrCb9hmptNG9dJ0upTlQBnJVtLE2rTwOYAomtzJYF5/RcMqxa
	xBc46XZEi1cQdKFU+DGRz5oDcE18fy7nnpwkQs3cLxv8X3PtRt8LJqiVi601G/U9zvFv3+NQWxr
	VzrqP1sNiRuaGMDjxdQ4mearDscuCidQXy12l8gHSkDpdjSJnRhJoX4GmLPqCrhq31g==
X-Received: by 2002:a5d:50c5:: with SMTP id f5mr35784540wrt.37.1549007040992;
        Thu, 31 Jan 2019 23:44:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5usZtqgredY7LMuOaItjrzx5Gf65KL2QEx8WDcgRhqgmKl4l8mxsrcmxRRCJDjTA27fJ5+
X-Received: by 2002:a5d:50c5:: with SMTP id f5mr35784495wrt.37.1549007040196;
        Thu, 31 Jan 2019 23:44:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549007040; cv=none;
        d=google.com; s=arc-20160816;
        b=Ner8/vob2gHl50+zxmEu8leMhzB5hrx496bgPp8oJQ/79S/a9TZivi50sgaq0znAUQ
         VbRDXs320/PeJ66sgMjovJXV1gaHG7WZYOXUVnm+vqcg84Xp1BE7a6Ar8raXqwzDNGlD
         VjwshdGgvN5/oo6+7nWiFjHDwSXuxrm8C77ejg3UJhrh/Q+/UL33apkTJ4ejSjyjt4iC
         W9xxkbz8Bbh5JSI5XTKMR0HGAN+RkqOafD5pDMjQRxoSrxub6BCglOtl35bqONTDCqNc
         Y6faEeTQxLGkeK4kOd161xGDhxIeazTZKnce2FDlLFDnb1lLtWkieNz6AbGSufEzZL18
         Rfmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=awK+GUAseTO0Gg0C2WGVsytn14gnXFDxU5KxYk4SwX0=;
        b=uKqInDTls+oq9QPJN0CyPZrW0vaWFZp4ObAVZ3iuaoxKKBGOqoMZkmowZw2dVdo0Mo
         RUT5zn2coDL53gX/ATJ4XnsRGpX1PSxiXbZxqyuNv1sbYSq8OCWa+uVqUPEr7/OuXFtY
         TxW8/LUNVsyNRlOYapUJ1s+ADrHddewUhbmzQT56T8+lSlXIq8YCLsq9+hTYm6O8jAjH
         Fb8WoiirwwTb+abg3Q6oAE1pjNc6OzQy6S0647zocH75RieYs0gntYyRusfchFUpVtJP
         LJScqm85zzl0Qjwq8tZ8cyGaisCK7vI5xKhUYm5ksaQ3fjRrJuM6mJzh66Z6JaWQ1+8C
         gPBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id w9si5138018wre.454.2019.01.31.23.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 23:44:00 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 45A5268C8E; Fri,  1 Feb 2019 08:43:59 +0100 (CET)
Date: Fri, 1 Feb 2019 08:43:59 +0100
From: Christoph Hellwig <hch@lst.de>
To: Matthew Wilcox <willy@infradead.org>
Cc: zhengbin <zhengbin13@huawei.com>, Goldwyn Rodrigues <rgoldwyn@suse.com>,
	Christoph Hellwig <hch@lst.de>, Jan Kara <jack@suse.cz>,
	Jens Axboe <axboe@kernel.dk>, akpm@linux-foundation.org,
	darrick.wong@oracle.com, amir73il@gmail.com, david@fromorbit.com,
	hannes@cmpxchg.org, jrdr.linux@gmail.com, hughd@google.com,
	linux-mm@kvack.org, houtao1@huawei.com, yi.zhang@huawei.com
Subject: Re: [PATCH] mm/filemap: pass inclusive 'end_byte' parameter to
 filemap_range_has_page
Message-ID: <20190201074359.GA15026@lst.de>
References: <1548678679-18122-1-git-send-email-zhengbin13@huawei.com> <20190128201805.GA31437@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128201805.GA31437@bombadil.infradead.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 12:18:05PM -0800, Matthew Wilcox wrote:
> On Mon, Jan 28, 2019 at 08:31:19PM +0800, zhengbin wrote:
> > The 'end_byte' parameter of filemap_range_has_page is required to be
> > inclusive, so follow the rule.
> 
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Fixes: 6be96d3ad34a ("fs: return if direct I/O will trigger writeback")
> 
> Adding the people in the sign-off chain to the Cc.

This looks correct to me:

Acked-by: Christoph Hellwig <hch@lst.de>

I wish we'd kill these stupid range calling conventions, though - 
offset + len is a lot more intuitive, and we already use it very
widely all over the kernel.

