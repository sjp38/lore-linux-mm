Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BD76C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 15:17:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A18C214DA
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 15:17:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZM1/k2tv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A18C214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A44C8E0003; Tue, 29 Jan 2019 10:17:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72D558E0001; Tue, 29 Jan 2019 10:17:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CF258E0003; Tue, 29 Jan 2019 10:17:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 005608E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:17:11 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id f18so8064779wrt.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 07:17:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Gjx0D2Hp2M6LW1jg+jUAo3bizRCgLIialUofJPerBW0=;
        b=jEnyD5k/uRvalAN9lmSigdSWzHsNRa0PHuzbb1W7zxouN1Ncp0SyokwkozJCo03ck9
         wdzdw2W0J2rbaMLGgbQh2p1/quoLLbapBR+1h7UNHH47MaJKg4z8y9TASTfu+49Gwb2C
         /+F7aGg3PjDbq6At+XQOYs2MSx6E/5Og5+kqKyu6BE9/XySEYC93Jl6xUU/5EncMrS+5
         xBqwKk1UhI56QbYeJ3uA8KH23CJ3pVCk8BVCwOm2tXkilF/x0+jjr3uY5chu5BSfiZwe
         7bz0c1Jhi/8IlTYCQ05VMs/CJz5qdBts8WgWKFfL3RrlMvKKwroOrSUtxEbFA8K4s/uG
         DdBg==
X-Gm-Message-State: AJcUukcvwElxr6zkqyHyFDZElCytpsmcPwRhAhgn+Dxml1d9VrHv12/c
	vCquUd/9wls9pjMjjGpaS3o4mbkhMOAE2drOwaHkWU//aPGzCAm3AixEj1/0U1NGDXNPg6viIyS
	VhCjkBqmBxIQGbGpq9ho3YQzaMy2fDKteFvyrV8sIRVy7TGFlzyk08BSGUSz4Bohy4g==
X-Received: by 2002:a5d:4b8b:: with SMTP id b11mr26378459wrt.180.1548775031550;
        Tue, 29 Jan 2019 07:17:11 -0800 (PST)
X-Google-Smtp-Source: ALg8bN74sTHxveVDOIzcsEZJesPbauFWN6a0ghE0B2+zTQgKzyDGCgIbv63fnCn8wsIQygXYW48v
X-Received: by 2002:a5d:4b8b:: with SMTP id b11mr26378399wrt.180.1548775030732;
        Tue, 29 Jan 2019 07:17:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548775030; cv=none;
        d=google.com; s=arc-20160816;
        b=uVHaG0gk4BNuR/f0SDNKNPZ+Ucn+KoY1YzXeu1YTCgegQBPDWQHLwUFEdBOeR9fvtA
         P2NLJLMwCTs/Pg08UIjG+VrL3CoQ8TPPMUXZGest9TEuV1ZDYO26k8J1HWbjLgj803nb
         y0lQthWywEUIuyftwPtAzi9ht4G0hCOKdzFP3l2XUVDTETbMfKfllimNdMzHo8ZiFHzJ
         P5ihk1vd08opu+lfrsHgrh84S9ZdNhz1PRVte83ds+++I5Gw5U4/vL2ekDaieUMc32bi
         LqWL6Qd9uulsci0UsceoUYqZAkjAVI7FYkTrQOhS85LQ50QByBcjzAWGFpyzf8szS3Gb
         sj8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Gjx0D2Hp2M6LW1jg+jUAo3bizRCgLIialUofJPerBW0=;
        b=si59If2uo5HGKGa3pT56k6uigFtB1C+NyCidxt8OhhGqJh3Xz2ONLqEOXE2tsJ4LiG
         +/AaZcC2NK5hTc4Wu5Y7iMHf6mt/6C3QLszSqb71erzECNsHKMK9uIx60gdj/p5WeGmj
         GhuMzvo42wfn2F5kcF+Txrq9MfHOlmHSQPBQvqa51Pc1Fh0EeCrDPDzrPdfwYpOFa2Gp
         BQZNP+ERnhZpiy+TIHjkypzXdpNl9XHsl1xwKOZvTrQOC7Oqw7lwRrYr14ppfeBoFO2I
         bpPq9nE34mk21G2/rtkDTiW45nj9RVaKwgknCRlmN7xDz4mdlm2OwlMS1BhzG1jBVWxX
         Gw4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="ZM1/k2tv";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id g1si2154463wmg.78.2019.01.29.07.17.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 07:17:10 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b="ZM1/k2tv";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Gjx0D2Hp2M6LW1jg+jUAo3bizRCgLIialUofJPerBW0=; b=ZM1/k2tvtEsbf4Yr3BAZU68P2
	aGBBvKiUnJ+pC5oDVacZS5s3oyMtjDVlQLFFy8uUEUxLSZViutxEhxlBgCApf2IBQmpOcml9jf5Di
	f7H74YUBsdSIu4OA/tIhqmsDJUIB49ePezMZuopRrv4+la2rnZZ4x5SpBxtlBwOPUc93t1f2d0wEt
	QYsAZYHfu9GTwbS1+QIgz6TJr4hzdUdy6G4hycQWTDwJyqzrDUgwT/ZfkXqQpwcQnuY2idiRbxenN
	ADWS3xs25+rgsjAP8/QvH7fjMcKaT0IlurWuD8d2nBh5HNkIKCd/w5H7Zkw3Bkvpn7q5dNGx7JeOs
	+LXkOyuWA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1goV88-0002kd-8I; Tue, 29 Jan 2019 15:16:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id AD64520101B8C; Tue, 29 Jan 2019 16:16:49 +0100 (CET)
Date: Tue, 29 Jan 2019 16:16:49 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
	hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org,
	dennisszhou@gmail.com, mingo@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [PATCH v3 5/5] psi: introduce psi monitor
Message-ID: <20190129151649.GA2997@hirez.programming.kicks-ass.net>
References: <20190124211518.244221-1-surenb@google.com>
 <20190124211518.244221-6-surenb@google.com>
 <20190129123843.GK28467@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129123843.GK28467@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000115, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 01:38:43PM +0100, Peter Zijlstra wrote:
> On Thu, Jan 24, 2019 at 01:15:18PM -0800, Suren Baghdasaryan wrote:
> > +			atomic_set(&group->polling, polling);
> > +			/*
> > +			 * Memory barrier is needed to order group->polling
> > +			 * write before times[] read in collect_percpu_times()
> > +			 */
> > +			smp_mb__after_atomic();
> 
> That's broken, smp_mb__{before,after}_atomic() can only be used on
> atomic RmW operations, something atomic_set() is _not_.

Also; the comment should explain _why_ not only what.

