Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2A21C76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 04:22:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7138A208C0
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 04:22:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7138A208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1C556B0006; Wed, 17 Jul 2019 00:22:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECE586B0008; Wed, 17 Jul 2019 00:22:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE3248E0001; Wed, 17 Jul 2019 00:22:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 942436B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 00:22:36 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id h8so11513668wrb.11
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 21:22:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8jmZySa/x1ljWQ8ESLAWCccSfpJweuM8dsExuQm64fo=;
        b=ge/1KveTQZvW9g8zRu5LQM9tBDoStc2C4R1nvnNE1MU4LPjJOTPIKHuHSOtcFU17gY
         59zynvbgPBvMKcLAG0wzCE8eyCeHkRh0lBWmBRn++72xSlLJbS0BwAf4kiqcnjfI/Ls1
         1FOhcfrjyZAft4TmHeqPZd2Zs2jCqt8kDsIOyF9qT2cuSSqEDXtMYRn7E5MH4dzD5PDr
         tHe1wEQv7MsQsgfXwVqcsXtihJrmsNJdhmlLtPznnqA8pYwO2Ic7iRwY2ixgHUXtDDej
         dDcDRPeh0vJk9rwpim01vALDG4b8azHXLG7wtBHFe5kx+c/k+isl1uFwbSoHrIkHtbkQ
         GBiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVIEWG9dYnB8RAypkmg5Xm1UWlJtnd0h8GKov7zo5xQaqpJwYry
	0YXdHKKyqwY47jTpnSld41IXRlvxBOhMF6Cupf5zGHASUt5/lVZho/r9hwV2tptUOiDUmptBmlT
	baJXA5HUx6/h6Qf5C0A4LHNsQ6ymjZDPMP/Pk2BOuWwWOKsmtUj6dvR0WJznb6VQyoQ==
X-Received: by 2002:a1c:f415:: with SMTP id z21mr34874678wma.34.1563337356052;
        Tue, 16 Jul 2019 21:22:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrTGfbiCl3+r3qwSKjWrZcMsf9dlaaEfdCb9jg+Qe3KWiJcBoY1uJbyH4V9WDBOv3ce+nK
X-Received: by 2002:a1c:f415:: with SMTP id z21mr34874584wma.34.1563337355161;
        Tue, 16 Jul 2019 21:22:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563337355; cv=none;
        d=google.com; s=arc-20160816;
        b=f1zJUgtzAlHyXK87n0PTCOzghKqBvkyG4CaW9xtr9kOCmh+F+HBu1g+LAmoafETnLz
         d/OSQRrQdBCC02xznRU4pblwS9qc4qbH0lMdWYQB6ifHF4E91dMayFXX1Q+NVm3hehvq
         aRvvhVua5zKOZQrMe/T4gYcxN77ih12IRCfmsqKPPDbQ4dzS5x9utovadwxgnpYv2tES
         BzobHwItmDXXpcMRLGL/89khVOf12yWlxLVpyX/HgAEjsMM2UKIuT0pwWZ/RiolmbJfm
         BGhK0oa0G/mtPLVmQqAJyZPv6OeZYDfCaITdOIYy4KsQBtZp+LtpspUILBtkeIrmqH2j
         jzFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8jmZySa/x1ljWQ8ESLAWCccSfpJweuM8dsExuQm64fo=;
        b=oHNGlCu1+d6G3jUZOA2vZmEQr464CLLsfE1MqT8RnLUVbvdyS3SaV0PHThvtyaCnKi
         1oj2D+hGpedheJTcndp1eqQXBFm/+m8bpCmKQe/gOI2yjkPmcc9UUcFyWFoIWDmiCmml
         6Xmc1DvfPH6rOXA5jFj/IPzZIFc4Vy4M9i2XeUqr1t66hcmEYnGxY7o2EiGZpzo7qolW
         9g0xVXHEql8+ctsviVmKuAN3r22E0Ck2TU/hWhzq+jSmZX1iijNKNSLan6S8NELeffyT
         KUpYu4kqGVhz99wrzJFVuMEu+qQsBFb4mEtZ6tDJK3+dOSKEmUnJ4I3rf0L2wP326cUK
         sBAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 15si19013820wmg.163.2019.07.16.21.22.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 21:22:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 6DB4E68B05; Wed, 17 Jul 2019 06:22:33 +0200 (CEST)
Date: Wed, 17 Jul 2019 06:22:33 +0200
From: Christoph Hellwig <hch@lst.de>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, willy@infradead.org,
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Pekka Enberg <penberg@kernel.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: document zone device struct page reserved
 fields
Message-ID: <20190717042233.GA4529@lst.de>
References: <20190717001446.12351-1-rcampbell@nvidia.com> <20190717001446.12351-2-rcampbell@nvidia.com> <26a47482-c736-22c4-c21b-eb5f82186363@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <26a47482-c736-22c4-c21b-eb5f82186363@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 06:20:23PM -0700, John Hubbard wrote:
> > -			unsigned long _zd_pad_1;	/* uses mapping */
> > +			/*
> > +			 * The following fields are used to hold the source
> > +			 * page anonymous mapping information while it is
> > +			 * migrated to device memory. See migrate_page().
> > +			 */
> > +			unsigned long _zd_pad_1;	/* aliases mapping */
> > +			unsigned long _zd_pad_2;	/* aliases index */
> > +			unsigned long _zd_pad_3;	/* aliases private */
> 
> Actually, I do think this helps. It's hard to document these fields, and
> the ZONE_DEVICE pages have a really complicated situation during migration
> to a device. 
> 
> Additionally, I'm not sure, but should we go even further, and do this on the 
> other side of the alias:

The _zd_pad_* field obviously are NOT used anywhere in the source tree.
So these comments are very misleading.  If we still keep
using ->mapping, ->index and ->private we really should clean up the
definition of struct page to make that obvious instead of trying to
doctor around it using comments.

