Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9240C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 19:34:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85DBF217D9
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 19:34:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VGj5f8mT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85DBF217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA2458E0002; Sun, 17 Feb 2019 14:34:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2ADF8E0001; Sun, 17 Feb 2019 14:34:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCAD28E0002; Sun, 17 Feb 2019 14:34:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86FA18E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 14:34:39 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id q20so11079348pls.4
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 11:34:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ci4uWoH4MBnwWxuQBmGDuzl0iJ8j/tRWg8gzhD2bYUc=;
        b=XR8Binl3tw3IoTf632w03GPV2baN4tAEQrSDuIbRc1vqOJ4eWpfRIMxlHHJJhS5Mb7
         jESBlVoe0xK929DUUulZQahK/8Iwa+V349zKXzEVwDm2XVLDzOoMl8f3ffYfhW6G7/17
         LabYlcuHc9vtll7XzLBv5zCSMqNEtbxesv02CHTwQ/c8OrD5iMjGvAEdrPAiPZ6ox6hd
         DXbJdH0tda9onZ9np1CtAPz6ZOj19PujuvczGF09x/+NATJFcmExqcY0vANqJbF5tBcz
         fL91xZ7FxGCaoEnrQPmHoDrXcNb5n1+0ecFPeIzTIj6hdkoaq777VMgaIdoaxpAsInjb
         FSJg==
X-Gm-Message-State: AHQUAuaA2jULE7Bk/dHxZFqlNY9UN7aluPywXYIHx5tZgVCA1NLdRMGV
	mUQgZcQlc1IqN09nm0FSWoXLLhRuMf3EoVxdMqZ6i8V/wA9HbUNR8qSbk0Xu2Oa1m4Yu+huOGy6
	CbnLXH0zaubw0za5p7+NOF5gA3MSt/g+JB41VU28htLeOYcJ61ozd1tGZwVAkHAYSGw==
X-Received: by 2002:a63:4342:: with SMTP id q63mr15469563pga.63.1550432079111;
        Sun, 17 Feb 2019 11:34:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ7kgjJeLkNXdUaVAzaW/pasnMSEYlMrnwt1w9hKbDzzlvduo5N/Cq6s1fwx9IesQisTPJK
X-Received: by 2002:a63:4342:: with SMTP id q63mr15469516pga.63.1550432078365;
        Sun, 17 Feb 2019 11:34:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550432078; cv=none;
        d=google.com; s=arc-20160816;
        b=QvX2786jE65ZwUDIZSKzbidZiadfNhwRM6QKiaUKAiWtX8hBeKg7SfsVSmJ02atcHI
         tJFU4vJvzLPZN4vn8tc58/JiC2v9z7HSfQeLcpX045PGAFmSSKemLtVupOSMMD4gj9Q+
         gQAs7i9H50IiEOR51aYl7xxLlILzS61iPvZHDRjhm3ZOAwNVcSb/nQLdJy/KXstjqsaG
         53u9RnkT4JCvMJG/dKA7O/1l3ljZWKu550m1a3mfpHHWR3tnPaFO3AUth2rtTC3jrRSm
         vYB9vFwTNWJXOcm80IORl3zX2PgC2/8oKbtP2pcMC5y+ieuqwgbdth3DT0hCbretpZaW
         YtuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ci4uWoH4MBnwWxuQBmGDuzl0iJ8j/tRWg8gzhD2bYUc=;
        b=BB4FPtF1A/z1ZlC5KwRgScGSIEXDQiaj0TJi8p2M1qA8F47lN4KJb7IQ3YDp6BLJxR
         NdMvXWTrjKwvua563bV0c/pUB0uUa+szFnEJk8XMW/Kx/qHgewGkiQsJT+6l+9kSp7kx
         ftJkAO9I+naEJ1/TzgfirNVQsBAQaoRejVy++sM2Jpny7sA6jlTUSfuu0AvEUIR7a1Yo
         MQ1mzMAV2mXRImCx4zuxv0JsuZDEviH0AlRaBm8KS/zu31vKMbs1EokC1hn2embORNWM
         rqeiXPKqWXV3dXUEjHnnJUUITBq2ieYGQbXsYf3IHJ6GYV0OuE0+BrLkfjdoUZMJb6+X
         99EA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VGj5f8mT;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m3si11252309pgs.8.2019.02.17.11.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 11:34:38 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VGj5f8mT;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Ci4uWoH4MBnwWxuQBmGDuzl0iJ8j/tRWg8gzhD2bYUc=; b=VGj5f8mT/RltwkdWydT6SH9bH
	gNKHcIOvyeM+xSHUwIM9Hp/tfShzNNxDH+Ab9V4YnIehCrpb8Jzz3XSYOloucbZLIuOyVher4cy4i
	6iHA/JHjdYMJ4bzWV7hn89vsXaRIkfsJUJ/MPLGgjHVfNcjPQ4vVQTWvlL6oDKwd20/VhtLfPJQd0
	TmMvy/qOjcueJEsO+KtK3x8iltswq2CPwh5kNNvDvukpQLI9JuoG+uvWQh2rCvHt/TI6CbNhoxhV8
	blfMuzSfJJHq5YvKjb6gRKSH65PM8XKp/j30nZ+/nSVFwePnmrEaFw4LCzsCGpagcMjJjBf2JEG5j
	If9vS0R8w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gvSCw-00060S-U5; Sun, 17 Feb 2019 19:34:34 +0000
Date: Sun, 17 Feb 2019 11:34:34 -0800
From: Matthew Wilcox <willy@infradead.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Balbir Singh <bsingharora@gmail.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
Message-ID: <20190217193434.GQ12668@bombadil.infradead.org>
References: <20190207072421.GA9120@rapoport-lnx>
 <20190216121950.GB31125@350D>
 <1550334616.3131.10.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1550334616.3131.10.camel@HansenPartnership.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 16, 2019 at 08:30:16AM -0800, James Bottomley wrote:
> On Sat, 2019-02-16 at 23:19 +1100, Balbir Singh wrote:
> > For namespaces, does allocating the right memory protection key
> > work? At some point we'll need to recycle the keys
> 
> I don't think anyone mentioned memory keys and namespaces ... I take it
> you're thinking of SEV/MKTME?

I thought he meant Protection Keys
https://en.wikipedia.org/wiki/Memory_protection#Protection_keys

> The idea being to shield one container's
> execution from another using memory encryption?  We've speculated it's
> possible but the actual mechanism we were looking at is tagging pages
> to namespaces (essentially using the mount namspace and tags on the
> page cache) so the kernel would refuse to map a page into the wrong
> namespace.  This approach doesn't seem to be as promising as the
> separated address space one because the security properties are harder
> to measure.

What do you mean by "tags on the pages cache"?  Is that different from
the radix tree tags (now renamed to XArray marks), which are search keys.

