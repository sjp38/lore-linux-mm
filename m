Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76CB2C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:35:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33B5421670
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:35:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ADuedBrn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33B5421670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEB256B0003; Tue, 30 Apr 2019 11:35:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9D0B6B0005; Tue, 30 Apr 2019 11:35:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8C586B0006; Tue, 30 Apr 2019 11:35:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1B86B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 11:35:49 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id x9so7311447pln.0
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 08:35:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=oJB9h4ESLWko23xHyhMmp9ethq1vvp3IIiVrra55IMg=;
        b=IbKzzVLXhGk9mj6EXAWoWVykaXTK26zouaqDP6OSPm/wHk2j6Z00nX8QdFUaHBG5Dn
         aHFjPRIqwgWCYPVwUqEU5CcSsNwuebYI+gT+7Gph2mLqFC448T0mcClzo9zIqhsd9Vht
         hFPt0JD2+3rhOcmFhokzlX/VqyPljyrhZWIy/mIgfDvIwKFgr2jQi0LvTbmThBJUWrPm
         AfMH9Fzl+cCnhKUNCN6FW9H2CfDPrwaKdzRSrDHLhjEnihY7utFq8jqcJUUrbNoKsVp7
         KDS1CfIHe8jsRfHYk0ofMto0vJElzTqMvdT4p3e9YZ58Rf12iLUOoxsE/eTrcjfm1oFk
         Nucg==
X-Gm-Message-State: APjAAAVwr99HLe84RLbd92uHWgbaz9KzG/YV3krTgcD5yhLuwLEDO8Fx
	rpvlyRYiVkkSeazpcUPnf+WxI8PpKRTgSgZLFOwGHONxwxHbluxx4GPkO6cNXNACFjvG2jMTiCW
	nEQZksD9c4+/GqCoAl6/8rV2GmX9Gasv8OQVgxnhoPyb/tSb/Ft3xOvDdg5zEwTRNqg==
X-Received: by 2002:a63:8149:: with SMTP id t70mr20219345pgd.134.1556638549259;
        Tue, 30 Apr 2019 08:35:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydSQCIimY+PiJ/JmxTRsD2tfy7YuV6t0KYFEjNL98SrGPZmrKjTjgIFiI9QhLMnuZEfizf
X-Received: by 2002:a63:8149:: with SMTP id t70mr20219267pgd.134.1556638548558;
        Tue, 30 Apr 2019 08:35:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556638548; cv=none;
        d=google.com; s=arc-20160816;
        b=rIxnucDMcdv7TcTNs3nWXVv1+xuUxn4CNepP7Le0nmFJjL54FuNDaZwu7rOhY0ZDN7
         zRh+ehscwHAvlMwvVDgMxCpTOMqG7teH87OVfAPrVpWKmcD8e6BYh+rGNWiSIChMXAYP
         Pnzk392tUY/b/7GnSIhL0WqogfzU8u/f92P9CVEDWnFOIMTufNXVl95AOVIF6c42nSXa
         /o7dcdFLb+eT8qGd/r5I3js9ZqckwFxwe8F4Uk+1HhsgWc8Zr3aPsUQiL0JyiSCkL5vf
         p0WFdh6akFa6qLlA4cipVLfdwE/7T6pxxWuRypEeY2fDQzIck2zFtexYajfzTynkgfZv
         OR8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date:dkim-signature;
        bh=oJB9h4ESLWko23xHyhMmp9ethq1vvp3IIiVrra55IMg=;
        b=CGr3N1ZAPeb2kNpB+nEIPPNdXwly0r0+oeJzAQ2ydN8cgwJ0NTm4XnQ2DSFW4nugUE
         BkTt/Jce9Qfz8u4cv0f1atVW9CGQGf26WxFgL7hYdQFxNkRkXtDkSLziGhMF+fO31Ddu
         WW8x7J9sICRLHVQ9a+b3yA/LeC+vozJkSyzfd8ubC64vt9jLZarzWciGYXMStpLKsNdY
         2usFRndShB/kvNTiaM/jjMCDbOR8BVQwN1424KF8BqkRpElAD9wxxl3JCY/VUSHXEqRe
         QVYXXvV/dHRpbhloAo/yA76j1YMNu/yjiMuT3zpRxnAWAYfW7OPa1yLEU3mfLgYcFtAS
         TzbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ADuedBrn;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c10si39201143pla.231.2019.04.30.08.35.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Apr 2019 08:35:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ADuedBrn;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:To:From:Date:Sender:Reply-To:Cc:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=oJB9h4ESLWko23xHyhMmp9ethq1vvp3IIiVrra55IMg=; b=ADuedBrnZiNbdVrRmpadCvZak
	tpXSRQ+dtQFB4hdGRKLB92AhPYIpjqSpKCYZBGWU/O/nLOE4UNnTLaL2IogsWkb2K4OfskxFGTA59
	cvsFSaExy4VIQnRf78KT5H/MbsdPf5RfLsaC9C2p40Fu5Z0f0H+4X7CucKXmJdL15NaabgKpDTn6c
	0aCQVhWTTWlTxzkC4eKx3TkhAwZoUWn48qmNeiQ5eTbG8YJx8McZz/XQ99B1P199aLPmNI+ks2vR5
	noLpak4ZAQbp9ZYfnAnAZIzOSji4NfDP0C6YYtHie/VS1Lgb8sW+cuxTQ6rqnDFQaZ+vdWyOw2np6
	JZB8G0XTw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLUnL-0001Al-KL; Tue, 30 Apr 2019 15:35:47 +0000
Date: Tue, 30 Apr 2019 08:35:47 -0700
From: Matthew Wilcox <willy@infradead.org>
To: zwisler@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm: Delete find_get_entries_tag
Message-ID: <20190430153547.GH13796@bombadil.infradead.org>
References: <20190430152929.21813-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190430152929.21813-1-willy@infradead.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 08:29:29AM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> I removed the only user of this and hadn't noticed it was now unused.

This is based on Linus' latest, and I know there's a patch in the akpm
tree from me which modifies find_get_entries_tag().  This should be a
relatively trivial conflict to fix.

