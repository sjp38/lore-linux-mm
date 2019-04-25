Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35E18C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:03:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 481632081C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:03:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 481632081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EEF66B000A; Thu, 25 Apr 2019 11:03:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89DE76B000C; Thu, 25 Apr 2019 11:03:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 790BA6B000D; Thu, 25 Apr 2019 11:03:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3B86B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:03:57 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id a18so97598wrs.21
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:03:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VJRE3UxZ7UlpWqD1mOw1SJXr//OiyL+W/hvV//itOks=;
        b=o2AYMGEX+D3LUgwkFVSDWGwnZUZf1di826dFjiELLI5x5IUWfLay0i2zHhRQuilE/S
         vpeY3Y1Oc0pa+qKApDCR+ChnIXomVSO98bge4+BhdIkCkJLTQBIL/Po5s6itEwgijMKw
         n+TTQGX7wZkjhW7PXhO+rmqG8b9cq97z/DUD+mb7aE4rs3LeaLHfRsNUpFo1GCaONjsc
         LhzFGqjkOffUhPy1UbVDsH90TR17HWOCibFaBlz7WgTlNLgJg2lZSm1msxosSiy8b/SA
         HgRRJarIrU5CxCZWjLnkO4TN6SovXhs9v9/RZEGcD5NlmOXcvMjVRhiKQdHRaSGU358A
         CczA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAV3PS/7sTIpHNcAsw6Mt4maN0Owrru1n4P295pwoRi7aCv5ZEeO
	6vopuxwq3UpbyeJG6fYW+W9ngkBjFmPdzuZX/6uNe0eNtDb3pYHi2OgftvqtvWwA8IJAnS8mLXE
	kA+ChZt0LQg03JuQCx91D7HFgJo6B+R++o6L8qg2+nCGBfO0s2XXjUmfI75tzs9TKiA==
X-Received: by 2002:a1c:9950:: with SMTP id b77mr3590813wme.133.1556204636810;
        Thu, 25 Apr 2019 08:03:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRn5JpNwcSUKllrO0Ize8nyANcNyN41nNUYG6c3Ve15QNvmu2ziYLapj08slJczmGToK5I
X-Received: by 2002:a1c:9950:: with SMTP id b77mr3590750wme.133.1556204635763;
        Thu, 25 Apr 2019 08:03:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556204635; cv=none;
        d=google.com; s=arc-20160816;
        b=LB4tPkEqQmKjx3arhVoL5F12JIC35SnQMKJGZdsNrfDJ+0ZWCNMJiqp5Tjy31Pm6lB
         gNkI04Hrv/MHppyMs2fZEcRGE28OTRPo8RqONWmZNeDZ4t1o9uk5B5U75HKRKBo8G9D/
         VE5k7Mrp5+/TLuMxDiSnXDK0FpaqLSrBL4l42QWkG1k6aifcOWHP6vwsEj4jjsrXrXIk
         aOW0vAeTkS8B24yRTjGgetCgVIEF2fUuHOB39erc3CgZaN6DfA4S0lpa4n8pLk5L9HMG
         MI5wiOsjp9ur/XZ1XLQLn3w9w73bvjXkslaF3ORpx77I1leSnp8eL2TKweZgWq1Rw+nR
         9sfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VJRE3UxZ7UlpWqD1mOw1SJXr//OiyL+W/hvV//itOks=;
        b=BwhUuiVXAuZD2GpXl7KaO/c6vZrdYWovNHA7k6e1oSLCdwee7ccSS8WMUe9/kZF8TI
         6MSzqwYbVS0nLz93VNiJD6Q2pmYu3oeGbYjARrK+svmbnrhdEtPP3VaKcF2MUN9CdSNS
         6+WOY/zxhlpkjJ+lxHDt6T/XVY6me4MFuCscP83cwwBAaprVdnyncdZwtkUv7FO0ONQL
         0KxWziRGvFHOOQRJhWpNjt8LxMtkiAG6hkzVhM/8+6lz2WnaRAEIhwX0NIBq/JwOFB5V
         HmUnxKTjRvE/S3sFpEt1yuUK6ZwuPNhRmFlMrtViXmkUL7n0mifQfdma8XzQ2XHFa4f8
         Cqew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v18si16517202wri.292.2019.04.25.08.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 08:03:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 7866168B20; Thu, 25 Apr 2019 17:03:40 +0200 (CEST)
Date: Thu, 25 Apr 2019 17:03:40 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jan Kara <jack@suse.cz>
Cc: Andreas Gruenbacher <agruenba@redhat.com>, cluster-devel@redhat.com,
	Christoph Hellwig <hch@lst.de>, Bob Peterson <rpeterso@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/2] iomap: Add a page_prepare callback
Message-ID: <20190425150340.GA17504@lst.de>
References: <20190424171804.4305-1-agruenba@redhat.com> <20190425083252.GB21215@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425083252.GB21215@quack2.suse.cz>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 10:32:52AM +0200, Jan Kara wrote:
> Also just looking at the code I was wondering about the following. E.g. in
> iomap_write_end() we have code like:
> 
>         if (iomap->type == IOMAP_INLINE) {
> 		foo
> 	} else if (iomap->flags & IOMAP_F_BUFFER_HEAD) {
> 		bar
> 	} else {
> 		baz
> 	}
> 
> 	if (iomap->page_done)
> 		iomap->page_done(...);
> 
> And now something very similar is in iomap_write_begin(). So won't it be
> more natural to just mandate ->page_prepare() and ->page_done() callbacks
> and each filesystem would set it to a helper function it needs? Probably we
> could get rid of IOMAP_F_BUFFER_HEAD flag that way...

I don't want pointless indirect calls for the default, non-buffer
head case.  Also inline really is a special case independent of
what the caller could pass in as flags or callbacks.  We could try to
hide the buffer_head stuff in there, but then again I'd rather kill
that off sooner than later.

