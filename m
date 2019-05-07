Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16A39C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:37:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD673205C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:37:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Lv9eHU/Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD673205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B79D6B0005; Tue,  7 May 2019 13:37:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2682E6B0006; Tue,  7 May 2019 13:37:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 158436B0007; Tue,  7 May 2019 13:37:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D08CD6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:36:59 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e20so10645618pfn.8
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:36:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=clVmOpDd5LzvkH+bJWwETDAH6oZsPTXJW+h72BQ3YmA=;
        b=W8GZbT66OntIHgUUJt6FxeA2fchJwaFy4MeHPpccDykZsJHaIbUq9f07tc3fFd9Mi6
         VfEyuR+OU/EvsKhKAyPRrLyTgtI8hmSxFg6LATpewj7YFdPQdgJ9DQRRNFK7O4RG+rUZ
         8kNjp0cdfyrp0ZWiFRAUuHEE//GHn2Baxg7DRVsgI236byQuSP+yWqJ1nFGLW3PE2WB0
         dLvVFCx3x1SCthWjD8MgSdLIq4T9k/vHKEmq8VlFCmJZA1XKujPswrmADEO251LKvzJC
         ZPUxRUwGzsZ0mqaf3tNFcBEA2NJfS41Aa3EPEccM/5tcfT0nJeb28b/7BmROzvXpa+7w
         xnHw==
X-Gm-Message-State: APjAAAXbXYVT1RQz5CwWPUIOGIa0dDbh/OqWvl47rYb8hZavrBDhlc/L
	cXf4/4gASDgO0eoxAcuzd+SnDU1ZbmUNaI/JqDw2ee4FELQT2Ssn+GJpE6s8hoFjRISTmtu/FS8
	kZOfjcsdJUH0iKc8EExbtv/Fn+RgYDsLJq5ot/Gv/KZDdoGuDVCUpoyh0tV+Lj5ghyQ==
X-Received: by 2002:aa7:8083:: with SMTP id v3mr43709578pff.135.1557250619533;
        Tue, 07 May 2019 10:36:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7cKorEoG1jR1U861ao726k/e6LTpguIjez1XwT1nr2gRayO4zvNT8qUHks60atTenA3Nh
X-Received: by 2002:aa7:8083:: with SMTP id v3mr43709491pff.135.1557250618830;
        Tue, 07 May 2019 10:36:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557250618; cv=none;
        d=google.com; s=arc-20160816;
        b=ViNL0h+ND5QeAf7p8vvgF7sPjQTCGSdEsF9v1ySHewjO/mK5Wu2NdbCVaCNnPS8YoM
         TB67GAz3BzsP1cj3JV/D8iTdqIf7BemX1eT3e1g+X724AIHIGOgCPyPjl6WFywpQiZ9N
         TlC2LXTT5+vyuVQNig8rK0MBB1oqSMTWud937yyiO6A6Lmt2DzWynt2seQbFX2sqMdCv
         csL+zTfq++pnEtDf7latHLmChREM6c6qLo+dZogY+8mmGndRAVm5kwjbSUE/iw0Gprx4
         lAsDE5JigetTMPOqPxiH1B9jJGykPjjFLilEBuCPb72jWbiWcP1XNIhPNbtY0p+HflC7
         q06g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=clVmOpDd5LzvkH+bJWwETDAH6oZsPTXJW+h72BQ3YmA=;
        b=HkZQFFvMswHb4r6ZmRWfagBzXZe+RCm13L5WxyS7giMY4sqWslkaP2RNNqXxPtSlCw
         42ymE/y/iyCBiUnqajHrazLw3qFBMVKgBAaZiZRTjXuNLNDRhwlM+eC4Cvn4PfmhRHKK
         9MQMgtNPAsXNk1XhYb+bJaN/HDS7mduvD9wfgP1ozV4RkJmFVE/XLaRO5efdjOo59jMT
         I/phem0ynfIoUSeVFkdN7h8oA8xagpT4C8TzNkxwpoyVYN3PM8DeeQDldXHGm031ewmU
         UgGplphDFp7uC3cjEbXAuU2a4y+I9iEAQ1EDcnbbmwc468iYL82xZNutmWSrgrpnixz7
         pgBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Lv9eHU/Y";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d6si19062189pfr.262.2019.05.07.10.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 May 2019 10:36:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Lv9eHU/Y";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=clVmOpDd5LzvkH+bJWwETDAH6oZsPTXJW+h72BQ3YmA=; b=Lv9eHU/YCnEEcZbzOeCcafBMF
	OswjYy2ZYStFugMU0UuKCzCEoJL1SeV8aIwcRB9okQqJ9hF87xa9smgAI1nlogUPWbQt2/csogLsh
	klr5i5nLmuZlcA3EdxtfOlQsI/rKdwxGZAQBVMngU6fNViPjUE0ZjFowgSXAg8QafQF6y/1aUavH0
	DUg3anwUIkMdltSZOAIXMEjLKzAr+mCBhyHfLIPctmeSOWVj0/hAbr7k51DT5uC3RrDFnyzw4TvKi
	S0nHugtqx5JMKIFWALxBGRckiMkHDJtdM0Xq80o6t5HYCsbAMDW/hJD8IlHtxEyO7TF0+zvLtkShr
	WlE47EP3Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hO41Q-0000Zl-4S; Tue, 07 May 2019 17:36:56 +0000
Date: Tue, 7 May 2019 10:36:55 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sasha Levin <sashal@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	stable <stable@vger.kernel.org>,
	Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Sasha Levin <alexander.levin@microsoft.com>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct
 pages for the full memory section
Message-ID: <20190507173655.GA1403@bombadil.infradead.org>
References: <20190507053826.31622-1-sashal@kernel.org>
 <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
 <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
 <20190507170208.GF1747@sasha-vm>
 <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
 <20190507171806.GG1747@sasha-vm>
 <20190507173224.GS31017@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507173224.GS31017@dhcp22.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 07:32:24PM +0200, Michal Hocko wrote:
> On Tue 07-05-19 13:18:06, Sasha Levin wrote:
> > Michal, is there a testcase I can plug into kselftests to make sure we
> > got this right (and don't regress)? We care a lot about memory hotplug
> > working right.
> 
> As said in other email. The memory hotplug tends to work usually. It
> takes unexpected memory layouts which trigger corner cases. This makes
> testing really hard.

Can we do something with qemu?  Is it flexible enough to hotplug memory
at the right boundaries?

