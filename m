Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24714C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 20:06:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C724421655
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 20:06:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hSNfUmq2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C724421655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 670E76B0007; Mon, 29 Apr 2019 16:06:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61E3F6B0008; Mon, 29 Apr 2019 16:06:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C14D6B000A; Mon, 29 Apr 2019 16:06:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id F23246B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 16:05:59 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id j126so492586wma.8
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 13:05:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3bA1GjyiOqhiuVg99bZFV+UdtqoiitioJOxxTtpTJvM=;
        b=ByEgIaqmIGKSVtAgQCN4dwJ2ISG7lg7yGBapUc21TvFhm1e1Wh9ImNwiCeHkpa+iiT
         p8BPXs4k3B+QU+L2FNpiOTVeYSggOHVXsZxHNY8FMag1h8LU/xsPdy+685rPg8ICxdDX
         KW7EEzYjdex63jkdvOIQsiJ5L/nVj4ibToz1tjUGCKLiYuHVWs1yn29QHl7TTqkcEdwV
         nDfwiYPFthbWYrM5bOp02JGKDVJbDp6OMYRqCkEHCmA6ZhRwHqvMynFt9nMTUIPTdrkM
         DKm3fuz4lcAGMgfNv4J0HbYJcmG7YpRSVtqxS9qVgyEaZf2snfz44toL3rgBbv2og27t
         qh2g==
X-Gm-Message-State: APjAAAVSklAZxFZCWxW0+faA1bOnVl/6Dxq0NhUWamfbx3s4GLevEqPK
	N8UaUaFLbDNg9SWp9aFOy/ZmwrP7w5zNv+4EpqUtu/xp0qv0cPe9iuRyuMuS3fxBG4A8hYyAQhe
	XIzLPSyQMiWWABOoqMDiHwevw4Pt5u0wFwRfjYqJQdpZrex+YtZrdPFfbI/987cI=
X-Received: by 2002:a1c:b189:: with SMTP id a131mr510603wmf.107.1556568359535;
        Mon, 29 Apr 2019 13:05:59 -0700 (PDT)
X-Received: by 2002:a1c:b189:: with SMTP id a131mr510578wmf.107.1556568358533;
        Mon, 29 Apr 2019 13:05:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556568358; cv=none;
        d=google.com; s=arc-20160816;
        b=ErAGrcPDi+KbL3dZHa58Go9QJ+dzR+oMGd7yAt8kJ/wzGZ8O28xTROCT7Ommo1A4dZ
         IBTGIBR6qvB27QG1BxwrP73NyYMbZyvOr6uNZXGsBC+paeJ4bf29/UjtcVUvtke9U0Wc
         fcCv1+4TU+6ogeOPWG6AWye/XYpJpGaWEwxGrNx4aZUWk1TZoNXe3DFr4YIN4/OuZF72
         BUkpIAx5NHg9TmGejdaspPgQo+d9VHoKveErE/j40NyjJds3HtVAQ272GfFKbrgw/f1l
         h91vCOi8a7tKtfYTb9vd/j4bVlREsqzrxeGP8wAdxkKxbCyMzK3qVcZUsprLc2gnhNUb
         pfNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=3bA1GjyiOqhiuVg99bZFV+UdtqoiitioJOxxTtpTJvM=;
        b=cnR8iuNeCUUwZi/UJtKT88MSHjRjNrlL5na10qSZz5YdoYhGJsjUC9LWy4zyONOPDq
         e73SNoQoLLEFnB9skeCUPgynTzfzWtCnTYGGEX3xu7B8KfkA7BfY3oe/Ob6havyFE1zO
         M7WIiFA9HFZDVGKKFlAAHSdIbSNuUejXryscES/RTPOKSlIkQv7QPhTKYu5Eh3U4rmur
         FPwGA3XklMZXPMtgh5NEJj9M3ptozHgLs6Dw5W4WwLXveFWnbl+sckNKU8OO1SAgAu62
         9wSw3FUoDPKelHSDQsg5Pl/sDpuNMGAWR/5OuOFmcYnEiqXnKALg7G230Pc89xF173mQ
         s0uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hSNfUmq2;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l184sor18815664wml.4.2019.04.29.13.05.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 13:05:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hSNfUmq2;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3bA1GjyiOqhiuVg99bZFV+UdtqoiitioJOxxTtpTJvM=;
        b=hSNfUmq2FWt0hwGZGwRRx6ux4gGT19Z5mAXNwVuJXSN0QwcB9VBBQjDL8/gAfaXgqB
         PRlKgIyaEV14eqq9h9L4TUyYrd5sgX0pGXQdZc909GLHZU364d3jtzd7xrRSpqa9A11b
         D+Fs7K3AvlCcHWx8JTwPW3VZzB4DCl4bQlclAVlHOg4hc1KdEatZsLbKfVe8Z7vHPT9h
         LEKz9P0XxBAI+WUUh4KOezOQ/PkWGLnMO4oHEX0ohv3qDcS7KWvjVKizM2Xlp9Zpd7OX
         DZ2dAcF/7yL9BguEcP2PmPY8/G1Uz1NPA+EmHwCRlS5y9XWA4wBAg0gvQ7b2KYHtVEgX
         L0aQ==
