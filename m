Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EF18C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:53:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18EF72146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:53:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="E4Zgc0H9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18EF72146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2C7D6B0003; Wed, 20 Mar 2019 14:53:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB4106B0007; Wed, 20 Mar 2019 14:53:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2E7D6B0008; Wed, 20 Mar 2019 14:53:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 64E0E6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:53:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y2so3359505pfl.16
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:53:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=19J+W7mnzMxofEiVeKGPeMBVF0b3b1HaVTXfNyGBA6g=;
        b=tapPrGgVPNl1NJGJTg06Mt3K5tjrFmBJviWv9X23ZU8ZIPbmTrCVA9O2sbjNTuVga4
         kIjSCZCcTaKwwQ51CD6jmW1lYfgxW0SVPCHcb8RS/hMlEUlQYnWzHOj06+WQ+MUwRZC0
         V//dzjgIV716lnBHsU8+BOmSRC3X8+6rRWw+GPPIC+OA2//C7qu+TVml07ENaXq+P7p5
         VP6MHrM6JbCmeEErTKS1eYIAXvX7AkX/RWCMLo60SnGCwh9BQGwH9u5fdgjxOkGmR1kI
         pOTMzBSFFgfObJsSOdsdymzAI8y86irus9GPCyaeZFpRi/Ldxv+O2d97pPFL3V8Q1HdH
         Gi3g==
X-Gm-Message-State: APjAAAWK8owwz7hulubq3J37K2T6WYGbsAS7yDbNnWOHuSk1KwNjG95y
	I8KD1pgzDveh82r8H1FQ56Awc8q5H8Da1jXUEZ7hGFrAB6rG8UPKTNVrTSesUw9tkRvkd87ebjB
	GjLbL73eygNIu9hWtyx2jgDFt1O9zJJKkebfGvt5FDXo1qQJAc4LXe3dc7aJBWsCnMA==
X-Received: by 2002:a17:902:7e46:: with SMTP id a6mr9567342pln.150.1553108031048;
        Wed, 20 Mar 2019 11:53:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7Bq0XJ16dS30fpohQ2bCauJBsyFYrN7Jd+diiB3AKT3ZJEY6apPncUfSvidE95Szjz7i9
X-Received: by 2002:a17:902:7e46:: with SMTP id a6mr9567311pln.150.1553108030383;
        Wed, 20 Mar 2019 11:53:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553108030; cv=none;
        d=google.com; s=arc-20160816;
        b=aEoBlO7uaq5ISh+iAcYZuPIMrP9Liw1VV0RkLVVj9N9AHB2+meBGimYJ+vL+boCOhK
         I/+s960C39+RSNvfS3cE+AyfUCKU0hexiCY4+9/VQUEKptobGzR3S0loA6lDGc27wnd2
         /UsbpoOz0Qa4v1MgQG/f8o0BcvI3LHFQjy5k03Kbi39yfQOtLd0ZA3V7XsKVVdTT/4Bv
         WIxLWDlvBRPFr3WFxxSFqwoiJczuawVfBD30SjA/zJNgYX+JW4gYQu2zoPBVxSnmFHpX
         kgsc8qY1lS5+LRclIN8mkSQEKCZ9hQqjCcNm7OSdLMdk5W2UjbUuEItnWT1IWJ8gEuJo
         rb3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=19J+W7mnzMxofEiVeKGPeMBVF0b3b1HaVTXfNyGBA6g=;
        b=CPUhWs7gpuPCUsXvVvRSgEr4qofq9UO1rRi4yvQAccPYSQJZqWR/uAf3BteBsZssHa
         PFrIA9Li/5Lld3LM8XU74Y3l3fc8KL1CRifS2t+DNTBnogfVlfR6QnGi7GVJPejUdbPf
         RCsfc8uDbV03qUdhkRfQcqDnqIMjOpwQqNnCFGZXvUAWfIh4emw6fJOVxMR5mjRHM789
         5LlLafyidaV5LaOPlB+67q6KC4uPUw5LxjCBC2++x0e3gLQISbjHNkAojg1RG1R6H+On
         c4edi/QnV+shBSVpzg0meViWHszYjIhNjliuvJz7/FR5j8zB86rx/rcriN7BdDiOxfin
         VvIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E4Zgc0H9;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 136si2240943pfc.170.2019.03.20.11.53.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 11:53:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E4Zgc0H9;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=19J+W7mnzMxofEiVeKGPeMBVF0b3b1HaVTXfNyGBA6g=; b=E4Zgc0H9T3r8B3MviIDF03WoP
	/HtoUhhrOcbhOuSMgLsAiKywl8ntQbDZot9vppf3j1ZhHpVBs8dBIQ+oWlbfzGvq5ObJh4Zm9ITRK
	vBPhCnuJwODhSL3923phSEgySz2SifsDpBDvrPjW7w+MfMhUJaeEZRRYe8BlvgkZSoP2j+rNaios8
	3nZY5KR49A3NzOIBdLirAG6u0jdT3wQ7vhHSsb0x3QE2zJrLQ4MHfWLLdwqszN8zzsZKoufs611n+
	KwwrABaK4gxbwmNaB1W67rg3wMhahYvPxzOj4YmP7rhOMbilxpFfL5OSCcgC31pQSYkueD/rH6MIa
	meexl8+1A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h6gLT-0000z4-IC; Wed, 20 Mar 2019 18:53:47 +0000
Date: Wed, 20 Mar 2019 11:53:47 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@kernel.org>,
	linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Subject: Re: [RFC 0/2] guarantee natural alignment for kmalloc()
Message-ID: <20190320185347.GZ19508@bombadil.infradead.org>
References: <20190319211108.15495-1-vbabka@suse.cz>
 <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com>
 <5d7fee9c-1a80-6ac9-ac1d-b1ce05ed27a8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5d7fee9c-1a80-6ac9-ac1d-b1ce05ed27a8@suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 09:48:47AM +0100, Vlastimil Babka wrote:
> Natural alignment to size is rather well defined, no? Would anyone ever
> assume a larger one, for what reason?
> It's now where some make assumptions (even unknowingly) for natural
> There are two 'odd' sizes 96 and 192, which will keep cacheline size
> alignment, would anyone really expect more than 64 bytes?

Presumably 96 will keep being aligned to 32 bytes, as aligning 96 to 64
just results in 128-byte allocations.

