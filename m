Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C110C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 14:29:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 298AA20665
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 14:29:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="XlFx4Er3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 298AA20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB6CA8E0087; Thu, 21 Feb 2019 09:29:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A63578E0002; Thu, 21 Feb 2019 09:29:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92CD08E0087; Thu, 21 Feb 2019 09:29:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 481D18E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:29:14 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id o67so3261052pfa.20
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:29:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=q7Plgd2VjZ7JF1siNpI9/Bd0XLypOxPttlEVaXo3BAs=;
        b=Y8OhC8krY2m32KWR2VKVIGY1/jhMs7IDWw7nOCvzhwhbgODSX5EnHv7sZx11z8lpmV
         9qKElOG13p88O64oUcJnXcHWZLAnG+MTdR6B/uwEqpJbSyQ8aWJyogo2raGMq4Ykx2kd
         9H6bGgvt81rv3YR5M+YwFs8CWqJSCYgucjXlr4e9yS753erlfuPMahrHp3og0cpJIe12
         okXTHEcpKMI/GL1NyCzvdkzrteXMwnltj95uxk50ww42nT43CEL7rQ0LAXWr9EQk/ByH
         8fHmBf1q5utobGoq2DFoGrd40LdWsJ8Yvd0ssaaVt9/DXWhuYYYCnxa3g9YRIqeBq5iS
         H9jw==
X-Gm-Message-State: AHQUAuYThA6CHq/NjXBPsgyAm6VCyxW0NMghZDAguFGWGivgpB8YYiSQ
	71Z+M/0lLdA2eo8Ud4ApOwt+bMbBeCCWcjXT7snDsiIeZWAwwoRQFXEkfqVzl42WJEOnzvQo2s0
	XBNLvNDd6fa6xC1EjYdQ6pmBSn7MxyMEAbRKRUeK6BZ7pKk3l/CiOI1cj2jwtct+1cA==
X-Received: by 2002:a65:5788:: with SMTP id b8mr17193921pgr.8.1550759353863;
        Thu, 21 Feb 2019 06:29:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ1vhdJIJlZO+LvBVswOaz3kU7IhIkj+dsv9h4gRS/qcGiJOmTTvQoGDu3MLhVkvkNSuti+
X-Received: by 2002:a65:5788:: with SMTP id b8mr17193874pgr.8.1550759353152;
        Thu, 21 Feb 2019 06:29:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550759353; cv=none;
        d=google.com; s=arc-20160816;
        b=eagvzGj8CWq+1mYGSlUxqXVzmijcLo6czh/xbf3zDr26Qh+UmXBdWrUIYfuVGv6JIX
         EQXbdUh+5nwjHZKBQ4dMy3bg1UZOfQ1sn5e1k5WM5+O43tNxjMYCJ/LtvGt0ay9Jyygy
         adaoIbbaBheFLiXY4OSBJGarCQHHxTP5Ok2ddeaM4loM7LR1AzeNaJ92P3LT32/ufPjp
         3bxR/sViB9jetVbVKsTZkIrdO1NOLd+ijQnpVz4wljrTDDkA1wBWEyyh9r9GhHRuJhY1
         LJMX6biKPw+5gG+pA6vGXmwSzS7uU0DxclT8PbEmghKCS1kbRDwDVjWBD62rmi7GHzN/
         NT1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=q7Plgd2VjZ7JF1siNpI9/Bd0XLypOxPttlEVaXo3BAs=;
        b=JlVf+PVHqle8zRxyAHp+t+odoIwCjiR1azs54BzytUCdbCsXUkvoc/QGhe+WwP/aqt
         gd5noXmx/fv/P+9fO+Hzdvm0FjFcanHaHFW4dNoOJiq0VcpntOIvi8E/IhSp3gp4WQhc
         7QKZOXg2cwyeVjoiOUQboD0Oks5YLJtwxeDN84BPpPH3o2NB8VO7f+HP5EgkC2o54wpw
         ImyPDNYj3a0R0I3hq+FikxPXnkEt+DhFaKTsCmz04+b3Iu1y3gPvBNPfQwjVW0iNV0ay
         nIbCZYnXmXIDnAuEQv+Ak5UDRMxZ2Aw8XtYBuO98peotJjePKXgPpZ+NyQT/bqRzVtUf
         zuAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=XlFx4Er3;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n19si20605246pgh.564.2019.02.21.06.29.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Feb 2019 06:29:13 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=XlFx4Er3;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=q7Plgd2VjZ7JF1siNpI9/Bd0XLypOxPttlEVaXo3BAs=; b=XlFx4Er3TnqnV+j/O5apdeAFL
	IEoTkL+TPTt8zcFI5isnO4AJp9V/dFawTHAQR0Ts9gTb9s8wUWRkWOCi55Md1/GHsY91hwcXRAq87
	T9piXHKrgmfyEl2mNItox7MC1MlcwTXNTHX7mDuanOgNxU985dmrxf7luiGGSXwWbKrfzzUPGmS+U
	a6x+1U8Rq0JQFaStVbZu5mA3YNCnxuUvKEAHshbFXvfWAOBLNwMQSaCzP/LJkd+nGUKfV40nYK2J3
	cxqSZbadtZwF3QHCjG0QqBsW2ia6U2SQ0Gmd4eAZ+adHdBzBSeq4aa1ul8A4VY53yhWKiU9Yk0Z1u
	EhxPIH67A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gwpLc-00072J-6B; Thu, 21 Feb 2019 14:29:12 +0000
Date: Thu, 21 Feb 2019 06:29:12 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [LSF/MM TOPIC] reverse splice
Message-ID: <20190221142912.GP12668@bombadil.infradead.org>
References: <CAJfpegusa=r+sdbsTx1ybq6FMKy5Zp=L=u7viRYbndYiRLJh9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfpegusa=r+sdbsTx1ybq6FMKy5Zp=L=u7viRYbndYiRLJh9A@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


... also, this really needs to be cc'd to linux-mm.

On Thu, Feb 21, 2019 at 01:56:11PM +0100, Miklos Szeredi wrote:
> rsplice would serve a similar purpose as splice, but in the other
> direction.  I.e. instead of operating on buffers filled with data, it
> would operate on empty buffers to be filled with data.  rsplice is to
> splice as read is to write.
> 
> data source -> splice -> data destination
> data destination -> rsplice -> data source
> 
> One use case would be zero-copy read in fuse.   Zero-copy writes work
> with plain splice: page cache pages or userspace buffers are passed
> through to the userspace filesystem server as pipe buffers and they
> can be directed wherever the filesystem wants.   The reverse doesn't
> work.  There's code to attempt stealing pages and inserting into the
> fuse page cache, but this is far from being as generic as the write
> path.
> 
> What do people think?  Is this crazy?  Are there major roadblocks for
> implementation?  Would this have any other use cases?
> 
> To me it looks like this is pretty symmetrical with normal splice, the
> big difference being that uninitialized buffers would be passed
> around.  Obviously must make sure those buffers are write only, i.e.
> the previous contents are inaccessible.
> 
> Thanks,
> Miklos

