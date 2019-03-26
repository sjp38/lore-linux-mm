Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2227C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:43:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFAD32075D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:43:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZfRoeBOY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFAD32075D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 574F36B0006; Tue, 26 Mar 2019 08:43:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5247B6B0007; Tue, 26 Mar 2019 08:43:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 413D46B0008; Tue, 26 Mar 2019 08:43:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4ED6B0006
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 08:43:08 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w134so11446954qka.6
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:43:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DScYzQ4byzmAtySvZIm/BnXHpyQAg6A5PGezuWKmYN0=;
        b=cYPSv7swdWd7emRLu4wCHPch6s1A2EOHW21hm3TmPrZKvc9Ke+xhz2kcHOB6o3C+y7
         FS4unYyXDXsXWqCzZwc7ZfkEZjy2Quz1DG0WomzQ6XIdLlRG4sCTzfVrm7xJbpBSlS7r
         W9MK2XDRhv8JYVEANXrdOxV3RWKE4kKPhNWEcGvERcP+kIECXREHEi9hLx0o8JUJ52Bh
         XvTwwLXcVm2IIqrV0tvo9yMs2xKe06hXIuZBCRt5e4sOGM3IwMl+/Ic/TaqFisa0TjgV
         pl1419XXRKc61mAwQU2iAtvRllVNU206u0tx/a1zzhFNCO25r2QEvVnII5elbSIt2Pah
         gBwA==
X-Gm-Message-State: APjAAAV/CTjyjjZM7BwGjChO2z/Qod16f7YAjtxFdL0uBRVaSp55qfQL
	+38PPVAqxYt7qmmEM5l33N3xvmVaXhDYk9vRAwQrRU2xcfAtKcWMRnkZf6xO266qCbRU4en9QDS
	jTMNxCGXiPY9TebLf4zLYy4NrJkHs9p0WS8anU//UhPnujtaWKIr9Gk0PwFr/7SIQTw==
X-Received: by 2002:aed:3829:: with SMTP id j38mr24628249qte.385.1553604187867;
        Tue, 26 Mar 2019 05:43:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGS4aUeMkFgrqM3KhnB/apSUoyfkNcZ1fIyiwV4gJwd8VbnIOwm5ya+4sCwSkVPhDwL2CQ
X-Received: by 2002:aed:3829:: with SMTP id j38mr24628207qte.385.1553604187285;
        Tue, 26 Mar 2019 05:43:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553604187; cv=none;
        d=google.com; s=arc-20160816;
        b=uzosYl28TRo7AGYxAwvNQH9mMNTNfpjexFp5mKZ/GmkULOB/5+InSjqIzzXgvP3kDD
         MsLHO8W2OkJ6iUPMWvYWlrKPw7KXf7v58/4PiNuuZgTRTSliRhHu2KE0TjI5vwxE6+69
         EkOySFFuQ/W40qgLk62Pg6ebZVnxlnCcdQUj3BEX86kcCfOEFR8xW3YK/JNUcCAWiTui
         yqCO5/L/19XUHXHukr9c83FGxvEOKRInGH+E9PenExywGuWNBOXXIBeYTIcckAo76B6V
         tDuBYWfu8Sm3sf0WRdgwIVRfsrOCHPvy+U7FnsQD9TSSQPAK7g6DCZmoCSHf4Xdrz/7w
         78uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DScYzQ4byzmAtySvZIm/BnXHpyQAg6A5PGezuWKmYN0=;
        b=Dn82Q/sWZiKTJLChaEWTqcYPRpUTh7jnYaO8ykMxauywVJmcY/ymeKu907OWCkdcWJ
         tlL7VUkatTCz2TDNq2T9H38/tKY8D1ylEVTEnis9pFoZV/iZT2QZI/O/sR2nDMUOaMJV
         Cko4lq/QhAvwcwISYjA3M/RO78zBdfMCSgy7zZw2X2SmAmsxqX5PdzkBrelWje4IjGH6
         /fRJBV8hCYts35ws2mSo3unx3atP9Di2XEyOFw3Fg+f5AmgkyNbCO9qv+0V23/8pcW6u
         NhyAfgtKz5c0kBuNLRnF1M+CFJrpxm4yLrr/T4ni5jgWLKYDJ2xWFywS+Hazn8l+ERa8
         mRaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZfRoeBOY;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n9si4297775qtn.349.2019.03.26.05.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Mar 2019 05:43:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZfRoeBOY;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=DScYzQ4byzmAtySvZIm/BnXHpyQAg6A5PGezuWKmYN0=; b=ZfRoeBOYa4rFB7Zt+s6dOcrHb
	MjLtwfVm0PH884vVIab37rxpJIgZyOSXhJMe1Rjx4AApF/Pfcxwv6CMBEwpzDgjabcIWSeftQQxfC
	xH8oqn4FTXSH5nf21i1Mmv35xOhuYvedVp2ocvCpY3rOptFYE3ohp0Eij7jMMM6VXRqW+UDcFXFgU
	yDm0MV7cUKKoYk6SABgVgJojMsB/QxxaR7mOZU7hm7hXeox9M5LMcT1oJVdhjfLBdRpqKRq4m7YnE
	gpC+M/rolkI2QCM/62upYfccnBoRC2h1FvV4S+YkKz+9J3m9VQS/0dPTdYeLxq3+WhKPBLjF+TJHb
	Um2ZXWJZw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h8lQ0-0001ki-Us; Tue, 26 Mar 2019 12:43:04 +0000
Date: Tue, 26 Mar 2019 05:43:04 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [External] Re: Print map for total physical and virtual memory
Message-ID: <20190326124304.GN10344@bombadil.infradead.org>
References: <SG2PR02MB3098F980E1EB299853AC46E6E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190326113657.GL10344@bombadil.infradead.org>
 <SG2PR02MB3098B0C0CD27969FB7C9ECD7E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <SG2PR02MB3098B0C0CD27969FB7C9ECD7E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.009417, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 12:35:25PM +0000, Pankaj Suryawanshi wrote:
> From: Matthew Wilcox <willy@infradead.org>
> Sent: 26 March 2019 17:06
> To: Pankaj Suryawanshi
> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org
> Subject: [External] Re: Print map for total physical and virtual memory
> 
> CAUTION: This email originated from outside of the organization. Do not click links or open attachments unless you recognize the sender and know the content is safe.

... you should probably use gmail or something.  Whatever broken email
system your employer provides makes it really hard for you to participate
in any meaningful way.

> Can you please elaborate about tools/vm/page-types.c ?

cd tools/vm/
make
sudo ./page-types

If that doesn't do exactly what you need, you can use the source code to
make a program which does.

