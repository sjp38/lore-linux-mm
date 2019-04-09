Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2799C10F13
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 01:08:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2770D20693
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 01:08:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=iluvatar.ai header.i=@iluvatar.ai header.b="Fj4O1eqL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2770D20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=iluvatar.ai
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 816A26B0005; Mon,  8 Apr 2019 21:08:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C4926B0007; Mon,  8 Apr 2019 21:08:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B3A76B0010; Mon,  8 Apr 2019 21:08:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 316426B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 21:08:39 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i14so11712478pfd.10
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 18:08:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:content-disposition:dkim-signature:date:from:to
         :cc:subject:message-id:references:mime-version:in-reply-to
         :user-agent;
        bh=7PoxFksW/7Y5mrW/Yb3Kse3GMSMGjxnGjzU1zXRdg8I=;
        b=kTFlR36N1e2WRyxlXTtyVE5Xsvjd3G7QsUxEoFYvhYVXJoOqKmsjaSdnsxj9kmu5Kh
         SpCeh55Q4a+/DX+FR2sNs7vuQREGnt7vhuFJfj9wV+h1eCsYuJpcpl95/xPlmcWYyTK1
         GOV9LnwNFr3L8zR/XBMqMA0BcB+ulLlpp+Aqnx1qRlmlHOBkRs8iNQnMHtwvSrs7pqeD
         I6hrqfCcqTJnNvpUu12X51S/6AI+fhoSJKuJW8YLLPnH1eQXfWHeR9o5FQVu5P2EJYDU
         97qayq+QJq1vH/MpIl5aurash+VuHo5uAXgU7vXLKEDZVcbQu/6brlat+sTzIkNnPsBA
         xoow==
X-Gm-Message-State: APjAAAVb6qx2c5JE/6pJibabQOTaZLFDVoMvnmX35TAEuNXhfKrDzMSY
	Ot9KdZETAy2F/b5BeXqNoqWQNQ/7ik/sY75M2ZhoVLQFssSay82YHC8BIGidGapB+IxQ7eTEoxC
	kLFXpPd0fiI1sqF06aa1JPjJ0tj2vCTgtwrorziSf22M7E9n5IYB3dZ65FRFHvOrX7Q==
X-Received: by 2002:a62:1b03:: with SMTP id b3mr33797225pfb.150.1554772118744;
        Mon, 08 Apr 2019 18:08:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFjxvrglz91W68zJdSCLCKI3L8AsT0VnWFHx69vBNwdE9J9JypfkqTuOOcHcWi3GaZ+h9H
