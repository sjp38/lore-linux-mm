Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AA17C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 21:28:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 460022171F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 21:28:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Iwue9g6i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 460022171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D61BF6B000E; Thu,  4 Apr 2019 17:28:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE9F46B0266; Thu,  4 Apr 2019 17:28:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD8F36B0269; Thu,  4 Apr 2019 17:28:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9633E6B000E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 17:28:05 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id h51so3492443qte.22
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 14:28:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=kDVtXyoLfH5PgMwwZeROqBpn9nPOCSaBnbu9ZomO9sg=;
        b=Msb7qoJZ2noko+ykD9T2HK6lbfDN2uwBUbR251utvyi+hYIpHYd17j3VMJAJVFuyuc
         dV+BGVgZYlzITAfbpWVHJyzp4D5coKRNhVet6XxnQRVFo3ajLFcXaeGfcdWESTpDu61P
         iNBqJ79KeDnQ7Ydd8+MRY6W5Oycy6yDVQNKt6UEPSNBtiF+2zcAIJyqeWsBIsQt0UZOg
         a8rsbqtigBnYwECiDMJV4/3nXscIH1Al2yfjVoJvOLzinlWQlgoMPwOFy37n6JtytL5k
         O39MNUSiv8gZGzL8gxrpOi7IlekXmpTY/6C+/hmU9tDm0sT7MoO8cniGo6yFDquKTmi4
         UY9A==
X-Gm-Message-State: APjAAAXAuOA5SrOhqpo19wB71SZLz+tBdj6XM3Jk8o14rIuinUnpbtZo
	fvxivJK0ll9Dmz2M8khh2CzSYcmjMIbaBlJx7bKQTFdxITnlCoqxLr3RCgFhb8jafumR8anIpR4
	MPaWBub/5SVrOixTJXutOrwNyPA/TRr5OQxhmHRma3GWTKBO/f+rR5aS3zEX05zPCpw==
X-Received: by 2002:a0c:d6c9:: with SMTP id l9mr6929890qvi.58.1554413285363;
        Thu, 04 Apr 2019 14:28:05 -0700 (PDT)
X-Received: by 2002:a0c:d6c9:: with SMTP id l9mr6929839qvi.58.1554413284406;
        Thu, 04 Apr 2019 14:28:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554413284; cv=none;
        d=google.com; s=arc-20160816;
        b=qHH8I6Mn4aeAKa0DbgWKFxrQC23jzLUpwQ1VFgRyA/WtBq1M9QcnXK1Mo22avmOSY+
         Mn+Z0O2hZU4ufFRmwvTyxW+infk4Xcd7EWvYA6FOVOu1lJMUpuQOmCADrBeNFoRiBGdV
         e5Cz5tTpICqwetfcTbC/7H2rrEKae4mrI9myM0zMXGYHuPzzcVggNYoOuaemx4KYzPVc
         vA+hsk5Af8G99yj2hoSCjdmDf8tG3hSXq3OUy51P1oOuB2WjFH10KZ2d66SnYy+0aDzV
         yTA47kpvHmHSPw4AH4Wl2gyMdQNiXqGVQjtBukEVPuZ5bv/3CWtyZrZ6i20VUWPUgOce
         1Xmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=kDVtXyoLfH5PgMwwZeROqBpn9nPOCSaBnbu9ZomO9sg=;
        b=tEYBzn6nNmcjfDY+xRZ5DEdaAkJX5v7gqC5PmSMKFAIbLtNfpdS053ZFBCgY+Ieuju
         8YG3kcZ5YbKhosd8DflJaBGYgRf38i1I65rM22Nsncu/p5MnTMB9Ts5O+X8iYRAdoQW4
         rQqJeuouJwn/d+3FrJjEO5TlA/MojN0/C0F+bis/iDkv95FxRdJRYyiRbzXu8ovwwD/n
         q/+RgAIzoFXdDT4AvqrdwjntzYEpWyqZRZnRJl2HFAw1vzOYsy1bUDA/xqTwaSD7+E8o
         CzJUwjppJ0pCdOzWtmJ7LzQZ+XG4uf73DHTs3VhND1c6mSYN3XYe7JMtcBcF8fgGkoPG
         Y7pA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Iwue9g6i;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u6sor11669291qkk.95.2019.04.04.14.28.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 14:28:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Iwue9g6i;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=kDVtXyoLfH5PgMwwZeROqBpn9nPOCSaBnbu9ZomO9sg=;
        b=Iwue9g6ilQsOkQ6nS3w17XCdamF22RgS0RmJldESsJfDdkDnPcZBBBNnPC3zG8/GKQ
         xTn2s0E6v1ixsC9egerTSLV3TA0rC5UXRE26g37dSCP7TOPB9kyOnXVCynzm89OH4h2Z
         eBjLmieALKqkqEyugJXREkksOhsLUrvDt0nts76nR4rfD7+J5g6705C++MUShlOWA9yu
         F9TW+EIsg9ZaJPVcnZDnliE2+9Z65O9C+Ei/ak/Yf/gOfZK/9G2VGvajN6IYTFEWnXnC
         Pj2sf2f8iSMkdOuSHW3cn4d8PM96lUM+4FwjPiNoUnAu1Sb2zMeUTjwwsBg35AfOq2JY
         R0pg==
