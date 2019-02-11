Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 543D0C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:47:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C0A1218A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:47:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="KiSEO6jf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C0A1218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AA978E015D; Mon, 11 Feb 2019 15:47:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 958288E0155; Mon, 11 Feb 2019 15:47:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FB608E015D; Mon, 11 Feb 2019 15:47:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A61F8E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:47:13 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 75so240574pfq.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:47:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=admqwkaG5lh1FTkEW/ac1GyngyGSIJLfPe49QQhkzz4=;
        b=ZejWp17rJ9iBefxj3OUioTLJs7Cl+7oeLgaZZ+VByJanet68OmMm2piAB5D3RDgeb2
         vQO4TFA6aoWdfSowx+uKwQxcJfJPVLZOfXKs6VZeWtw4/TcZBQFxhbhONqcykzzYgQFO
         31EVb+GwfHzGJnNxE10T2hein1MYlCc4Cz5hT/MnMVksuJsyhxeRpboTxSSXTLAYh1ws
         NgPrTfVijlDU8EM1Ma0Ku3bQY2Z/rBEZrf8IivxnmEyetsCbOUnm/TC3z6V9M0stTXyJ
         83bMMzPSQ8DtFHpA6kp1bfbeGRW58+28NNvxQ/sLLwcVyVyk0c7ts6LdMzxHele+sWag
         /K/A==
X-Gm-Message-State: AHQUAuaSU+xqMD5A0pisz0Zbmvrvdyf9Un9lYOoTMx7DgwrBwFp8zQcY
	MKF93pcCDr4HElLKyBe+2rr1cK1ZWIany74g61OjiTr0T6pxnGwS6xFeV5JDGXSmlsT3RHzqUfT
	Qflnc4muaLC/fG4nOCEzkI5L3n4yK1VQARjAbRothkjZED9XbYP9KvyQNGTRdGqegjlCbjD9RDf
	zQbn7Pk1wMVGcxs1/SVVERnv2gF5294iiqNfW4cREzHdu65uzUtqaGBe4FQMJNHgLxQx00+gv2e
	/uicLrbqF2hIax505/PvlrMNPTaKdPUI8T2tSyAm82gGZwcS5YTKjy8A6ZTVxOjJWdfwm//WE0e
	LtS5ySBHcUaGHvNg0MyQ0wm2iUXdcTCt0a5BgG1quGe/rR23Ft9PClftEQtXHoWokvkeLmK6EY/
	b
X-Received: by 2002:a17:902:8c81:: with SMTP id t1mr131278plo.107.1549918032950;
        Mon, 11 Feb 2019 12:47:12 -0800 (PST)
X-Received: by 2002:a17:902:8c81:: with SMTP id t1mr131235plo.107.1549918032377;
        Mon, 11 Feb 2019 12:47:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549918032; cv=none;
        d=google.com; s=arc-20160816;
        b=eYZTi5xvSGQbXYeWeHl7FQ7c+mBFA9TDX4eQrCGxF5Iw9bvXVc6mWfNoh+wUhkXqIr
         hBmWExSr9ddQfjtEmZdXwA7dMk2ZJuRqIREGDZMvu0LHay+kpJuo8JhZ19bEHtRIfJHc
         WQ5B4Pkg7CxABsCtDWM+ry5N8uHExXqf4hR57XaAauH1S3mWBvyisFciA8KwHDK+Dj9e
         KEOOUWetYqQqrtFu8PhHf1CexvUGtrfP/tIBQhOdaAAkIveMi9W8JRFpSgLtjbbcx5Ka
         kaXudgZF0HoqQCQNmavDkHrzPN85rvAdjNBwXS9TDGqMYMf3lZBgXzZUTBX5CYqJaA8M
         Y5KA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date:dkim-signature;
        bh=admqwkaG5lh1FTkEW/ac1GyngyGSIJLfPe49QQhkzz4=;
        b=bBTFbVmtPLTxYrXT60NyKB9zfz4AF2V09Yhdq/ZPGj3OFfx8rYt82DC1U2MME35UJo
         nAtDmTkMTShNZBCJrEyhHYWGW4uSEAvkGGnPvu0FZgoMQ+APaEh+AYdQ7Kq7lXaSIO1x
         WDWovGIQkAeNSnV9+yEwMKSDtdOaG8yPVdKHDajiEwm2q4udKxjrO2VlLnhXgiFigp5s
         j/55Nyk+Oy0SDxclLbODC4kLDQzMl0D/AShPOOtCNGLrOUwntUyToAjx71SxHDoKvMdT
         HE7sKM0nkiE8hu0HaCW12K9vFKGDUvmq21D+ESUAhfPj6cCMPpySlRHJ7PNQbyLoIpPW
         R0Iw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KiSEO6jf;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d71sor15574168pga.73.2019.02.11.12.47.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 12:47:12 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KiSEO6jf;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=admqwkaG5lh1FTkEW/ac1GyngyGSIJLfPe49QQhkzz4=;
        b=KiSEO6jfK2JelDa6U7k4363ALxDhEZlUnqZvgtQW7SRLQ0XMhao/9CobgakB2ixce+
         YTKZq2kQztlGUmbj7oErod+2ihv08HydvRRbYNTazMqgWC72nH0BokMrdH3BI6YOXrKo
         GjD8tAbPjEjR7IQKdVjaOATb10nU1ec2MP57uoqdSf3E3I0a3Eoyqn7cy8Y3poEQl0FF
         kV9tgQbOhF0KlUNVtT3CmnPXVyxEechT9ybLIX552cHRmlxtwPfIKQHqao+7XSxakuib
         R5H7ZpFt7LTOd64tRxhQHC3qib+V8DFW9IK7fwCAUEo6QIC0jOWuecmUolrvRkfgrg0i
         V94g==
X-Google-Smtp-Source: AHgI3IbTBLlyiHtm7kKZnIRDGk6I9TyTIGu8eAgsVFw8Xec+BkLFkF9vWnH5PI7IwRFREdlVsHqkew==
X-Received: by 2002:a63:4d:: with SMTP id 74mr147404pga.248.1549918032115;
        Mon, 11 Feb 2019 12:47:12 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id s12sm8407652pfm.120.2019.02.11.12.47.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 12:47:11 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtITu-0000ni-Po; Mon, 11 Feb 2019 13:47:10 -0700
Date: Mon, 11 Feb 2019 13:47:10 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: ira.weiny@intel.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Message-ID: <20190211204710.GE24692@ziepe.ca>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211203417.a2c2kbmjai43flyz@linux-r8p5>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211203417.a2c2kbmjai43flyz@linux-r8p5>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 12:34:17PM -0800, Davidlohr Bueso wrote:
> On Mon, 11 Feb 2019, ira.weiny@intel.com wrote:
> > Ira Weiny (3):
> >  mm/gup: Change "write" parameter to flags
> >  mm/gup: Introduce get_user_pages_fast_longterm()
> >  IB/HFI1: Use new get_user_pages_fast_longterm()
> 
> Out of curiosity, are you planning on having all rdma drivers
> use get_user_pages_fast_longterm()? Ie:
> 
> hw/mthca/mthca_memfree.c:       ret = get_user_pages_fast(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages);

This one is certainly a mistake - this should be done with a umem.

Jason