X-Received: by 2002:a62:1b03:: with SMTP id b3mr33797144pfb.150.1554772117617;
        Mon, 08 Apr 2019 18:08:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554772117; cv=none;
        d=google.com; s=arc-20160816;
        b=fo7fGXuqxRkVrbLeOhyLCxiYl6fkb73M41VnitN3tWcl+4Upsw86d1Fipttr32fklH
         dGjSf3jEL51hrK5OgMsgydwQ8fZPCZg5llNGWE125P97byz88Rs1fWXE/2lisxYjqi7K
         80mMquBi6dHrhwixnz3Sf+iwOh6G0Y9cf4YhK+7Tc7qVopmRO5WIKQ3jozoXT9BIJzcw
         e0rc3p5z7AR3fKHcl1VBxCa3ZUuRa/Kh2m2aN3Q8K4TuSi9Z+nRbBFYGrNP5WcQX7h/0
         HhsNtjlvg5PSl7ZSa902KxRwuFPv3+f7vC/2DcOHRWWZ1itq7BHd+LJ25+jJwT+QyQsm
         wjRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:mime-version:references:message-id:subject
         :cc:to:from:date:dkim-signature:content-disposition;
        bh=7PoxFksW/7Y5mrW/Yb3Kse3GMSMGjxnGjzU1zXRdg8I=;
        b=mt7bWyIbi2hgyZDRxfV9T0YhwXbUXqkLnaj3KxO0w2mqT6gqQUdySmtlrOlOvLnYCX
         Vih3DN8Kd3sJgZxW1hzNAyZcKb9NUDWkV/omfflViRLqzp4elt+pBPWrfL31Qc6fX78m
         SmdiSwgtImUfyC2GTFn3hU8KBlw9v/W3NXENmeVE5et7ZPGQZMQaZ/JV9RMM9LqZcoAy
         B753ioykj/TPSUHsWwR8e407f2CMAki6rkasx/MM/jt2S9keNTmd0OplE8+tNx8/QeJd
         6aJxQW5QUXNMqymAlZMUOx3+ceafUd4WzxBp/7ltxXoT4MT3zhg6ECuqvKmmkOAQ4xy3
         rFBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b=Fj4O1eqL;
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
Received: from smg.iluvatar.ai (owa.iluvatar.ai. [103.91.158.24])
        by mx.google.com with ESMTP id w189si10601007pgd.381.2019.04.08.18.08.36
        for <linux-mm@kvack.org>;
        Mon, 08 Apr 2019 18:08:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) client-ip=103.91.158.24;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b=Fj4O1eqL;
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
X-AuditID: 0a650161-78bff700000078a3-8f-5cabf093b18d
Received: from owa.iluvatar.ai (s-10-101-1-102.iluvatar.local [10.101.1.102])
	by smg.iluvatar.ai (Symantec Messaging Gateway) with SMTP id 06.44.30883.390FBAC5; Tue,  9 Apr 2019 09:08:35 +0800 (HKT)
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
DKIM-Signature: v=1; a=rsa-sha256; d=iluvatar.ai; s=key_2018;
	c=relaxed/relaxed; t=1554772115; h=from:subject:to:date:message-id;
	bh=7PoxFksW/7Y5mrW/Yb3Kse3GMSMGjxnGjzU1zXRdg8I=;
	b=Fj4O1eqLq9eKptCrCrpUPwnVDMk/Bcb81pxPlkLUsXqS951w230uGx869AGQh+OKFwcd7xE4amB
	QE8j8AJ/1tRPncTNw/YMemB4TG8C3Fvuqe/Ub3CJOBuYz0h5FHNOIEgIrnwOEoTa0baTlQrNSEwWR
	l5d7WBuX91Fqq4b1Flo=
Received: from hsj-Precision-5520 (10.101.199.253) by
 S-10-101-1-102.iluvatar.local (10.101.1.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id
 15.1.1415.2; Tue, 9 Apr 2019 09:08:35 +0800
Date: Tue, 9 Apr 2019 09:08:33 +0800
From: Huang Shijie <sjhuang@iluvatar.ai>
To: Matthew Wilcox <willy@infradead.org>
CC: <akpm@linux-foundation.org>, <william.kucharski@oracle.com>,
	<ira.weiny@intel.com>, <palmer@sifive.com>, <axboe@kernel.dk>,
	<keescook@chromium.org>, <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/2] mm/gup.c: fix the wrong comments
Message-ID: <20190409010832.GA28081@hsj-Precision-5520>
References: <20190408023746.16916-1-sjhuang@iluvatar.ai>
 <20190408141313.GU22763@bombadil.infradead.org>
MIME-Version: 1.0
In-Reply-To: <20190408141313.GU22763@bombadil.infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Originating-IP: [10.101.199.253]
X-ClientProxiedBy: S-10-101-1-102.iluvatar.local (10.101.1.102) To
 S-10-101-1-102.iluvatar.local (10.101.1.102)
