Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55CA1C282DC
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 16:52:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12042206B6
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 16:52:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12042206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A45A86B000C; Tue, 16 Apr 2019 12:52:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F2436B000D; Tue, 16 Apr 2019 12:52:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E14A6B000E; Tue, 16 Apr 2019 12:52:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBFD6B000C
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:52:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n25so1313459edd.5
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:52:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=qcQyrF0CKUvg8j3w1/E3L1zRT1Ucmr+al8/eDGYg3fo=;
        b=gxQjcvBaKOnX1IhbbEj8GHfFYo00AhRAODr84lcM+OUJhNCY/3x6cWd1zEf3TIvIJx
         ybJ+XAqjpJjtb+8HMWVpUVd34iJ+VNzqd9wtY6magZFqpHHkpTZqE8iJX37ETLBl1oVE
         qJTjIC8qhiCr0GG3uxAiWvhxer9RE9g1u4EjMIfKN7xeQ0ND4kOk/xy0yOGGfYCdceNQ
         Be1gw2z8ABxAx2/EK1biIPOVCKtrsk5iOMybgA8HqLnAJOt6vKLc/eTkPDHMohoR3mLV
         y90G9CH98mryNWzqia71vNLOPCaj04R9FoEy55DEDgjV92HxL6EBJenlOEjupipm8PIp
         MQow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXu1hh2sdQdqzNH/iKt9Fz5nfmqnV59rsRvhfJ+5cAoWUyX5PrO
	LnNljakCRtJvCjopSKze/wooTSwsn1FgNVMspAdKjyiVRz45DCDsBhIxp/+wjbpQ5vCjufXifO6
	1QYUInP0gCoZE1Z2mBOSFzG3jSJL5/6b7pC/rgk6SzLMIsyLZocqbjchr672r87Co6A==
X-Received: by 2002:a50:b18e:: with SMTP id m14mr17858475edd.209.1555433528794;
        Tue, 16 Apr 2019 09:52:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9ZuA+yoDO6ZUxnJ0NekjXGUhiFLxZpgQriGWZuFF4k+7Atgq0PSKuuZelr6GqtieWoonx
X-Received: by 2002:a50:b18e:: with SMTP id m14mr17858405edd.209.1555433527870;
        Tue, 16 Apr 2019 09:52:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555433527; cv=none;
        d=google.com; s=arc-20160816;
        b=bulGIyVIM9co0tn0RO9ZG90gDPx5ovLHpw3RCH9JwRU5ag3CH+uuvCseJCiRYlhBea
         j1x10PZcLcDYb/bkXoeHXJAn0o0w9GsUuyfuF1c3aZkzEg2fbgOJ1usLAiUY2J9S12Kf
         JdDkCQDRrDhLPlAvS6sUOF8LQgAnO+5wb1LKv4kf6l8J69b4PfASIPRnVzmJ78uCwjzo
         kQJL0HBh6VFablr5Jf+WNNSs3rS88sz8a0BXd9LF5V/yfuXFMThgdkDmS6sa1Kstnm0Z
         RQRa3ThR27NtEUXll3qLSTf8n+cOMPVBxjgvcKNJlpJ7fmoYhnmIEBgCCejZ3CjbhXwl
         Cstg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=qcQyrF0CKUvg8j3w1/E3L1zRT1Ucmr+al8/eDGYg3fo=;
        b=FFw/Qyn4RfDj9VAuRRIMbJjKvaB7j23NZeXBK2jYCJjKV8BMlIK0646cDcDbwgmSr4
         L7vI8eyOA6dvk693QKI9CZEV/dM59zaCsVBfFwdOmfawUNUGuEDsz9PTvcyAOeVfRLKx
         cma/FLeuVt7woBUD6FFdjqd50IbxtZamKB06x/DWEBnTM1cGU2egVL6II7gmDf6iPCZ+
         RtsqgpOwQY+5IrIyNVTN/R/eRhj6Eo1XnGAVSyBZYbekyc8BIDfA4qL3/xom0qEhVtU7
         eQW8RTEecGcDZBQe7F4KKM1RE9kESs3I0X86Ab8hzXtKDhyoEBs3n3iz40IdHI/yaeQE
         6IFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ck14si8605381ejb.191.2019.04.16.09.52.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 09:52:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3D821B077;
	Tue, 16 Apr 2019 16:52:07 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id D663A1E15B4; Tue, 16 Apr 2019 18:52:06 +0200 (CEST)
Date: Tue, 16 Apr 2019 18:52:06 +0200
From: Jan Kara <jack@suse.cz>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1 10/15] block: add gup flag to
 bio_add_page()/bio_add_pc_page()/__bio_add_page()
Message-ID: <20190416165206.GC17148@quack2.suse.cz>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <20190411210834.4105-11-jglisse@redhat.com>
 <20190415145952.GE13684@quack2.suse.cz>
 <20190416002203.GA3158@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416002203.GA3158@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 15-04-19 20:22:04, Jerome Glisse wrote:
> On Mon, Apr 15, 2019 at 04:59:52PM +0200, Jan Kara wrote:
> > Hi Jerome!
> > 
> > On Thu 11-04-19 17:08:29, jglisse@redhat.com wrote:
> > > From: Jérôme Glisse <jglisse@redhat.com>
> > > 
> > > We want to keep track of how we got a reference on page added to bio_vec
> > > ie wether the page was reference through GUP (get_user_page*) or not. So
> > > add a flag to bio_add_page()/bio_add_pc_page()/__bio_add_page() to that
> > > effect.
> > 
> > Thanks for writing this patch set! Looking through patches like this one,
> > I'm a bit concerned. With so many bio_add_page() callers it's difficult to
> > get things right and not regress in the future. I'm wondering whether the
> > things won't be less error-prone if we required that all page reference
> > from bio are gup-like (not necessarily taken by GUP, if creator of the bio
> > gets to struct page he needs via some other means (e.g. page cache lookup),
> > he could just use get_gup_pin() helper we'd provide).  After all, a page
> > reference in bio means that the page is pinned for the duration of IO and
> > can be DMAed to/from so it even makes some sense to track the reference
> > like that. Then bio_put() would just unconditionally do put_user_page() and
> > we won't have to propagate the information in the bio.
> > 
> > Do you think this would be workable and easier?
> 
> Thinking again on this, i can drop that patch and just add a new
> bio_add_page_from_gup() and then it would be much more obvious that
> only very few places need to use that new version and they are mostly
> obvious places. It is usualy GUP then right away add the pages to bio
> or bvec.

Yes, that's another option. Probably second preferred by me after my own
proposal ;)

> We can probably add documentation around GUP explaining that if you
> want to build a bio or bvec from GUP you must pay attention to which
> function you use.

Yes, although we both know how careful people are in reading
documentation...

> Also pages going in a bio are not necessarily written too, they can
> be use as source (writting to block) or as destination (reading from
> block). So having all of them with refcount bias as GUP would muddy
> the water somemore between pages we can no longer clean (ie GUPed)
> and those that are just being use in regular read or write operation.

Why would the difference matter here?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

