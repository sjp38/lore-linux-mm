Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7BE6C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 11:56:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59D8820665
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 11:56:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="F0D/nOEk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59D8820665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6A996B0003; Wed, 19 Jun 2019 07:56:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1B4A8E0002; Wed, 19 Jun 2019 07:56:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D099D8E0001; Wed, 19 Jun 2019 07:56:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF2AF6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 07:56:34 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 5so15296148qki.2
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:56:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=aIyKDOmF25sa+ptAgfuszqALqlc+ol795zmgMWT7ReM=;
        b=d6yOubwjSqwVme7el7aXWn7rvJgIaDhVtwDlDh6XpoqJXO4os8X1csyfCUzQSUQmRI
         PylbcsUB52bxm2GbABMfjEH4iF6wkq3dMEWBC0LBdNpUf5zmti/liLJiNgcvJ3u1u26c
         +NcGi7g5eFtFvoY3rumDatiZgpp4FGC/+k+YBQCxPwWmhpix1fZzf8F4DpCd62ZO9SFq
         RN9mj60cgM0xTEebwctewyjUvhEegCOhk8gX5uYTaUOmikA3MjJH4uJlt5ZFMo33BOnl
         Hw4Neoe568ty4bvhvO0jaZAXULItqL36m3Q0JM1iAWOTUeSBOvDKtvP7I2Gd89H8frm0
         5UOA==
X-Gm-Message-State: APjAAAWFuDR68tX/WCU0x2CbSghj76j8DE7lEORpH4Lc3AA/gHbuuOqx
	LX6Wpw3CZ51mp4CxNJhOPN026Hl4MM8Hvo7aoBDLUQRb8b64t3KLw7U7KjCKwtkVZIuyrERjSWd
	keFH/A2MrMshTHNPlM6UmRcSlIbft4upVZGucQDhT2N+XZb5t/7GxmBIHy07RL5qssw==
X-Received: by 2002:a37:9042:: with SMTP id s63mr19833598qkd.344.1560945394465;
        Wed, 19 Jun 2019 04:56:34 -0700 (PDT)
X-Received: by 2002:a37:9042:: with SMTP id s63mr19833566qkd.344.1560945393933;
        Wed, 19 Jun 2019 04:56:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560945393; cv=none;
        d=google.com; s=arc-20160816;
        b=RESwv2SW9VDz0ngLQbE1S60nY7swBsIBTYqnhIfoFDvdbBZjPYsPQBuXarg4/o6+BO
         UeI9ixRGKjcGAGmK6BFZaYrhbRco7PTfrZIQanwMpS8KllQde99LqYTUtpVWASk2cbvR
         6wL9sreNgtLHRYQVUcAgIrJGYNePCnfAz9RAJrmcLVAIcsuVxRzpe4Oyg1X4P2OK1Hey
         P3R5OMEFkfj1+yNsguS5swOqrATHR8WDhbTUg49juYKtoxGnNFJKxtlrYgbxrwR5BPn5
         f5y6KOi+zzCP93D5CFgKmrfithHSUf3G68N0tRnWA7kGixAmSmkIMERbao/cUB/4g5ZR
         oyuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=aIyKDOmF25sa+ptAgfuszqALqlc+ol795zmgMWT7ReM=;
        b=0iAjhBbhUrvU/MhnUiOSADxOH8GlPkaQeY9rh4NzvZu/Rz9+zzpERih0rfEOkNY43v
         ESumi2SYxo8e5J5kzwsCNBDlw3yWoMksM+m848recYYD5URqtCTuutRj+ba9zbIIhrol
         /HcUZLmKwRPc344q0qqtRfiaxp4ADMRvaQvNkdCtBjJUz1AEBA77iTUxBgir3ZWvf2Et
         XjfJMwEnNHAhYSpnXwIKlJ78PFRUl4WqPgH+MVWSzDEp1Y1MKx6dCn33UiTOBwYIEPyr
         bansAv6J5An7dB5XJhnQ4GY6ZUBJI15ksx+kmlCuVuv8cJVblCxe2+Zgq7/hm70yyZBW
         mE0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="F0D/nOEk";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d45sor15331778qvh.62.2019.06.19.04.56.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 04:56:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="F0D/nOEk";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=aIyKDOmF25sa+ptAgfuszqALqlc+ol795zmgMWT7ReM=;
        b=F0D/nOEkUs6Sluf5qwUaaXatuIYH0Kewqi3at+sT1omrKjsK7hh+55S+3yOdioLu1y
         kLGplu7LdHjOqetDdcDArMO8rhcNYAfEC/4iDVbECenXZ5rzvImGFgzIxrQjlhLK48Dk
         Vwdy+2avjCBUG0WPpNFolYWtgh+/PrpsKjDYVMgY2c77acE7Xu5xm12glEcYkQccFa1c
         hr+8jfUyWiTURljXzSjxKWQ1CLPDzxvW2Mom/x30FY9VzZ4ngqplYyBIbo9oWyebHM97
         63QODAfcqMfegCTl8X2RAUhqEqzx3k46c6At4QLG8O2Fselsf1BVT4/rkjea8tqv0zhT
         O0ig==
