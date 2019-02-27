Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BCE9C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 12:35:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCA772133D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 12:35:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ENy6xRB4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCA772133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 651FF8E0003; Wed, 27 Feb 2019 07:35:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 602728E0001; Wed, 27 Feb 2019 07:35:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CACB8E0003; Wed, 27 Feb 2019 07:35:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06B278E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 07:35:52 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id e2so12335933pln.12
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 04:35:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=veXYNZXkTz32yr7pG7zMQq2sFTPk6DxGJSlUptrCxC4=;
        b=OkRVcPSG+oHszgehoG+EAkx94oq/pgaaeNCJ+qI6uel1qca/IR+Vs4jipYHI0qtFki
         4xysJYDr7aJ9PW5bXHgvldboF4iNgNcOz3J65lVrPwjaDTLA1vMgZekLXcDn3WWjl9Id
         0OuwdiWmTqOA8byHFwVa2OT87JkDkUFheBQiGSFvjf8y+9M631F3PZTPTIQ7CuIJykqK
         3htQ3nVQaoCPAjlwCkoK8n6EffAq/Syy1K4CMMYF0cX2BV/ckKBd7B4FSFba5WzjS0gA
         6E261bfiPWmh3YPQwEQ8V3zPIiJ8q6ltr7RO8RkPWKBhFnAuV8GwVYIRMYs/sQL4cNEL
         Cl8w==
X-Gm-Message-State: AHQUAuajQ5eye1fUum0aeI4rs/SsiDmjHCHgSW3NZFdhkCA/aRLVKSIy
	HefB50jnXpZbwJUd4ffM9dJ3pgTEkWvXLbUiSzEUPo6LdK0kPORmVlf90iaGAW2tUGovudJnOr2
	3gEB8yYkCoTEMAiH4nL9Da40KB7QvJ103AEnx60dPz7S5Z1d53bH54p6HLNRJlYezgQ==
X-Received: by 2002:a17:902:8217:: with SMTP id x23mr1984788pln.332.1551270951142;
        Wed, 27 Feb 2019 04:35:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iasf7E1BL9cSjgczUVjdIpi4SEiIGHX0O9Uzr+kh0ebYeORNt5l+e2L/6wuZpR1Nr6BivYL
X-Received: by 2002:a17:902:8217:: with SMTP id x23mr1984701pln.332.1551270950243;
        Wed, 27 Feb 2019 04:35:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551270950; cv=none;
        d=google.com; s=arc-20160816;
        b=ukSQVPuTpyH+lKUV9stRZsIe2Gd3aZQEP+tYCNDUmo0PJEnC8SLHAoLhF1ZmbFHCcp
         lazT60kNS/89yWU5iEBfpyxdYbD11TGZThOBYFLH1Abyzb9K4rbhQSEzkKyyxLfNtiXt
         x+Aea9Ui/aE+W+0CriYH/8tNSd3fhttfNSLULB/iHFC3NKWy2V88yOQ8v40igVhFCLOh
         xeC5/aG+5dBcTHBKbfud6rG8GySXb5ysy5/q3jq+dPtm0y1iOtuqeeSWJRhrHh5RRW7w
         Dmw5c6+4LpNibdtg3tVoBuJ4IOLZlsHvGtCMn6j4whcRnhVhcm8bWn39Ku8H9/xx868L
         y4GA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=veXYNZXkTz32yr7pG7zMQq2sFTPk6DxGJSlUptrCxC4=;
        b=DtrmfwIM5bT9xyV/t5lFGFtM4l8pXlhROcKceDlVPyLAcf/0iBEVeFKqjM4wX5+9wP
         mpjHqCksz9vZa7471KA54Fp6maORYHKN5qnfn1h1pECcEakz9WtaRC3eSvKItIjlE0hF
         kbSkyu21lCp+9/k+vkUl7hikMvZ1lrYs+cyLNZjsa20VG7mDxwrkRpBS2ltwzSBeuva+
         jaRtqCwSeTlnzOOTtrQFq/VkpH/hwnqgxyTHITtb8As2iwWki2Pq/a5EPoG/7D1HCfF9
         FrceyNv6RpasKCRg0UNqjGGnwWfjD5cCNg6GoYaidVYcv6dyjEdRCPkY5PwYQiau0DJE
         vubg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ENy6xRB4;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a62si14754652pge.506.2019.02.27.04.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Feb 2019 04:35:50 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ENy6xRB4;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=veXYNZXkTz32yr7pG7zMQq2sFTPk6DxGJSlUptrCxC4=; b=ENy6xRB4gg4RjL+g7mOPQO848
	4zFsei+JdPi+jDtFeLRVYtZX3Q6wQEeJ2+iX61jaHTD4ju5fjqOu+q7kkNT699gAGMtWDc1zqZoHn
	arihQMvylc7RTb7RZeqjO5SeW3qJOq2e2aGxG0NnqLsZHDY72JETHotnjdt3jFc3ZmUPGGvMS7Mti
	iTeGSc8wPJ0uz0ytEBjV9nQ/v39v2mGg19Ew39EdwGa+CGXcjjoJzs7xXiVhqVPfywEJrQIBJ5y4U
	38Q/CWPIJk268gXaO8v+XeBzAkSt9yqUdkf2N1FEKQRg71+ApsyRvU6My2BvFkQYb+RQG58XQ8IAF
	3h+XIZTYw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gyyRA-0007Tc-L0; Wed, 27 Feb 2019 12:35:48 +0000
Date: Wed, 27 Feb 2019 04:35:48 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mgorman@suse.de
Subject: Re: Truncate regression due to commit 69b6c1319b6
Message-ID: <20190227123548.GK11592@bombadil.infradead.org>
References: <20190226165628.GB24711@quack2.suse.cz>
 <20190226172744.GH11592@bombadil.infradead.org>
 <1551246328.xx85zsmomm.astroid@bobo.none>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551246328.xx85zsmomm.astroid@bobo.none>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 04:03:25PM +1000, Nicholas Piggin wrote:
> Matthew Wilcox's on February 27, 2019 3:27 am:
> > 2. The setup overhead of the XA_STATE might be a problem.
> > If so, we can do some batching in order to improve things.
> > I suspect your test is calling __clear_shadow_entry through the
> > truncate_exceptional_pvec_entries() path, which is already a batch.
> > Maybe something like patch [1] at the end of this mail.
> 
> One nasty thing about the XA_STATE stack object as opposed to just
> passing the parameters (in the same order) down to children is that 
> you get the same memory accessed nearby, but in different ways
> (different base register, offset, addressing mode etc). Which can
> reduce effectiveness of memory disambiguation prediction, at least
> in cold predictor case.

That is nasty.  At the C level, it's a really attractive pattern.
Shame it doesn't work out so well on hardware.  I wouldn't mind
turning shift/sibs/offset into a manually-extracted unsigned long
if that'll help with the addressing mode mispredictions?

> I've seen (on some POWER CPUs at least) flushes due to aliasing
> access in some of these xarray call chains, although no idea if
> that actually makes a noticable difference in microbenchmark like
> this.
> 
> But it's not the greatest pattern to use for passing to low level
> performance critical functions :( Ideally the compiler could just
> do a big LTO pass right at the end and unwind it all back into
> registers and fix everything, but that will never happen.

I wonder if we could get the compiler people to introduce a structure
attribute telling the compiler to pass this whole thing back-and-forth in
registers ... 6 registers is a lot to ask the compiler to reserve though.

