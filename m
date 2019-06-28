Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D601EC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 05:47:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9645E214AF
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 05:47:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sifive.com header.i=@sifive.com header.b="lmpx8dS8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9645E214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sifive.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 378616B0006; Fri, 28 Jun 2019 01:47:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 328178E0003; Fri, 28 Jun 2019 01:47:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EFA38E0002; Fri, 28 Jun 2019 01:47:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 020E76B0006
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 01:47:40 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id j18so5389022ioj.4
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 22:47:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=JonNVAGavnRlJhh68LVsFtVqprQdtcLj2PTjdYw2e9k=;
        b=U6WM68L7R1LOZxhEAzNqCrH6eq7NresEp+7uDlV0wBNP7tc5DfpjijfiDXdQ9rK0uO
         L3EdJ/aMGpQcK0fMHQ9i1gg7sgF2Ece+gYb/rdKzhTSSoO0HVFvnzJlPHnFpw1J8DVz4
         YDVZ8XqhivVi3qVD6VThXFOJqCEvulhUlF+g82NIEVpWRDRQkA3iRq/ao088aL5vX4wj
         7ULSRaApYHpeqXzWnWGemtV2PlhTiuI0RplweHejoJvBSyHLKI8e4IfDI73JDKzYskFA
         WUkhIncpcNOK6MGUGdjSpFag2vSAKudeYcHictAxk3mAY3tffebUMf8QYM+LOw8O9bUY
         nvAw==
X-Gm-Message-State: APjAAAVGXRK8/itXBTpWmkJ0AuAZ64oVjy2pwBDJ5dQxuBvt2Q1AJFqr
	0RTEkN9AK4cBrh08Y6rm6cxYbCns7x2g4I0+uS7uLrOHlnXH9CLQpygPImZhd3Fy95B+7XyDFln
	9drU5hKh9FaFOLt+UgBceR81xLlr2Fj2PXkOJVa8qyX392KW79UQb+qb9cPNGZ1wwLQ==
X-Received: by 2002:a05:6638:605:: with SMTP id g5mr9714121jar.110.1561700859834;
        Thu, 27 Jun 2019 22:47:39 -0700 (PDT)
X-Received: by 2002:a05:6638:605:: with SMTP id g5mr9714069jar.110.1561700859158;
        Thu, 27 Jun 2019 22:47:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561700859; cv=none;
        d=google.com; s=arc-20160816;
        b=MIXw/AiPUvIIYNSF8e1rEPMkisHNRWhh+yrbaIc/3Y17OL9siPrCtK51nGSKTbZlxk
         fNp9cPaXdMsWSJB3xZcNrD1jYrSe0dOMlCCKCO9ZaMB0A40C9yZYAuNWM7deceZ8eUew
         PGKWGFKT50zAN/zX206M0AU8Kv5Ld7DJvj0SFRXxNLbIZQqd+YrgSDdBexJODWXgxH4Q
         cml8PddylXaiZHU+gBEPjWunJ2eyPxjhf4jYoI0tuhEMcrbK4KdPZUiktX3koq3hKQMG
         Hv/e5yQPXUrj27H5wCQAALAvBGHYbRdrSM/mM7GFxwxYjgxY2ZkeYmfLB4wIETlklzOQ
         jTMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=JonNVAGavnRlJhh68LVsFtVqprQdtcLj2PTjdYw2e9k=;
        b=jnqxLDHnwPOBe3RCNZmYMgdY/ET4/AnF036SUnO6qPpBmLn60WEkfekjKeRvgyMEj4
         5etR6zutCF7jMedM94hGFO76ilevu42rQyZjR5q9gdk1IKAo6ryo7ujxdCrxVnR0dx5a
         vXJuxw4v+l2FcCoZxj3cZyGUnUc7AlvrwRg9Q9raUFlnY8Z5neAd7Swo536TrzAXBpR0
         zjHGzKmqQwp9w/XI6zBPo6NzbtjGnGpkzh68BzU3zHKvWJ/pOqk5q0udcS6IPa4YvHsf
         Wl7T/I7ZI8Inj3iAlJi74ZiSRS4nRHWNRejbCK1Ej3Tae6D2UD90ZYfeicTRgImtVmar
         lzrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b=lmpx8dS8;
       spf=pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=paul.walmsley@sifive.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z9sor978872iop.12.2019.06.27.22.47.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 22:47:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b=lmpx8dS8;
       spf=pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=paul.walmsley@sifive.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sifive.com; s=google;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=JonNVAGavnRlJhh68LVsFtVqprQdtcLj2PTjdYw2e9k=;
        b=lmpx8dS8SmmI+bod4CIGHygIhMfXqrGVR8dl/YJdRJFestIpTr/2lSxlvkarvtECIz
         jx6ZaHJ4aIqG/48rZvDj+pl6lnRoAg9OZ9mxYeLRu+N9SYpUGe3wfh4MU68CNNoASNHc
         CGNxA2syIdCf+HG0oxmfLEi5SFjUdX3hg9TniJxA+g7sQYNxfgMtpYyJie9GQC9bxwvC
         cReJnEEoKLA8nTHOoZ5SvxX9pXWN/Xc6nNnzVxLP0Q0BGFsjFwe1RkKw61gfOyGVyCmv
         qoJTVQu/+2v//+Sk7Cwc3qJ9hw8ZgudhaYDERLiqQNqOdyIAwuu6iSAeKjQ6bW/nLZQu
         bTRw==
