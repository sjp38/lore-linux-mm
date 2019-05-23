Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B5F2C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:45:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C58022133D
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:45:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C58022133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DE5E6B0005; Thu, 23 May 2019 08:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68E986B0007; Thu, 23 May 2019 08:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57DA36B000A; Thu, 23 May 2019 08:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3ED6B0005
	for <linux-mm@kvack.org>; Thu, 23 May 2019 08:45:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f41so8917934ede.1
        for <linux-mm@kvack.org>; Thu, 23 May 2019 05:45:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=w6Nm3klmpJAjWregQkU1uqRrDfKu5QPTnff+YgnXYLw=;
        b=id+jTFx/94Qwtt5j2RQbHnBgTue9M/IDFSmAbFF3KAuG7DHr0sSNhVFQsMcpPbZZO4
         T1D8H4AFznx/9d7QHUy89ao5m727hfL/0KW7fDoyfl45600qFWOYjfmZAoZz+fxJ20/d
         jpAXgFhqWW+2a/nExWnd/pE05b1vxJVuMksBYW4KDTxlx8WC+audDxenXd69WxPMwjNA
         TSF/vi73OTU0hWrnDlGmKgIXh1YcNciIBkwsZby6m2qGSQByorrpyRVTgvk9A6We5ikn
         Nceii0Jj+WIRsOUYiFICswprmyg2u/IKv/0O+STWP80uaYrko49nKB6OWfcXCRe1SEFx
         64+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Gm-Message-State: APjAAAX2f4zFJ3aapoJuA/9rW3lzRME4auSTAuLGtKhXQXj6dTS0ha5L
	X8tKs8Um3fA/+quXhQZ+WMlwIkCciwEOyHr78Q7+dojCMURWUEC8dkwwWCgGF7ZyrAwX7I4bI0x
	nAFXArlQKpzvbJYdyPYtYQ70+7jT8bcJbhpat11rSlHiORQOOL3/iU7ZdI3Y5Nu8L/g==
X-Received: by 2002:a50:bf0c:: with SMTP id f12mr97538731edk.181.1558615510718;
        Thu, 23 May 2019 05:45:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzu8s1D1uH1E6FRgFWViR1hjMSIoHE3oZBlxX1I0XmzNDMG0UsVRtw6lpDjHw49vyitLBUT
X-Received: by 2002:a50:bf0c:: with SMTP id f12mr97538639edk.181.1558615509955;
        Thu, 23 May 2019 05:45:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558615509; cv=none;
        d=google.com; s=arc-20160816;
        b=ME9Qu8IM1SLbNvnevCPkXvzhfFDFw1xA+VV0B+eTl37g0CseCcghGYo+92n6gJNqgG
         IazQJ5mxBDDEi9MO8F2/ljVKzWeTY0tAjqNlApGl5wm8pHj6YWeISeVMG9hh4ajiBlPn
         nQoqeMtlVFXbPhcCEN2vqdgbRRy3Bh6jzrOVR4FNP0ZfMTfwPSplTtSpIAXP8sfdNGED
         JQeVFak4mkUvTKB6Plpq+48iR/3GTSmDBrfs4o2ZhKCD8b5NtwYoaqZZ7M3AC2GFwHp0
         nd4kZBFPfzR7UblDA641jJhn9t8qzmyJPEZ6xLdHapL9hlJHLRg7CC00TQI4mfkwQyKN
         cT7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=w6Nm3klmpJAjWregQkU1uqRrDfKu5QPTnff+YgnXYLw=;
        b=Lg0CGO2ncLyPv0r0hAqd2MswGFIHfoNIJpkpfV3QXe6KfzClk8+zbIp2Be5BfLOMWp
         ZwUvsW/IheGOsK11zLPk48l6Z5ET7w7d3QSwkci/nFREaepp0Ycui/Gl/ubTEGWsuw4z
         LEXHExyTcFh3Ks8F9f7Su4eBZcWqCHArb3tz/SQt8mrPX7uuGwOXYJBg5crTjP4pfGb6
         1r2NZ58xqaE25RtY/uREUPjZmp+qdHRJEtcknRJltJRYAcJGbPg+fZTSuKxjp3x8itlo
         3GUbtglBLUdKLAhXPualISaQpmu4oJiOWbrbY+X9AGBo+9fJChKlrMrmaPXhqGFbo8ss
         Yrjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t25si4143117edd.368.2019.05.23.05.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 05:45:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 645D9AD78;
	Thu, 23 May 2019 12:45:09 +0000 (UTC)
Message-ID: <1558614729.3994.5.camel@suse.com>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
From: Oliver Neukum <oneukum@suse.com>
To: Christoph Hellwig <hch@infradead.org>, Jaewon Kim
 <jaewon31.kim@gmail.com>
Cc: linux-mm@kvack.org, gregkh@linuxfoundation.org, Jaewon Kim
 <jaewon31.kim@samsung.com>, m.szyprowski@samsung.com, ytk.lee@samsung.com, 
 linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
Date: Thu, 23 May 2019 14:32:09 +0200
In-Reply-To: <20190520055657.GA31866@infradead.org>
References: 
	<CAJrd-UuMRdWHky4gkmiR0QYozfXW0O35Ohv6mJPFx2TLa8hRKg@mail.gmail.com>
	 <20190520055657.GA31866@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On So, 2019-05-19 at 22:56 -0700, Christoph Hellwig wrote:
> Folks, you can't just pass arbitary GFP_ flags to dma allocation
> routines, beause very often they are not just wrappers around
> the page allocator.
> 
> So no, you can't just fine grained control the flags, but the
> existing code is just as buggy.
> 
> Please switch to use memalloc_noio_save() instead.

Thinking about this again, we have a problem. We introduced
memalloc_noio_save() in 3.10 . Hence the code should have been
correct in v4.14. Which means that either
6518202970c1 "(mm/cma: remove unsupported gfp_mask
parameter from cma_alloc()"
is buggy, or the original issue with a delay of 2 seconds
still exist.

Do we need to do something?

	Regards
		Oliver

