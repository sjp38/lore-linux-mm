Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7807C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:31:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45FFD2183F
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:31:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45FFD2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E34EB6B0003; Sat, 15 Jun 2019 10:31:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E13EA6B0005; Sat, 15 Jun 2019 10:31:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D49278E0001; Sat, 15 Jun 2019 10:31:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id A21906B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 10:31:13 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id q2so2335322wrr.18
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 07:31:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DfNBeJJdhL+bmO6pkJtJFod3r67ztQCuqB06blSagSk=;
        b=tyNEf9Dx1LFE6oDzydgng1aqq5gShnFfYrdx8Jf2u3I63oduxlGl+UIQ7LHnVy6ymf
         3JzE87YY/qQi7QZwiPFBUlB8EvGR9Ka5FOyY+Axs60hvqXS+7O9FxekOuCijBec20GVO
         7Yik9Y2i29Xbw3RJzxrQ6zH5k/9XWnNL4D7A/wSyVLrklyrCs49O6JlE8/g1QtzChWSo
         wwqE69XKsJrrosP+22+s6yfzm1aPjRK4n+L76oTfOwfvOMO6hf2/VAsKca7ctnhFKsFv
         6tG712yWAxnQG0de/IcaMRnyuMHPiovFxrYWStutSQJTIsaGXHk4+CcbC/yD3PnVFH49
         CBpw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAW32xDbvBvlPlDTM2E538HTwy5SvR3JnLSSQy38YEPxCrgpGeZu
	H4v28QIRrxpQxDS3t/GtRbpS1l51xuF8a9EGMQROCVuaHwlq4DA97H6RPwcoYHPFpwTfdwAVznI
	MquI6u/p2VEOn+bAZ7HRr0ol8b5wCP64uPozQkeNFtdxNbBDSZc1y4Dihgk7HO+DOWg==
X-Received: by 2002:adf:ba47:: with SMTP id t7mr12784199wrg.175.1560609073217;
        Sat, 15 Jun 2019 07:31:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRxYe93Uxz6R4gAFivqMFSOnOXwR0ZWsaeDQIsfp4N1tS1bAplUk6SYjDhN7pX5UvyZbeu
X-Received: by 2002:adf:ba47:: with SMTP id t7mr12784166wrg.175.1560609072598;
        Sat, 15 Jun 2019 07:31:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560609072; cv=none;
        d=google.com; s=arc-20160816;
        b=LXuBYwzT76kb8ZRdT8n+ewXF8WkGvYkcHDH/QAJudvrqumOtzpkUMGUZs4pcz4zpm5
         Mv8WGo9duxqYLgJTUOnXwkdH5gUgHb1ZyJYNHYZbtymnTumWOaudwj9ITMA1/R6UGEt3
         SkGl893AZLeQtKPZNlC3sB7n8dR3/XPTbtnVXPtzbAtDQfCDl3HFFfs1SEN0z+a+q15X
         kYAm9xccOWCclUpYDxTo4qDpw26NjXVVJ1JvRB/ou6YpBCRJUF2ESBUOVBrHEqFxpN5S
         vSRBlLT8UVpHILk78Fm+/Sl6bDOgqpGM8QlrAmuoRHKciANaPhPYsH92vpOal+UmHtOZ
         Mcww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DfNBeJJdhL+bmO6pkJtJFod3r67ztQCuqB06blSagSk=;
        b=ElVu2cKVZiArrYX3dMzRFslf8EvVcCjWLzYxilMjDkjdLIyy7w5zQbA4rHFIrvhvoU
         ONSml+VSndUwZwPF4TZGYeYJQ3LLU9gkuTT91kAlYQ3vK4PX3d1ea1dI87X1cxmZ9YkX
         9glvwrKjjcCZLrNR7TeLLcSfH57d2/rHv9b6oOac3WJ4IMc1GjI4zUUagQD6lWF9aTLO
         d6OTQxUnCVUYBkqvFZH6C2N8XhkxwdzFawSe+BPoqILw57gcket8dezcpFtqdj3ZM1dS
         5kTq952gxy1OMl9sIpzmVuywR9uGUgDgMp3kpD+uqpdlR4hZUXggRK8PnPlsVFucZ+sI
         EGCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t19si4106192wmh.149.2019.06.15.07.31.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 07:31:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 57B1468B02; Sat, 15 Jun 2019 16:30:44 +0200 (CEST)
Date: Sat, 15 Jun 2019 16:30:43 +0200
From: Christoph Hellwig <hch@lst.de>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 06/22] mm: factor out a devm_request_free_mem_region
 helper
Message-ID: <20190615143043.GA27825@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-7-hch@lst.de> <56c130b1-5ed9-7e75-41d9-c61e73874cb8@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56c130b1-5ed9-7e75-41d9-c61e73874cb8@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 07:21:54PM -0700, John Hubbard wrote:
> On 6/13/19 2:43 AM, Christoph Hellwig wrote:
> > Keep the physical address allocation that hmm_add_device does with the
> > rest of the resource code, and allow future reuse of it without the hmm
> > wrapper.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  include/linux/ioport.h |  2 ++
> >  kernel/resource.c      | 39 +++++++++++++++++++++++++++++++++++++++
> >  mm/hmm.c               | 33 ++++-----------------------------
> >  3 files changed, 45 insertions(+), 29 deletions(-)
> 
> Some trivial typos noted below, but this accurately moves the code
> into a helper routine, looks good.

Thanks for the typo spotting.  These two actually were copy and pasted
from the original hmm code, but I'll gladly fix them for the next
iteration.

