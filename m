Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29EFFC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:12:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAB7A2173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:12:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kowBbUHO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAB7A2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74E928E0004; Tue, 26 Feb 2019 07:12:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FEF98E0001; Tue, 26 Feb 2019 07:12:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6143D8E0004; Tue, 26 Feb 2019 07:12:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21B5E8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:12:22 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f10so9460296pgp.13
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:12:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rfvgT600SCeY1GxBCoS4srQI51Vh12EHfnz7EkKXv7Y=;
        b=rcR8fHYA7VGsNWOrFm7mbSMcYYn+usPy4t+kBy+nf5G2f+jD+TX7rSyhPL7kAwunnH
         JeVk0XuX1izFfPG4cbUCiW738TQajTGsF79UwOy5m3UZW2PFHmDOv5YFAn0SQcAQrF7f
         lfuiDMDfnKFCoXvK7erfMfW/55peDgW1w+9t34B8E6FtrFIXq4H5sqtbFCCLXUptPQNW
         CaYKvS/odn/CJK118YDg9bGZSPV6sRo403MDJikt68pvm3pcUwkJ292GvJECpVP4r8AJ
         g0CgknleqaOglLK4haaB7SNfLLWxh59hEP2G25OlpcYEPSeVca9Co/FBnQ9UozAKk3vM
         BKDw==
X-Gm-Message-State: AHQUAubWe3bROcr+IuEYQvGF4ZioN6+/5oXJoOkBwDKvTHMUOudYaxyt
	RWNUZYUdHt6l43FMHUQvrxg07Wt3QJiNlZDNjXZOLS6PueblxmjHuXrKglZj8Q+nm2+gndJsA1v
	E0RTV2YG2fvbcMCpcrb7zgKDAseDNqdokBGdyK5AH6lDHSYIuJIMAQQWCSqtXXNF+4A==
X-Received: by 2002:a62:4e8a:: with SMTP id c132mr11380235pfb.24.1551183141658;
        Tue, 26 Feb 2019 04:12:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaekpIrB4z1InwvVb0EhHFmPZe+oGNdTs4L05z1B6w7JfWpE4PTV4/WTlhHX/1vUp1CqsUT
X-Received: by 2002:a62:4e8a:: with SMTP id c132mr11379808pfb.24.1551183135902;
        Tue, 26 Feb 2019 04:12:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551183135; cv=none;
        d=google.com; s=arc-20160816;
        b=OtV3PWRM9SzLsGrFHS0D4pSAjpZwwu3t6LLHcpu/5Tm+bxW74yi7A7IoHB216lw6ae
         EoAuNcSKVwLNN7fNrOV4k9a0x1J7nKuhW5quQ0pmniWz7pKu7W1H77kWhBA5C3E15kxa
         5PP5kf1KYzcageuyJndhzAOSIykyULZTKAZabQI1sOXz/6xblISQ1LV/fX2/Q5XWGRCP
         EYdByk+Xx862ls5YpPBwlf1/oLWnmD9DyYuUdN0/8KrdMwGLSMpHZph7qVToeNHCatFH
         TfIDdcN1DYE4NvhJdNp39edTlgzx3jRTpZOMtvnAI+DES1a0vqmA3jizL1U1bqHg42hN
         Pr5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rfvgT600SCeY1GxBCoS4srQI51Vh12EHfnz7EkKXv7Y=;
        b=QgDj+tTE1DVRbjyg0SMlXyv8ojYN2O3JXxaJMoW/QaFQDZdHBJj/kfhK3q7chUs4ZU
         M2YLV4SDC/pDGEYfcpOOenx0mWB+sDCCf+YBY5FKZcFLViE/tgrWrfAeF0qPpqWCrFFN
         +j0Yv66/HXxLnpio+UpzLiLlsqg0RYTrt4wf6p/BYTsiewmSOmDHvjHGoBozZorsxMkK
         gejqPE+cO0Y6POqMpgO0dojyb0iT5ZrtR6cF5+q8jOjLnxBBBapNK+Z3sS+QyH6GmmUf
         8RBV/m5gYxa2H3P8ZmkVetKGO48w20FHlQYAAfmG+zBWK8MKnvcjnUhkoQk7VOf+kbOU
         2wsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kowBbUHO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m2si12095116plt.394.2019.02.26.04.12.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Feb 2019 04:12:15 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kowBbUHO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=rfvgT600SCeY1GxBCoS4srQI51Vh12EHfnz7EkKXv7Y=; b=kowBbUHOGJxpkdwvXHNEsYGuW
	zmnj+vAR9a+8vG/0eagusSoeqnhexBgPYYg9uEOul6XmofqsWxyE7ngmnzy2hYLPoOWAt07ELccjk
	g22/QKYOu/bktyRXamee+00gtj7LY6P+Sjz7sN+oOFGePNEKoU3fzvnNZ+BLbCnksRBxR94sQZJy4
	c9uTMM7TJsKEDwU2GKjrVLBGN0mlzg0xkL8QWX4hGlOxp7SjwKHh37KppzrdFl8AiSL0bTEzKp2vw
	N1w5Q3nkqU1PtAVm/RM+d5e8wgaaTnTlt1t3+aviHEA0u3ej6mrEVAsgljaxVY58ElIX2ZcZw1ewq
	PQojgJ7xg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gybaj-0006iH-KY; Tue, 26 Feb 2019 12:12:09 +0000
