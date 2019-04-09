Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CE19C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:02:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 455372084F
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:02:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 455372084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D77DA6B000D; Tue,  9 Apr 2019 09:02:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D26EC6B000E; Tue,  9 Apr 2019 09:02:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEFA06B0010; Tue,  9 Apr 2019 09:02:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 710D36B000D
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 09:02:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o8so2118824edq.1
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 06:02:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2RymSiVH8W4SJMBL3FEStegmjqfCTIJor8UL1qw5SDA=;
        b=P4YzMV1ANkwdFsRJWQTQqq/BWhPUx73oOgWqNwGIluJtlGgYmvMsMOskSyYkzoolnH
         WlQCv6ytYMefRb58PJ7sAJeL09XEATYbtw6t0awFcoO854pMHYGxGll3cZmu2X+Ul9z0
         ypro2C/eZ/xMhcA+4UxlLyRLSb7VKdc97mwz125IqHcX4zGcabsh2WdyVOZ8MZIunRfB
         4Jo/zzkTMFQ7AIK9UnqPv9tRTDsxfvbSInOKFnCWQmb1sMn713+7h/1QxuYCYpz6ma7u
         eqPm67A9/tt9UZZC2N1a5j21zH3S3VL6LosQeAhRtHlrCMS0/CxDfODwPPQqMWQMi6s5
         iwdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of pmladek@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=pmladek@suse.com
X-Gm-Message-State: APjAAAUMVytZUS0HIEDBpKrFQyPqgJ4KP79LZNayQnxpM12ufDwgHJ7S
	sz0+N+jd2Isxdvemh302UxBsSF8hRbqGNV1UEBX0taci/xIYZun+ZJBspZOQjpPzM597yvMH9jK
	j+2jPrnPDxiDDsPlmM4VWbBjJaAp8O3VP+drRSv0Kb7+/J6QkFYaWpfbym4CsEPgQbQ==
X-Received: by 2002:a50:ec86:: with SMTP id e6mr22633737edr.204.1554814946027;
        Tue, 09 Apr 2019 06:02:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzf2gb4I74zzl5FGhlZgD+gTEJpxa1b+c/PEhU2Uri2iK2iyEvPmJhJo2f6EbsijIUskaGl
X-Received: by 2002:a50:ec86:: with SMTP id e6mr22633672edr.204.1554814945066;
        Tue, 09 Apr 2019 06:02:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554814945; cv=none;
        d=google.com; s=arc-20160816;
        b=UphygfyqszZrgOT9vsn6D009i+/T1NKVP3gR0rFXlcQOAaK8JoJsBdaxcUX6Ewsat8
         0qF7NU6GvgLz1Q+3gZ4zme01HF4o8Tx+aeD624KsOnWm+Ep2g2USH+Y6NxRjEcdDHZ4s
         wWLuDMLg9GPCeX6EiYKmBxQKtkhtMNcSDzqwFQRhqzeOU/DI2m+e/10NBZA31gG5bgk+
         hvGPFPb0y3iXdfApLFzfrXnvDeocgeOIateJo/rfmUhrMTyodDrn3cm9EJZsijPWKSIX
         ZXz7b0PTiOVc9yp7tuYfNYrFRXAtLgfurchNLWnkh3LUfAZnoaVNNJSpqLFCSrVKfBJ/
         FR5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2RymSiVH8W4SJMBL3FEStegmjqfCTIJor8UL1qw5SDA=;
        b=oTT3Q89u5WnefvE3NzE2FRPIVR+xClgm+TRbWhMiZk2/laY6CRa6xZKhEbPvrc2Y7d
         bCmYVLfVuzoSkKhcIrMCdQJI5BWvpA4T+67wHShZCdEdEeeCuAYhKyh+S90sH8z0cwDc
         gUu/yovyO8GbJEwZXrWP6Ycw/Jodg/JlHKVp/zxB1XyQNBbOL89lctzwYvlHfxnidDoP
         1NxXDOP76wfITbr2RKhiuyJWs16lfZ7pczOm8/+XuV3e9A7xs+bv0TcXvyqn9dfgCik8
         kEfHSUxD0YwMFNscOICbvJpxme/kaMtzXbRt9n0C1kCsiaMVoqtMEplTr+jFPUA8r3Nr
         jV7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of pmladek@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=pmladek@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t2si2220059ejs.335.2019.04.09.06.02.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 06:02:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of pmladek@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of pmladek@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=pmladek@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 634F5ACC1;
	Tue,  9 Apr 2019 13:02:24 +0000 (UTC)
Date: Tue, 9 Apr 2019 15:02:23 +0200
From: Petr Mladek <pmladek@suse.com>
To: Sakari Ailus <sakari.ailus@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-arm-kernel@lists.infradead.org, sparclinux@vger.kernel.org,
	linux-um@lists.infradead.org, xen-devel@lists.xenproject.org,
	linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org,
	drbd-dev@lists.linbit.com, linux-block@vger.kernel.org,
	linux-mmc@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-btrfs@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-mm@kvack.org, ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	Anna-Maria Gleixner <anna-maria@linutronix.de>
Subject: Re: [PATCH v2 1/1] treewide: Switch printk users from %pf and %pF to
 %ps and %pS, respectively
Message-ID: <20190409130223.qylyzna7syu5cdc4@pathway.suse.cz>
References:<20190325193229.23390-1-sakari.ailus@linux.intel.com>
 <20190326133510.cylhvyvc7l77bqdg@pathway.suse.cz>
 <20190403112814.7frkxkwmitzugzmt@paasikivi.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To:<20190403112814.7frkxkwmitzugzmt@paasikivi.fi.intel.com>
User-Agent: NeoMutt/20170912 (1.9.0)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 2019-04-03 14:28:14, Sakari Ailus wrote:
> Ping.
> 
> On Tue, Mar 26, 2019 at 02:35:10PM +0100, Petr Mladek wrote:
> > Linus,
> > 
> > On Mon 2019-03-25 21:32:28, Sakari Ailus wrote:
> > > %pF and %pf are functionally equivalent to %pS and %ps conversion
> > > specifiers. The former are deprecated, therefore switch the current users
> > > to use the preferred variant.
> > > 
> > > The changes have been produced by the following command:
> > > 
> > > 	git grep -l '%p[fF]' | grep -v '^\(tools\|Documentation\)/' | \
> > > 	while read i; do perl -i -pe 's/%pf/%ps/g; s/%pF/%pS/g;' $i; done
> > > 
> > > And verifying the result.
> > 
> > I guess that the best timing for such tree-wide clean up is the end
> > of the merge window. Should we wait for 5.2 or is it still acceptable
> > to push this for 5.1-rc3?
> 
> The patch still cleanly applies to linux-next as wells as Linus's tree.
> Some %pf bits have appeared and fixed since (include/trace/events/timer.h);
> the fix is in linux-next so once that and this patch are merged, there are
> no remaining %pf (or %pF) users left.

I have pushed the patch into printk.git, branch for-5.2-pf-removal.
It is v2 without the include/trace/events/timer.h stuff.

Best Regards,
Petr