X-Brightmail-Tracker: H4sIAAAAAAAAA+NgFprCIsWRmVeSWpSXmKPExsXClcqYpjv5w+oYg7ufDSzmrF/DZrH6bj+b
	xf6nz1ksznTnWlzeNYfN4t6a/6wWmycsABKLu5gsfv+Yw+bA6TG74SKLx+YVWh6L97xk8rh8
	ttRj06dJ7B4nZvxm8fj49BaLx6Xm6+wenzfJBXBGcdmkpOZklqUW6dslcGWsejaBueCtQMWZ
	e5eZGhiX8nQxcnJICJhITP28jLWLkYtDSOAEo8Tl+50sIAlmAR2JBbs/sXUxcgDZ0hLL/3GA
	1LAIvGWSuP3vBTtEwzdGib377rKDNLAIqEgse/wXzGYT0JCYe+IuM0izCJD9ZosRSD2zwEVG
	iQ0zjoMtEBawlFjXfQysnlfAXGLHk7lsILaQQJbEsZ7HzBBxQYmTM5+A1XMK2EjsXriJCcQW
	FVCWOLDtOBPIfCEBBYkXK7UgnlGSWLJ3FhOEXSjx/eVdlgmMwrOQvDML4Z1ZSBYsYGRexchf
	nJuul5lTWpZYklikl5i5iRESVYk7GG90vtQ7xCjAwajEw6vguDpGiDWxrLgy9xCjBAezkgjv
	zqmrYoR4UxIrq1KL8uOLSnNSiw8xSnOwKInzlk00iRESSE8sSc1OTS1ILYLJMnFwSjUwJc7U
	m8r46sXv7J3/Y4Oa6lQ8HRnNzsgGPzm9uWRz8O3Jc80mcEw7flz22iQzSw826yzFnUeaZ+Zr
	FCj9DoxnZFlxmLf16HU7v9Sjgnc/BsTO6V7EejBijpeN2vXIslt+Ke9/1GmbTb06qXyBl0b/
	szsGmc/Xdcelr5oatfPwhafuv/Rue6zm/bP7QHfFz42eftlPileFLax5oLR7Rg93lu2WpwfW
	rVTyCuermLxP6Jm2w2EvsbjLPUFd1/RubGWs9rmxsu/z1OuNArusb/GFl7B88rj5Km/y+9My
	/5/O5FvVv/jyialzTZev/9RWwbnm3P0qWZZ9N0RmfXGuf/b+0zWuk3bhE7yCjbkmfcxhmKPE
	UpyRaKjFXFScCADnserWJwMAAA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 08, 2019 at 07:13:13AM -0700, Matthew Wilcox wrote:
> On Mon, Apr 08, 2019 at 10:37:45AM +0800, Huang Shijie wrote:
> > When CONFIG_HAVE_GENERIC_GUP is defined, the kernel will use its own
> > get_user_pages_fast().
> > 
> > In the following scenario, we will may meet the bug in the DMA case:
> > 	    .....................
> > 	    get_user_pages_fast(start,,, pages);
> > 	        ......
> > 	    sg_alloc_table_from_pages(, pages, ...);
> > 	    .....................
> > 
> > The root cause is that sg_alloc_table_from_pages() requires the
> > page order to keep the same as it used in the user space, but
> > get_user_pages_fast() will mess it up.
> 
> I don't understand how get_user_pages_fast() can return the pages in a
> different order in the array from the order they appear in userspace.
> Can you explain?
Please see the code in gup.c:

	int get_user_pages_fast(unsigned long start, int nr_pages,
				unsigned int gup_flags, struct page **pages)
	{
		.......
		if (gup_fast_permitted(start, nr_pages)) {
			local_irq_disable();
			gup_pgd_range(addr, end, gup_flags, pages, &nr);               // The @pages array maybe filled at the first time.
			local_irq_enable();
			ret = nr;
		}
		.......
		if (nr < nr_pages) {
			/* Try to get the remaining pages with get_user_pages */
			start += nr << PAGE_SHIFT;
			pages += nr;                                                  // The @pages is moved forward.

			if (gup_flags & FOLL_LONGTERM) {
				down_read(&current->mm->mmap_sem);
				ret = __gup_longterm_locked(current, current->mm,      // The @pages maybe filled at the second time
							    start, nr_pages - nr,
							    pages, NULL, gup_flags);
				up_read(&current->mm->mmap_sem);
			} else {
				/*
				 * retain FAULT_FOLL_ALLOW_RETRY optimization if
				 * possible
				 */
				ret = get_user_pages_unlocked(start, nr_pages - nr,    // The @pages maybe filled at the second time.
							      pages, gup_flags);
			}
		}


		.....................

BTW, I do not know why we mess up the page order. It maybe used in some special case.

Thanks
Huang Shijie

