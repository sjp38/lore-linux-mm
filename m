Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E68EC3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:51:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14523205F4
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:51:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14523205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B41506B0005; Fri, 16 Aug 2019 02:51:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF1C76B0006; Fri, 16 Aug 2019 02:51:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A08496B0007; Fri, 16 Aug 2019 02:51:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id 827266B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:51:45 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2FCEB81DA
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:51:45 +0000 (UTC)
X-FDA: 75827370570.15.beds92_2c5af63b4553b
X-HE-Tag: beds92_2c5af63b4553b
X-Filterd-Recvd-Size: 1409
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:51:44 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 4F8CD68AFE; Fri, 16 Aug 2019 08:51:41 +0200 (CEST)
Date: Fri, 16 Aug 2019 08:51:41 +0200
From: Christoph Hellwig <hch@lst.de>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: turn hmm migrate_vma upside down v3
Message-ID: <20190816065141.GA6996@lst.de>
References: <20190814075928.23766-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814075928.23766-1-hch@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Jason,

are you going to look into picking this up?  Unfortunately there is
a hole pile in this area still pending, including the kvmppc secure
memory driver from Bharata that depends on the work.

mm folks:  migrate.c is mostly a classic MM file except for the hmm
additions.  Do you want to also look over this or just let it pass?

