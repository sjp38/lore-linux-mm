Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 255F0C10F01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 15:07:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D86242173C
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 15:07:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="1SsAkKfQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D86242173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7120F8E0003; Mon, 18 Feb 2019 10:07:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C0038E0002; Mon, 18 Feb 2019 10:07:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B04D8E0003; Mon, 18 Feb 2019 10:07:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 352A68E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:07:11 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id n124so30443126itb.7
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 07:07:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=V7D2tb83B/k3a0MhgQcMPKpK5/X7LK+ZuAqk/vZ9Klo=;
        b=GhCiFWfenoQwdbh/iVK04AKOfBdyXac0HsSwBnvKCXdVXElpqmlujVGTCPKa3S0rNj
         RNpI0SNWqSqiNvvDI0c0DPV2Ki37ZynK8nBt6mRsZmoP0dO4oaCRSbdEFd7M0DgvsDYi
         GuEyxEkW4TXRycU6lHLaA56dwkt9xYEAq1+4aSCpiPIBeiKksjBqkKgk4bWYMyvzXHFz
         jGKRVexdw/pIsrHjTRzrLaWDmFdEKoJXdK5BZa8YaXeY7nsotcqvHkhaT87lcq1Vgcru
         hcY1mFzGaVRrbhkwrWnwtAcIn3Fsj7rYvnRznHU3LA0tRS9dOD7f2b+RY7Z0/F1gxJYF
         3ohw==
X-Gm-Message-State: AHQUAuaYaFp8aAanQfG9bgrnorFmhoZyTkM1QOOqOpYXW6kB0NW7I4JM
	zjPk4x4EWf/l0p+A16r57UwMFKCcsh8WdBg5Oho8IJHkh+ZWLK405GxfJfWu9FgblobClux1Z2/
	h3fxqz1hzYJiqdKOINA3Nqx0WR92zVgO1PiLvIxWt2UoQJvbzRfGf6FlAy2I8jooztw==
X-Received: by 2002:a24:7f81:: with SMTP id r123mr11714032itc.89.1550502430974;
        Mon, 18 Feb 2019 07:07:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaZwrT7ZmBPDs92CkGxu9cEKjhGgGqzb3kuUGJRv1xdc3Bs7nd/G/TJtaetrbuo7YXlBqtR
X-Received: by 2002:a24:7f81:: with SMTP id r123mr11713990itc.89.1550502430280;
        Mon, 18 Feb 2019 07:07:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550502430; cv=none;
        d=google.com; s=arc-20160816;
        b=n2e5JwBSMwyf8Hk8RxCrdoqm+pYQXy7WJPkey+BvUwE/b90AxKeg7pkKLuuwXU+bsq
         RTBUMVdreHwBeaYcoxKSF/CPL2UxxL0xOMaDEPvZraEXtQApWumIXQ0QIm7J99QTwzvj
         SrPqA3yxseLVPIGECMHVGEzGCsxhsxiegpbbOxGTcBfXCvYFoDApEBMssfFT3ERr/Hpg
         6wY5wwNO049NJxzd0zwHFQ0E1EgTwC7w4qamXzP0ff0p7mp1yWLSkVMNEuMX2nPAQStB
         7ID3xDulU2zYCu25Xde/NHCOy94pMvwGGUpuKvRbOBJWBTTHhFey9J0DKujQeJb3CUxM
         ZngQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=V7D2tb83B/k3a0MhgQcMPKpK5/X7LK+ZuAqk/vZ9Klo=;
        b=IlEBQwpZ0z5ISvK8Xs6XWCVSKQuJID1yr196UpFCrI88XTJF3zgNosgaWDIYoeo222
         39jdZKsLU5vYVIVu7e6M2Kd4uXEmKeEkBBngbQmzZnYB2Y41mmYiB4AKb4PjfRLdZMTM
         zGStXzg68wd0CV7D+PxzeQCm3CVTX1SD7URHYAIT8w3P6om4oABE4IT2YHn22790bJ/4
         Cvs4GbBTGzqJCD6tQVqgVL6jjOj6iNCTxyEWWH4dodLHKq+ynsxf73fbPuEiFSxlswPL
         x4V7Hbl5Fh9WSJB9i9JACQwcHcv05aY4qk6cJbfCmYISuPd9f39MWVqL60pihnmIUEXq
         ltAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=1SsAkKfQ;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id w8si5312349jad.84.2019.02.18.07.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 07:07:10 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=1SsAkKfQ;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=V7D2tb83B/k3a0MhgQcMPKpK5/X7LK+ZuAqk/vZ9Klo=; b=1SsAkKfQnl9ei2xyBX4OwT7OT
	eliuZz8M4KgN0McIytxvaXv5qqOVzh6BNRG8Cg2dWNzcsmqQcGQ17F2PgBl1UHrPH/Is/TtQIo3Gg
	d2KriK7PI5tCFSiTsH4pqttHYmChKm10yKUZ1qPpLynWTQ6hQeNh7tQXqfUtZux7gXXIw2OSoYRWl
	f8rINapsFGNEonzpQR26+Ari4nmdOw0OnVVh1ffyXPNVq7nwnU+Q0gaD4rXWf7nbO5Wdvoj3z+vxT
	CMa72il8jPuzM2HpbK3Mnm7cyIahaBf1Qt6rsUYvfbTwtufYMUGs4MAjUb+r20b/qzt85XE1c8GBW
	YrZUG53FQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gvkVY-0007qs-O1; Mon, 18 Feb 2019 15:07:01 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id B66FE201A4F68; Mon, 18 Feb 2019 16:06:57 +0100 (CET)
Date: Mon, 18 Feb 2019 16:06:57 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Steven Price <steven.price@arm.com>, x86@kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH 01/13] arm64: mm: Add p?d_large() definitions
Message-ID: <20190218150657.GU32494@hirez.programming.kicks-ass.net>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-2-steven.price@arm.com>
 <20190218112922.GT32477@hirez.programming.kicks-ass.net>
 <fe36ed1c-b90d-8062-f7a9-e52d940733c4@arm.com>
 <20190218142951.GA10145@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218142951.GA10145@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 02:29:52PM +0000, Mark Rutland wrote:
> I think that Peter means p?d_huge(x) should imply p?d_large(x), e.g.
> 
> #define pmd_large(x) \
> 	(pmd_sect(x) || pmd_huge(x) || pmd_trans_huge(x))
> 
> ... which should work regardless of CONFIG_HUGETLB_PAGE.

Yep, that.

