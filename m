Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1CC0C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:29:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1ACF206A3
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:29:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Dzz9eun9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1ACF206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E3906B0007; Tue, 14 May 2019 03:29:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 294726B0008; Tue, 14 May 2019 03:29:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 183216B000A; Tue, 14 May 2019 03:29:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D8C906B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 03:29:47 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id p12so10087488plk.4
        for <linux-mm@kvack.org>; Tue, 14 May 2019 00:29:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LyILN8tiqYOrBbTwx/bEvqalqGDEJJBbWfhDeckm5hE=;
        b=T7wClRhesUC2y3fFuatgDaoF1nPtM5gD+nCcQZellWpZowHek7PKKVraSxj+wUbSb4
         zS6neFWYG4NawQrLAaomiPt15s1X3fjdNG7DDmr39Y1MY09Bdwy24GTb8vmQ2z87GMBm
         /J8vyXJXaUNrox3NJ2tp0dGjGgZAmc1IZhXSsGf0l/ciXZfrSYIaPibqGy96jypzUr37
         89g1ibC7Rw2Ckp0RZvALRXgw6N0YjFgOGlI3+7M7vRjAY4nKCgDCiPszdWtAnZnAKhyv
         s2aJDA/zwpNZ9VZhHbGj7pJNUVNo1wQ7H9wkE97xRfUoRPDojX4l4GZbMOwRk43aauys
         IMdA==
X-Gm-Message-State: APjAAAXIrlqq8oFuFQmtaWKhZp0dY+XuecqjCjYYHc/uG9sW0R8Tql5r
	krKkvOpfNKkUHhYU8ehokw2YiMXCmYCpcjEJdMaSBDBhZ/8I3/Ii+iBBwdhAj2Y0HYGUmWN7GjA
	iZQF+C5BN9+V0Yp6uY53wTKshP7WJxIFs7ax6LrUB/8V9nO2M8TfqG7aJfvsGU4bM/Q==
X-Received: by 2002:a62:3892:: with SMTP id f140mr38582813pfa.128.1557818987497;
        Tue, 14 May 2019 00:29:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxb3g0b2pWjhaZ42tHSbjJGoLL27fSsl5TtXIFlDT+5NEtC7N+Uj5apvtnKxurVlKCEgM1z
X-Received: by 2002:a62:3892:: with SMTP id f140mr38582738pfa.128.1557818986586;
        Tue, 14 May 2019 00:29:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557818986; cv=none;
        d=google.com; s=arc-20160816;
        b=dOV+/8G6O05XC4jeXcxN09Aadw7m3sKOAuc2i3RaOlA1xXaJOCqiff9PpXaYDDv28z
         Vp/VsJASb0uZbTtAKxiFhFOZ76clT3drbhNFI/cStD1s6H/eiL/1uPphxMwdIs5kfY4a
         TTxIfXgzXviuc48DXblhjl35FwCxJv7k0ugIZYP3YfOLE9E5L+PK4eNNgPx3TIEM+FeF
         pd/bx74g/PM7qWYp0ISE3AXLNm/SbFQvITUZmBLfjv52YFmUvEVytd7pWyQ1P9Nb98vE
         TaPEmWkFFg+VzFlS9o7yI9bukmNcMPUbnL5TvFj7I+oaJzqSovlLM2BnSRz7mbC+brNi
         YfzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LyILN8tiqYOrBbTwx/bEvqalqGDEJJBbWfhDeckm5hE=;
        b=cjef6TdGaD9BO9clk8XtezLgI78C5iLjJHjPgBI+1kejIEb3cVZGH+tO4guHXTDamE
         KzqhahIDSbRezXv8cOrqzWHmP0MrtRf5K2ySQvcNrWxTVgQv0B7Mkq7IQz1V2q8gSYFT
         d8Y+czxOgrOwClXRNj4pC2bod2EJvf6/Qvkeg6L03p9Q4glaBHNi7i8SABQukVxvTX/e
         6RL6Z7NXeKVC0uGV1mjMXy+DEV9vMsWGhGH42bMSOYypyS5oj/3Q714JDGhzm6vB6Mle
         O62nrilFjqrZ5KmFGphNG/8iDXY59QbADgvSpQ9rGCS/ScFLbgn621J6NbVqjgTztq0c
         Mxpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Dzz9eun9;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n1si18137351plp.272.2019.05.14.00.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 00:29:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Dzz9eun9;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=LyILN8tiqYOrBbTwx/bEvqalqGDEJJBbWfhDeckm5hE=; b=Dzz9eun9Mdy9wxo6bjQ/SIsbt
	oaxyTesAJhv9qhYG29ELdIzQ8B/4GLPi0S8UY+SnAcrWsieohzt9xVLpRhitf05XQyxO7ZvDUpA0D
	cS8cXr+iCRBYbcZyZ7yfxlixVscm0v/7u4FMWGSfjFQof4+63mREl05GW8UbuYtl0yzm5KhC518wa
	3K0+dFcGdKuj0Q3+Da79oPBpMcssZqcdi8szEOuBHxkpbs5D9EZOYRhpClyX/WmZZ7XT/F5ssJ6Il
	DBeWy+3TfcJ/0K1sCsfibvbpOdBb6QU26+YWbFL59jn27d7emM4RUrVU80JjsfqyYCnyCGrQaB3VT
	WW2asI+rg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQRsd-00054W-Bb; Tue, 14 May 2019 07:29:43 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id B13822029F87A; Tue, 14 May 2019 09:29:41 +0200 (CEST)
Date: Tue, 14 May 2019 09:29:41 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Liran Alon <liran.alon@oracle.com>
Cc: Andy Lutomirski <luto@kernel.org>,
	Alexandre Chartre <alexandre.chartre@oracle.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim Krcmar <rkrcmar@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	jan.setjeeilers@oracle.com, Jonathan Adams <jwadams@google.com>
Subject: Re: [RFC KVM 00/27] KVM Address Space Isolation
Message-ID: <20190514072941.GG2589@hirez.programming.kicks-ass.net>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrVhRt0vPgcun19VBqAU_sWUkRg1RDVYk4osY6vK0SKzgg@mail.gmail.com>
 <C2A30CC6-1459-4182-B71A-D8FF121A19F2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C2A30CC6-1459-4182-B71A-D8FF121A19F2@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


(please, wrap our emails at 78 chars)

On Tue, May 14, 2019 at 12:08:23AM +0300, Liran Alon wrote:

> 3) From (2), we should have theoretically deduced that for every
> #VMExit, there is a need to kick the sibling hyperthread also outside
> of guest until the #VMExit is completed.

That's not in fact quite true; all you have to do is send the IPI.
Having one sibling IPI the other sibling carries enough guarantees that
the receiving sibling will not execute any further guest instructions.

That is, you don't have to wait on the VMExit to complete; you can just
IPI and get on with things. Now, this is still expensive, But it is
heaps better than doing a full sync up between siblings.


