Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2951FC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 09:57:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1C93205C9
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 09:57:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1C93205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 796186B0007; Tue, 23 Jul 2019 05:57:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 748328E0003; Tue, 23 Jul 2019 05:57:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60E838E0002; Tue, 23 Jul 2019 05:57:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1222F6B0007
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 05:57:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l14so27934446edw.20
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 02:57:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ChqCczgPPMAdZGIJfk/xI6N8p5HZAKgav0uSZ0NSoxc=;
        b=V/s8md1myVbTA/rBovIOf1JAS+UCS23BiJNKKXRaxKxt4jqFp78XliPrpMXI1SuQJz
         hecDdCdx8lsShUXJiZHTHFzZx8TZXMTo1U1Gp355yZ2NrqBus5j581gTwi4CYuU1Vu7R
         qrMbk61TObQqjA7ffkPOXHEJ8UATn7hEu5+0Yr2y2bOMrXxTJ4ZwxaZ4Z9teOP1sLCWN
         mCSdVYjuwViGO2Ps2exV/y8z562TS5UTzF1egY+/ODQVxDmbj/nfDcB8ih3HdEalekuj
         oD01j64JFDCrdpErI8G0MHX25HusilQSPtNEgz1Rz+r6l2tCnKCvEp72ToBHy7mIPYzN
         vssA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAWs0VzSImQnLMLL2X16mv2+kaVARgQQ1nXt1htw/GTpal79RjTZ
	HJ0gcBnGzcqv8FMJ8DOhnu3uGKZbSkkGqHg+YoSh0QIopEfv3xHb7/HgkSbTeePu+GeBamZUNfn
	7BhH55ebcWfL0yCMsTSnWmvF4zzFUFuxycE2Wx5GWP5CR9cRo3CxCBZq5XSAYC82Tiw==
X-Received: by 2002:a50:f410:: with SMTP id r16mr65403068edm.120.1563875874636;
        Tue, 23 Jul 2019 02:57:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzsc/s1WDzrzoDY6SLjJdvmlnuH39oaQ9OagadZQg8AMSjcrBB061LmbhTIkS0DfOIRU61
X-Received: by 2002:a50:f410:: with SMTP id r16mr65403027edm.120.1563875873931;
        Tue, 23 Jul 2019 02:57:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563875873; cv=none;
        d=google.com; s=arc-20160816;
        b=Nno7drHZyl8uuP/vR3GLOjQNFk7SjyhU6hdYdVVzhr6WdQ3r+prNol80UktHDQP8sy
         b8boT91PklwHNzuB9lwy4WBwSJiU6BBhcTr7HPYIVpkxuDt2juBX3D0MsawzmUDYGyfq
         dpHgRIXLm5tlQOwjm1ucY59Xs+IX6ixG4UGUwzE4e5GicwIPTOEu3K2w3vawg+fSCpl4
         QEXCRqz4PrH9lTyrZuPWJm2V/U8gq/EhaQ5T3Liz/q9k/92+Ero8ol/A3+f/l6d7IH2t
         couwyqMn8MaXr/WW7l06dLzU8s8hnjNN6tBGoUzH/jOwoKvY/h0eJ+mOQZEe1fNdlqzA
         HtQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ChqCczgPPMAdZGIJfk/xI6N8p5HZAKgav0uSZ0NSoxc=;
        b=F3MgT6r9XVZfV2/CVdzHRj8OjN1Iny+56i3ZVfqQtvCWK+1LQslegyoo6Xl1CGYBGF
         6JSJV+yjv6W94oIuOSJoUExbI6APVsnOMTX4M/KsLmRL5A6lJz0mT4auM1rsnf+/XqW2
         HRmS+WESaHjrP8jJL4LbuKWHtNzdpH3vTjzgu3iCMUkLh7Kgb5dxYVdJme3SUPoUP78+
         3EfBw+XunHI+7dxDeIVGA1o4mFEvHYs0K1/YqPki8x5lbeCTAdehRA0DpcXdWCGlroDa
         lln+npLk+v9VLx4lzmk2u4JFCpmBWkphhzO8EubKDvx8Ov2RwW/tuvBJuSzB/kI41CGz
         2v3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id f13si7129905eda.21.2019.07.23.02.57.53
        for <linux-mm@kvack.org>;
        Tue, 23 Jul 2019 02:57:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D39B8337;
	Tue, 23 Jul 2019 02:57:52 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 639E93F71A;
	Tue, 23 Jul 2019 02:57:50 -0700 (PDT)
