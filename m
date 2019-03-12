Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95ACEC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 04:35:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 505932087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 04:35:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="dPZiNMzA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 505932087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C63418E0004; Tue, 12 Mar 2019 00:35:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C133C8E0002; Tue, 12 Mar 2019 00:35:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B01CE8E0004; Tue, 12 Mar 2019 00:35:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 847C18E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 00:35:16 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n16so1162882qtp.14
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:35:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=4mqdNc8jzh5hJ0hdB0WUXyd0kgpmExzkooynOQeDpZQ=;
        b=gPUWqumwOrGMrUmPreVJsOTvOPoGRqPHrankrAmRH3nC4cHIICspDlsq2pqSHSMCIx
         JvX5lEKkYdujhi6KrtliD39xz3uCrGX3HD5aoy/4Nhh+flKbksum6NA8T6HMgOkWdyg1
         wLiY61HbHE10qHa0cN0JYAuLRfD61+mJW81fooaeZNeV+gqlWp6QKvOcB/kA3nrfJEvl
         8Igv+j5aTMD9vzQx7N2Kha69fnebOkK2ZmxBLHt5KPAvYwx+DBWOGLVbExLD/vAq2TNy
         BSDJuzC5kLtwqHoJa/znIgOF1EkjH0U2lryUNxQ7ljg8+eXAHN5Q7Bgo21ZkbCQuiSjX
         8UzA==
X-Gm-Message-State: APjAAAXktZdfzCAiq39YRbSBhOPOZYaQ8SmolIZg2ht0BPmnu5aOCz9o
	zGraxlZGbhlJkPVDJBXGX5siORm2pIWeMGxVQ3IhSIDRQzh0VPOaVjE1xIVGU8lxU0u08C25/Ro
	zNUIKwyfnQ+2ZirrVR2bD11yZcthAflAvfqzZmtUrO8aF1COX/cmc6VmkU6JHZPE=
X-Received: by 2002:a37:8301:: with SMTP id f1mr2081326qkd.215.1552365316257;
        Mon, 11 Mar 2019 21:35:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzbGMLi6lP0eOtmlS1ILhko5P/jKlDhFsQxVaHPKupT14Qxl41WPSxTGUjURM0QmF31WQ8
