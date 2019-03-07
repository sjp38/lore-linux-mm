Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27CF8C10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 15:06:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD89120449
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 15:06:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hcf+6bUq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD89120449
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 680DC8E0003; Thu,  7 Mar 2019 10:06:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6314F8E0002; Thu,  7 Mar 2019 10:06:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 521A58E0003; Thu,  7 Mar 2019 10:06:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 122548E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 10:06:27 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id u8so18085510pfm.6
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 07:06:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qb+k4GhrBX2hxsqg3i9im3MoXFh0HQnNOWfXG9OtdlM=;
        b=hZIm7oawewk8dM67AwAX9gTDfUntfzO/g+L20AcXCsRcXWHxqCWw31l7SI3cY2vGzS
         Cdpto9kwKXhFWa2mUSV+QpgMLKYFYfV5/oAGHkouJpBR7r6386kHWTMVsKpaw6okSHT5
         qmWxjrot3neKAT4E/Afh77I6Kb7oaR2TzVF2mmhl+tza2y+j8bcdPhPTC+lPdqEueN7h
         7DwOD9SGB1CUi1MoIX9/2hZqO5JiYEJE8uX/gXXxQkFCTHHZE3JMDh0WdBkylh5F3UJ6
         HnCv4kwQcoqB69uT2n8JqsIeo5dNl0tCkaV1aOltT35/c7xe1L1cJMRv1Svwfg1FAisY
         wqKw==
X-Gm-Message-State: APjAAAXVre/HutLi0qCyYCrWj9t8PZx/XbPNJgsW65geyocciBRPSGWP
	qPgrgFZ55tinVVvvy00BrbrxyH/lpDapsPY+FypT0GAGjHsfkVt8Ek+a3JNp2T8B1pwc8cBeKJY
	S6IIe+5ku6qn+bYCDPMwVo0RDWbBlqw4VvNvuZqhZEYx9Rji9G0jkNBlQVnIcT8OZ2g==
X-Received: by 2002:a63:cd10:: with SMTP id i16mr11422194pgg.90.1551971186586;
        Thu, 07 Mar 2019 07:06:26 -0800 (PST)
X-Google-Smtp-Source: APXvYqwyL1JBrkyERo0XFpZURwSgVtfFlXCbIT8wAmgI7CwIvL0VH0VpAYbzdy7ZEVX7yznpsWJP
X-Received: by 2002:a63:cd10:: with SMTP id i16mr11422095pgg.90.1551971185157;
        Thu, 07 Mar 2019 07:06:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551971185; cv=none;
        d=google.com; s=arc-20160816;
        b=Desb3KK9yQ7Rxd10I937o/3aEcoi1A3cRS4Y0YmeoJTnXkgzE7D8OdH6tr/PkQBSZA
         5WcoTWzZe1/mR/K3UQ148pv76G7c9uCHKpKKUEZxGJBrGHAo9np5177DJUy6xFP1fd/E
         5YA5UPKVA9TAYXrigEB9Jyx2YlgPw/KeRJylxFCNWvU31H5lUL5shgZRoYJ6x0f5HSBq
         uKKxqMNhWwunAXNuv7Dpais3SMM1vu+OpjWVwxuvBJfo/IOX5CMCIzG2SnHDcyYRTW2G
         8EsAu7eTi0MpDuFt1dJoYGKATlepWUSZ9bu6H08HQl0jSwgyQdD/voPaRbKNsTv8eYEn
         fSKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qb+k4GhrBX2hxsqg3i9im3MoXFh0HQnNOWfXG9OtdlM=;
        b=OUeyNBWTfrSHkptyMrJDv29V63Hfd1dUekyTjjZKxt2NjU7MyVad0JCTjW62drScuQ
         ACd5k7ModYG4eB62AXxFoqH/1fy75AXFNvTsjkaQ5m34fDsqr/MkHZxLqhjAUpyIaRuK
         lni2LCLMcMUfql9X0R4fGBybozU9rPPp7hB3P7QnLFVoP12r8deoIs7A0oyilaJbm0kD
         1qPJ0vQAbIEfnVKgcvFjoCnnR1zcvfQONTxRdqE/HibMaR1O8UD8Mu/armW4lykPtrSP
         t5Nq4g2w9c/Y9Yedz8KkPFYFG7+nGyD34FgQrXsJt6L/C+QVeldVTOiNzBxbBJ2gh5ci
         GDVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hcf+6bUq;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id cy1si4698286plb.429.2019.03.07.07.06.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 07:06:25 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hcf+6bUq;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=qb+k4GhrBX2hxsqg3i9im3MoXFh0HQnNOWfXG9OtdlM=; b=hcf+6bUqLpzgnUybBrYqB2G8Z
	UmmQcyI+2HIvQ9/9P3mpkBnEdqombSYLvaqqgyJKyY89ZsAONGFwjRH8ebdUoaPTpiEH5w4+TcOTq
	RLivVxI3g6nzUUEQjhHl9fcEWv+qn52w7zxcRpTvi8AS5A/kJ8OejMz3AoxjUyhMQn4s40RTLlGWR
	Fdd8SchL2qZRJCRGTBQzaTMtRqfJA1YUGSz2v9QTcTRpvqMNmB0hm/PygVem4AOpBOHoDjhLKMkYx
	pgwhbailvbUIl9xKaqyEIofDgJdoWdYpmsHscFfvEKNfpGfDoT8eLSZ4QXy1ZnTlzpt/FuQ4DSNBG
	HvecyzSNA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h1ubI-00016F-1H; Thu, 07 Mar 2019 15:06:24 +0000
