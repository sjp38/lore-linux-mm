Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D308FC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 16:26:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 937D420657
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 16:26:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="0Bdz75ko"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 937D420657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31B8E8E0006; Mon, 29 Jul 2019 12:26:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A46B8E0002; Mon, 29 Jul 2019 12:26:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16CC88E0006; Mon, 29 Jul 2019 12:26:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8A918E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 12:26:57 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id f22so68061917ioj.9
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 09:26:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=UR1nwN2DobERwDBbUiUS2eO5vjDIciCJ3KKzmZdKH0Q=;
        b=PKWRzYNiTUL4HjZKR2gEg4m+3xhXu9MGkUJrGDj+qp52rO4s3V3b7HsciVOZLHacWV
         omFtN0p/3burXTVAikh3I1SNrtOlRyVGUKzdifIWLu+th1JiBoduS/bFpgq5j5m1V0wA
         yIvWAVyDlJulZZL4Xzdj6/gXTJHcN11G4AX4YUHGEfXcW5tDNSvw3Jnpl9PA81mVqYxK
         Xdv/Q0S0Q7sFBUfKasW4r0I1fZc9bgF7f57JlcHTao1PcSnLOxmUQY2G8Em5+hEMDx1R
         W6USk23U3Br4ytr+HUTOD7mU0CyjHJkC6GM8ZNS5mUrGg3BgBZW9nsE/c/DcrETDZF3T
         xCZw==
X-Gm-Message-State: APjAAAWyE37IYgKu/Ryd49E/Uxx16sCRWuVyxCJMpusGFHet6n3OUc+k
	6+fg7tIN4Ia4b3wnMpEJOJag9MmkFvOBgJhO3MdAeT3Yz/WjP7vaenjyy5ubgIyk0MGjKIVxQ8n
	ov3fifZWU0xVw+EQpdwQCkwLjSaqMJFarek8EDterStevOFbJu5leQ77U3fPp58YA5A==
X-Received: by 2002:a6b:2b08:: with SMTP id r8mr57317086ior.34.1564417617637;
        Mon, 29 Jul 2019 09:26:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMUgFhH6F+6ORl+NK1n43FyjAtBCLcf2mwEKhQp1d+scUi9kQI0V5nvT/U0g6qbqJ26PRw
