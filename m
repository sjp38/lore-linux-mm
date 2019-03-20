Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45575C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:53:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAD2720835
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:53:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JOGPfuVp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAD2720835
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 898706B0003; Tue, 19 Mar 2019 20:53:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8485A6B0006; Tue, 19 Mar 2019 20:53:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75F726B0007; Tue, 19 Mar 2019 20:53:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 346116B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:53:54 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h15so858867pgi.19
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:53:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=dpCddqCmlhGyWyhS7C7r0+CGxfO81qERzU0CKME3BPQ=;
        b=c9ZyS6KRquAo6GsM3SKiYqUlliQeYdZbtGXNhZww12pVoCpPUgkgMHhRIAU1QgjAIV
         iOcD9FSs2wJdgO5HMEEPy2fffaq12cdlYerP94SUNUb+l6O8drp1SO5GfdYtLwpSeGVT
         xSeZQRO2ULjllHOhPPZT3uIi0TX2rnuWdYy2nKLp36sO0yDYqaVBMrmGGVZAvIKR7Ixt
         TC1Plki1X9bAJxHzOazCBXAZiAzPCyWysIoxp97xuhTWXRyVxC/mYPYmYC69LjZXnRzw
         fJKPZ+a+BhdK0o2q1YMIZRoYlviexprSzawj3RJzp3faXQt8m3LkFUDLjAPjuU9mrvB2
         H+nw==
X-Gm-Message-State: APjAAAVoubGqmMj1D2+znll/eK2cEPK6gApjpIKLJ52wGktWJcAdpsD6
	8M8YX56qLZv2grJCpe8OTPkkEJWsfU7Dg1Sw6mvtIEoyIZS5Yf0dLG5piF5ZRBAqH5tuC0+xzzL
	PT+KqHMNJUBVnaT7YaUT9ksg0h7FxB6UK3YnPmmxEtuODpRowBiz8+f0371xfivyXdQ==
X-Received: by 2002:a63:618d:: with SMTP id v135mr4615804pgb.2.1553043233869;
        Tue, 19 Mar 2019 17:53:53 -0700 (PDT)
X-Received: by 2002:a63:618d:: with SMTP id v135mr4615765pgb.2.1553043233022;
        Tue, 19 Mar 2019 17:53:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553043233; cv=none;
        d=google.com; s=arc-20160816;
        b=HKNvOIz1QKDp+GW99xy0d/09E0VvRywmhzYVCrcShain2/wNszLCqYNrDdlhwwIQxJ
         /9nc776FQcA/qgSvOeEBaB5vYhsHY3nZ+4yGCTda8YC1+5Wlw/6jq7021oNE6kTFbTe8
         wV8L7SYjTERilxsRAoCV4+5EfZzP2sl3Ta++2uMsMmUAxAYAMjv4hHH9hgMkPeaakVne
         SzUpXQM/UuHyLoHTB8dOG2xjV6/eIVGknfiLYjDRhZgGtqHWWkM1isQvEZJqJuw3uzjp
         HzfBZiCVTzuoGVd++H9OIxsE5oCoQIy6dYCh0AqbdXqA+mO8rUWAUJ9HoP6u9iRpuD4F
         rjOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=dpCddqCmlhGyWyhS7C7r0+CGxfO81qERzU0CKME3BPQ=;
        b=AaN4Ri/8cTmXb+w6777FlM9e82uHl3OTqf+MAJb3uNdX7Y3Aes7xhaAOKW9c7XNKJ/
         JyrRS322KLIzOBv+JwuNQwrzgUFVBWi2oZNAcxX4yJXFDplfdDVfKg39+d3I293i+OGP
         FJHDQM6FJoY62P/dVrIqnCCwY7Q4uTx4RN9+NSEu6wTgyjuTQ+5IG5wABRsH+3ZKMzKD
         DLpMDNhH2IBsz6V9s28WPS0MRb+ED1V/moBZCChmekHrkeiNWGH2DrSeJygVPbUWtZ4d
         ll+5NC9byW+iCQEZyz1cH+Q6aQUYscemF5Jd5yn7DONWGWu6aZh+Qmg5REXpMVTw8wQG
         ZJgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JOGPfuVp;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d14sor423494pgg.50.2019.03.19.17.53.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 17:53:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JOGPfuVp;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=dpCddqCmlhGyWyhS7C7r0+CGxfO81qERzU0CKME3BPQ=;
        b=JOGPfuVp00PibJiY1lX80qZBVdsO5epnmcGnA4moddPxIant5w0zqj+2ybWCeSXZJ6
         0jCUUUZi3eW295+Sh5BtwmBYtxZ8as2yWJ1lkSvD0V3FIbVGUGdUrmSjsbBioGRy0SwT
         a6/EuOxh+DliX9Tz6xEanzUqCSWW7m3i9fUPPukpY/7muVzgmv6BgnLjRc6WRx+ZVNVu
         5Q9Su7CxEkc2/o/UE8OBtbyS5pL0hkBNHWmIRuiVmKFJd+gJGHZ6Za0G/O91bmw5R6TB
         Hn6dGyy6zJ76TZOcvfzWJ/3x+kcF43IgpGFCCVrJI7LZneZuaWvgCS4EJjgCpeSIhYcA
         CJjg==
X-Google-Smtp-Source: APXvYqzmJ7dvx65HjZAxLlw7ltFKPcvUh2AmbHzeB3QMbmXSc2V8s1/umdgGWpPJmU3/OFGevH9fwA==
X-Received: by 2002:a63:e002:: with SMTP id e2mr5015037pgh.300.1553043232442;
        Tue, 19 Mar 2019 17:53:52 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id i126sm316612pfc.101.2019.03.19.17.53.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 17:53:51 -0700 (PDT)
Date: Tue, 19 Mar 2019 17:53:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Christopher Lameter <cl@linux.com>
cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, 
    Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>, 
    Matthew Wilcox <willy@infradead.org>, 
    "Darrick J . Wong" <darrick.wong@oracle.com>, 
    Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@kernel.org>, 
    linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, 
    linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Subject: Re: [RFC 0/2] guarantee natural alignment for kmalloc()
In-Reply-To: <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.21.1903191751560.18028@chino.kir.corp.google.com>
References: <20190319211108.15495-1-vbabka@suse.cz> <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Mar 2019, Christopher Lameter wrote:

> > The recent thread [1] inspired me to look into guaranteeing alignment for
> > kmalloc() for power-of-two sizes. Turns out it's not difficult and in most
> > configuration nothing really changes as it happens implicitly. More details in
> > the first patch. If we agree we want to do this, I will see where to update
> > documentation and perhaps if there are any workarounds in the tree that can be
> > converted to plain kmalloc() afterwards.
> 
> This means that the alignments are no longer uniform for all kmalloc
> caches and we get back to code making all sorts of assumptions about
> kmalloc alignments.
> 
> Currently all kmalloc objects are aligned to KMALLOC_MIN_ALIGN. That will
> no longer be the case and alignments will become inconsistent.
> 
> I think its valuable that alignment requirements need to be explicitly
> requested.
> 
> Lets add an array of power of two aligned kmalloc caches if that is really
> necessary. Add some GFP_XXX flag to kmalloc to make it ^2 aligned maybe?
> 

No objection, but I think the GFP flags should remain what they are for: 
to Get Free Pages.  If we are to add additional flags to specify 
characteristics of slab objects, can we add a kmalloc_flags() variant that 
will take a new set of flags?  SLAB_OBJ_ALIGN_POW2?

