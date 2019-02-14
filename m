Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA333C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:16:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85EEB20823
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:16:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="EmWX0F+U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85EEB20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 240CC8E0003; Thu, 14 Feb 2019 17:16:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EF908E0001; Thu, 14 Feb 2019 17:16:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DFCF8E0003; Thu, 14 Feb 2019 17:16:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C061D8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 17:16:33 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 38so2907759pld.6
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:16:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=t1hVwJWaLn2x3podPvX+xTLteVECyauDZZjQoDe0D+0=;
        b=O/E2qq2TMNOxc1KxHaEyBtjbwkXmilBaIO2rNhIArnDxl62qnAh67h6Bj74r2/+xSu
         ECzDjzMdJpBfEPtTYZMfd1U5mXseFfLgCl4aaTd5zjg6z6RehIJmwUwsJ4PXHwyTlMVR
         cAudwrQAjuiaEt4P/UlDm4YBwp04OcNzX4vZ0CLt/NtRjJCkDe4Ut4ulZY5Vsl8jrtQn
         5kuZfdKGwJDgHpzqQHtk0zDMaKIrZdAYfPaZAr/X/NFrvcyHylakCDJtdyGP+gsQcWlk
         GKWTYH1P80AKI4T5pji7a3nLxi5J26vQD8qZ4aBZiXvpH5dXO3Ne6QIqz7dahavQSbxv
         HLIw==
X-Gm-Message-State: AHQUAubbIpLyOvFnsxQMKY66imDMFUvvLTbVgIas6lQVVQmvGIKN93zl
	t/M0KETiScTowr4Inbf/XvzSBNBPvzo+SvRc73sfTJT+/GbIZ5Y39aGL8o5njouaIvQI0doS3vD
	zH9ZIOVlzKaOveDkezgMctMiVKwg9EimzCTb1Jln8USyOs9nG3wNm12sUHWw6XNyUNQlQeeC9x+
	jt+zdMs3ejtaguGlxV1B5CSPETpa7nyWTyFYMhsqhyMsVB3ZfUnDiXwIvhFOpuVX/15SK01ZszV
	nS2mpkSwS6tQiJevzF5gqVQV4Se03e6YBq7vvKUlD0QnnAwbJII/GUGSipy0OGMPVGWc38rfYW4
	IV89buap8x5PeN1o1d9gZvNd1xkQ0vGHlw46+ZNs7u3BY6+1UyX6UbhxGhsmEi83EL6Yby1oVYj
	Q
X-Received: by 2002:a65:62d4:: with SMTP id m20mr2049580pgv.215.1550182593462;
        Thu, 14 Feb 2019 14:16:33 -0800 (PST)
X-Received: by 2002:a65:62d4:: with SMTP id m20mr2049504pgv.215.1550182592341;
        Thu, 14 Feb 2019 14:16:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550182592; cv=none;
        d=google.com; s=arc-20160816;
        b=wu6Uo/qFBrMwB0emHIjIQocQ4dQ1rbEjUZTiyu2iz4We0d/Xdq5lDFjU99wosKozTN
         lywDGFgBW/YrhWw8NoGaAunIopz8jVd10NHC1OQvnolEPSgXNGyl806xG2wttk282Ul5
         xRZFi3OqxGQf4HL3qlrLej+1akhv/xmUkerQrqae8l5kBwyQGWVvm/e+IRdZYy1raMyB
         jpWezOef8i2G/FlnRLgIAkCJA+p2TC/em6sc49AxVg6A6jMtjeVaBxMJN/kARAUfNmiU
         xwa/ilJb4SjS3uXGGRJ/2bYvobTQ/wa9FaribiL50U+PJUzHbmky6ry7AheehI9er1IR
         8LMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=t1hVwJWaLn2x3podPvX+xTLteVECyauDZZjQoDe0D+0=;
        b=AC5zTFJrqYnf9rrJNliN6hPl4tkynUXA0S3XiJkXZ87FudFTGnTfv8HwqxW/nXyWKx
         o6ceFsRiBeiFAnci9BX3axeKVCqLrE3yAUjpPnJVk2KbAhImE9cCb7tQqEj0qQxr5hLC
         qWMcSwtRgk0Qz8Gxp+fMLNxcz5wT10UMah1M4OtsHpM6CyGg0ceBIwWyZpkJrr63c6+m
         DyWxUWDc7RDWJnd/voVMCQbj34mFYqdgnfgoOAosncHlNWjk18c45vChyDmSAZfXWTa4
         6oXM1bhVhaOEEn2Alkj37+2/WjrEcXit7VypZeKV3JGigm8sIajOtDCGotByQwcAfTzQ
         Bwvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EmWX0F+U;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l20sor5933482pgj.4.2019.02.14.14.16.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 14:16:32 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EmWX0F+U;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=t1hVwJWaLn2x3podPvX+xTLteVECyauDZZjQoDe0D+0=;
        b=EmWX0F+U8QlHwgyOQyU7/GpC3WglrqT05XbL6OtUXhmICyYGqD//fSe0HIl+i8ygVj
         KLImM7wLgwqYgwHC38M8+IdJpGvQF7STuPF4slPbpqRbJi4onN9XO0pxqn7viPOReHoA
         yD50Kc68GMkGWx3uRxx22P3bY9gTYJmFuwYuPUXwzZF+V0RVlVT+vctp2K+b0qkFvJIn
         S42lTYn684RC3NIapzX5v7GhbOGbCpPUAGz94OauM4EFokmqxeIVwCBS8XRmddSLSnkA
         XfaqPTxJ+62cn994jdfrHXkNizC58LofY5+68+iTjn1jXJqa3vqLrTUAPaCHMxON+wdK
         8Qsw==
X-Google-Smtp-Source: AHgI3IYc8C5MWgcYOAWGTiHgiPL4HnY4upCes3+oFK6jZQx1q2Z66Zc0aNY3zCVaegBZFxjxNhBD3g==
X-Received: by 2002:a65:6249:: with SMTP id q9mr2077195pgv.229.1550182591612;
        Thu, 14 Feb 2019 14:16:31 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id l73sm7556152pfb.113.2019.02.14.14.16.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 14:16:30 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1guPIz-0005gz-UH; Thu, 14 Feb 2019 15:16:29 -0700
Date: Thu, 14 Feb 2019 15:16:29 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
	dave@stgolabs.net, jack@suse.cz, cl@linux.com, linux-mm@kvack.org,
	kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
	linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
	paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
	hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru
Subject: Re: [PATCH 0/5] use pinned_vm instead of locked_vm to account pinned
 pages
Message-ID: <20190214221629.GD1739@ziepe.ca>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211225447.GN24692@ziepe.ca>
 <20190214015314.GB1151@iweiny-DESK2.sc.intel.com>
 <20190214060006.GE24692@ziepe.ca>
 <20190214193352.GA7512@iweiny-DESK2.sc.intel.com>
 <20190214201231.GC1739@ziepe.ca>
 <20190214214650.GB7512@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214214650.GB7512@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 01:46:51PM -0800, Ira Weiny wrote:

> > > > Really unclear how to fix this. The pinned/locked split with two
> > > > buckets may be the right way.
> > > 
> > > Are you suggesting that we have 2 user limits?
> > 
> > This is what RDMA has done since CL's patch.
> 
> I don't understand?  What is the other _user_ limit (other than
> RLIMIT_MEMLOCK)?

With todays implementation RLIMIT_MEMLOCK covers two user limits,
total number of pinned pages and total number of mlocked pages. The
two are different buckets and not summed.

Jason

