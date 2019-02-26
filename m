Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83BE7C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 13:02:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27CA4217F9
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 13:02:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Dm/Icpah"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27CA4217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 971A08E0003; Tue, 26 Feb 2019 08:02:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 922748E0001; Tue, 26 Feb 2019 08:02:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 838958E0003; Tue, 26 Feb 2019 08:02:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FDC78E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 08:02:36 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id f10so9719248plr.18
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 05:02:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iCmFmWiV3xb5AOVJB0XEU/x7knedJSI2kLqY2YUO43c=;
        b=qK6zvumtCbu94hLvjtd9KnKIooFKGTgQ1M4J2RqJaa/pfYBe9IdHZJ0fq2vhWlLeZn
         FY8b5DKJkHCu1TfvbGhXmjIy/1dTYZmNlXiE6kF6ErKSb2jWwEdpp2oHU9ciOv/t0Pns
         jnTga7SEwp16bSPpY0tTi2N8ZHAbBK2BaF6DjdH/sN6hEGajdF0FbqpHraCoU06xRqpT
         eu5MGTuReCeZ7fmV2ET2QqmqmRsjO8vRWwM0Ny2BaaVeNImkMQ3eoJuqC30wlzBqeKm8
         5avY7npxqGIixNqQBmVDwA76kfUEtjukyokEMY+EH0ZNQl+KDYO1QlSDyG6HmeZl9h4j
         hNHA==
X-Gm-Message-State: AHQUAuZi92/KYE+TeM0N868AkVzI9gfwV0lViB1OCI+eCM98fWwIOYE8
	p6simqIAWnnskJOnJwES0hFnonEkYZZbrBvXoLWBIBwoKSvpsIUl9mNcLepPMIcOrXFF8xJPPn7
	QRivZIxPiKNXE6m8mUrr0XqprZxrjQpqE0T8gGk/S7w7suK3JpwTzvDgesZAI+V00dQ==
X-Received: by 2002:a62:a113:: with SMTP id b19mr25676903pff.227.1551186155883;
        Tue, 26 Feb 2019 05:02:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYqxHPv863MkOCFmtQhINHmIE1G2QanPVfOC4LW3LLdpqs8WFkiR52OrvNdi3Rn0ExvfHVP
X-Received: by 2002:a62:a113:: with SMTP id b19mr25676821pff.227.1551186154779;
        Tue, 26 Feb 2019 05:02:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551186154; cv=none;
        d=google.com; s=arc-20160816;
        b=Ehg3UXxMeWHoCl2EdZz834Nha7F8alpHvDf4go3bQV2GgiCrO7ptUo31SUkp+iS5DY
         DxxuneY79whz73tNvCQvwX1zFjNNgWw8MlHINSbDGLO3IHMLcX+PdxYcp3yKGNqnHGwT
         PqdJ9votImdURNvWtoa+2bpEOXjGUZRP/lJtUfaRxFN44pwtRmDNgYp+1cWwBdFK2SJ7
         nwztsm4+xA49RgvoPkpf77uSaarT++jDOi1F6+d+f4FqLu66xZrf+gq2FhxuNMc6MiwM
         QV3T31FhTSI785KK6iwx1k2Pc/ui6E9NhnI2GwNaJhzSX7s3P/c0oznLt4JVj2oqiaDU
         bg+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iCmFmWiV3xb5AOVJB0XEU/x7knedJSI2kLqY2YUO43c=;
        b=AkIVilPzDhn6l5QyLLeJEFrNNDPUyD+7ki078Xp4IFIVILpzNwOCKkP72a9EoMS//s
         0mKgL9KSNCVDCTpq/u7PpyLGOEgPBz/A8brspo2ZWfeH06cnCj+RO6VGtLoMyz2rxigH
         yHUmTag5Pinh+0i7THbhOJgY8czl/6hXJUiYTXBvJtPBUCWaIlKe4gOZc1WFFaR+rydg
         Jqp1xxF8W1UQhhgy1/U9+HdBoA8BJdjruCdYhdyAOT+JVDVpu0xw5Sn2v07ijmubQUtv
         kNNCgp4sx+Db8Um26XokYo/l/Ras8+oVoYi7JCZCVAkTTWrio38ntoaJod90i53wCIEk
         0vow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Dm/Icpah";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id a8si11556473pgw.380.2019.02.26.05.02.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Feb 2019 05:02:34 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Dm/Icpah";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=iCmFmWiV3xb5AOVJB0XEU/x7knedJSI2kLqY2YUO43c=; b=Dm/IcpahO0ZOhqdZYsO+RF9de
	HcWTIk0ykKJwiCQ7ClRXTt33MZpvZJoBiDPktX7H6P3wZ9EX7UPTWEa50nDi8oiuAI/yvXUXWqYBO
	3fjWdTdySwFhkitqGJ/aJDr2WJQ58BtyHaJqEydY95E1cKqnddoPiM9ZhuzewlzohU1M5pwa9Bt5B
	G44IAyEGHk28DfhE/IfTiTb/YDRUCfaxPfITn/rb+RVNijE8duubfXeLZNga198lOoywJnnYxLWvK
	bVa//J7t3actOLmik7JsKmn2/VnIZ6f6eA+X40kB8DVFx+415kByOpzltDAoIp69vbtdt3RGrlTQf
	0Qlpp3tXA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gycNS-0005tY-Bt; Tue, 26 Feb 2019 13:02:30 +0000
Date: Tue, 26 Feb 2019 05:02:30 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Ming Lei <tom.leiming@gmail.com>, Vlastimil Babka <vbabka@suse.cz>,
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
Message-ID: <20190226130230.GD11592@bombadil.infradead.org>
References: <20190225202630.GG23020@dastard>
 <20190226022249.GA17747@ming.t460p>
 <20190226030214.GI23020@dastard>
 <20190226032737.GA11592@bombadil.infradead.org>
 <20190226045826.GJ23020@dastard>
 <20190226093302.GA24879@ming.t460p>
 <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
 <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com>
 <20190226121209.GC11592@bombadil.infradead.org>
 <20190226123545.GA6163@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226123545.GA6163@ming.t460p>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 08:35:46PM +0800, Ming Lei wrote:
> On Tue, Feb 26, 2019 at 04:12:09AM -0800, Matthew Wilcox wrote:
> > On Tue, Feb 26, 2019 at 07:12:49PM +0800, Ming Lei wrote:
> > > The buffer needs to be device block size aligned for dio, and now the block
> > > size can be 512, 1024, 2048 and 4096.
> > 
> > Why does the block size make a difference?  This requirement is due to
> > some storage devices having shoddy DMA controllers.  Are you saying there
> > are devices which can't even do 512-byte aligned I/O?
> 
> Direct IO requires that, see do_blockdev_direct_IO().
> 
> This issue can be triggered when running xfs over loop/dio. We could
> fallback to buffered IO under this situation, but not sure it is the
> only case.

Wait, we're imposing a ridiculous amount of complexity on XFS for no
reason at all?  We should just change this to 512-byte alignment.  Tying
it to the blocksize of the device never made any sense.

