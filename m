Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,T_DKIMWL_WL_HIGH,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 713AEC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 13:19:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32B51216C8
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 13:19:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="TmoJ0AL+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32B51216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEAE76B0007; Wed,  8 May 2019 09:19:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9AEB6B0008; Wed,  8 May 2019 09:19:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8A2A6B000A; Wed,  8 May 2019 09:19:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 74E746B0007
	for <linux-mm@kvack.org>; Wed,  8 May 2019 09:19:00 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j1so12629028pff.1
        for <linux-mm@kvack.org>; Wed, 08 May 2019 06:19:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tWoRD9HnYFP+9T9TvGeagFmqEIR3y8c9jV8+CKmW6Mk=;
        b=F86uNMfqg2va68ODWERcBIV5iPTSu8xsI9ksWz1oktqcTPLZMOvqmFVzhX3hoZCs/9
         7/bT3bS2zzf2p4YitCBYIDOZncOHvXf0ze2eakkq9tvf5ziiBN3SX2cd37buA/EHgHol
         Z2AyOrZoQT3hzsyeaD+SaFV2VXIqCkF3icclLVbLefNKBJ63YbazZjEsPloBrkL4CAh4
         xi+wKVGEO5AnRfPPs/Ly3aDUiopuNQF/pPl+Wix2OT00F5wFU0gRnpduHGJIbQ4a5Ko8
         aG1XVCG2D3oHCzwmzcpP6sDsFYNNoa4MMnosRqGr/nwew+fU32Xg1y7hYxxp0MWYoDwp
         OJSw==
X-Gm-Message-State: APjAAAV7gohLkTSG5X81PA28E4mGrzivk8LIYpLKMSdDRIXAbFv4mcxV
	hw2zjjMFLZnyoWsb7O3AfmsL2gPDjtp0ww9/HCpp7ZGDHnlQ6JaawTlcQQnNQGd/KE5ecXcnLSI
	0cyYvfUpKtSPKUACUux433MmiFB/zqQ6c4lbkhUyRgJSyrKcbq40L1+RB+AJOb/bdew==
X-Received: by 2002:a17:902:28a9:: with SMTP id f38mr46515847plb.295.1557321540042;
        Wed, 08 May 2019 06:19:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZVRKUgsc0suTxVrfzIoLDSykUbcqgmEXJyzc7YdEiBlJds5A5dquMJ9p5PODYxkPN23X2
X-Received: by 2002:a17:902:28a9:: with SMTP id f38mr46515734plb.295.1557321539290;
        Wed, 08 May 2019 06:18:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557321539; cv=none;
        d=google.com; s=arc-20160816;
        b=ApSuLnCzNrVxu4/7MJunrd9KPtnhBPtNs2ISQ/BJ1QZ1MA87NP22kdx8KhxbTWL96Y
         K9SXW+jBIx3PxQWXESr2bmWbqS8qEbhjdMrM8RvK6/eEITtSWQCnIDLkaPMAaXVRg4/r
         7si0ezyax89vppGJvFPi5Yt1qcht85Jf/XFlKDQYmuCpyUR24OKg2lhrraH52Xrru98x
         pWUXuO1PJk/yRPw8StPoX91IcTkOSAGfKFtXdPAe6yvsJ25Q86BR6DBVD678HXmE3OqE
         DHef7pT4L7oq+O+hYldPCLteNrs3OskxQdcUmTDb8WUjGmZBLt8k4Q4oZ6Y7FhKpsgOO
         Atwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tWoRD9HnYFP+9T9TvGeagFmqEIR3y8c9jV8+CKmW6Mk=;
        b=Q2dcpAEhy3aZ6MAjC8SfD9MCE1orHGJUzieQsn6AWwyOv2ydAjT+WJfcvlYXHNoZsq
         UyiD3ThM/52vu7OJxO1mIx0MCL0ArXqo4dj1zwQ5q1XLF8vwfcf8R5DzS5UJRF4/WReX
         kUJso23Xcz2PPAYHa/9lyKVBBaHX14TFJoolF7AbqP7lNhssgYP4izV20AVDFNRArUOS
         7nCNOH0TdBpEwQr0ubdZ3FY6IIDbKTNky6wRlZOkIaPxPi1qmGujvBauj0z5p7//IO/7
         lIOwMYUdTBBV/814ffxM7bFLHBS3lc0sFqkiUCwcKh3o3Dk+S4tTi97OECAuKDEVOsQ1
         7EHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=TmoJ0AL+;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g11si21821254plt.35.2019.05.08.06.18.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 06:18:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=TmoJ0AL+;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 72CF620850;
	Wed,  8 May 2019 13:18:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557321538;
	bh=R3TjH0YJdscasMYMZYlof8TulS7fu3leM4eKW3RkjvI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=TmoJ0AL+BZaAX0RU4qiQ72Plldpus4mjIr4SdB6Um7klIduUN0lcI9hJjHn6iHzg2
	 IdsKQlfLKruxXTlGhBIlhYfwgiN+JozxY2Z0yDSElIvSGv1ggxiLLDCA0Kz+5QcY9K
	 USsnJL5aRGKJwejw9TuqJYviKaxl6Frf0mkRZF7s=
Date: Wed, 8 May 2019 15:18:56 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Alexandru Ardelean <alexandru.ardelean@analog.com>,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	linux-ide@vger.kernel.org, linux-clk@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org,
	linux-rockchip@lists.infradead.org, linux-pm@vger.kernel.org,
	linux-gpio@vger.kernel.org, dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, linux-omap@vger.kernel.org,
	linux-mmc@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-tegra@vger.kernel.org, devel@driverdev.osuosl.org,
	linux-usb@vger.kernel.org, kvm@vger.kernel.org,
	linux-fbdev@vger.kernel.org, linux-mtd@lists.infradead.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	linux-integrity@vger.kernel.org, alsa-devel@alsa-project.org
Subject: Re: [PATCH 03/16] lib,treewide: add new match_string() helper/macro
Message-ID: <20190508131856.GB10138@kroah.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
 <20190508112842.11654-5-alexandru.ardelean@analog.com>
 <20190508131128.GL9224@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508131128.GL9224@smile.fi.intel.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 04:11:28PM +0300, Andy Shevchenko wrote:
> On Wed, May 08, 2019 at 02:28:29PM +0300, Alexandru Ardelean wrote:
> > This change re-introduces `match_string()` as a macro that uses
> > ARRAY_SIZE() to compute the size of the array.
> > The macro is added in all the places that do
> > `match_string(_a, ARRAY_SIZE(_a), s)`, since the change is pretty
> > straightforward.
> 
> Can you split include/linux/ change from the rest?

That would break the build, why do you want it split out?  This makes
sense all as a single patch to me.

thanks,

greg k-h

