Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08654C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 03:35:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEBCD2183F
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 03:35:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="qJNVSV/g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEBCD2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 554626B0003; Wed, 26 Jun 2019 23:35:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DF338E0003; Wed, 26 Jun 2019 23:35:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37F678E0002; Wed, 26 Jun 2019 23:35:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id F087C6B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 23:35:53 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b24so619215plz.20
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 20:35:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+wCwdaSxTB8YKlW81OR1Th+bQGIzFRA/syRzv9dk9Z8=;
        b=dj6SJg1r8kfOyJKq3rPjPAoRkZulkqMYyZMwSASdHrUfjbxLRX4thSLaK4gFQceWt9
         zHbdy3TI5pPfy8sTjVS0qDLMaq9OV+caMA/KBqA7VzVaThsvOO9C1N4xQzS/CXlkx5JV
         s0bpGHYwdFJzV2o1se44nZtmnw13Lue9EbdtYDvO52iJZEqK6ZiWmIMyE+a24M+KpUrN
         ZTK7f3ZFjwyAdARpixoGoWiOvaLgYmZqRWr2lFvU/MvQf4RS21qGsI+cBiQ/IiWl56ar
         /8iQ2B3g8aXBqOEfUbIdgG/YZRT4ucdnwR1K7FUyCYg5kYI7qqcVeYac06cI7SUaBVqr
         LJ0w==
X-Gm-Message-State: APjAAAXI6gvLgsy5Jo/WY3RAfnENXFxDI25htSahtx1noT9wSswhfd3F
	YP5Wd3bKF7b/ZoOAEAVa94bMrKYfMyYmfsSB48JHx3Gc6c8lD/4YDvl1g3F/7JacZAFajok374f
	wnogQYzstT0X2+zq5jsxBmtS1re/pilvvQ2GWUDZBWL+bWkiBldoiQvvag0pbXi9PNQ==
X-Received: by 2002:a17:90a:2008:: with SMTP id n8mr3210508pjc.4.1561606553508;
        Wed, 26 Jun 2019 20:35:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMXehVrPPUrlFzbi8ge47emqY+U1onk/JKmt04IiquBPL9JAueh6a0iiXxwYmN61UdVs8O
X-Received: by 2002:a17:90a:2008:: with SMTP id n8mr3210441pjc.4.1561606552726;
        Wed, 26 Jun 2019 20:35:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561606552; cv=none;
        d=google.com; s=arc-20160816;
        b=mW1IrbDuInQE881rfZhiOq/MFijjgyNkDk+gFked1NDs5hQuoV4BRxwc5sMjrld43O
         z4O82ETeTr7wP23tjmF9VPgMyoL0mDTN8Eg+77NtP8EJ7v7/SBL5k+2qbzclRCG5jcq4
         LVTV2qQkiw+CTPrQqIodz1+IcM4Lay9qO1Fbnyi5RSmnwpwVSGR+QKpeeKxc8wn9YQbS
         Ve6EDAXAK9wbo5uHLHLKjYELvdKTDa0cieXQcFHx9CUHqUgG7FIM48uvU8dD/RcqcVxg
         mSOXY2CzjQEyFKRK76zl2hkzESYs15m8WbfFl2Oty9ipa6BYLok2Mb1WO+w4m242deIG
         YXOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+wCwdaSxTB8YKlW81OR1Th+bQGIzFRA/syRzv9dk9Z8=;
        b=xheJg+NaNK4384eG9tZAg6bKnKxxqZZ7gPN1I8ABBaHuyU81W+pIuRdFUIJvJJgUyt
         0JINFqsiuUACEe2R2IbigOepegcoSOTrZQZozcVEP2dgz8be+q2+fmduryB8Ex2QIiZP
         E8eNT5M6k4kDY96QS/qKhSj0tt8xzX93892vbmOTNp2hxLSdRHbeL+jcPPUeumCQkGlr
         /+HynJ92f0hFrEkszPgoOdm8hGPR94PeqU8CNdHw7dmkhg5J4YYZysqdbArZfE3DhuF1
         oD0pG9pRMEF+1M0w19qjsOgzDZ2QSMfGhXvuJal9Zy4eXxldLPOgNgRXjfkcTP0GoFxl
         6vJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="qJNVSV/g";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c82si1317860pfb.32.2019.06.26.20.35.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 20:35:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="qJNVSV/g";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C898C216E3;
	Thu, 27 Jun 2019 03:35:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561606552;
	bh=VbXYrl8hV0yD1BgA3FSNiW43CpbVpvSODNnRganJGDE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=qJNVSV/gh5CVGeGNXpkcW2nF9iUxd1Sdk2X1TV3BnRqByggZqSGbDMq/6dRMBaEd6
	 X2eUMCkVnjulZ29brgN5QAbJUKPSXyQbRJD2zzaU60IjlrKzh1AKlvGVn63QYi9OzC
	 IK+TVy8Lf1kt5G+0QGXbfgv6unH4vFb+A9uGD3oE=
Date: Wed, 26 Jun 2019 20:35:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@infradead.org>, Mark Rutland
 <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, "will.deacon@arm.com"
 <will.deacon@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
 "anshuman.khandual@arm.com" <anshuman.khandual@arm.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3 0/4] Devmap cleanups + arm64 support
Message-Id: <20190626203551.4612e12be27be3458801703b@linux-foundation.org>
In-Reply-To: <20190626154532.GA3088@mellanox.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
	<20190626073533.GA24199@infradead.org>
	<20190626123139.GB20635@lakrids.cambridge.arm.com>
	<20190626153829.GA22138@infradead.org>
	<20190626154532.GA3088@mellanox.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jun 2019 15:45:47 +0000 Jason Gunthorpe <jgg@mellanox.com> wrote:

> On Wed, Jun 26, 2019 at 08:38:29AM -0700, Christoph Hellwig wrote:
> > On Wed, Jun 26, 2019 at 01:31:40PM +0100, Mark Rutland wrote:
> > > On Wed, Jun 26, 2019 at 12:35:33AM -0700, Christoph Hellwig wrote:
> > > > Robin, Andrew:
> > > 
> > > As a heads-up, Robin is currently on holiday, so this is all down to
> > > Andrew's preference.
> > > 
> > > > I have a series for the hmm tree, which touches the section size
> > > > bits, and remove device public memory support.
> > > > 
> > > > It might be best if we include this series in the hmm tree as well
> > > > to avoid conflicts.  Is it ok to include the rebase version of at least
> > > > the cleanup part (which looks like it is not required for the actual
> > > > arm64 support) in the hmm tree to avoid conflicts?
> > > 
> > > Per the cover letter, the arm64 patch has a build dependency on the
> > > others, so that might require a stable brnach for the common prefix.
> > 
> > I guess we'll just have to live with the merge errors then, as the
> > mm tree is a patch series and thus can't easily use a stable base
> > tree.  That is unlike Andrew wants to pull in the hmm tree as a prep
> > patch for the series.
> 
> It looks like the first three patches apply cleanly to hmm.git ..
> 
> So what we can do is base this 4 patch series off rc6 and pull the
> first 3 into hmm and the full 4 into arm.git. We use this workflow often
> with rdma and netdev.
> 
> Let me know and I can help orchestate this.

Well.  Whatever works.  In this situation I'd stage the patches after
linux-next and would merge them up after the prereq patches have been
merged into mainline.  Easy.