X-Google-Smtp-Source: APXvYqxR3zehgtEOdBHpwTeIDqzGFX95TU2ulLq0B6rfBAE40U0kZdfx3CunL/g1AA6rUTWd41LQDg==
X-Received: by 2002:a37:4988:: with SMTP id w130mr6849630qka.262.1554413283993;
        Thu, 04 Apr 2019 14:28:03 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id a47sm13855216qtb.79.2019.04.04.14.28.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 14:28:03 -0700 (PDT)
Message-ID: <1554413282.26196.40.camel@lca.pw>
Subject: Re: page cache: Store only head pages in i_pages
From: Qian Cai <cai@lca.pw>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <willy@infradead.org>, Huang Ying <ying.huang@intel.com>,
  linux-mm@kvack.org
Date: Thu, 04 Apr 2019 17:28:02 -0400
In-Reply-To: <20190404134553.vuvhgmghlkiw2hgl@kshutemo-mobl1>
References: <20190324030422.GE10344@bombadil.infradead.org>
	 <d35bc0a3-07b7-f0ee-fdae-3d5c750a4421@lca.pw>
	 <20190329195941.GW10344@bombadil.infradead.org>
	 <1553894734.26196.30.camel@lca.pw>
	 <20190330030431.GX10344@bombadil.infradead.org>
	 <20190330141052.GZ10344@bombadil.infradead.org>
	 <20190331032326.GA10344@bombadil.infradead.org>
	 <20190401091858.s7clitbvf46nomjm@kshutemo-mobl1>
	 <20190401092716.mxw32y4sl66ywc2o@kshutemo-mobl1>
	 <1554383410.26196.39.camel@lca.pw>
	 <20190404134553.vuvhgmghlkiw2hgl@kshutemo-mobl1>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-04-04 at 16:45 +0300, Kirill A. Shutemov wrote:
> What about this:
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index f939e004c5d1..2e8438a1216a 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -335,12 +335,15 @@ static inline struct page *grab_cache_page_nowait(struct
> address_space *mapping,
>  
>  static inline struct page *find_subpage(struct page *page, pgoff_t offset)
>  {
> -	unsigned long index = page_index(page);
> +	unsigned long mask;
> +
> +	if (PageHuge(page))
> +		return page;
>  
>  	VM_BUG_ON_PAGE(PageTail(page), page);
> -	VM_BUG_ON_PAGE(index > offset, page);
> -	VM_BUG_ON_PAGE(index + (1 << compound_order(page)) <= offset, page);
> -	return page - index + offset;
> +
> +	mask = (1UL << compound_order(page)) - 1;
> +	return page + (offset & mask);
>  }
>  
>  struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);

It works fine.