X-Google-Smtp-Source: APXvYqxSBxEznv5crFBLQNZa0Y7NNPYl7akgvsmNh/b7ftqbAIdgqF6gL+AZSuyVieJq0WKR7ZDQsQ==
X-Received: by 2002:a5d:8195:: with SMTP id u21mr9407119ion.260.1561700858671;
        Thu, 27 Jun 2019 22:47:38 -0700 (PDT)
Received: from localhost (c-73-95-159-87.hsd1.co.comcast.net. [73.95.159.87])
        by smtp.gmail.com with ESMTPSA id t4sm1064999ioj.26.2019.06.27.22.47.38
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 22:47:38 -0700 (PDT)
Date: Thu, 27 Jun 2019 22:47:37 -0700 (PDT)
From: Paul Walmsley <paul.walmsley@sifive.com>
X-X-Sender: paulw@viisi.sifive.com
To: Atish Patra <atish.patra@wdc.com>, Ingo Molnar <mingo@redhat.com>
cc: linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, 
    Albert Ou <aou@eecs.berkeley.edu>, Thomas Gleixner <tglx@linutronix.de>, 
    Kees Cook <keescook@chromium.org>, Changbin Du <changbin.du@intel.com>, 
    Anup Patel <anup@brainfault.org>, Palmer Dabbelt <palmer@sifive.com>, 
    "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, 
    linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, 
    Vlastimil Babka <vbabka@suse.cz>, Gary Guo <gary@garyguo.net>, 
    "H. Peter Anvin" <hpa@zytor.com>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-riscv@lists.infradead.org, 
    Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v3 1/3] x86: Move DEBUG_TLBFLUSH option.
In-Reply-To: <20190429212750.26165-2-atish.patra@wdc.com>
Message-ID: <alpine.DEB.2.21.9999.1906272236550.3867@viisi.sifive.com>
References: <20190429212750.26165-1-atish.patra@wdc.com> <20190429212750.26165-2-atish.patra@wdc.com>
User-Agent: Alpine 2.21.9999 (DEB 301 2018-08-15)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Apr 2019, Atish Patra wrote:

> CONFIG_DEBUG_TLBFLUSH was added in
> 
> 'commit 3df3212f9722 ("x86/tlb: add tlb_flushall_shift knob into debugfs")'
> to support tlb_flushall_shift knob. The knob was removed in
> 
> 'commit e9f4e0a9fe27 ("x86/mm: Rip out complicated, out-of-date, buggy
> TLB flushing")'.
> However, the debug option was never removed from Kconfig. It was reused
> in commit
> 
> '9824cf9753ec ("mm: vmstats: tlb flush counters")'
> but the commit text was never updated accordingly.
> 
> Update the Kconfig option description as per its current usage.
> 
> Take this opportunity to make this kconfig option a common option as it
> touches the common vmstat code. Introduce another arch specific config
> HAVE_ARCH_DEBUG_TLBFLUSH that can be selected to enable this config.

Looks like this one still needs to be merged or acked by one of the x86 
maintainers?


- Paul

