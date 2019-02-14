Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F8D7C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:25:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAE89222C9
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:25:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="sRmxpgYF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAE89222C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A5988E0003; Thu, 14 Feb 2019 17:25:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 654888E0001; Thu, 14 Feb 2019 17:25:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5457D8E0003; Thu, 14 Feb 2019 17:25:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 156338E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 17:25:47 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id i5so4432531pfi.1
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:25:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pdhKxVVqmXpVOXlq9Z0kCS3TO3miCpdx6bwvuDnZVMM=;
        b=bndhV/6G13vim4ECkn9etAkfdjoOsWdGnRmqrexry4pZlRPbmKa3QsLlTJxOWe608Z
         HVZzH7dZYTo71UQifwTNyNcu18N04+XoikcPChgD9Y1luvCzC/dNSbhNz4CsaOFmFg/f
         H2sOlT5fANJRU142j8wjPuMOPTOKuY+biu9Jyd8PjGXWcjJdPwq/Kf+I6MIKoNRsHlUd
         CRuUPJpLzDhMcR4zlYyyUWWTG/UE9Ntjwm5QULTSrIctdt7hTITSRIfiBEEqz0G9Ns3C
         aafr5mY/eZ3gCI47cfauDWJEgB/kEYsa3qJNDnsk9jJuYnvymEU+JSnEjogEANTDj/Q7
         HMnA==
X-Gm-Message-State: AHQUAub2NDZ5sVBeDmuV/DEjRC5UV2Cryjzb7yf3+Go+OVU4ZFPPoLtK
	IQPtmP29intDXk1yeP/tiyYcjNQteLvPWfnLBzznj71Bh/QS54GimLR72nJdTR8vAISH5MxE7GI
	y433viNEs6sZ75gE5yIkgS/Mutf9fiEoGVGux6rCx4fzbX8Yz0CjJLArLY2CzwmL8ZA==
X-Received: by 2002:aa7:824f:: with SMTP id e15mr6373081pfn.192.1550183146779;
        Thu, 14 Feb 2019 14:25:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaiZS8kZCMFloMESGCSwbpeTgy1FJBxfAjTmBfMnFbV2eH85TZAs3Kv9mn/JktUJFJYD3gQ
X-Received: by 2002:aa7:824f:: with SMTP id e15mr6373037pfn.192.1550183145810;
        Thu, 14 Feb 2019 14:25:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550183145; cv=none;
        d=google.com; s=arc-20160816;
        b=JrdpXc+nawBioXZgmay2dfQR3xM5liVD5bxHPJIAyT5+IxEMF8P1yrzoB6YArD7gaj
         FkS7oGG2xGEyF5D1RLBk73TJwQt1Mvy3RMMD689Lc/l593zygkv1gF1axk3TjfXdNN1d
         a1yVfwT1Y94C7fLfB3KA7wBpusxyCXiMpYu6FcgFUpyI8UGTi/ON/DZ3peYvJkk7wDMI
         WBRjvMwgnkS7+mZhKzMx65/baaIxkSoU5/e8jQip0VYaCuVyFOUDiUc4HGeku042qP3a
         eRqQUDa/I47/DEnb/5SMH3zejJ7CDQdYFsDfOhx8WOCinvxpPW9dNRch4CHb1USwv0Gi
         ZAzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pdhKxVVqmXpVOXlq9Z0kCS3TO3miCpdx6bwvuDnZVMM=;
        b=00s3oUbhmgN5UYK2vYi8Qgeh9CzGrOGE402wgdf09Aof4q2AbTgcPgBnYiELXw1MSx
         0smiZahnl85uriQS9a7RmIXV0sGmvdBLGOD1zAkKecEdCeSYp4oITdfMBqFwO7Gh6vIl
         TXMq9/GvyBK4Gz9I1qGPXOX3zQHE0m+0Njt4LoApwbaEySCCvqwFlMT6DzIIOZZmdXWV
         8VpNm9HftwfR0+reolhZyjCyrxlnTHoJ13ueBhh7grFsqcYJXSIc11tFOPRKOTF0ayw2
         R678K30rQWJdH5sqD6g2VRnvlWHVttgcx0opytLqIczyhbY0aTAxUYjRCr088mvkcHUZ
         5XUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=sRmxpgYF;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z128si3584698pgb.372.2019.02.14.14.25.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 14:25:45 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=sRmxpgYF;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=pdhKxVVqmXpVOXlq9Z0kCS3TO3miCpdx6bwvuDnZVMM=; b=sRmxpgYFBjZqBxHYfNG/Vjxc/
	6WK3Iz5PSY3xD7ZBEWFmpYXymwkHbp7hKHd6Cz4ZVeaI9vURVsakD8MO9G+TKUzIaq9NWJW2PDf7K
	TvzmsMklmQnZs5g1oeLApfP4dn3/v9Fzh+wvJ/jI4cOwjeW8OyhsJRvYfshferKEdB/f+y/OkwrKS
	uZDWMvsqB9sA0MXmuGH+UULMnmJHF2FsNniCs2LikU4zNxEbKSSufcn90RDDjofCTIf+X5YC1QuaK
	b89bVrmLmhQUZMf9eN4N30BsxnRmW9D3P+dnmYjCOc9SlxXd8bqBv8+7vtjCowb+mHhi84+VSC2Ck
	AEf1npnGg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1guPRx-0002av-0E; Thu, 14 Feb 2019 22:25:45 +0000
Date: Thu, 14 Feb 2019 14:25:44 -0800
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190214222544.GG12668@bombadil.infradead.org>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
 <20190214205331.GD12668@bombadil.infradead.org>
 <20190214220344.2ovvzwcfuxxehzzt@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214220344.2ovvzwcfuxxehzzt@kshutemo-mobl1>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 01:03:44AM +0300, Kirill A. Shutemov wrote:
> > +		/*
> > +		 * A page got inserted in our range? Skip it. We have our
> > +		 * pages locked so they are protected from being removed.
> > +		 */
> > +		if (page != pvec->pages[i]) {
> 
> Maybe a comment for the VM_BUG while you're there?

Great idea.  I didn't understand it the first time I looked at it either,
but I forgot to write a comment when I figured it out.

                /*
                 * A page got inserted in our range? Skip it. We have our
                 * pages locked so they are protected from being removed.
+                * If we see a page whose index is higher than ours, it
+                * means our page has been removed, which shouldn't be
+                * possible because we're holding the PageLock.
                 */
                if (page != pvec->pages[i]) {

> > +		/* Leave page->index set: truncation lookup relies on it */
> > +
> > +		if (page->index + (1UL << compound_order(page)) - 1 ==
> > +				xas.xa_index)
> 
> It's 1am here and I'm slow, but it took me few minutes to understand how
> it works. Please add a comment.

I should get you to review at 1am more often!  You're quite right.
Sleep-deprived Kirill spots problems that normal people would encounter.


                /* Leave page->index set: truncation lookup relies on it */
 
+               /*
+                * Move to the next page in the vector if this is a small page
+                * or the index is of the last page in this compound page).
+                */
                if (page->index + (1UL << compound_order(page)) - 1 ==
                                xas.xa_index)
                        i++;


Thanks for the review.