Date: Tue, 26 Feb 2019 04:12:09 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Ming Lei <tom.leiming@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	"open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>,
	Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	linux-block <linux-block@vger.kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190226121209.GC11592@bombadil.infradead.org>
References: <20190225043648.GE23020@dastard>
 <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
 <20190225202630.GG23020@dastard>
 <20190226022249.GA17747@ming.t460p>
 <20190226030214.GI23020@dastard>
 <20190226032737.GA11592@bombadil.infradead.org>
 <20190226045826.GJ23020@dastard>
 <20190226093302.GA24879@ming.t460p>
 <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
 <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 07:12:49PM +0800, Ming Lei wrote:
> On Tue, Feb 26, 2019 at 6:07 PM Vlastimil Babka <vbabka@suse.cz> wrote:
> > On 2/26/19 10:33 AM, Ming Lei wrote:
> > > On Tue, Feb 26, 2019 at 03:58:26PM +1100, Dave Chinner wrote:
> > >> On Mon, Feb 25, 2019 at 07:27:37PM -0800, Matthew Wilcox wrote:
> > >>> On Tue, Feb 26, 2019 at 02:02:14PM +1100, Dave Chinner wrote:
> > >>>>> Or what is the exact size of sub-page IO in xfs most of time? For
> > >>>>
> > >>>> Determined by mkfs parameters. Any power of 2 between 512 bytes and
> > >>>> 64kB needs to be supported. e.g:
> > >>>>
> > >>>> # mkfs.xfs -s size=512 -b size=1k -i size=2k -n size=8k ....
> > >>>>
> > >>>> will have metadata that is sector sized (512 bytes), filesystem
> > >>>> block sized (1k), directory block sized (8k) and inode cluster sized
> > >>>> (32k), and will use all of them in large quantities.
> > >>>
> > >>> If XFS is going to use each of these in large quantities, then it doesn't
> > >>> seem unreasonable for XFS to create a slab for each type of metadata?
> > >>
> > >>
> > >> Well, that is the question, isn't it? How many other filesystems
> > >> will want to make similar "don't use entire pages just for 4k of
> > >> metadata" optimisations as 64k page size machines become more
> > >> common? There are others that have the same "use slab for sector
> > >> aligned IO" which will fall foul of the same problem that has been
> > >> reported for XFS....
> > >>
> > >> If nobody else cares/wants it, then it can be XFS only. But it's
> > >> only fair we address the "will it be useful to others" question
> > >> first.....
> > >
> > > This kind of slab cache should have been global, just like interface of
> > > kmalloc(size).
> > >
> > > However, the alignment requirement depends on block device's block size,
> > > then it becomes hard to implement as genera interface, for example:
> > >
> > >       block size: 512, 1024, 2048, 4096
> > >       slab size: 512*N, 0 < N < PAGE_SIZE/512
> > >
> > > For 4k page size, 28(7*4) slabs need to be created, and 64k page size
> > > needs to create 127*4 slabs.
> > >
> >
> > Where does the '*4' multiplier come from?
> 
> The buffer needs to be device block size aligned for dio, and now the block
> size can be 512, 1024, 2048 and 4096.

Why does the block size make a difference?  This requirement is due to
some storage devices having shoddy DMA controllers.  Are you saying there
are devices which can't even do 512-byte aligned I/O?

