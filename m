Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 235B9C468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 21:41:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE73E2083D
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 21:41:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE73E2083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 816766B0270; Fri,  7 Jun 2019 17:41:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C5EA6B0271; Fri,  7 Jun 2019 17:41:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B5C86B0272; Fri,  7 Jun 2019 17:41:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 17ACD6B0270
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 17:41:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i3so5043624edr.12
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 14:41:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OVtIURD1TiJyiciouFgxnPzvqEltpMSaTRKbY9x6PTc=;
        b=Syv3MgOaE9B03LghyH07E0qXQp2fJcw2Ec3j0TcXI7x/3Bzj3bBXK6LPxvId9Ft5m+
         DMH+HQwCoDUXNfCUGoX3iR0NOfrE+ZEFw7rjp8nBJLXvdlsHykHaP/R0XTq5ytjhhGhm
         t4kn6lkLj7zm67LT1F8kJ+JTOMdhbnK0Vy9W8eor/A+VFxAoIYPTdo9pMT8jJuSBkLf0
         7sW7//KW50o9L9U7NjR7Bqmzr97ADUzte3fbjiHaX57x+ZceWHRyT4KojWg4DvL6nRu6
         6OFVRcDccB1l7wADy097oaow/wQsVJJNV82Uaw8GIK6pztnzXceCC7AO9mo7Y68XDk9+
         hltA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVI4liTaLskne6jEqWtv4RaCfiV+1NQu4cRerLjU9YEev3/CTr8
	D8pc/eo0PidDYXpQEui5MHbHga+qiVyi/kbdqrGYLEYFgkQkM6HN7DZgfJvUG8dhlYDyWq8kql/
	Uw1a9l8hozUwi+xvEQ+Fxq1UEVkNRnptTcdHcEobUbY+lJI64atKVTPrwe+oJIn+wbQ==
X-Received: by 2002:a17:906:5284:: with SMTP id c4mr9001631ejm.184.1559943690669;
        Fri, 07 Jun 2019 14:41:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjgHvgd3rm50TvkHwtSRKWylNVSDWltR6E8FJhMG0PNpO1PMJZltBX3mZa9YgCcPJt25n3
X-Received: by 2002:a17:906:5284:: with SMTP id c4mr9001600ejm.184.1559943689942;
        Fri, 07 Jun 2019 14:41:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559943689; cv=none;
        d=google.com; s=arc-20160816;
        b=p3PktKTa00aGP0JCSLfbOvwBF7UxigdCTL9227P1XE0Mz8GrV2XgDzB4qX1O2fGROJ
         zDhiyRDn8spZwvXSboZN8On1GTHGdHmF3D7pYQSoPfwzDgBf3Q75RkoLaX66UTMBT5DY
         IlM9Td9awLJFJAGoINYqQSu3wx63G5Pt37GHeBwBf1uqK2zshpDm8iCaTTVdLb/DCEo6
         zfkpwCbxV5nFd5sAojd2+yPP4xEgb4PaBOI+A9ACvsOcOop9xi+oQlgg7GAxgy0Epham
         +BgJSL009bmMeVJp4VkFfoI8vUH4aEp37ySbYVZXQNww/CHwuVx04sAEqn50sAHZJOwQ
         NTnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=OVtIURD1TiJyiciouFgxnPzvqEltpMSaTRKbY9x6PTc=;
        b=gHDCsx9Ro15NhOfeBUxfABlaN3e1ZtZ/Lhn4SMyQYFs8w29joF7D8ydFeF7hr0jgSg
         56l8D4gYPXRKtxFO2vqrKWIgVXXwInWR66dmerjg59gKoWaQDMn2h/a0A7q0Zy0S6i+M
         8dkB8Jj2y9yR3BRypt4PWuqJgmM0osMFCNuQEb3wcgc0ewgC3IhSWwjD64VgL8TISqKZ
         nSdw4vfiiIMqcjst0UYDdYZGLztwroj/nW1h10cy1pyM06jpyxCvCLsy+pWdrvQaMGlz
         4X9Ednuo7lIeoB4uAU7xMKlRk75zRLY9EslouGUnRrWYaNoWNEN4/Q9OUgETU1jz+mBy
         By5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10si1392972edb.74.2019.06.07.14.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 14:41:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 56294ABE9;
	Fri,  7 Jun 2019 21:41:29 +0000 (UTC)
Message-ID: <1559943687.3141.8.camel@suse.de>
Subject: Re: [PATCH v9 08/12] mm/sparsemem: Support sub-section hotplug
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko
 <mhocko@suse.com>,  Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe
 <logang@deltatee.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Linux MM
 <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Fri, 07 Jun 2019 23:41:27 +0200
In-Reply-To: <CAPcyv4hgmjUvA0+uMWYJibmgSWtoLw7zM-jFuP7eRdU2xyVxOw@mail.gmail.com>
References: 
	<155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <155977192280.2443951.13941265207662462739.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <20190607083351.GA5342@linux>
	 <CAPcyv4hgmjUvA0+uMWYJibmgSWtoLw7zM-jFuP7eRdU2xyVxOw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 08:38 -0700, Dan Williams wrote:
> I don't know, but I can't imagine it would because it's much easier
> to
> do mem_map relative translations by simple PAGE_OFFSET arithmetic.

Yeah, I guess so.

> No worries, its a valid question. The bitmap dance is still valid it
> will just happen on section boundaries instead of subsection. If
> anything breaks that's beneficial additional testing that we got from
> the SPARSEMEM sub-case for the SPARSEMEM_VMEMMAP superset-case.
> That's
> the gain for keeping them unified, what's the practical gain from
> hiding this bit manipulation from the SPARSEMEM case?

It is just that I thought that we might benefit from not doing extra
work if not needed (bitmap dance) in SPARSEMEM case.
But given that 1) hot-add/hot-remove paths are not hot paths, it does
not really matter 2) and that having all cases unified in one function
make sense too, spreading the work in more functions might be sub-
optimal.
I guess I could justfiy it in case both activate/deactive functions
would look convulated, but it is not the case here.

I just took another look to check that I did not miss anything.
It looks quite nice and compact IMO:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