Date: Thu, 7 Mar 2019 07:06:23 -0800
From: Matthew Wilcox <willy@infradead.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux-MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org,
	open list <linux-kernel@vger.kernel.org>,
	Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>,
	Song Liu <liu.song.a23@gmail.com>
Subject: Re: [PATCH v3] page cache: Store only head pages in i_pages
Message-ID: <20190307150623.GL13380@bombadil.infradead.org>
References: <20190215222525.17802-1-willy@infradead.org>
 <CAPhsuW7Hu6jBn-ti7S2cJhO1YQYg_RDZUgkqtgFO8zpBMV_9LA@mail.gmail.com>
 <CAPhsuW5a8=QJe2acWXQGWic1a=CJigwPR6BxSu2O2vg4W1mhzA@mail.gmail.com>
 <863F9255-E992-402F-827D-DA5F4661B9AB@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <863F9255-E992-402F-827D-DA5F4661B9AB@oracle.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 02:36:35AM -0700, William Kucharski wrote:
> 
> Other than the bug Song found in memfd_tag_pins(), I'd like to suggest two quick
> but pedantic changes to mm/filemap.c:
> 
> Though not modified in this patch, in line 284, the parenthesis should be moved
> to after the period:
> 
>  * modified.) The function expects only THP head pages to be present in the

https://english.stackexchange.com/questions/6632/where-does-the-period-go-when-using-parentheses disagrees with you

> > +		 * Move to the next page in the vector if this is a small page
> > +		 * or the index is of the last page in this compound page).
> 
> A few lines later, there is an extraneous parenthesis, and the comment could be a bit
> clearer.
> 
> Might I suggest:
> 
>                  * Move to the next page in the vector if this is a PAGESIZE
>                  * page or if the index is of the last PAGESIZE page within
>                  * this compound page.
> 
> You can say "base" instead of "PAGESIZE," but "small" seems open to interpretation.

Agreed on the spurios close paren.  The THP documentation prefers the
term 'regular page', so I went with:

                 * Move to the next page in the vector if this is a regular
                 * page or the index is of the last sub-page of this compound
                 * page.

> I haven't run across any problems and have been hammering the code for over five days
> without issue; all my testing was with transparent_hugepage/enabled set to
> "always."
> 
> Tested-by: William Kucharski <william.kucharski@oracle.com>
> Reviewed-by: William Kucharski <william.kucharski@oracle.com>

Thanks!

