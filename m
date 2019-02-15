Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F624C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 21:17:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4452222DB
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 21:17:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="ty/rwedp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4452222DB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 400788E0002; Fri, 15 Feb 2019 16:17:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AED88E0001; Fri, 15 Feb 2019 16:17:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C69C8E0002; Fri, 15 Feb 2019 16:17:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E148E8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 16:17:45 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v16so7732848plo.17
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:17:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Z1uyvqXrQXSc3rwNLm0+e7l6LqHeD5zT+elzxuoWcjk=;
        b=tSnbDZtcbN/FFPJOTDUhiHb3eGo3xBrVwHe5lajOU2IxCxzQpkOad4y7ajJwilEG3o
         WXy9qliZ7GGl6U+S6NWV++hosa+NDDEssomjHDHZhF1U6QIgtElm/ZLO2FuQMfuqRHR4
         ez5FETTdMW1R1z5tjgsNZ9KYhb7aA3P6hMXJ6Ws+AwFH9PfsSmYJRZhrC0uGUsPIFRI+
         MvTKxgJ+ODhLDi12yIBuCzE10f7QzZOozB7ygqonBhaC5vv4R49ZNDVi6nuKeWfO6elW
         qfd5eBkd7EypAyqhixPWwciIHzwsUWJhp1rok6nzUBDzFn6rRCur+U0OItwb7PPOoZyE
         /gqA==
X-Gm-Message-State: AHQUAuY0BfqMLBaeLdTZrj1j4QVck6Job7KdkONrSXUoSSfx6gcBG+lX
	XaoJTIwA8U+HrN5A2FGC9ZwnnlxC73nt4QLzU5M8IbOHMui9wjdWq3DQx7gM8kXIV+TtnakKxy3
	btNqtlJnj4gj+lVYt4zTYI28cdNI3AUUEBXwnFlnQ3Yx5peSbWVTSS5EDbymORWOQ7Lbe0z5wJj
	0+Jb1uB9jkVB0l6C5ODgP3AR8EE6J0NcaH8xAFtNYSqnl3DVTEm3M3C/aRiH3gMTcWc9kZu69YS
	LInpw2oQMa9HdbfxSg8+QYsM97tTdQHJA06EsHOwSvjnHeNg5rPBpgA3H6u3KVzqFtpuKNd+fzw
	R9sABK8uJK1r0NEOlTziAsYzNsVWEh6N1bLAdHskrHHu2aEIVa+iuI/ZdMvlGKiFiCPetYmPDGr
	p
X-Received: by 2002:aa7:9099:: with SMTP id i25mr11918897pfa.102.1550265465526;
        Fri, 15 Feb 2019 13:17:45 -0800 (PST)
X-Received: by 2002:aa7:9099:: with SMTP id i25mr11918856pfa.102.1550265464791;
        Fri, 15 Feb 2019 13:17:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550265464; cv=none;
        d=google.com; s=arc-20160816;
        b=F/rM1/OSUrB/w7kELniLjUsOmbRKWvqNSbV/tlr85QepshUv4b42UO3jV3Fg7HnbEX
         9rqCUSSb1Sd4U/q1Gb1EOqeU1ciP5fc+2bQt5fHZta4WrQoyA5V9W+ejvi0WXNHo4N6X
         Jd8dnwQQYm/BejgGAZ1wmAd6ZtS4DU7ulVmCps8LfnfhzrH7WzsgkaoN93BQT0a4pR/o
         3xFJuJuTt5fLbZQYoYXrDIKrb8JmyeHH08T7e9G6RKjqan/hKYXeRTeztAlkYy7YyoQi
         GVE4nRNJ6h5A6W5T4tmDscUlkcT1jaCdjT5Pfxflh7HgU0nnTvdbVd34XLvD0WV/LXLg
         p+og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Z1uyvqXrQXSc3rwNLm0+e7l6LqHeD5zT+elzxuoWcjk=;
        b=XD2g20GwA4ZGQKSSZ9+E1jQGvE/sHb+VSI41av1LB3fGxxknaUt98tG0nNB+dH+YpO
         n9xOcnPsccEJSMg1qgNbcWB6zQQ19JCtxWnLjgcXMN0aOEiEwoS+3dbgXDEMA5SxASyq
         3uXLNot8x/5KYjnHw3z9eTDNJmgsYgnTF2wtPByQtbFIWznGeuDFAhIzJjesz2HmBC5/
         K0n7jkNOTMOX6sCTQ/gP520+NMCKWIaLv4jb+kkG+6DIcas4/eC2oBk3PMXnsW8IEcFw
         olpHAF/EWVhktZwb+l2Wb/67lbZcrU/qccfnPMf/WAYRFJawJFb3gXeKQlYDZzaDVk3b
         9+mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="ty/rwedp";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bc12sor10417115plb.37.2019.02.15.13.17.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 13:17:44 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="ty/rwedp";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Z1uyvqXrQXSc3rwNLm0+e7l6LqHeD5zT+elzxuoWcjk=;
        b=ty/rwedp34mDQEgOzJS45T9dmUZ0GKuG3idqkjg6TLazmQyUlDkINR/cdaEaagBQYt
         4MvkKESa2BPuQS4Op2ZCFtpreOxstdtpStCmHBP6lMIixyqYN/WbNypxWojVPP9gmObH
         hXtcdmBIqOLGqRDu/kdgIRyP2lWO5DPWoC5o8M7hyxlAF1Qn4DMvJoxmEdhcWRTvVBl2
         Njpvlk6shD6M96Itafm4sqs6KiwDSI6mFuSkqNN10U7WjyjroYVuruALp2AKNx2RCGSg
         3blSnsx/ytFuwiGirssZGaKFqFPWVkALYlsJmzOFtah5mbKqQWSLcpCWZMcqXWGcv7Qz
         LGng==
X-Google-Smtp-Source: AHgI3IaeDUcZ2lkAt1807uEGaPCN7vEpWtQa1sFCBcPGSgINsgZanwP8wKQQM33RgHM8iibOZDwLkQ==
X-Received: by 2002:a17:902:7c8a:: with SMTP id y10mr11977436pll.71.1550265464148;
        Fri, 15 Feb 2019 13:17:44 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.82])
        by smtp.gmail.com with ESMTPSA id w185sm10199147pfb.135.2019.02.15.13.17.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 13:17:43 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id C13AF3008A8; Sat, 16 Feb 2019 00:17:39 +0300 (+03)
Date: Sat, 16 Feb 2019 00:17:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190215211739.44qnml4uk6vtku5p@kshutemo-mobl1>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
 <20190214224115.4edwl7x72abztajb@kshutemo-mobl1>
 <20190215202056.GK12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190215202056.GK12668@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 12:20:57PM -0800, Matthew Wilcox wrote:
> On Fri, Feb 15, 2019 at 01:41:15AM +0300, Kirill A. Shutemov wrote:
> >   - __delete_from_swap_cache() will blow up on
> > 
> > 	VM_BUG_ON_PAGE(entry != page + i, entry);
> 
> Right.

Thanks. I think this is the last one I found.

Could you send v3 with all fixups applied?

-- 
 Kirill A. Shutemov