X-Google-Smtp-Source: APXvYqx83INLY1tOphLQBSuL2n2XC0sWDzdU9zK76pUp/d8/new7r9oZpKe73QludbDlywxZpabUmQ==
X-Received: by 2002:a0c:b148:: with SMTP id r8mr32123100qvc.240.1560945393639;
        Wed, 19 Jun 2019 04:56:33 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id c184sm9739470qkf.82.2019.06.19.04.56.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 04:56:33 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hdZCa-000393-Fg; Wed, 19 Jun 2019 08:56:32 -0300
Date: Wed, 19 Jun 2019 08:56:32 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	Ben Skeggs <bskeggs@redhat.com>,
	"Yang, Philip" <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 11/12] mm/hmm: Remove confusing comment and logic
 from hmm_release
Message-ID: <20190619115632.GC9360@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-12-jgg@ziepe.ca>
 <20190615142106.GK17724@infradead.org>
 <20190618004509.GE30762@ziepe.ca>
 <20190618053733.GA25048@infradead.org>
 <be4f8573-6284-04a6-7862-23bb357bfe3c@amd.com>
 <20190619080705.GA5164@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619080705.GA5164@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 01:07:05AM -0700, Christoph Hellwig wrote:
> On Wed, Jun 19, 2019 at 12:53:55AM +0000, Kuehling, Felix wrote:
> > This code is derived from our old MMU notifier code. Before HMM we used 
> > to register a single MMU notifier per mm_struct and look up virtual 
> > address ranges that had been registered for mirroring via driver API 
> > calls. The idea was to reuse a single MMU notifier for the life time of 
> > the process. It would remain registered until we got a notifier_release.
> > 
> > hmm_mirror took the place of that when we converted the code to HMM.
> > 
> > I suppose we could destroy the mirror earlier, when we have no more 
> > registered virtual address ranges, and create a new one if needed later.
> 
> I didn't write the code, but if you look at hmm_mirror it already is
> a multiplexer over the mmu notifier, and the intent clearly seems that
> you register one per range that you want to mirror, and not multiplex
> it once again.  In other words - I think each amdgpu_mn_node should
> probably have its own hmm_mirror.  And while the amdgpu_mn_node objects
> are currently stored in an interval tree it seems like they are only
> linearly iterated anyway, so a list actually seems pretty suitable.  If
> not we need to improve the core data structures instead of working
> around them.

This looks a lot like the ODP code (amdgpu_mn_node == ib_umem_odp)

The interval tree is to quickly find the driver object(s) that have
the virtual pages during invalidation:

static int amdgpu_mn_sync_pagetables_gfx(struct hmm_mirror *mirror,
                        const struct hmm_update *update)
{
        it = interval_tree_iter_first(&amn->objects, start, end);
        while (it) {
                [..]
                amdgpu_mn_invalidate_node(node, start, end);

And following the ODP model there should be a single hmm_mirror per-mm
(user can fork and stuff, this is something I want to have core code
help with). 

The hmm_mirror can either exist so long as objects exist, or it can
exist until the chardev is closed - but never longer than the
chardev's lifetime.

Maybe we should be considering providing a mmu notifier & interval
tree & lock abstraction since ODP & AMD are very similar here..

Jason

