Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE8D5C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:09:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B076208C3
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:09:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uX/PF8/B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B076208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22F646B0003; Tue, 14 May 2019 03:09:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E0926B0005; Tue, 14 May 2019 03:09:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F6836B0007; Tue, 14 May 2019 03:09:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEC926B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 03:09:50 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id n3so11376932pff.4
        for <linux-mm@kvack.org>; Tue, 14 May 2019 00:09:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/z5RzNGJzW1HToa5OVxP0O9danntTUkXNkeid122vEM=;
        b=qnmtyqob8R5zR8FnFVy2Nzkw5QuHwUKkzxuZmyU3LJt2NeWRxDTHTVBQZWcRNoD8Sj
         QDt7inqWGQaxlvhFGwZKAn8Cw9b/jPXmCIMd4XRjjy9Mvr42IrzbUwh8dMkfLoaFAN1U
         qK9PFpbEi4UacwOMQyMqOwXYrxnYqT8+PHNJK97tzFsWQQCsX8dsSKbDzIny9+lspUKC
         qJZVzdKXFfRsg1lgar/7UUXFtEyaRcgc/DphvdvCBCXxbGBbSovW3c4PPqMENY5WTV7d
         LH7npTt+C1GkKXmumcJuyeqH/jkpGJjyuS0Nm+yDVBnMG/5FoIs1tRuMbayTjiwyeobu
         dZsw==
X-Gm-Message-State: APjAAAUB0ReTJVj2hJ9WOx6quk9SNKLL3+NrPt5utdNBBgsEZFubZOXT
	ra90L+o8y4R6xYphNNnlyO9kSkjGlCtur/aeh9U7C8bmKTF8JZKMx4rKmFFycIS3aYImGlnT85o
	5kSJtiwjJne4MU5qktJdnZTgQoTD4blF4VLnHrdLo/UOSDtWzLheK+IzTKhUZORd4iw==
X-Received: by 2002:a17:902:2ba8:: with SMTP id l37mr14771532plb.229.1557817790373;
        Tue, 14 May 2019 00:09:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpL2cq+9IjH8xV9gTyaYK83T5qXJ90mnDX3gj++0zgZo1EN79WgK4AbxqUTtFjHw0nEY4h
X-Received: by 2002:a17:902:2ba8:: with SMTP id l37mr14771405plb.229.1557817788577;
        Tue, 14 May 2019 00:09:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557817788; cv=none;
        d=google.com; s=arc-20160816;
        b=IMqm5ezj+PJZkzEaVAxbGo4I3Gt7+kBBckvHkW2mryIQYJ4OKNuWNiFhWsRb4YeloH
         L6YjDI2/RxTVtTKZrhDq6y4PAThHWR4JVHDyRppRu/dcZDicncpOhwQ7dEfO4JY3OGYj
         fxmeqokoetkanZ7/+Bc1BPTJsIffMrWeAiRPhv7XU9WK0+xMxjVMvvziUsW+8XQ3UIb+
         AzASWOK0edrcvpygepoxOKH+CxzlE/wo02mvYASH1hsV+aTVynFxdcovLkZLuEsGO00k
         RyZ9PCI8TwWiAK+YFhQfMH+a753ev/3DRswZZwldPBS5Xenz8gqyqdnwi3W784oiMdEw
         LEmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/z5RzNGJzW1HToa5OVxP0O9danntTUkXNkeid122vEM=;
        b=g4AR215NFT5C3qmlvMK7+Wm4GwiTIM+tZapsQpybslwCpWvnEQkOdG4JwG+hF6lL8R
         37icYHdSH6ac+45Q5x6h3WF+ZyfX2Ojfy7szSB+LICRvxKBR3uLXN625RnALRDOvc70b
         0HfOZ+FmHN2+KTvqTqJQGxjDPSV6PkS3zxrBqMqs3yu+BsoZDHk3pZy6CZN5owEWRaJI
         t7X2s9upJ7/kx/XiknYC2VvbvupQO0pE1pWG+9M5j/KMeuLggss0ZTaO403gTyMZgBD7
         4y9Qmc+NeSEHV4TC1f2kMF1J7ssFIf3TZ/bEmROWdyT10+P/Ju2iH4gV2fBRVE4l8hAk
         7c8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="uX/PF8/B";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u7si14613254pgi.339.2019.05.14.00.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 00:09:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="uX/PF8/B";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/z5RzNGJzW1HToa5OVxP0O9danntTUkXNkeid122vEM=; b=uX/PF8/BZSeVv5cPYS/kBWxFp
	UDDr+gcUIfetuw8aGDKQAfysqqZJaUz81VHEMON8xTdLLiTpmvG5WCRkt/CEY21gb3D6P2AlCsjNa
	sf0i36/+rwA+lGQOrFddAhvfXScybliJbFvtwsTcLmcFia80AO9SPV6fbZAreQpv5iwSvaXbG5clt
	qAWW+0m229JhnOySjs3Bm0qnNwoc5kzUN/Zdjgf7IEFS/vVTiv9X4ZmIi0PMu6AnplhZzKcMcqcbA
	pBmJBkzg/ZEv1TJPg3f7a2OKjgL7A/SQEMkkAMbOx0FX6IMKXMEaIGyTsnQkbUyFo8ri6RR70llLI
	uwPjbMl2g==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQRZH-0006YZ-Fs; Tue, 14 May 2019 07:09:43 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 032842029F87A; Tue, 14 May 2019 09:09:41 +0200 (CEST)
Date: Tue, 14 May 2019 09:09:41 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim Krcmar <rkrcmar@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	jan.setjeeilers@oracle.com, Liran Alon <liran.alon@oracle.com>,
	Jonathan Adams <jwadams@google.com>
Subject: Re: [RFC KVM 18/27] kvm/isolation: function to copy page table
 entries for percpu buffer
Message-ID: <20190514070941.GE2589@hirez.programming.kicks-ass.net>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-19-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 11:18:41AM -0700, Andy Lutomirski wrote:
> On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
> <alexandre.chartre@oracle.com> wrote:
> >
> > pcpu_base_addr is already mapped to the KVM address space, but this
> > represents the first percpu chunk. To access a per-cpu buffer not
> > allocated in the first chunk, add a function which maps all cpu
> > buffers corresponding to that per-cpu buffer.
> >
> > Also add function to clear page table entries for a percpu buffer.
> >
> 
> This needs some kind of clarification so that readers can tell whether
> you're trying to map all percpu memory or just map a specific
> variable.  In either case, you're making a dubious assumption that
> percpu memory contains no secrets.

I'm thinking the per-cpu random pool is a secrit. IOW, it demonstrably
does contain secrits, invalidating that premise.