X-Received: by 2002:a6b:2b08:: with SMTP id r8mr57317033ior.34.1564417617039;
        Mon, 29 Jul 2019 09:26:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564417617; cv=none;
        d=google.com; s=arc-20160816;
        b=W67PpJ4HBHUB23IvwYZcyx8lFrsOqJbmeIf+jC0NVat3a/Q02xwNtgNPRMIz+FH3Vi
         t42fwYCTQIs88MvPfsZRgEosV6CHSl4ygmgBNZiEde0CSjylyXXZSd3RXxOjQHqRiYO2
         ZHHWa1FiScEPz7d38yhaSe+DrKVdkfX3IhOdHrof/Bmim8HZRnFKZy4qGpxn0vbobCDI
         dAHKLDe3NnQVtZcE7HSUCkGqQafoaZoabr63JgccvAwzShWAr3GlU/EE+pvfAgD03nCH
         Ktg28BJdysdi+09kHcf7GReZoFNhNHSf+yd5QFyKC80X4tyCbT3lMoB1a+bVOx6NdoHX
         +byA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=UR1nwN2DobERwDBbUiUS2eO5vjDIciCJ3KKzmZdKH0Q=;
        b=HzQxL31b2WZd0TuL3wGi8RW82r8zTKB4Bf4yTRUhr8l5H/BBd36UcEu+7f2YNaQgES
         LDsX40vj5Qj97CTDK4OmBp2GTX6ztEAoNMwu0hhGqEq5bmc6QICn6Md7x/1+w7syRjDH
         fap+/APy0W/Bkh9TQXhX5zeAlMVKcA5owYdM5arVEibGWTsz+C0vw2WegXlCNDa07aPb
         5Fiq+wxfbSM1mVOvfCQIKm0p27u3qWdSZevpustt0l51KbzP6zyBEBlrzuyEcr+08+rP
         7r1j/6kQKGjJjOq+LbQKvSaWsurcG24/WNaln+K593xN79wnm8YVvnUWD+sOIE/2mm9Y
         0S4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=0Bdz75ko;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k17si55952462jap.19.2019.07.29.09.26.56
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 09:26:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=0Bdz75ko;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=UR1nwN2DobERwDBbUiUS2eO5vjDIciCJ3KKzmZdKH0Q=; b=0Bdz75ko9JlIuIV7NBooLQGYXZ
	xKeLkiHp/upUnBeY/3RRAQ0w80wxz5hCRhdmbkGPTGDXX9l34bW83spOgXr7BkgDvyJTpD+nzx5Hk
	f7FHE5z3duaS40ug1H6vAfes/hnn2Ko81P07zJpuFTAL9ysk0mR3cEIhP4kdMn+6LN68BxDqEqg3v
	vkbk9UEmf86iZJLfE3J2DUX4/gv/0Oc6UlSCCyR2JKl/sG/g/FaCWfhkauzVmzAft4OuEWMV9uzqL
	q/iTWXu+CcGDHtSRVDr/0z1kzIMyyfsTEHTStTW5ZEfMyH43HSdf7OqvfzZOKEvTHMaAeCC7x0xSI
	V21kBB3A==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs8UA-00041z-Ot; Mon, 29 Jul 2019 16:26:55 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 75A7C20AFFE9F; Mon, 29 Jul 2019 18:26:53 +0200 (CEST)
Date: Mon, 29 Jul 2019 18:26:53 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Rik van Riel <riel@surriel.com>
Cc: Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>, Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
Message-ID: <20190729162653.GE31381@hirez.programming.kicks-ass.net>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
 <4cd17c3a-428c-37a0-b3a2-04e6195a61d5@redhat.com>
 <20190729150338.GF31398@hirez.programming.kicks-ass.net>
 <25cd74fcee33dfd0b9604a8d1612187734037394.camel@surriel.com>
 <20190729154419.GJ31398@hirez.programming.kicks-ass.net>
 <aba144fbb176666a479420eb75e5d2032a893c83.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <aba144fbb176666a479420eb75e5d2032a893c83.camel@surriel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 12:10:12PM -0400, Rik van Riel wrote:
> On Mon, 2019-07-29 at 17:44 +0200, Peter Zijlstra wrote:
> > On Mon, Jul 29, 2019 at 11:28:04AM -0400, Rik van Riel wrote:
> > > On Mon, 2019-07-29 at 17:03 +0200, Peter Zijlstra wrote:
> > >=20
> > > > The 'sad' part is that x86 already switches to init_mm on idle
> > > > and we
> > > > only keep the active_mm around for 'stupid'.
> > >=20
> > > Wait, where do we do that?
> >=20
> > drivers/idle/intel_idle.c:              leave_mm(cpu);
> > drivers/acpi/processor_idle.c:  acpi_unlazy_tlb(smp_processor_id());
>=20
> This is only done for deeper c-states, isn't it?

Not C1 but I forever forget where it starts doing that. IIRC it isn't
too hard to hit it often, and I'm fairly sure we always do it when we
hit NOHZ.

> > > > Rik and Andy were working on getting that 'fixed' a while ago,
> > > > not
> > > > sure
> > > > where that went.
> > >=20
> > > My lazy TLB stuff got merged last year.=20
> >=20
> > Yes, but we never got around to getting rid of active_mm for x86,
> > right?
>=20
> True, we still use active_mm. Getting rid of the
> active_mm refcounting alltogether did not look
> entirely worthwhile the hassle.

OK, clearly I forgot some of the details ;-)

