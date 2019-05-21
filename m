Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C940EC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 13:27:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81FF021743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 13:27:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WVQbSLh/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81FF021743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2855C6B000A; Tue, 21 May 2019 09:27:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20FB16B000C; Tue, 21 May 2019 09:27:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0616A6B000D; Tue, 21 May 2019 09:27:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0EAC6B000A
	for <linux-mm@kvack.org>; Tue, 21 May 2019 09:27:24 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h7so12323557pfq.22
        for <linux-mm@kvack.org>; Tue, 21 May 2019 06:27:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yt1TSE+hvjdYVZh8L0V5R+F6bnTH4NU+zMd4kOaAMvQ=;
        b=oCyYmXbyPNGvqUEKx6tgCBkq4UE6vWVDUxmU1ECUrDaxzMil3M8O3MgPp4Tyedy9xg
         RmjKyJ4DB664f5VaQG42QX9vNUv9AoGSjYkbl+sHeqTDfFG0/3Jn3+KggJOCAQrqewFo
         DGik5mvSy/wgONpKzKDf6jQaOExYa574aCaMk7kN5gx/anBRotx0eTouAR4DQQ6RcI7p
         KelbTxVkJ3/bjT/oeRYVUC+OnX3QKgW6iu8Gk8PlKLR4wz7WoBuo91yXWoCR13nCkrOZ
         tEbRK+ysRcwk8GOLX2NfyR4iu/ZZ8rqLUCfzMqQ13y+KFI8uc26j6RceUG6mlizK8sbS
         69rA==
X-Gm-Message-State: APjAAAUVeZPqJ3t+lhHgfSX3LRN9LnehIyw6cdj5h7eYKt3bb4n9UmNM
	QwCrNHiMIjNpvCwFCx+sBBTeFtSvhM/v43Kqr/PLivUSSAeFaWOFvMj3uUoQg7DNgiSET6fqMps
	liDxAh1hcHJ4GRHxp55wh/Wv2zhHaZVel9Og+MlKKIXRQABoEeSaXS+mEFt58PBn8Fg==
X-Received: by 2002:a63:e042:: with SMTP id n2mr80507502pgj.201.1558445244387;
        Tue, 21 May 2019 06:27:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+hjYdPNacB/+gwYXpIWFiVU44HcuReG+ANqVdhm16/mzbsbBxu/usgN7UWIjmum3X5fRO
X-Received: by 2002:a63:e042:: with SMTP id n2mr80507426pgj.201.1558445243737;
        Tue, 21 May 2019 06:27:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558445243; cv=none;
        d=google.com; s=arc-20160816;
        b=sXLnwcE/WmUMK84clBqQPkw62C1fVGt0FUkpA8crz8I+KFyjoUEn3tqiFRbolk+q2Q
         82/ziC61ApM3nurGw7T1BsNTWCHKTGzjopcIfGllgyoN80eTL8l4H2wPemVK6fmYAn59
         E6dHT59jQpPBDCCKNr3ewmWxtjAhzi/4DFVLCdqoSAmRE2224h+NY0TnGsWxLqYJhJsx
         rOlaWVoJEQGdGu7J78mFnx7JXDKbfF7T9txZxmilqaPzrZ/HY4ubXCFVCDAoKZH0bxUy
         9L9LU0tBAw1dam32xmRsi7+2bj6ZjRV5M9EhacSXDZBmE7utSMRqhimK6H7zKDAMKWSP
         hUfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yt1TSE+hvjdYVZh8L0V5R+F6bnTH4NU+zMd4kOaAMvQ=;
        b=Xkwfs9Xjfk5FMQeBNHZkZLu5IKjRwFvlzejkhxMSVDCyEMJUIMUdI/vVaGFjP06bYj
         hxMcQ5MkvLDq6gwcK9SUn0N8igppbJ7h+sJMCsna0IQP/8C6uDJCIv9p86pH78dq4iBx
         N/QvsM7Ie/38nQERhpLa3/IEcvhnAtIeeljSlx+BU8J500GTrShUpRl1Q2Y3H0bPcjiD
         mUPQ3l7Q7UOW1G1FFRgtZD8b2nb9CVrEdISEEn/miWlioq/3QBlHoDfJUNlyKJHd4R/I
         oFg4ejBolH+oYkipVJIydg1J7CMgygDdM1RmKaT7Tu1EgsGMGlUojyVcqxPA2j18iKNE
         psHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="WVQbSLh/";
       spf=pass (google.com: best guess record for domain of batv+dd3a5481af7880b59d64+5749+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dd3a5481af7880b59d64+5749+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g5si20462573plq.109.2019.05.21.06.27.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 May 2019 06:27:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+dd3a5481af7880b59d64+5749+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="WVQbSLh/";
       spf=pass (google.com: best guess record for domain of batv+dd3a5481af7880b59d64+5749+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dd3a5481af7880b59d64+5749+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=yt1TSE+hvjdYVZh8L0V5R+F6bnTH4NU+zMd4kOaAMvQ=; b=WVQbSLh/MDT4P+lDDna9iiMLr
	RRbMOAsBBmx4mCsZkNt49bylRYvcHzTVyua8N+OHNPIuw3GOInsrr2tiwogTLqP5AK7jQXqd5vN5O
	FjMt7ysOrVATKhJxwsW8wu+IQw/7kazzkaztdjb/VdxkhrNb2+NFaafvKE6FHHNvmGdLiztCuWzq7
	Rn6o/w88n0EJknBygF+sAKOyOMzco10Xo9MPtUSM57FxRbDwkIeLozXg2s6fnIwfuhrOPFLM13NnE
	BMFnkXKcR7RVT9hjYGA8A55oRboTjDWL+0GercEMTRGgwU8IlWl4Oph/kXhf1JAplB3yExABbnpFX
	AIZzOg+Ig==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hT4nY-0006Jh-Ty; Tue, 21 May 2019 13:27:20 +0000
Date: Tue, 21 May 2019 06:27:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Oliver Neukum <oneukum@suse.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	Jaewon Kim <jaewon31.kim@gmail.com>, linux-mm@kvack.org,
	gregkh@linuxfoundation.org, Jaewon Kim <jaewon31.kim@samsung.com>,
	m.szyprowski@samsung.com, ytk.lee@samsung.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
Message-ID: <20190521132720.GA23361@infradead.org>
References: <20190520101206.GA9291@infradead.org>
 <Pine.LNX.4.44L0.1905201011490.1498-100000@iolanthe.rowland.org>
 <20190520142331.GA12108@infradead.org>
 <1558428877.12672.8.camel@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1558428877.12672.8.camel@suse.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 10:54:37AM +0200, Oliver Neukum wrote:
> OK, but this leaves a question open. Will the GFP_NOIO actually
> hurt, if it is used after memalloc_noio_save()?

Unless we have a bug somewhere it should not make any difference,
neither positively nor negatively.

