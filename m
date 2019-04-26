Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19A85C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:47:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB8C82084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:47:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="sbavI2MS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB8C82084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55DD36B0008; Fri, 26 Apr 2019 10:47:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50F776B000A; Fri, 26 Apr 2019 10:47:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 425526B000C; Fri, 26 Apr 2019 10:47:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 08F9A6B0008
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:47:08 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i14so2349456pfd.10
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:47:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VFpwf0uER1KnB426+X7UPhdTtG2qivWWYDz6u/XxK1g=;
        b=fHwh/dw7cQ53WM8VQs6Wdar2CBZozhBpnSzB0ks/q+X+u4KdFEOJf+VpJvJxXZ7n/f
         AOTOahucJrvrjNpmBNrdX8xdpzyWD8oOEbPxNfYLlrGPaOHmBBj9gVGzM9z/YMnvHh3g
         T4g5tFxxdlZh+8koLVwDRgXYMyKsLdfP4h4/75sHk5LM4VeJYIlp4PfGbNAwo25rES3T
         r521TLPGB/qp86FCxDnTIzXqheh2b+tlO6vXbwv8pt0wgSLSNdj0GJ2OL3oaFQalZT66
         abi0TDRDBOb1jJ5fwMazitTHBJfr5oCaNSRYcu4O/GQrUWE1w/lIUhLUG5bmOzklG9sT
         kB2Q==
X-Gm-Message-State: APjAAAUsPNA4lQP/+mYim2dujklldFOpO3mQeGyPjqGwZ+urmcfj4e2c
	Wju5Ma9apJKpjoQRo4tfpkLDSFKSQgy1zEB1eiVyOqbiBr8AKNyGgyO75bZmFjoVIKRGt0Rklu9
	EL4rB+wn6F6wuxrFKAmRCq2okErNho4Ko3yYdtP6tZa9NWVjtyWIoTSbh8Or6c8etXw==
X-Received: by 2002:a63:ee15:: with SMTP id e21mr15015206pgi.180.1556290027722;
        Fri, 26 Apr 2019 07:47:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqUdOnTm22/ZhPAHNpob1lxB/qLBrUB2Cfarl+IR9OZ0OK00LhjfGxmKIkMC4iGN8lV/z5
X-Received: by 2002:a63:ee15:: with SMTP id e21mr15015166pgi.180.1556290027112;
        Fri, 26 Apr 2019 07:47:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556290027; cv=none;
        d=google.com; s=arc-20160816;
        b=L2kWEyrrFBqDbmebXIFc/tB6deIRzXGscJ48o12pKZkjlZAI78mKLdjM6kMe+72gG0
         sMb7o3aFQsW9EtHOheyCUdUqRzGkt6DNPEDkXjOhMbVY1v7IXBWxnvX42/wUo8+apR9r
         /ltGVEaUMQAONuH5vj8//CauUqQq+T+UrGa6ciQ91dOX6sEuyWCwa7Aopcz5nlK2kbL3
         2Qu2YULBz+VRlm+ZttWCeE3VdNXhZ0BDN5zL+eVxSNDYlGzhivPiARiPfIZqSNr6E62w
         lcGVphKcXTAvyhkqw4r+aiLDJWbq9JToRLAEDM3qTX0lRQhQc3NzXxJ2vAUVmY/JWN5P
         hh4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VFpwf0uER1KnB426+X7UPhdTtG2qivWWYDz6u/XxK1g=;
        b=piDcYJvO4gLsael6O0/JjKhMuQgpJPryBEGcMyjR1DpB4yUDiqnM7PJLSz5l1/Y+oW
         fF3j2rpyN+XDBMUj0aia2egvAinMKvCSw+hZccYdoaRdIPweBLofpuBhQUllOP+ASDCO
         IiizhYxHLJW+UsXyF9qAR2qY7vQhrpdpm5jrsnWzEIphG2vSH6jFMvcVmpUu5frQqnXA
         a7cCahjm79bgprIi+p/6oorgcgo4YjEZBV9WKJxMAMrXyqnvylwP6Z5jIEVOQabcmK/a
         FH8KfPTwCarInxNwahNKlD7nEUMWlbSGkY1h43gsnFmJRxscsi3cqZzmWIt244bOU28Y
         84IA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=sbavI2MS;
       spf=pass (google.com: best guess record for domain of batv+69eb5840461690eae8c6+5724+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+69eb5840461690eae8c6+5724+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m1si2706150pld.163.2019.04.26.07.47.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Apr 2019 07:47:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+69eb5840461690eae8c6+5724+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=sbavI2MS;
       spf=pass (google.com: best guess record for domain of batv+69eb5840461690eae8c6+5724+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+69eb5840461690eae8c6+5724+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=VFpwf0uER1KnB426+X7UPhdTtG2qivWWYDz6u/XxK1g=; b=sbavI2MSRVslbfYNWMJ8CH2gV
	qZXWW6P6OIWyK/t8anm9RmHQ+1qaj2s+x9TIXR5Tg/WFBSXfLhZvjWyAoCEGYJ2XORzognBfR5Wqs
	UYxNndXra6db+ftv2kBVYNZBfmnSlRK04528quRuNTrr3X9HZWontxJVP5ufGGrzy0I8cy1+cAbpi
	zs81GKmnYPKzI6FAn7x7k3F6tWxErEYig2Vc2PUrshvWyns8EouqYdNPcFv588BZAvfYwgUlEZji3
	USy3Em0jkxc3Msas3qswjEBn12UycKskY1tFmidxo3Hu+bNexQsNe/JOpCSj8fdrjH3l+Kv2V+EKF
	xGvbNY8uQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hK27y-00011k-L8; Fri, 26 Apr 2019 14:47:02 +0000
Date: Fri, 26 Apr 2019 07:47:02 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dave Chinner <david@fromorbit.com>,
	Jerome Glisse <jglisse@redhat.com>,
	lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Direct block mapping through fs for device
Message-ID: <20190426144702.GA31264@infradead.org>
References: <20190426013814.GB3350@redhat.com>
 <20190426062816.GG1454@dread.disaster.area>
 <20190426124553.GB12339@infradead.org>
 <20190426144507.GB178347@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426144507.GB178347@magnolia>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 07:45:07AM -0700, Darrick J. Wong wrote:
> Hmmm, this lease interface still doesn't support COW, right?
> 
> (Right, xfs_pnfs.c bails out with -ENXIO for reflink files)

Yes, but that is because no one bothered to do the work.
pNFS/block and pNFS/scsi explicitly support a compatbile COW
scheme, it is just that no implemented it yet (at all I think,
not just for Linux..).

