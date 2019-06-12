Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2205C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:00:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 899E4215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:00:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YrZ7aTZf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 899E4215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CA206B0008; Wed, 12 Jun 2019 13:00:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0543A6B000A; Wed, 12 Jun 2019 13:00:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5D0C6B000D; Wed, 12 Jun 2019 13:00:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB3DB6B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:00:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y7so12420560pfy.9
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:00:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ntWDNfgCNc/sndoYBEa1e+idBiANLDkzcnLcfROE1SY=;
        b=PdqDyx0+Hfm6d6N2LOHwxu/OaZ+xFqgut2HwMUQx51PXbwP4CPoXQ+SUmvkiahFAZx
         75JEaIPCpxBb8V3xLwbSI7s3xHkOXkApiwd7g8G9bT84jWEF4ZUKL6UaDnLJebkrdRRn
         H8Unvozcf1ZSKWR0ABvXAc8c7RW8YzdIbLLzZcJTo0o4HyYIevoNWLx24Jj53eyo9/It
         jUui9Y6ZS/t4R73BdFk6BS4MJF06YydlqgUX21u3HECh91nSMhq+uHJWOhpgTjQgMUu0
         6J0Jg+TNn6qe3CN/nS6dvmH94DlvrNEyYjINEE9zuo9BoW6dE1zkSY1XFjMEVEVjZ1QD
         ZPyQ==
X-Gm-Message-State: APjAAAVwTjW2taPGbYDoKL2xWmGT1Sfp1jX7UrBX3ZoeIaoxepuwH7kS
	1MOBVXTcXs4qRYPeA5lmy8v2JvIKueevVzfpaw18y5XdcMYNYq7UMqs2KuvC3HkTgevUVVxpUcQ
	sgYrmifQJBC3xro5jz2HaJ1S9Gm/AAWxZUUgzdYheDdnj8ETOK5cjfMm6JnkXVqd4LA==
X-Received: by 2002:a63:1516:: with SMTP id v22mr26696784pgl.204.1560358838324;
        Wed, 12 Jun 2019 10:00:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytqtF7x75orU1vRld/yp2C2u/N7UECqvMsDQYvsffctpLJNw5p4q3XnlF/RbELb6Vz/WDB
X-Received: by 2002:a63:1516:: with SMTP id v22mr26696719pgl.204.1560358837430;
        Wed, 12 Jun 2019 10:00:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560358837; cv=none;
        d=google.com; s=arc-20160816;
        b=mZbLaCQ42QDEKZlkRKljyUo0TENHrLD0pJfSWT7KVQMgwwq73OWOA3RXGu4H3IEMTS
         x+JQ2NWkYTXS672vEjmX9bwkl30V9PU7qenvL0r25LIljFsHIPaBogDA6OqOe7DrWdp+
         E/1gKvV9c/FAPpGIk0s+ofIerbfMUwNMVIehbqutVt1J093m/eVO3NEmCZ1WAGZrQpfn
         dufvVpePWWr0VonvZsOuy/0mt8itVJZBf/x9DmryXjwZFks7NNiIXXulzMVqbZ/T0b46
         Lp8LJ6gNxft6H03wpmtNILiJsxnc013NSq/qlvXlWKoPijbr7qnVXXi8bhPybQmwqpt/
         Me3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=ntWDNfgCNc/sndoYBEa1e+idBiANLDkzcnLcfROE1SY=;
        b=L27gXjJK643LH6cR0CxfT28zEeSxgSRcLp5gyHyA/P1CViIgwEmov+ZWtYWiyE9M4Z
         dMh0XymcxxdOklu/1v9+FKq8fbJRuRICsaiX4jYnFu1P63wJfHcXcr/VJsoSVvBblyzb
         v/gFxidGHfhE4rQFMuG+uvd/MEdCtNqb7e5t+4MsEkO7ouG8MYO48XkV+WMS7kKExuBn
         bDXXIlT+mIyXLH01GtoN+Z9fkhRuzskVrN2uJyTaj2Ad6fZm0hE/bwwpBkC10hmhFW/g
         pzizs0+hnW8n9FhoKaNWpXHGOgq81A0+9z2lwOUfWn1B/MfsSZila38HJKWS6ohrd2nj
         KZ/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YrZ7aTZf;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f15si303073pgi.56.2019.06.12.10.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 10:00:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YrZ7aTZf;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ntWDNfgCNc/sndoYBEa1e+idBiANLDkzcnLcfROE1SY=; b=YrZ7aTZf2lH6dOw36x7OfJ7HZG
	JDXb9QvjQqfl8BtXA9x04yG6aQl/qTNDN8eCSI0VqNbXzJIC81iw+vy9B/fhS3uM0sNd9txORD+s4
	oJJGz+SZAOxxCX5aQUNvk7y09p9YfwfabsIcNusBi59Eu2YYn0Okw1D3drqE+J/v24+EAre78/vdj
	2MRLls7NG9naeJ0Lp+pU/yE+7bw0wlEPDkmOb6UkgFu28+cSXU+MAvjhTFU8F6Ag4a8Mo4sDavAv9
	1CvnVSf1wiqL+le77gmkRpOmyJ62SBr8T/izEXJtUnEQ232zgWapdXoINmv6sMXJuwV/6xfdh9yUK
	YBepZjxw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hb6by-0003OL-Vj; Wed, 12 Jun 2019 17:00:34 +0000
Date: Wed, 12 Jun 2019 10:00:34 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, gorcunov@gmail.com,
	Laurent Dufour <ldufour@linux.ibm.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [RFC PATCH] binfmt_elf: Protect mm_struct access with mmap_sem
Message-ID: <20190612170034.GE32656@bombadil.infradead.org>
References: <20190612142811.24894-1-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190612142811.24894-1-mkoutny@suse.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001942, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 04:28:11PM +0200, Michal Koutný wrote:
> -	/* N.B. passed_fileno might not be initialized? */
> +

Why did you delete this comment?

