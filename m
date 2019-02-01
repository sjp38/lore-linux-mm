Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65115C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 19:32:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DE71218A6
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 19:32:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="c6V8PTX4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DE71218A6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A443E8E0002; Fri,  1 Feb 2019 14:32:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F3238E0001; Fri,  1 Feb 2019 14:32:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 908F58E0002; Fri,  1 Feb 2019 14:32:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7678E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 14:32:36 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a23so6415054pfo.2
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 11:32:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=RZgk2aNkCXaJYsnAWfrrVd2nngALPiWt3qNUKB1h63M=;
        b=Ub4w5hnSyTKW6rQBoukj95XpFdG3jexjQ8QxLSk+5GS87k5gCaneNXquQWeUUYs204
         4rrirO0rSrVtDFrtxVDnF1Uh8LPNyGjMBt2mfWTyhkiNd4cFfOiGOqS7ByhZ2s9OfiJa
         NW/2tZ8LqmNwFCNqJIZItZXxowCJS5pHxmhzY4FrG3BsaBqP5mMRHTvr+I6SDL3+QrFX
         PrqdffDxR0spmCD9K25Z15/lK9zJbUOQZvCN4Rveq4m3bGszHzepkOW5qaSxANm4tDVU
         vhdkaZu0iQpZ8Q1G/xCU8ABItaWff5eXIxcAxb2HJRYo/g0o2+2jLaBhgBEk3lUzMqBG
         ExfA==
X-Gm-Message-State: AJcUukcK9C8Vbil0IOY+8U6Pf9crUEGGsHzs2sOjUEvkOlLXls+7ijGO
	Yl1GoHE58ILR7YUGxgByLqXbDzs6OD2qVlg5H4p9t9DzmZLUSzR7DkKRm3hXjuwaRCtX+sHrANh
	H3udtXqEq09AGe8dgtYtjMJbH5xdrrj7YwVeM3PsYJy3WKiZ2Ga9Qa5YhZMladhwNAg==
X-Received: by 2002:a17:902:d90d:: with SMTP id c13mr35411751plz.31.1549049555757;
        Fri, 01 Feb 2019 11:32:35 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7X+7g1Sm7sSrDuJjm8kMzNSHU12Xhu+7xDgSZtQTS4L/NiCoqj6tt50LK3uadqwqYLuK/p
X-Received: by 2002:a17:902:d90d:: with SMTP id c13mr35411719plz.31.1549049555044;
        Fri, 01 Feb 2019 11:32:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549049555; cv=none;
        d=google.com; s=arc-20160816;
        b=WY4q7D6T1hKfGefeg2Y+3rcPHShdz6K0uuHXDY7+bs7tUmX3j+Xy28NBmAyGsuH8KR
         /JJA6hfpQXLSCrv5WUJepL+lyjX+hJBbXEmnmCM3ur/g18EGhC/sUzoAg/CqY1+oMxBr
         MWTNNdNrWqh+ZW86ljeawQbdOHILcYr+Byv2Mu8gDxCAfUz0J9+1b3LTYIkX1cEKgPVK
         Ve9GPX5aQyB72p1pSVwt8nvZ0QrZL3Ty96y9odefCFzn66gPWAgKT/qZq2M85bv1vbFq
         Y5dP1bFg+X8RrrpSaRSWtSZkkOuhDSpYpFDiR+HfiwsgB+eghIzlFKcMkfa7JO3yQB3S
         KhVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RZgk2aNkCXaJYsnAWfrrVd2nngALPiWt3qNUKB1h63M=;
        b=wEls9XTQoOu5A6SQbF/OUiyusZNyhpVwM5X1bxPcndtT9ydoPTg56FvXlilOY1ni4H
         MIfb8fUWlg9YR0zEfzWioZASc/q2ZZn6qpQesCoBPntuQZ33ZJK+xlsFh8OklPgIl+Bp
         vgBwVl2gvMQ7USOfmTz3ZjZjKmMvBOLOiD1RFGk99lMNZOUqjAYyItRvGFZuYdfh/o/8
         hWSwDq9cK4hMI8LQik2GSglVH91VcxzRjg/5dOD1xdJnOqM/zWvZo6L1Za0+hHz+/Brv
         CKq/pM5QIwVZRmacQTW4/Ov6iplUQjzX/p3GOO33Ha+7deIn0lYIdXyF6e3sr83UyEj/
         VNNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=c6V8PTX4;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id i7si8169632pgc.144.2019.02.01.11.32.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Feb 2019 11:32:35 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=c6V8PTX4;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=RZgk2aNkCXaJYsnAWfrrVd2nngALPiWt3qNUKB1h63M=; b=c6V8PTX4+DKazSfGI6GDwrdWN
	8iBJpvqK2/e6/mPs/sXmiQ9sB983gVxgEvu9H6EyIBbM/E5S3u3C+X/n9lgEgrAgJ+D3VNuH0kNjD
	gdSnmLm6UJBahTyVaYhEK6mrqpi8aDkqfqXwi2HScmvZUCuGqyXLNkfIHGWAnmJ2JK3DnAgJ5zaH2
	kbzmIcgfeFdcyZVsql2MIkpCe5CpvV0BV3NTCBu+yvFazrxUIXl+PlR7V0U1GKhT2dvwJKqbwnSiv
	bV2s9pCySiTKUKY+Gfe7I5/sSfzLVSvKK0Arxw6eVf2r8C68G4sIof7ju+GtmOtHmtRmXZhG/o0Vl
	kuvKz1H/A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gpeY7-0007ml-CA; Fri, 01 Feb 2019 19:32:27 +0000
Date: Fri, 1 Feb 2019 11:32:27 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Christoph Hellwig <hch@lst.de>
Cc: zhengbin <zhengbin13@huawei.com>, Goldwyn Rodrigues <rgoldwyn@suse.com>,
	Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>,
	akpm@linux-foundation.org, darrick.wong@oracle.com,
	amir73il@gmail.com, david@fromorbit.com, hannes@cmpxchg.org,
	jrdr.linux@gmail.com, hughd@google.com, linux-mm@kvack.org,
	houtao1@huawei.com, yi.zhang@huawei.com
Subject: Re: [PATCH] mm/filemap: pass inclusive 'end_byte' parameter to
 filemap_range_has_page
Message-ID: <20190201193227.GA11123@bombadil.infradead.org>
References: <1548678679-18122-1-git-send-email-zhengbin13@huawei.com>
 <20190128201805.GA31437@bombadil.infradead.org>
 <20190201074359.GA15026@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201074359.GA15026@lst.de>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 08:43:59AM +0100, Christoph Hellwig wrote:
> On Mon, Jan 28, 2019 at 12:18:05PM -0800, Matthew Wilcox wrote:
> > On Mon, Jan 28, 2019 at 08:31:19PM +0800, zhengbin wrote:
> > > The 'end_byte' parameter of filemap_range_has_page is required to be
> > > inclusive, so follow the rule.
> > 
> > Reviewed-by: Matthew Wilcox <willy@infradead.org>
> > Fixes: 6be96d3ad34a ("fs: return if direct I/O will trigger writeback")
> > 
> > Adding the people in the sign-off chain to the Cc.
> 
> This looks correct to me:
> 
> Acked-by: Christoph Hellwig <hch@lst.de>
> 
> I wish we'd kill these stupid range calling conventions, though - 
> offset + len is a lot more intuitive, and we already use it very
> widely all over the kernel.

It has its own problems though; you have to check that offset + len -
1 doesn't wrap past zero.  Really, it's the transition from (offset,
len) to (min, max) that needs to be avoided as much as possible within
a subsystem.

