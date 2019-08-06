Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD90AC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:59:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DD232189E
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:59:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="j6NOly9E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DD232189E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CD536B0003; Tue,  6 Aug 2019 17:59:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17D9B6B0006; Tue,  6 Aug 2019 17:59:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 093A66B0007; Tue,  6 Aug 2019 17:59:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6FE06B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:59:40 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i33so49119543pld.15
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:59:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3qYfQ+bP7/64XjtgiW35HPdPjsot5sl43j1eBZY6058=;
        b=HsAyFT0VOqn1bVQG6gC3LUEvIYMW476JGOOoeciSyX5zA12Fau53tljobub6xqk+Az
         bZrlfrru6S0xvqeENQzeBvmWyvieb08ghXcSreMm7KLr4+EOy7Rd00nR2HYC9uHjCLYr
         LO4dep/1ncHw/2K5Fi4DvETMQQALNm42mbO1FrKvOCLbht/0a0zOVjP3s3dkX6RzUb+q
         i22EPUrlCx6DWbKXic/4mo960/XLBRjMFhpFMu5q0bfhtyzKpOPjUnfjbnl+BF3bo1+Q
         Ki2ACzzoxShi20Ef76D5u/qvMrGyyPchqXnHHofbApdkDH/EIRE+MOy+/TtX+mpMpZwX
         awqw==
X-Gm-Message-State: APjAAAWA2sli37RuXp+Y7mxnqSAon56+ynh0VEGTltmMdx1Vsa1Cfher
	rXfPZU8gcBElyn8CyfYMu6bTbmcoXabnuj6bfU0U9B4J2HKZe7YodSa51BXtnJOKtIScgHaN+Wd
	l3PWIz4z7Cmp6vKeK5eOArAVR/pxXU0mN9qpIq0EEKbZjZcbRF02RTMshMkaraqFRVA==
X-Received: by 2002:a17:90a:710c:: with SMTP id h12mr5160701pjk.36.1565128780586;
        Tue, 06 Aug 2019 14:59:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPhRJpC+NaNdWrAOnuhJxmq0UyhssoTaHeZgIYt+C7EbWBdG8CUQ1f3EXaFTkQva8I5TMe
X-Received: by 2002:a17:90a:710c:: with SMTP id h12mr5160657pjk.36.1565128779919;
        Tue, 06 Aug 2019 14:59:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565128779; cv=none;
        d=google.com; s=arc-20160816;
        b=RHEGsUrjiOzRkd3mDli/jHhQLfLu8vutues12796R/8qkLeWukAE2s4q18Hq/fZH1Z
         /nY1iO0HL7c7xnkCkchpKBUVEKsjOJkFyBwj920/K0hoXn3Qsh4pMLg+kQPZQFti3+hp
         8k9F0LxVjV49WPv3olX6n1hy9hVPHKbrU2VnXUXIwrVMK4HjPkFmpll3a812BLY90BS5
         xF+D0m5eTjo3Yre2h89R6WNNS6FeJaWPc3Cri2T25OnoDII+hFR/RHNPz5EJbeo1AtxN
         mYYrcZ1loy00sGJpWSGh94CNCtp819J75jF+NjBOnXArtPmVE6YokfNsYOWcevF50uZ1
         rZng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3qYfQ+bP7/64XjtgiW35HPdPjsot5sl43j1eBZY6058=;
        b=hT+5/DPaBXmFyO64jPqQUuD4P+L2bN8PvU+iG5bTT8bldvzC1IgmsWrS+qWSIJ6iEH
         ZefESo2oRaNqrabkKjtigtxnFpIDY/8AqjfLo5FkmLqbyehS50Y8y3I9UnozXpQBDNgn
         a4IvowXWtOU6YKSMWsXLag6y8hzF1OdVL5koElX8pZgm1Pv8Ev2e4Ttvlsv+tIQJeVV2
         4a7Dc6mBuUr4ddsayqO8z/uJlqoy8TC6gdkG0CMr1nVhg5ydN2urJvQIYmhUJ3f+GDE0
         HoTELkFOze7VHcc/BUhxGdQA7LxC2HGCWEc9yGjXuvIfIpGqKVSCpvx9mbh8ZSrGEjxI
         YqEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=j6NOly9E;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g12si48907547pgu.319.2019.08.06.14.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 14:59:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=j6NOly9E;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0619121880;
	Tue,  6 Aug 2019 21:59:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565128779;
	bh=1RMsskiZ8XVMBQDTVxtlNFNMusXQHddlOkDSsewP6+4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=j6NOly9ET/FlzEE+ReFef3quZD7dSpaM+K0YBXtz8VA+vS7c/LWFxUf7A6bBL8CV9
	 8lFAYSwzFCE9PoeQHnP/wrsJ9gdeQqyp6VATDTbxOZ7DIQcrH/evgl1FraCbvtbHiC
	 DcJ4axHUto1TLm98VHwM3J4vnkw7n0A1bzc0FGqw=
Date: Tue, 6 Aug 2019 14:59:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: john.hubbard@gmail.com
Cc: Christoph Hellwig <hch@infradead.org>, Ira Weiny <ira.weiny@intel.com>,
 Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse
 <jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, John Hubbard
 <jhubbard@nvidia.com>
Subject: Re: [PATCH 0/3] mm/: 3 more put_user_page() conversions
Message-Id: <20190806145938.3c136b6c4eb4f758c1b1a0ae@linux-foundation.org>
In-Reply-To: <20190805222019.28592-1-jhubbard@nvidia.com>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon,  5 Aug 2019 15:20:16 -0700 john.hubbard@gmail.com wrote:

> Here are a few more mm/ files that I wasn't ready to send with the
> larger 34-patch set.

Seems that a v3 of "put_user_pages(): miscellaneous call sites" is in
the works, so can we make that a 37 patch series?

