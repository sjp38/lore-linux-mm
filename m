Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FF5BC282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 13:42:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF7082081B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 13:42:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="bUnzJi0H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF7082081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50CFB8E0044; Mon,  4 Feb 2019 08:42:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BBEB8E001C; Mon,  4 Feb 2019 08:42:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D33A8E0044; Mon,  4 Feb 2019 08:42:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFFAA8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 08:42:06 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id p3so11739569plk.9
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 05:42:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NSzXV8ZhnHo67p2jZfhA01o+VR5IxF6NSFWwjcl9vBs=;
        b=Ja2agb9rCFYU7ZmE2EoNZUWCvTpAtiid0OahUKY4czRlj1WTEk4h3UxO0ZHLZYeBmi
         vJnF7ftOQAbEBYHThH8ymot+XaBmbrC6y1Nq1Bw6du0lB0ZVKjIDg+uJbq9k3E65m7W9
         jUGB6MACfsnJLv62L3dllD+9pW0TfY4HuLqtptwHKzhvcJNGmaPQbgguIj4am5v03GRf
         yIQCmKMnP51m9s1V4nBak39/GjONjFl8iERn+wN6eZVCs7Aybn3L7IXDYc2TasmLrhms
         c2pk/X3jOyQ3rI1WHqjSH4YSBzJb+aa0m26SHSh2/97Wi6fLQ0r9Q8EEwcbkoYezuLMw
         k8cg==
X-Gm-Message-State: AJcUukfXIAHZUsS/KpvVLxKAajUC4Mn2gBltdzs7OutNf6ccG8EksKhJ
	otmMfDJ7eOi78NGze60/AvDy4nCyh8XGF/aRmMGYHbJoQVxLuYZumYd1DYN7v3kMgLkxzFXSMMT
	WkAJFtHxaxdnKCizBlXpklW9HyNhExlsF4m9UYYug4rib+D92g/FKal+gU8kevZEG8Q==
X-Received: by 2002:a62:1043:: with SMTP id y64mr51774385pfi.78.1549287726653;
        Mon, 04 Feb 2019 05:42:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4TyG3FXM7k8guF7cDUrHoehLs1PYykPS+j55yaDqa3N3gQADDav6wvIjB5n9vIfLiRYzWx
X-Received: by 2002:a62:1043:: with SMTP id y64mr51774334pfi.78.1549287725879;
        Mon, 04 Feb 2019 05:42:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549287725; cv=none;
        d=google.com; s=arc-20160816;
        b=SUczbl6FJ5Tlu5W2xrMYaspNp4F5Bh1ICQgJlkEXElVXmgQoVHnAbca4ItesFwSf03
         f4eMMh0epl/62KiXYSeAYHZ5rNSnKfmTHQsjkv7KgNkB5HS/S1AFgtBTkWvywa/4ZFHx
         t1soJl5ZjfQx3CNZ+lVmqi8NKu9yWyoiuQ2iTRPT0Bgd7aB5+fcBsayUXjoGuSmahObS
         iFxaHCnLVgVKY3yAJCZy6dnaCnq+wuVd9NSFlfBmoM4Z/dWVOkK/hngg8t66EQXksg/S
         3y4yj0Ze4TNrI2rcIV6zt3OTuNbOjDS9iBE7/8UmI+kl+Zb1amtku2peZYVXDi+XYeAf
         3ZNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NSzXV8ZhnHo67p2jZfhA01o+VR5IxF6NSFWwjcl9vBs=;
        b=bguDouLSZ3CzLZY9AKj8vwn3d/Y4oVm+098ptQtUI78406s0vrRaZ61LZhfEjkTdyp
         WtTRAoVOPc5HoIxF6EE88G1khp64YITGL0CKAnE1+AzAelUuAX2KqVr713cqVzfoihfp
         jyjyQ8B7gtU5Ej+827L+zqKPxE8iEqb72G6q3Tjmz6Gu5EKWwW6m5QZN4agQ0+ZK2bHF
         1XAx8HDI0nPuRIHBc4WqJh0GKC0v5eMFEpcgov+QojON0v3ogDK8Azg6O54SNN25DnEv
         BFuer1RoY8hrgcdpJfYs13QJHdxIBgqiz3ZX8xphTYmvIw2Dq7Wi9QOoHCo4sWRTRdZd
         77vg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bUnzJi0H;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b30si87807pla.285.2019.02.04.05.42.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 05:42:05 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bUnzJi0H;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=NSzXV8ZhnHo67p2jZfhA01o+VR5IxF6NSFWwjcl9vBs=; b=bUnzJi0HT/ox8NGH24iKpoHBI
	xG4ses5V0Mn7w4vkiSQmd5Rqs5J3C8QHKSyv8rFLvP0evF3kNQx17HrKPJnppfheNZ+ahjBByzIER
	jJnf4d5ty0ueeZQle7TabyGqk5cfAFkMDZrXKHzLqNsSjKsfrSISbEq09jBjfICBnJOjORwkkjPb3
	Dp0rNRLAxNvJwFD/1baFqIQgJ+EpmnXcujd3yIzj5f9qPnVaTu3hviNOlnvaFz/nH+Tqw5zfTUGvb
	U9bPRQ773d4DyI1r+4EEeKjr4mhRrmPh4BUC5W0dctXkrHGRXEN6v5Q44hciYzE3z3mdHDDP8mwS2
	Qpg+dF+Sg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gqeVf-00088t-R1; Mon, 04 Feb 2019 13:42:03 +0000
Date: Mon, 4 Feb 2019 05:42:03 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-mm@kvack.org, kernel-janitors@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] mm/hmm: potential deadlock in nonblocking code
Message-ID: <20190204134203.GB21860@bombadil.infradead.org>
References: <20190204132043.GA16485@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190204132043.GA16485@kadam>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 04:20:44PM +0300, Dan Carpenter wrote:
>  
> -	if (!nrange->blockable && !mutex_trylock(&hmm->lock)) {
> -		ret = -EAGAIN;
> -		goto out;
> +	if (!nrange->blockable) {
> +		if (!mutex_trylock(&hmm->lock)) {
> +			ret = -EAGAIN;
> +			goto out;
> +		}
>  	} else
>  		mutex_lock(&hmm->lock);

I think this would be more readable written as:

	ret = -EAGAIN;
	if (nrange->blockable)
		mutex_lock(&hmm->lock);
	else if (!mutex_trylock(&hmm->lock))
		goto out;

but it'll be up to Jerome.