X-Google-Smtp-Source: APXvYqxGiHSnnNJ1a/9EZhUrXaRjPVCn9qMn/skaREokKLrBVmvLfqx2RSYt4Z2utXm9gg1l+N3zKw==
X-Received: by 2002:a1c:d7:: with SMTP id 206mr567213wma.69.1556568358168;
        Mon, 29 Apr 2019 13:05:58 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id c63sm762243wma.29.2019.04.29.13.05.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Apr 2019 13:05:57 -0700 (PDT)
Date: Mon, 29 Apr 2019 22:05:54 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Atish Patra <atish.patra@wdc.com>
Cc: linux-kernel@vger.kernel.org, Albert Ou <aou@eecs.berkeley.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anup Patel <anup@brainfault.org>, Borislav Petkov <bp@alien8.de>,
	Changbin Du <changbin.du@intel.com>, Gary Guo <gary@garyguo.net>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Kees Cook <keescook@chromium.org>, linux-mm@kvack.org,
	linux-riscv@lists.infradead.org,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Palmer Dabbelt <palmer@sifive.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	"maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>,
	Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 1/3] x86: Move DEBUG_TLBFLUSH option.
Message-ID: <20190429200554.GA102486@gmail.com>
References: <20190429195759.18330-1-atish.patra@wdc.com>
 <20190429195759.18330-2-atish.patra@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429195759.18330-2-atish.patra@wdc.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Atish Patra <atish.patra@wdc.com> wrote:

> CONFIG_DEBUG_TLBFLUSH was added in 'commit 3df3212f9722 ("x86/tlb: add
> tlb_flushall_shift knob into debugfs")' to support tlb_flushall_shift
> knob. The knob was removed in 'commit e9f4e0a9fe27 ("x86/mm: Rip out
> complicated, out-of-date, buggy TLB flushing")'.  However, the debug
> option was never removed from Kconfig. It was reused in commit
> '9824cf9753ec ("mm: vmstats: tlb flush counters")' but the commit text
> was never updated accordingly.

Please, when you mention several commits, put them into new lines to make 
it readable, i.e.:

  3df3212f9722 ("x86/tlb: add tlb_flushall_shift knob into debugfs")

etc.

> Update the Kconfig option description as per its current usage.
> 
> Take this opprtunity to make this kconfig option a common option as it
> touches the common vmstat code. Introduce another arch specific config
> HAVE_ARCH_DEBUG_TLBFLUSH that can be selected to enable this config.

"opprtunity"?

> +config HAVE_ARCH_DEBUG_TLBFLUSH
> +	bool
> +	depends on DEBUG_KERNEL
> +
> +config DEBUG_TLBFLUSH
> +	bool "Save tlb flush statstics to vmstat"
> +	depends on HAVE_ARCH_DEBUG_TLBFLUSH
> +	help
> +
> +	Add tlbflush statstics to vmstat. It is really helpful understand tlbflush
> +	performance and behavior. It should be enabled only for debugging purpose
> +	by individual architectures explicitly by selecting HAVE_ARCH_DEBUG_TLBFLUSH.

"statstics"??

Please put a spell checker into your workflow or read what you are 
writing ...

Thanks,

	Ingo

