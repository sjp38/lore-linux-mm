Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0444C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 12:45:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE9A92084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 12:45:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AZhuFqvb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE9A92084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D03F6B0007; Fri, 26 Apr 2019 08:45:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47ED76B0008; Fri, 26 Apr 2019 08:45:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3701C6B000A; Fri, 26 Apr 2019 08:45:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F411E6B0007
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 08:45:56 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a17so1960945plm.5
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 05:45:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=akHd8JqiMAzxrz2WCE0z9Z8wSwIAjNmdXhzSk4evgGw=;
        b=B7s56N3kpqQdUEFx3Q4uvpgZuyByrEA05JL6MQzRtJfmJ5//dkXJoqBFuRcQLpqD4E
         I0Y+mwOsA/dnfTKkLxqbxDYM2L//B9PC9EU+FgvRSzZWDJhSUV2wZ3/6BS/M2ptYGeYX
         0i2RCCsr7+mwcEpCnPYnNlZD8e/dD9iG3rAuAwKeZfDbreuNrZ0r1Y+DkLRGu0ZgX8A+
         9bKzKvy3wMkbs1GyNwv5nSF+8ppQ05cSuQG6ob9eY1VV+/SoHxMStGQ+3+hkdYry6eIA
         M7lvPxOAmPD78wBe3RcLsIc7PSFWp7s1O8r5upY1/gcl0axXg6e7KjHAUYQigX6TZE9d
         w5Ug==
X-Gm-Message-State: APjAAAWVykAglrCmt2FAGpRsrTpDYWYGFliv2tKc5Cg2LkPv/TRfrVF4
	CQ9isZcEXAdrxxuOp+jz70u5+poT5e+en5a+rri6KwKVnGDNGjXMknBffTbPG37gmbG7WBPV+4y
	nJ4bx4x4Rnq4v05/WfLsDvRandGxylqv1qQdt6uTrpFbltuMSGIz2iNGMFbGBiC1iYA==
X-Received: by 2002:a17:902:7206:: with SMTP id ba6mr11081558plb.301.1556282756243;
        Fri, 26 Apr 2019 05:45:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmWQaSTVODX7gs+h5jBGICEtBHPN7NvErtltwa4d406l4S0/nPy/4I8vbx6yWFyZU1vj3/
X-Received: by 2002:a17:902:7206:: with SMTP id ba6mr11081516plb.301.1556282755586;
        Fri, 26 Apr 2019 05:45:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556282755; cv=none;
        d=google.com; s=arc-20160816;
        b=fgzoodChGJ3Zgijjj11q5FnJ6MRvx2Wrnxv9jgXwwQs0ZTe1bfYXuChY1DfMtqCasZ
         DfaIoIgRM8i7Ylul8uOrt8c+eXrkB7/o8GWfE26qOe8KBVMHfgXC8d9odTKWwM9E49uO
         dchWDVBEPjB4d2RavwhEcLx8luzdrvyEux7GqWcia59H7AVDsOvedC3OxfwkOa7o58PV
         js3GhqdC19HwCP0SXvylF28pg4/uB21d1OTchXPBhIwhWbu1/EarsrKkPOFHWZl3Pkza
         Ta4bGVii84m9gXp/ybQEVEGlvKAl30wDvH2R1aVr9OqycFoqMxgsgsCPsVSqbiIcuIuj
         6dFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=akHd8JqiMAzxrz2WCE0z9Z8wSwIAjNmdXhzSk4evgGw=;
        b=Ct/JxWhpbmwQ0esaJkvHdvUCiOPxhSMPLFsRBXZKn/9wcbHEVSReLw0pQY3j8us3FO
         EcuPu1g3SEeHyV4xrTNEi7stUH1Jy3HzS5jCMxTxzAXaIcutV8Dw05VHepytWt9zF2Yh
         bgJFcUEi4FxJLoIm6g/nr+JLz5qmjnGOoq241x2pshs2xo//w9yjSidjrNzi6190slYS
         Hz//TujLLQSGpsnvnkgshR4gS2tB1fz+1hR/k4eQfQSOD1IeA6/lwKN8uSKEgZr9HROn
         vCWBGmq76OCv7XeV1Gu0HM471RdCOQS/0t/pSgeN383pvdtgW+371wELKia8GCU7UaI0
         jCow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AZhuFqvb;
       spf=pass (google.com: best guess record for domain of batv+69eb5840461690eae8c6+5724+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+69eb5840461690eae8c6+5724+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c7si9931453pgn.277.2019.04.26.05.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Apr 2019 05:45:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+69eb5840461690eae8c6+5724+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AZhuFqvb;
       spf=pass (google.com: best guess record for domain of batv+69eb5840461690eae8c6+5724+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+69eb5840461690eae8c6+5724+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=akHd8JqiMAzxrz2WCE0z9Z8wSwIAjNmdXhzSk4evgGw=; b=AZhuFqvb56ZemhjhPqPx8RzlB
	DHLTZNxiXAREhfS6hcQN84QTKvH+1PpWmT3ZWfsXF+elp2AQmuYMqGB2t3FEbi0ghPRncdVSagaUg
	smuSONJ+ayLRN+gwNnSaVtu/M7pIk1lzVenHes52Rp0bV1GYl1e5fx3YIjo4uYepzFcszxh3NyQuI
	6BJ994ZTbSsB/zVBP8yoQ04uSFpxPPUImZBAYzRQMwjI3NfjMEhuXJrp1MHliAIYRWty+euxnpKua
	qZKTJVagxc4Kmqtc601X8scFFP7/0W6OCj1Src9tP32GYwPDBknVCaZ7Va2LSJJEgOXC8jpQR+kyy
	s6+S28swg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hK0Ej-0007PV-L6; Fri, 26 Apr 2019 12:45:53 +0000
Date: Fri, 26 Apr 2019 05:45:53 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Direct block mapping through fs for device
Message-ID: <20190426124553.GB12339@infradead.org>
References: <20190426013814.GB3350@redhat.com>
 <20190426062816.GG1454@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426062816.GG1454@dread.disaster.area>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 04:28:16PM +1000, Dave Chinner wrote:
> i.e. go look at how xfs_pnfs.c works to hand out block mappings to
> remote pNFS clients so they can directly access the underlying
> storage. Basically, anyone wanting to map blocks needs a file layout
> lease and then to manage the filesystem state over that range via
> these methods in the struct export_operations:
> 
>         int (*get_uuid)(struct super_block *sb, u8 *buf, u32 *len, u64 *offset);
>         int (*map_blocks)(struct inode *inode, loff_t offset,
>                           u64 len, struct iomap *iomap,
>                           bool write, u32 *device_generation);
>         int (*commit_blocks)(struct inode *inode, struct iomap *iomaps,
>                              int nr_iomaps, struct iattr *iattr);

Nipick:  get_uuid isn't needed for the least itself, it just works
around the fact that the original pNFS/block protocol is braindead.
The pNFS/SCSI prototocol already switches to a device UUID, and other
users that work locally shouldn't need it either.

