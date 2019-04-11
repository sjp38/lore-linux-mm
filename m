Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86A4EC10F11
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 02:33:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48BD7217D4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 02:33:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48BD7217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C84A66B0266; Wed, 10 Apr 2019 22:33:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C35FD6B0269; Wed, 10 Apr 2019 22:33:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFE596B026A; Wed, 10 Apr 2019 22:33:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6228A6B0266
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 22:33:57 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id x18so2784916wmj.5
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 19:33:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=CPhlCb1xiC+aF9i/+wHcC5N2VlUxpHJ03lW18xSoMSI=;
        b=F6lYr9xTi6m2LwxS45JJq9QaA1cbd0d7lh0MhBDpAb03Mln52ReCuXUlCvus7HjCvF
         UWizvbdEEOmkJTwXtt3vsMb9wlmYwM0RrsbVmmY8CgOMHWCq509Q94G89HJnhAo/7Ezq
         AKjgPDMgGGoANizNwPOdib3ZDLEQSpsNJ6+SaCsFn5S2FuYmZCUXSnZKE33SlDiUXvBF
         MWhu5cn5gGIuTB5U4wKtqulxNI9roptlsFmrPtl5FnldEmEftupI7TQ9XdRMIlKmAKBD
         Iiewh/KvdBm+xAChS71nMINh4qVfT+Ek/7s637smDq5jd6xeXoxTEPKrbnEycvuXXmkw
         w5+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAVY0p+n7rA7DoI+SsbUhSBzQvlROTQXhtfaGJlWJZEBD1CTQffz
	IJ81sqoX7Yx1vduE975GJ+GbO5iLH24zJ+fxV+2VWdeta2dwLBSLY3MlYyuYARhfsll+WYHMKAs
	cDdc5kAfG6wunlAlqLVn8Z8MvzmX9e6nv/+mTOvBVMS1Gs2f2UPyVlATI3xxQlDR3PA==
X-Received: by 2002:adf:ec11:: with SMTP id x17mr31483659wrn.120.1554950036847;
        Wed, 10 Apr 2019 19:33:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6XRvkzMyicRXvWBOnDO8QcdjzBmEsIC5vRg65OAoGIZs3/Qa9tp7LUwN9tEO2axKIrjjL
X-Received: by 2002:adf:ec11:: with SMTP id x17mr31483618wrn.120.1554950035884;
        Wed, 10 Apr 2019 19:33:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554950035; cv=none;
        d=google.com; s=arc-20160816;
        b=Rb5xFwWaxcYtSC4Zr2l3rneSRGLupJpcSmosXPgy0ZjoerSeZKR81EzTTPU/rkYJqU
         +EfWnvSJG+UMtuZrdA1X3wq5e8zbokgKzxjntC7F2H5/RweMoo34v8Wm4hl1oW/5umZY
         i5ghbx8DGqbghbinF6HeBAhZ0oXXrDJf0bP5cxG3DDrxg9/SLaAeTo5s9Dfht00OPW6i
         PoijL2U8iDjUQs74oUdwWzyMR8AEUczeMPnUE6Lk7/rGa19OqmARFefRzBB0peWmhk8a
         ttJ2Sfu6a95Rz/+OEZo24UZQ2WWgj8VK/28dEG2GmpY0bHV5NQzyrJGMLIrb0my6IGjo
         dbRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=CPhlCb1xiC+aF9i/+wHcC5N2VlUxpHJ03lW18xSoMSI=;
        b=Z44BMxhPVJIEGwcdanTwHoILVFkeKYsO8lrq7YKVIo7+68O1msy9Lbuxih54+sjTuZ
         +hkpadL45+2VqCftK637k/tXXs/ws+9xglqrJpaHsVVeoVqxHh2QoVLtWCppmW+GL9fG
         Vt2akQuBc2X/pvNw0Ac5iqsW6u6uw63ijQqm9sKFdL8XvHcdkzT5VL9sBKx4tW/9TDuD
         a53/64ZZKeD6VODLCxoheXVCrMC8ChPRicBkb90KuwTYCuQ1cKznikc/ll3hKk0OQJSs
         rif9buijgPzNuxCN2RFDIk0ti9gFKqBw79p4wNRL36QoHXl2U/iJz5m5S5lt3NPaEG4c
         MRMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id h13si2299296wmc.65.2019.04.10.19.33.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Apr 2019 19:33:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hEPWk-0002SB-Qp; Thu, 11 Apr 2019 02:33:22 +0000
Date: Thu, 11 Apr 2019 03:33:22 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>, Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v3 14/15] dcache: Implement partial shrink via Slab
 Movable Objects
Message-ID: <20190411023322.GD2217@ZenIV.linux.org.uk>
References: <20190411013441.5415-1-tobin@kernel.org>
 <20190411013441.5415-15-tobin@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411013441.5415-15-tobin@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 11:34:40AM +1000, Tobin C. Harding wrote:
> +/*
> + * d_isolate() - Dentry isolation callback function.
> + * @s: The dentry cache.
> + * @v: Vector of pointers to the objects to isolate.
> + * @nr: Number of objects in @v.
> + *
> + * The slab allocator is holding off frees. We can safely examine
> + * the object without the danger of it vanishing from under us.
> + */
> +static void *d_isolate(struct kmem_cache *s, void **v, int nr)
> +{
> +	struct dentry *dentry;
> +	int i;
> +
> +	for (i = 0; i < nr; i++) {
> +		dentry = v[i];
> +		__dget(dentry);
> +	}
> +
> +	return NULL;		/* No need for private data */
> +}

Huh?  This is compeletely wrong; what you need is collecting the ones
with zero refcount (and not on shrink lists) into a private list.
*NOT* bumping the refcounts at all.  And do it in your isolate thing.

> +static void d_partial_shrink(struct kmem_cache *s, void **v, int nr,
> +		      int node, void *_unused)
> +{
> +	struct dentry *dentry;
> +	LIST_HEAD(dispose);
> +	int i;
> +
> +	for (i = 0; i < nr; i++) {
> +		dentry = v[i];
> +		spin_lock(&dentry->d_lock);
> +		dentry->d_lockref.count--;
> +
> +		if (dentry->d_lockref.count > 0 ||
> +		    dentry->d_flags & DCACHE_SHRINK_LIST) {
> +			spin_unlock(&dentry->d_lock);
> +			continue;
> +		}
> +
> +		if (dentry->d_flags & DCACHE_LRU_LIST)
> +			d_lru_del(dentry);
> +
> +		d_shrink_add(dentry, &dispose);
> +
> +		spin_unlock(&dentry->d_lock);
> +	}

Basically, that loop (sans jerking the refcount up and down) should
get moved into d_isolate().
> +
> +	if (!list_empty(&dispose))
> +		shrink_dentry_list(&dispose);
> +}

... with this left in d_partial_shrink().  And you obviously need some way
to pass the list from the former to the latter...

