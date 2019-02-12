Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C59F8C4151A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:55:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76E812080A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:55:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="uIx0d4mf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76E812080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FCEC8E0011; Tue, 12 Feb 2019 03:55:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AC368E0008; Tue, 12 Feb 2019 03:55:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDD6B8E0011; Tue, 12 Feb 2019 03:55:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B04B18E0008
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:55:54 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id d18so1882462pfe.0
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 00:55:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fAgDmfFW7R8j1gGA/S02y2C6trlbzZofS5eZevLDINI=;
        b=En/4nsDFYjcLwoqq6ZaY+JMn5EueKyZIQLkrypG+mA2jorxaKlisFx5aLxkKCmXcEL
         7t1ylLiQo1izra3u4Ffp7E8hFnDol94Cfz0d7GCFeV+p2o9fSIuRNm9ojPo15/zG/XJF
         KfHYexGbrxTEObtTdxfXSw8qIFGwiR39PP5vPN7ku7mUrpIdsnMUD9w3hAIJlav83BNN
         J6UGMb9NWwNQhB3+bZegeiCLWxhRZRKTZidfmkQYDNcbZTndd68mqjnvRKwTzhl8W/gA
         OhsARy3b1/s4Ai/o3GFmmzUvvSh5CPus0x0ULQOJIvkKMF+x2I30e2d2iKGVD8YHHiI0
         iAew==
X-Gm-Message-State: AHQUAubdyzqlLjTf2Db0hvnr4fGL9+wMkr4H5X47+7kn8vTn+Nzi3VpM
	JcpY2So7f20O/flzzKJEheeZXiNWSQNBElobK08GTvxhQ/dOlRYOuccg+ab98Dgr6UwAIQkrhb8
	AwcQuD+7ZS/+Rmaen9t3AnW33Amc5dyhtfjIhvySGE8W/J5BBo96tO6GGkcq/v7qWRKgQguXprd
	Ccdqn3Cq8+X7GBH3Uqm1c1u9h6ZAYX9sMUe2C8MsVyHXMJdSTXvm/651TK8mFt8KbmCl+JsO4Wt
	J8TzYgAo/HKliypJze9xfqTF0JXoLSk0LOr5OF0A/DaYkDzxdkwjlAjF1SFsDnKqYKCzEUtwit8
	JAO2XLCAJVV+yXd8zKgfG+FcewzZiWXQRr3UK9xmg7/d8aX+2iI0zQiyTCrLMugzqYA4VUcnQOT
	k
X-Received: by 2002:a63:b94c:: with SMTP id v12mr2593518pgo.221.1549961754404;
        Tue, 12 Feb 2019 00:55:54 -0800 (PST)
X-Received: by 2002:a63:b94c:: with SMTP id v12mr2593482pgo.221.1549961753688;
        Tue, 12 Feb 2019 00:55:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549961753; cv=none;
        d=google.com; s=arc-20160816;
        b=QZkIDfu/66QdlWnLOpQqLHLG2cLBnEa8LAsplF0D6BNgg2ogn9CdaU69fSX6poEa6c
         XlncOe4BVjZwXBq/oZIHpJv0OCBahOAQBGahVkSkBM1P+DHVgueMOpzDrcSbETUn/Oie
         nGJjG/xtnzJqnc5SkKdEyPqWV2/8w0rTBpGT7DfiCxbRkZXoccouxj0WOlqM5sDH0y2r
         U/+7dc1c+Wlok329rwK58CyPv9uhzCM9UkuDoQ5opuU8UlY+fQalkKIcG+SVh7y+9UWU
         drBIN5dEj5jMzl4SRTMYdOi35IADJPlViIwIWY1cBqhBFnXf5aRNTxmWKv11jXVDlJQD
         ys7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fAgDmfFW7R8j1gGA/S02y2C6trlbzZofS5eZevLDINI=;
        b=p4CSp6dycWwDqPp40GSeStclLNq4PN0OoOgbFiNYvXnD0wu23qajwPjkgoxrWH7Hd4
         CaCa4l31jUq3aFc6lcZ+hKz3o8jcLgnack//29vOCNasHWyMQDW58HtzSULux5hwJfqr
         tBYcUzMNUyJgSOrOT0MSggrKfBrFgzQ6n+vnaH8gE3AfDrycKxjBfcG90BBYSNurftD1
         +icmNs1H94OSY7U035b5p4VxImuPSRoYTKkGg6tsmo6LBPD//YfIhyamzRRyDoR+eekX
         /rmNFOYGddRVF5tBikYmdYTkSPvBDfbdW0HDz2Li/jq9H4KWqsvuKlzq+oheqpb7IeZs
         LM5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=uIx0d4mf;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c13sor8429637pfn.21.2019.02.12.00.55.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 00:55:53 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=uIx0d4mf;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fAgDmfFW7R8j1gGA/S02y2C6trlbzZofS5eZevLDINI=;
        b=uIx0d4mfYaBDMbPSgW637OxlxvZBkXVM+ZrWR8bi1Mpz8ErHen3n2furkAkp8kiJWo
         sY/efNAE+Q+q7ZVk8sed5RBgxHt3l6nexYM+ia9Rxm6l3wRK8POrsZtNb4cuyvuPkJ/a
         RJ4q+d9hCmD+9TQVuGi4UYIYKVjwoEhT+UQQUVUjBPn7tHmiZbgHKlyFP0Jvi86SnnJJ
         Jl6aAhSJBvTmYf+uX7WF8lUZNdtOfRHGRipv34yDMkErm77a/VQCP0N1R/hB9RoozvDb
         vAtpHqhtFbEKWeuaNOSKaFaVh0IvsaAk+pi/UoyLnd+TV7qEeLYZPBRKyt2V4vcdE1Bs
         kgNQ==
