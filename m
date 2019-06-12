Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61B81C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:14:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27CEF208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:14:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SlKYE6/0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27CEF208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF27B6B0269; Wed, 12 Jun 2019 08:14:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A796B6B026C; Wed, 12 Jun 2019 08:14:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82F726B026D; Wed, 12 Jun 2019 08:14:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A558F6B0269
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:14:07 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id c4so11228119pgm.21
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 05:14:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MuB134CvZ+ahtWza/rg2L29zFcKfvY+JEgj2hbgZkKg=;
        b=H/l2MqWFW+dL1qqr4qKoMwqM8duH7SybXT3vt3Jwk3yvkOTfK59G9bd1LZVUdCSbtB
         QpPaNIATIcCSd+eu3RAZfwDHV0NSxqU2BTwPNi6Uoh+Ug+N9U+RFqjE51yyiFGDr3cy8
         HnwWhd5NgfbVqynNqvYfiPT2w3mdl+liFzAa1tUBagjTazIRELlD1N415vCws3S3o+nA
         QQi4gKGcFYb7HZkzeCnq7lE6cbcWnl7+NLERPDd3tNjHhI2sAE57q7zB0yRa2aRstF0I
         W4DbTB3G03AUgHhkgjE4vPu/ma9IkoVpJXMU+OGz/h+FVpPYbaQgJanN8qWn6W+usQjg
         WbNw==
X-Gm-Message-State: APjAAAXUCWP79fIrCWZH2uKATW/WRRbFLVBnmPsmd08XnTMWQeOMMG23
	ln5C/ODMBvZheGvLI5IEUxIoM1t6Mr7tsassRHX6zOR2yCC1cv4uZrRUTHjHDMhAFCkjpoCyLq5
	Bwyde22D+OQ5VRpr/qgcx1H40TbrUk882iK1ZxMra5SMNhJ0Vn+U0jcwBOZ4+KuFelg==
X-Received: by 2002:a63:4813:: with SMTP id v19mr18634905pga.124.1560341647216;
        Wed, 12 Jun 2019 05:14:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFFa4kPBhxfm2ZFg7xSvIh/QfhQ1To4OQBL53cRrFO28rujTYocrYVwn4CicKVZc2LPnib
X-Received: by 2002:a63:4813:: with SMTP id v19mr18634868pga.124.1560341646604;
        Wed, 12 Jun 2019 05:14:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560341646; cv=none;
        d=google.com; s=arc-20160816;
        b=GbXIKgUmOh3xm8ld/2YrFPSTcZDRjIP7r7ee7trSNQu7NXsZZPpOJPmT2elKvtKwiF
         Goliw/EqxiTwkjRnhsEMWgTSIB0IXjIXk++4/+kpoVenlJST2rn1Nbjht0HIDifpeW6X
         htO/9+qkZxv7Fs8yG7fcm9IYKwqBKmTEqlAqb9Kz8437hFHwD0vyqoNFcOeIT62H/256
         vhf6Vvlfah34WbWoEAdTvVnSVJmuKuJ50y7CY5z9RWGu1rmhuPJSyPFjtjyfPF7xBXHH
         SgV9S+SAmLvdKIKTUMBmLRwj7PFirWuaF4Y/eLFEEe8M9gKqSTyvl3ZdcWL1GkdTtXZn
         ms0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MuB134CvZ+ahtWza/rg2L29zFcKfvY+JEgj2hbgZkKg=;
        b=eDC5AQ7DfXBqFs7OnRFEKds5lyWmaPJ3VDEQ5Pm/TeRCkHlL+HRlvtjuBhXsXm0H/d
         FCub3BHSyIWllinShc7/YHQmwIHRSfyat7f92fi9qCfUz+VaYMIEFEqReJ8Nm5WikcB6
         296fiKtPtrzWBfyF0djb7qD9hbyrUab43BH8wKupkkidSGeUD14vafWgyLwF1fUQVFKE
         fAoxNSqkhvWw7QupjZtCWq43egsLcxVL/bS7ViM1QSKCjvJTsLxmxm2x4zO1RgeQoh7K
         Pao/HunqDpoaeMLTAF6030znH4VG+NPerDxycduX+KAHfuyZxFewubhIDSmfuZXTrySj
         Nrqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="SlKYE6/0";
       spf=pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h11si7917486pls.374.2019.06.12.05.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 05:14:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="SlKYE6/0";
       spf=pass (google.com: best guess record for domain of batv+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+eeb336ffa9092f1fc134+5771+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=MuB134CvZ+ahtWza/rg2L29zFcKfvY+JEgj2hbgZkKg=; b=SlKYE6/09sXEUzAquFUIC06H4
	msOpbvssFhXh6ebKsUighYE+VEdtmnZjrewFXkyiRYxSAQl/WcvFnZYa0b5FwldmGrKVenMSco9E1
	6FWfB+y0e40Bab9kX90noMMR2gFA5dR8H5FpHKzGw1Ltd5p5BvYCWVLY8ROHgcaghc3FGyacUrgO7
	iSHfyUeY0lSHgCslfC/lhjt4BByLi6AbKVYLux4inMb8UDigONXt70fjSU37Arnqpwi7dbv58VjEQ
	vH2hAYeAPbYyjpGX0Jqdl0Ni7A0BybKwlb0QiRCbr400bcOMxDtEOfDtTXiA/WIcNvTpfTxDT3UAR
	owMPzAq9w==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hb28a-00011T-SF; Wed, 12 Jun 2019 12:13:56 +0000
Date: Wed, 12 Jun 2019 05:13:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Thomas =?iso-8859-1?Q?Hellstr=F6m_=28VMware=29?= <thellstrom@vmwopensource.org>
Cc: dri-devel@lists.freedesktop.org, linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com, linux-kernel@vger.kernel.org,
	nadav.amit@gmail.com, Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>
Subject: Re: [PATCH v5 3/9] mm: Add write-protect and clean utilities for
 address space ranges
Message-ID: <20190612121356.GA719@infradead.org>
References: <20190612064243.55340-1-thellstrom@vmwopensource.org>
 <20190612064243.55340-4-thellstrom@vmwopensource.org>
 <20190612112349.GA20226@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612112349.GA20226@infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 04:23:50AM -0700, Christoph Hellwig wrote:
> friends.  Also in general new core functionality like this should go
> along with the actual user, we don't need to repeat the hmm disaster.

Ok, I see you actually did that, it just got hidden by the awful
selective cc stuff a lot of people do at the moment.  Sorry for the
noise.