X-Received: by 2002:a37:8301:: with SMTP id f1mr2081304qkd.215.1552365315540;
        Mon, 11 Mar 2019 21:35:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552365315; cv=none;
        d=google.com; s=arc-20160816;
        b=edbFzFyuwmPoBbw2VGZIye5kJ2k7AtanMY7IyahCtpaSORy5+Wq8yUn0M5TkkcXoyr
         BTN5roZGS2fz33LsiSaCcw26vI+nqb1S4i6szF7WNDNF9n4afGqeeaLQdibtI5MuclQt
         0mEKC5H1GYvIKrGGEQfgsSPZBaGQaJ1ue9u/YELNJHm9VAzrfyKdYjwA6gmwLSMADjTO
         bOacNuDswwhLM/Z9x2fC+U7j4EmGm1UWMUe04sLyHtJGW+ZI/hqby1Aqu682Y/PC07V5
         FngAg+nSZMICtTNrhGHeJzrPFL4o87izTr82MCkyXYWGBpQfJW+CcMdHnlFRfnGsborq
         rUDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=4mqdNc8jzh5hJ0hdB0WUXyd0kgpmExzkooynOQeDpZQ=;
        b=MAJm0Y8DCOyW5sB3zD21rls+DrXHCN5gDeqv7OkTiDvGIt5r46Gs9iyQ/jg0q5ErV4
         qMrcQZTyBuXxi6oH40BDq6er6ftD6nh7cP6dKynGnnNJVd4kvfFtHz6wEHGfchiQjR2D
         p8IU37xzZapfrPLshWK3vgS3/1G/GEclcCPmhdJBNzXUeGHloUSZWl/NYobZZqjRhHyz
         WzGiBFoqffgqWMddm/4G16OrIoRQnO3JOsNjjJi/nhRBqUlscPgsiClAasjrK7/HFWKz
         LD3BEcxz2l1ue4Sf0NsJ8pwxK7+RwgK/xPrKTde/ZbmWLlJo0Sw/496a3hLpzHj3HDsX
         z23w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=dPZiNMzA;
       spf=pass (google.com: domain of 01000169702ee357-fe8b85e5-e601-41da-8ba2-25e8b7db52eb-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=01000169702ee357-fe8b85e5-e601-41da-8ba2-25e8b7db52eb-000000@amazonses.com
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id c28si4284141qkk.3.2019.03.11.21.35.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Mar 2019 21:35:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169702ee357-fe8b85e5-e601-41da-8ba2-25e8b7db52eb-000000@amazonses.com designates 54.240.9.46 as permitted sender) client-ip=54.240.9.46;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=dPZiNMzA;
       spf=pass (google.com: domain of 01000169702ee357-fe8b85e5-e601-41da-8ba2-25e8b7db52eb-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=01000169702ee357-fe8b85e5-e601-41da-8ba2-25e8b7db52eb-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1552365315;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=IbeuS+zdcBFTccbustqiwuLJ9wpMqCNVsFWBtNbKAts=;
	b=dPZiNMzAgEKy+d5R3GmABBmXu0+p3BIgveTRcb7Y/V7shB2pxnRd55Rqpq7Yz/RQ
	7+pnOikBn+Tz2XvX+HJq2s3moWzsIlT6WXoDzB+cHCSn8yPHAMbQ+c+XWdpOzK9LIjj
	1sdDXaJUK9OT5kVjMh14wrdnAv2+iM2QHZ5z4Jjw=
Date: Tue, 12 Mar 2019 04:35:15 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Roman Gushchin <guro@fb.com>
cc: "Tobin C. Harding" <tobin@kernel.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@cs.helsinki.fi>, 
    Matthew Wilcox <willy@infradead.org>, Tycho Andersen <tycho@tycho.ws>, 
    "linux-mm@kvack.org" <linux-mm@kvack.org>, 
    "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC 02/15] slub: Add isolate() and migrate() methods
In-Reply-To: <20190311215106.GA7915@tower.DHCP.thefacebook.com>
Message-ID: <01000169702ee357-fe8b85e5-e601-41da-8ba2-25e8b7db52eb-000000@email.amazonses.com>
References: <20190308041426.16654-1-tobin@kernel.org> <20190308041426.16654-3-tobin@kernel.org> <20190311215106.GA7915@tower.DHCP.thefacebook.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.12-54.240.9.46
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Mar 2019, Roman Gushchin wrote:

> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -4325,6 +4325,34 @@ int __kmem_cache_create(struct kmem_cache *s, slab_flags_t flags)
> >  	return err;
> >  }
> >
> > +void kmem_cache_setup_mobility(struct kmem_cache *s,
> > +			       kmem_cache_isolate_func isolate,
> > +			       kmem_cache_migrate_func migrate)
> > +{
>
> I wonder if it's better to adapt kmem_cache_create() to take two additional
> argument? I suspect mobility is not a dynamic option, so it can be
> set on kmem_cache creation.

One other idea that prior versions of this patchset used was to change
kmem_cache_create() so that the ctor parameter becomes an ops vector.

However, in order to reduce the size of the patchset I dropped that. It
could be easily moved back to the way it was before.

> > +	/*
> > +	 * Sadly serialization requirements currently mean that we have
> > +	 * to disable fast cmpxchg based processing.
> > +	 */
>
> Can you, please, elaborate a bit more here?

cmpxchg based processing does not lock the struct page. SMO requires to
ensure that all changes on a slab page can be stopped. The page->lock will
accomplish that. I think we could avoid dealing with actually locking the
page with some more work.

