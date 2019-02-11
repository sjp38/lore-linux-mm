Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02A7EC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:34:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2C83218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:34:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2C83218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51EF88E0158; Mon, 11 Feb 2019 15:34:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CDCA8E0155; Mon, 11 Feb 2019 15:34:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BCDF8E0158; Mon, 11 Feb 2019 15:34:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECDBE8E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:34:31 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v16so160269plo.17
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:34:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yROl79dMkhGVliNKqLSE8RB6X+hOZPkAe5pCMR56CqI=;
        b=LJtcHO2SorsMMgv8IUNcZGGttgX56yEQ1FrQ1SNMASC9ioHozLT5PMWxDMFK5ZZTNq
         2OqhjD214zbhHxizxsc4SrdF2FVp/2/x20FEQskmbAIC48hPoYgNkrcqZ833vJBMf2nS
         TzPjYJB2Ej/2IesdC/I4xr6iiJQnXe1mGOUY7Jg4RHHZ5sSfbUM8n3C2/7ShFbpU8kTB
         UPu1nug6tXY6JYg0bFmfWIk2YoqumyT6DJ8jlEzY22yJNKaP6QmEZKC6ltZmhiG0PbGp
         A/vUc2aIVS1ripPhU4luYOvl58f5iEfpqp+vGKPinqKg9Pakhz1WF1+WHHv58fj2xveQ
         49Wg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAuYB68P+Y5sqYHoHuHirIvDrsY5MjxkxuXfhl7IoAWuJjHJsvuwF
	Tru7W3bAcRAGCf9M8/+R0+lJE5UDkaU8pJGzDSQ/PuyxJXkne6hTh48lMXfOZNbNTwON5hIq91o
	YNJLQgksosr/Q2KquFtW30VjUkFlJKYB1uotIf3BUhQLaxSIIpXYm7Y9Gd5XEBPA=
X-Received: by 2002:a63:101:: with SMTP id 1mr100766pgb.152.1549917271654;
        Mon, 11 Feb 2019 12:34:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZGfhq3KdvJoyDEMgLHm8eUOq89j7dAXTuq5pWV1hbyBN/k7kSBxRqp3/pk4RtgRlNxATq8
X-Received: by 2002:a63:101:: with SMTP id 1mr100720pgb.152.1549917271009;
        Mon, 11 Feb 2019 12:34:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549917271; cv=none;
        d=google.com; s=arc-20160816;
        b=sYrhO8CLl0kbdQieXxvuuTYOGpGII58/2NrL0d12qURxXe8rLBUfKrIxGmMyZqXae2
         M7mYHCEjTXOgw144XmdIeMt3cGe5flK7emxNsfPAo295XU5LghSw6v88JbbIqIEin7Ep
         WK3SKRW3acLHFtXhU9d9/hB23tQaS+LqoleVYm6y88ifg4/XKLLZebl0oPZ6mYTxQKVE
         WrRdwJfEq3nVlT0WIdehNKS1zUu0dGbfuU5dbVnBC4JtToZGdVtnPZprQEHVex8GAp+r
         P1b8oXdf36E4pL3dd9U2x3HBOr4LTPjkvIIGXrNexvkSDST1b4q6MbbMYnJ2ksl4/7yr
         Sqrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=yROl79dMkhGVliNKqLSE8RB6X+hOZPkAe5pCMR56CqI=;
        b=r9hdvsOHsnvc8DtwX4L1P87jVTojASCWn2ib8tuU/e4U/9xr0DZgV95CUhprthfAdd
         j7iqI4lsUa70Y/bDgd7O8bliY6TkN8q994IRAKvgZ06+0W9daa3azyl2AO5pATYKjv2J
         mOikmIq5J7yGjdGQO+4NRnb7AySwy/Alc2yzoF31G80otycRCECTz98WBeCksljdkGSC
         vXlDFxKqRTrN1Wq/emiz03J7YqgGff7UztgBxjdPj2RtlazsUUvUBNtRsdm6eVG4oeod
         THFCkdpC94pyQHZ58vYYnALBr1j8DX39gK006UqQfi6yHJhJ9aXiK0Tk7KvsKFpvUtOd
         UbAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v25si2128407pfg.135.2019.02.11.12.34.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 12:34:30 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4998EB14D;
	Mon, 11 Feb 2019 20:34:29 +0000 (UTC)
Date: Mon, 11 Feb 2019 12:34:17 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
To: ira.weiny@intel.com
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Daniel Borkmann <daniel@iogearbox.net>,
	netdev@vger.kernel.org,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Message-ID: <20190211203417.a2c2kbmjai43flyz@linux-r8p5>
Mail-Followup-To: ira.weiny@intel.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190211201643.7599-1-ira.weiny@intel.com>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019, ira.weiny@intel.com wrote:
>Ira Weiny (3):
>  mm/gup: Change "write" parameter to flags
>  mm/gup: Introduce get_user_pages_fast_longterm()
>  IB/HFI1: Use new get_user_pages_fast_longterm()

Out of curiosity, are you planning on having all rdma drivers
use get_user_pages_fast_longterm()? Ie:

hw/mthca/mthca_memfree.c:       ret = get_user_pages_fast(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages);
hw/qib/qib_user_sdma.c:         ret = get_user_pages_fast(addr, j, 0, pages);

Thanks,
Davidlohr

