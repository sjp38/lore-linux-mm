Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3267C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:28:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 417AE222DF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:27:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 417AE222DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B4008E0002; Thu, 14 Feb 2019 11:27:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7602A8E0001; Thu, 14 Feb 2019 11:27:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 650288E0002; Thu, 14 Feb 2019 11:27:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 227A38E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:27:44 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id y91so2716730edy.21
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 08:27:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YhwkAe3eiUMRNa816Mm3xz0ihyEiXrHd1wc4FHIsUrA=;
        b=kfxShTKXhJUANVMX0ORedT42V/LV0jD7XnS6HMOMwZt5KSuK3olELkABZ/JXXOVzu8
         rUPAk8Le5n8/1Vqdy77WiwL94IZ9J9H7+sVp5s9AyJEF8n0u5M+CQvvhDGNcrom4SJKM
         Ym1u3cBX6JMPyIv3FXUPjA1dtmwMnmnK6Xz8U5Smdat9HvYcD8wy6eAz6jMBlynCABnB
         EuIdV/fjG2ZfjCkJE7a29lv0N3EKdz5NB6tjdvyQkL04I/huuv70DSqpGN2rxyQz+GiY
         2J+GshD8LDnZOdxMHxvKAX12/VLUpzrrW6tzJkNaivXG+K2eMumOOxzh0sEAVw5FvJ4h
         bcbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuYvR5hXh0BvVvgGa37+UsaK5gffPsNCLidxbUu/COXoqlveHO7u
	sNG5j9vxzp48YTETb+Ld2HKhSY7J3LIq35OGhT9Lc4ZvZuKgzdVMBm4OmydxClNrKacehQ/8gWh
	W4iCMdBfzatUGSAxI/AjKnvmlp5gypFrpWd+FfWTbwAdQpbi98cjInODNVfIZxc7M2Q==
X-Received: by 2002:a50:cdc3:: with SMTP id h3mr3894536edj.208.1550161663697;
        Thu, 14 Feb 2019 08:27:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYcDuQTY6uSzbuon6wyJ43q3kJuk/jtfh21AuuigpcYPutZrAGYQSnRJu7Z4Xpwv0PUkS/b
X-Received: by 2002:a50:cdc3:: with SMTP id h3mr3894474edj.208.1550161662824;
        Thu, 14 Feb 2019 08:27:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550161662; cv=none;
        d=google.com; s=arc-20160816;
        b=HHlVSI/cQ1Yl4GTarDF/Y6kUmpyLNysab9Ebeu9/XwH82oJijncSgyMrhWMJvyPPk+
         WlwmQZMyX7BevC/+BrNgimg9dH02gJEfMHCvxoenjaKMCot5aqcjcHWoP5KV85VOkfTg
         U3mUiw5OQbossau2teb2INFXP1EAK8v4Mkg9xRVpPDbW4Ul+y8H8E1QWWG6ON+eYJJ+9
         CIBW4UydvXdC1CG25k+7bGlaosSjEWiyWnssOiP9SjR5jn+schXk4P/CQuldeWVfkifo
         RAVZbGWLvDjGBhgNq/Kg8jsjlnbkvZKfcPERu7CqcNuLtrpUd8+xTDLosIfnMfSV8BbN
         qF9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YhwkAe3eiUMRNa816Mm3xz0ihyEiXrHd1wc4FHIsUrA=;
        b=hQnaCnsMe+zfoBWnTzQkSM3xp9jlsKB54SIVhF40ndJsUSYCR7fmiNFET/oS0KkG2A
         wU8sZzynRY+GY634WQMHL9nHdkBYdmMcMZ/ZQSvBcrbIlrsle4q2h47ANvLpkVjFuYrS
         Lu9yXkyjncQb5FAeMe4T8wthx14puduNf5gX4g9wsVpL572MxF7z6D+uwspW/YKyluhk
         NeGFyoCluHGD0XAF0ic1oV414cA6D6GIQBbLOHKlonunNd6a/jWc4MMmUP0LakuXgLVm
         l4cVhxTZ1x9KAQYA6TXTNdCDHaP2LXywdyhAuVVJAu5mKCLC7WwpN2s8xO6DKEx8TgSH
         ZgmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si1320608edh.354.2019.02.14.08.27.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 08:27:42 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4AACCAF56;
	Thu, 14 Feb 2019 16:27:42 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id C54271E0900; Thu, 14 Feb 2019 17:27:41 +0100 (CET)
Date: Thu, 14 Feb 2019 17:27:41 +0100
From: Jan Kara <jack@suse.cz>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190214162741.GA23000@quack2.suse.cz>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190213144102.GA18351@quack2.suse.cz>
 <20190213201715.GU12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213201715.GU12668@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 12:17:15, Matthew Wilcox wrote:
> > > -		pages[ret] = page;
> > > +		pages[ret] = find_subpage(page, xas.xa_index);
> > >  		if (++ret == nr_pages) {
> > >  			*start = page->index + 1;
> > >  			goto out;
> > >  		}
> > 
> > So this subtly changes the behavior because now we will be returning in
> > '*start' a different index. So you should rather use 'pages[ret]->index'
> > instead.
> 
> You're right, I made a mistake there.  However, seeing this:
> https://lore.kernel.org/lkml/20190110030838.84446-1-yuzhao@google.com/
> 
> makes me think that I should be using xa_index + 1 there.

Yeah, you're right. Thanks!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

