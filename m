Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32C70C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 07:05:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F41F72190F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 07:05:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F41F72190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95CDC8E0005; Wed, 24 Jul 2019 03:05:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90DCF8E0002; Wed, 24 Jul 2019 03:05:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FCD28E0005; Wed, 24 Jul 2019 03:05:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6888E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 03:05:57 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id l16so10448222wmg.2
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:05:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QHQrgXmr/PvS7gzjSStj5mj3QYtaq9lGEZK4VjwYz3E=;
        b=T/9fUXh82AT4UC6bx8AeRKVzXptG5WoVHwNI6VXgnFDZXA50s2HZR8hx/sc3T0n+JF
         28i0SMmgfeM+OoHAWCuqIDFTxjUAordNEUXtD9Y8r3d0YoNVWQTyUK1kjqcSG5EPcNHc
         NiepqQFZpzSlEMBztDkYOOdQlJVYe3aLTgVX1yd6ELQ82weageknZ+UO7AjFjnyA3Yl8
         bFcFSjSkAkEC7uqxpBpaPEIcs0uKClP/VBjpvj2bYN8GyFvEyJSNrO/d2hGQ642/Yi2e
         BklHc2kpJX0eEWJvn4ZsXFE71o8iUUWWF15KXlWh1bKGDHJmoCM1XDqNGbmJZnzyYdeK
         k57w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWIDj4xIXu4Wh/bVba3Ta8mdB/Rp6OVAiCfz8PUNA8R2KqOfq9x
	A0QHLx7+tinFNWlCYEmKiaVGi86dEZI6v28CKAoCTncsA06rwXFQJN7rBiEOgOTaWMkQYmKcAgX
	kuHLSh7Z6mImJ4EqgG0vo8auoVR8m3GqHZzc3juNcI/VOop0ng+jKI39P/UcKCc7c0g==
X-Received: by 2002:a5d:56cb:: with SMTP id m11mr84934126wrw.255.1563951956916;
        Wed, 24 Jul 2019 00:05:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwd1CDmAi9IV4Nm75eCdqLy7bHWa9HLm2me6XDzDBNputV/zzmjuJ9R9AzuKqUIQlmmY2k
X-Received: by 2002:a5d:56cb:: with SMTP id m11mr84934024wrw.255.1563951956312;
        Wed, 24 Jul 2019 00:05:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563951956; cv=none;
        d=google.com; s=arc-20160816;
        b=DkhfI/X+efRK13W7oADzFqQfpvH/KBKwQ1ZPHyJuZ9k/Jp1pqruL5pwEgb8VNpyb6c
         8viuK0UjohUnihQH29FhwHRir3Dbelb6DQBzCdFtqrG4ixY2IXsJcYnIlBi8AudLPmIO
         m1LlD1N7gfznADDOb/w8fpu0XjG6ATrdp4u1wmh/tfEs8iQjZvopuMQODTqWwCgj7ZE5
         oCYAWKC8wB4CvwzTIoA1olwiWXMIL9vb8Lj1Mo1ohedSm5dZStoWDgKLsEUQdBnxcCpl
         hsGSA09KMMZwXVcSX+0T3FH1kuz4NZ7WYJ9zuVcKmIG1MEGFNUhBIGt26gy1zDhNHH8/
         F/7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QHQrgXmr/PvS7gzjSStj5mj3QYtaq9lGEZK4VjwYz3E=;
        b=YldzLUDb7hPXtQhfnskM7PU3WXBqHtcV8A/fNIXrXTjE13lK9nzCDcIbqaPMIVqTLj
         bDMPAkZqZuqMOqhPyqI5QBB7cnJZtxYtPMdONG35eAWMtjaNoHbi7sS+5t6JPCnw2ofy
         hlH0mw5wO5R0GOlRSIYWwTtqpQb8Xv4IUWNtH+CSYC7170pHrGVXB2MzR0xMmAQv6iYv
         3FCh5ZF3FUkuGMdU8tpuJa5rVtCqclbYZ7s04ia0pt/iwKhGI6GEpLsPklymhzKrH9al
         vnscLoPkgeSJf9UMMfA8d/CoWuiY5ufqaTv2GfJjrKlefntsVKwtWLA4Y3JJgwGOFEZW
         sQ/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id o10si37112812wma.103.2019.07.24.00.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 00:05:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 715E168B20; Wed, 24 Jul 2019 09:05:54 +0200 (CEST)
Date: Wed, 24 Jul 2019 09:05:53 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190724070553.GA2523@lst.de>
References: <20190723210506.25127-1-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723210506.25127-1-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

One comment on a related cleanup:

>  	list_for_each_entry(mirror, &hmm->mirrors, list) {
>  		int rc;
>  
> -		rc = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
> +		rc = mirror->ops->sync_cpu_device_pagetables(mirror, nrange);
>  		if (rc) {
> -			if (WARN_ON(update.blockable || rc != -EAGAIN))
> +			if (WARN_ON(mmu_notifier_range_blockable(nrange) ||
> +			    rc != -EAGAIN))
>  				continue;
>  			ret = -EAGAIN;
>  			break;

This magic handling of error seems odd.  I think we should merge rc and
ret into one variable and just break out if any error happens instead
or claiming in the comments -EAGAIN is the only valid error and then
ignoring all others here.