X-Google-Smtp-Source: AHgI3Ia5JIUmLs7UcxrnZ/skthGJslE7aqEuC/i0CzISabI22NWBPnls/fIcH3AIZAY6xj95Q9Wy1g==
X-Received: by 2002:a62:9f1a:: with SMTP id g26mr2919719pfe.123.1549961753319;
        Tue, 12 Feb 2019 00:55:53 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id m188sm8851572pfm.53.2019.02.12.00.55.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 00:55:52 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 23547300573; Tue, 12 Feb 2019 11:55:49 +0300 (+03)
Date: Tue, 12 Feb 2019 11:55:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [LSF/MM TOPIC] Eliminating tail pages
Message-ID: <20190212085549.ez5ghqrzkcqx2h46@kshutemo-mobl1>
References: <20190211190908.GA21683@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211190908.GA21683@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:09:08AM -0800, Matthew Wilcox wrote:
> 
> I can't follow simple instructions.
> 
> ----- Forwarded message from Matthew Wilcox <willy@infradead.org> -----
> 
> Date: Mon, 11 Feb 2019 11:07:28 -0800
> From: Matthew Wilcox <willy@infradead.org>
> To: lsf-pc@lists.linux-foundation.org
> Subject: [LSF/MM TOPIC] Eliminating tail pages
> User-Agent: Mutt/1.9.2 (2017-12-15)
> 
> 
> Tail pages are a pain.  All over the kernel, we call compound_head()
> (or occasionally forget to ...).  So what would it take to eliminate them?
> 
> I'm doing my best to eliminate them from being stored in the page cache.
> That's a nice first step, but the very first thing that functions like
> find_get_entry(), find_get_entries(), et al do is convert any large
> page they find to a tail page.  So we'll probably need to introduce new
> functions which will return head pages and convert users over to them.
> I know Kirill has a lot more experience with this.
> 
> Another place where we return tail pages is get_user_pages().  Callers of
> get_user_pages() expect tail or small pages; they do things like calculate
> the offset of the byte within the page by AND with PAGE_MASK.  There'll be
> a lot of work to check all the users and convert them to something like
> 
> unsigned int page_offset(struct page *page, unsigned long addr);
> 
> Another thing to consider is that some architectures have a third-level
> page size of 16GB (looking at you, POWER).  So an unsigned int isn't
> going to cut it.  Do we want to support pages that large, or do we declare
> that there will never be any point in supporting pages larger than 4GB?
> 
> There are probably other pitfalls I'm forgetting or have never known.

Another place where we see tail pages is on plain page walk: we do map
compund pages with PTEs: THP after split_huge_pmd() or simillar. Some
drivers also allocate compound pages that can be mmaped into userspace
with PTE. I saw sound subsystem do this.

-- 
 Kirill A. Shutemov