Date: Tue, 23 Jul 2019 10:57:48 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
	x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v9 19/21] mm: Add generic ptdump
Message-ID: <20190723095747.GB8085@lakrids.cambridge.arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-20-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722154210.42799-20-steven.price@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 04:42:08PM +0100, Steven Price wrote:
> Add a generic version of page table dumping that architectures can
> opt-in to
> 
> Signed-off-by: Steven Price <steven.price@arm.com>

[...]

> +#ifdef CONFIG_KASAN
> +/*
> + * This is an optimization for KASAN=y case. Since all kasan page tables
> + * eventually point to the kasan_early_shadow_page we could call note_page()
> + * right away without walking through lower level page tables. This saves
> + * us dozens of seconds (minutes for 5-level config) while checking for
> + * W+X mapping or reading kernel_page_tables debugfs file.
> + */
> +static inline bool kasan_page_table(struct ptdump_state *st, void *pt,
> +				    unsigned long addr)
> +{
> +	if (__pa(pt) == __pa(kasan_early_shadow_pmd) ||
> +#ifdef CONFIG_X86
> +	    (pgtable_l5_enabled() &&
> +			__pa(pt) == __pa(kasan_early_shadow_p4d)) ||
> +#endif
> +	    __pa(pt) == __pa(kasan_early_shadow_pud)) {
> +		st->note_page(st, addr, 5, pte_val(kasan_early_shadow_pte[0]));
> +		return true;
> +	}
> +	return false;

Having you tried this with CONFIG_DEBUG_VIRTUAL?

The kasan_early_shadow_pmd is a kernel object rather than a linear map
object, so you should use __pa_symbol for that.

It's a bit horrid to have to test multiple levels in one function; can't
we check the relevant level inline in each of the test_p?d funcs?

They're optional anyway, so they only need to be defined for
CONFIG_KASAN.

Thanks,
Mark.

> +}
> +#else
> +static inline bool kasan_page_table(struct ptdump_state *st, void *pt,
> +				    unsigned long addr)
> +{
> +	return false;
> +}
> +#endif
> +
> +static int ptdump_test_p4d(unsigned long addr, unsigned long next,
> +			   p4d_t *p4d, struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +
> +	if (kasan_page_table(st, p4d, addr))
> +		return 1;
> +	return 0;
> +}
> +static int ptdump_test_pud(unsigned long addr, unsigned long next,
> +			   pud_t *pud, struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +
> +	if (kasan_page_table(st, pud, addr))
> +		return 1;
> +	return 0;
> +}
> +
> +static int ptdump_test_pmd(unsigned long addr, unsigned long next,
> +			   pmd_t *pmd, struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +
> +	if (kasan_page_table(st, pmd, addr))
> +		return 1;
> +	return 0;
> +}
> +
> +static int ptdump_hole(unsigned long addr, unsigned long next,
> +		       struct mm_walk *walk)
> +{
> +	struct ptdump_state *st = walk->private;
> +
> +	st->note_page(st, addr, -1, 0);
> +
> +	return 0;
> +}
> +
> +void ptdump_walk_pgd(struct ptdump_state *st, struct mm_struct *mm)
> +{
> +	struct mm_walk walk = {
> +		.mm		= mm,
> +		.pgd_entry	= ptdump_pgd_entry,
> +		.p4d_entry	= ptdump_p4d_entry,
> +		.pud_entry	= ptdump_pud_entry,
> +		.pmd_entry	= ptdump_pmd_entry,
> +		.pte_entry	= ptdump_pte_entry,
> +		.test_p4d	= ptdump_test_p4d,
> +		.test_pud	= ptdump_test_pud,
> +		.test_pmd	= ptdump_test_pmd,
> +		.pte_hole	= ptdump_hole,
> +		.private	= st
> +	};
> +	const struct ptdump_range *range = st->range;
> +
> +	down_read(&mm->mmap_sem);
> +	while (range->start != range->end) {
> +		walk_page_range(range->start, range->end, &walk);
> +		range++;
> +	}
> +	up_read(&mm->mmap_sem);
> +
> +	/* Flush out the last page */
> +	st->note_page(st, 0, 0, 0);
> +}
> -- 
> 2.20.1
> 

