Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 240C9C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:42:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C22792087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:42:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C22792087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E9778E0003; Tue, 30 Jul 2019 15:42:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 298D28E0001; Tue, 30 Jul 2019 15:42:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1889C8E0003; Tue, 30 Jul 2019 15:42:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D8CFA8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 15:42:14 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z14so34191424pgr.22
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:42:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XkJBF2doekJ4Iv+TVOYQJyouKel1/VeuFiZWcdh1rQw=;
        b=hAdXBYflAIy7+YgCth5W7Hloxnfcv03np9SBYLgaX9K5w6oikJps8YTXaDmWrSEBfg
         Ifx1WY9gJwM4PT/sD8lFZCeeVzyGqPGOrLOK8a9XYLByP3wiCV9n+E5+ETBFZGFnLn2r
         eVZYlM/uatc2n45+Glw/nmYMh9IytfCSo2XuodJrrosrBOImxPXV9AXhpfqqkeEpQPH4
         FBnBoYIYkxw4heHzLCOUzuogLFuKxHr6Ei+AAkW8A44zK79L9qHe8Pyi6W3C2smYq8mk
         yLfvSImwlDLqFHFNsi7AheSo8917h83tWtIhsnqGpzCg0Jqq3W9gREBe3Qw2uG8plzo6
         aHfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAU50GUXRqgTN+Vvxf6WRVZjXtk5wkmwEbqJAaMjhhuFP/Y5+bgx
	smxKv/J7lPpZaHhrrnmHdz7rhQ7qG+u/yRcf4BOcnqTLzu0p/dAcLQeGm3Rew7e1hodHb7bHXKF
	IsVxsqho1u6aVJ9md/zOznmRmRUw0xGL3p8OK6BXk0cfpyaxe5Serpyp3P1V+lDW+5A==
X-Received: by 2002:a17:902:b905:: with SMTP id bf5mr108944267plb.342.1564515734534;
        Tue, 30 Jul 2019 12:42:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvOpKI44ZhSC9ZuvlGVGIElkWUExpOYfZd2N3Ha066oljm9QsOGaWDJgEXYPLuseIcTGlM
X-Received: by 2002:a17:902:b905:: with SMTP id bf5mr108944236plb.342.1564515733850;
        Tue, 30 Jul 2019 12:42:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564515733; cv=none;
        d=google.com; s=arc-20160816;
        b=erBS/Lbc7IDXuu/eQ2r0kuWi14N94/fNNEswU8qFaTXOhX+CoSL9X9dxeldJdQgNZ/
         TTnQq2g1Ua7KrPl16W9qxtx/mbloibLGUxKnrwr9zs59XaPsdYjfdbhKUIXlbe6zDsau
         g9eraHYbzQxiC6NRA+AMdBvbR0dTEeOwdJCNeIRfuneg7u1XYT3HhzFajBwm21mWZJog
         k1DpxI4vUB1Lwh3FFd4m14bVpR877FcsvdNbgYvDlq2wxifpUZEEPpI0WajFjwdEPhUT
         tuSWnVUp1bSiNfNCMaEamF/BsDY7/vBrRUdtOg/7JILZWVfaAV2ClXK/nqJU9cM1mIf5
         tR7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=XkJBF2doekJ4Iv+TVOYQJyouKel1/VeuFiZWcdh1rQw=;
        b=0ZGNfO4rhkA7FUTGg9WZkh2QTkThpfy/qcpBBhVBtkp9tcmVfokVmTU8z+0dn+yjsp
         KNfibYuMVhZEFroMnpLB1GVT8JbzOBKDAlfRBr4Disls8QDQsvAG3aEFX0UeUN+KRG7V
         dawEsXEauI35eONgnp8i30VanXHAVDm9p/pX456eaSkquYIWvkk5YIv69PW5T4za35Hq
         2TGy0m9WOcCKzHPpLr/tBSB1MEv4z+yg5UOYgEBGeqHlVxocD+uBWTPir2YIGMwo5gNK
         UCIenf8nMnIj5Ht/shC6vKSZIwN239kvfEYK2xlav8ImaNq6el2CoI2TkLmntu+UV3Sx
         M9kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q11si29791755pjb.84.2019.07.30.12.42.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 12:42:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (unknown [76.191.170.112])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 878213336;
	Tue, 30 Jul 2019 19:42:09 +0000 (UTC)
Date: Tue, 30 Jul 2019 12:42:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Miguel de Dios <migueldedios@google.com>,
 Wei Wang <wvw@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman
 <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: release the spinlock on zap_pte_range
Message-Id: <20190730124207.da70f92f19dc021bf052abd0@linux-foundation.org>
In-Reply-To: <20190729082052.GA258885@google.com>
References: <20190729071037.241581-1-minchan@kernel.org>
	<20190729074523.GC9330@dhcp22.suse.cz>
	<20190729082052.GA258885@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jul 2019 17:20:52 +0900 Minchan Kim <minchan@kernel.org> wrote:

> > > @@ -1022,7 +1023,16 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
> > >  	flush_tlb_batched_pending(mm);
> > >  	arch_enter_lazy_mmu_mode();
> > >  	do {
> > > -		pte_t ptent = *pte;
> > > +		pte_t ptent;
> > > +
> > > +		if (progress >= 32) {
> > > +			progress = 0;
> > > +			if (need_resched())
> > > +				break;
> > > +		}
> > > +		progress += 8;
> > 
> > Why 8?
> 
> Just copied from copy_pte_range.

copy_pte_range() does

		if (pte_none(*src_pte)) {
			progress++;
			continue;
		}
		entry.val = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
							vma, addr, rss);
		if (entry.val)
			break;
		progress += 8;

which appears to be an attempt to balance the cost of copy_one_pte()
against the cost of not calling copy_one_pte().

Your code doesn't do this balancing and hence can be simpler.

It all seems a bit overdesigned.  need_resched() is cheap.  It's
possibly a mistake to check need_resched() on *every* loop because some
crazy scheduling load might livelock us.  But surely it would be enough
to do something like

	if (progress++ && need_resched()) {
		<reschedule>
		progress = 0;
	}

and leave it at that?

