Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECDD5C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:19:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2EA5217F9
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:19:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="efhWri0O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2EA5217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F3E06B0010; Fri, 19 Apr 2019 03:19:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A4796B0266; Fri, 19 Apr 2019 03:19:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11F846B0269; Fri, 19 Apr 2019 03:19:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C676E6B0010
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 03:19:01 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id n63so2991036pfb.14
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 00:19:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=M4U9lCHjwX+RI+C+4Qn3GQkY7/2O42PH32K/E1UYiUo=;
        b=CYoxdo4QOPN5vIHjV76NLjbCaa+EUjXQbLYu4lmdjjU6oOg5JjeBUBwXbKXKbKob7p
         oELpzsJwjM7iuLXiahu2TId9dCncOOy4fscfwtgvRw7+qCsG233R4pbyYEHu9uyLpRdC
         YZjqvjt+4/Nq38RQSa5+3/IySVd8G0AJnfkq0Ra3dOJuOFkTg193x7IJ6lAdoEwzZfhk
         PVPpPyhH22/U+ApDdGQG/sAKDOAPbmFkjVQhmN1yG3rhApkhLADAcOiwej/JyqjIM7r2
         zcIlX+SWAL9Lf11tmAy8BJ1m09PDhYfpv1jAkzuvkaU6tjNiTA2VwLJas5duu9spn/JX
         zOwA==
X-Gm-Message-State: APjAAAUpv5hB67aqdSrmP5XQofzRXq+cnQ8eA57r12rAquzGEVOMult0
	+A8QgLYwkIg7LKZob+TT+GxW6G+FXocVGVvNTOPsTxLgtOdqkBahyDiTaWLHKnuAGD2JsAqZDg4
	1bdRBAkOGapCldw/ow2b0QRW1zg/wnWggigPyI259NJEF6fqPs1DgBBB1/3oEY5WEXQ==
X-Received: by 2002:a63:fe0a:: with SMTP id p10mr2409995pgh.86.1555658341357;
        Fri, 19 Apr 2019 00:19:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRh+VqrYdIQCzt15jXzDVWOhBVrRunrccK+FigGPDtZPZUAWXVQSQPNc4vzIpeEsCMhN2e
X-Received: by 2002:a63:fe0a:: with SMTP id p10mr2409951pgh.86.1555658340532;
        Fri, 19 Apr 2019 00:19:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555658340; cv=none;
        d=google.com; s=arc-20160816;
        b=1AjP+RVJ8ilDSMTEip1XM+andW1QykwLkXNS5bWMMUSFgEVkw8DbpjU4rZEUok2khZ
         ajVgXj8olGAsEgI2EnTIB8reDBBzFhE5i7R5E8i9XxPDg5hWispWS1glIsp1+y+txmfb
         8I95vNsltXqN8cdHCIdNQ3BwLDFf9qE2GBeBITT2erN9vyECYsvx3Q/mSM3IozLthCV3
         2P3Xjmanlg/CQECl3m0Cq9j5ymOstCEVT5GSRQoyO+dy7OxTfkjHjp97sqlt7rvo2YMS
         TLITCmqucC2l93H+IO7+a4MvQgmCXHc7OX7ElZR8FrOBG8FrcsPShNzydFk57Sl5oJb9
         k0XQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=M4U9lCHjwX+RI+C+4Qn3GQkY7/2O42PH32K/E1UYiUo=;
        b=gpS43mkNOlIVIq4GpYEN+HXCZwCz0KkQ4KJ/d8fmnDmL2eRyKi+x1p3HIxNEuUWnWW
         ml52btPhacmxw5ISAEuxNzXrOx/nzIdivGq6q2/NzZspEufHfn4oIVUQ2JdhTg+Ylb4q
         vqgNJB8ShI0+xL1XJvmDxmytgp7zvupmXgjoZ6hKfAxgFe5qBJtrkDGsElVozTVt8iUR
         G+qrLKnow5R5E+QiotGwpTTn6Xx6PlpfSX8KMcLiapAY3qwRidxD8CYrvlItSIJCfSua
         IbXPTfKyb7XLOzkmn6fSmQUA4zD5s/IMzeBml2xVXWLgCbravaroHJVU7FtGjIlAkJ/J
         NYIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=efhWri0O;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z8si4205708pgh.82.2019.04.19.00.19.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Apr 2019 00:19:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=efhWri0O;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=M4U9lCHjwX+RI+C+4Qn3GQkY7/2O42PH32K/E1UYiUo=; b=efhWri0OqGFVL87uVOhTf0P8c
	VSvSxYJhAd6hWo8CmLsODUpgHy2FOdjPhzivpgzeDYDDeiD5oIiDpm5/7IbHgKjlq91wLpWzl1aD2
	91I3Ez2HBIUFPqmjTLYnv1ZBwWH/Qw3AsrWa3Rbc4zrTGp/lwd5liclNi1MQEvkxFpGtCo0tFht6C
	ylKfaemtfAjzZtz7n+nThE01KGuJI1R+8abPHEYloVasqEARRFqBwNStJEX8+DkrmdReR692/NWRH
	8Fb/ZC+LcMEtU9ngoXTQZys0EFT/JnwkdRRcHWVA/k49KlOl+ugsAq67JLMjnv0e+1/DskCXYRzRn
	lv2tg85gQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hHNnJ-0005As-Hx; Fri, 19 Apr 2019 07:18:45 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id C26E229B52F44; Fri, 19 Apr 2019 09:18:43 +0200 (CEST)
Date: Fri, 19 Apr 2019 09:18:43 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>, linux-arch@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Daniel Vetter <daniel@ffwll.ch>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>
Subject: Re: [patch V2 28/29] stacktrace: Provide common infrastructure
Message-ID: <20190419071843.GM4038@hirez.programming.kicks-ass.net>
References: <20190418084119.056416939@linutronix.de>
 <20190418084255.652003111@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418084255.652003111@linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 10:41:47AM +0200, Thomas Gleixner wrote:

> +typedef bool (*stack_trace_consume_fn)(void *cookie, unsigned long addr,
> +                                      bool reliable);

> +void arch_stack_walk(stack_trace_consume_fn consume_entry, void *cookie,
> +		     struct task_struct *task, struct pt_regs *regs);
> +int arch_stack_walk_reliable(stack_trace_consume_fn consume_entry, void *cookie,
> +			     struct task_struct *task);

This bugs me a little; ideally the _reliable() thing would not exists.

Thomas said that the existing __save_stack_trace_reliable() is different
enough for the unification to be non-trivial, but maybe Josh can help
out?

From what I can see the biggest significant differences are:

 - it looks at the regs sets on the stack and for FP bails early
 - bails for khreads and idle (after it does all the hard work!?!)

The first (FP checking for exceptions) should probably be reflected in
consume_fn(.reliable) anyway -- although that would mean a lot of extra
'?' entries where there are none today.

And the second (KTHREAD/IDLE) is something that the generic code can
easily do before calling into the arch unwinder.

Hmm?

