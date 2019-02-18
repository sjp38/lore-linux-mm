Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BB26C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:05:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EEB520C01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:05:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EEB520C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E4EA8E0003; Mon, 18 Feb 2019 12:05:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46E278E0002; Mon, 18 Feb 2019 12:05:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 336538E0003; Mon, 18 Feb 2019 12:05:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C94178E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:05:18 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i22so1622388eds.20
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:05:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zRxzq5NcWzVfKHAtosFBjQ0qO/xhFxoWAoaOoPHqiCY=;
        b=p9XOpJDqkURCqtWPywwBymUGPB6jUppcxX5nnD6OsILjKY22DxH7O/Hpw6BaqbIIt2
         RToXvz6wrAhDGXXG9Pjl8+omF9TCW0w+EIZjcBWLpXYxnIRz3kEnQ6eZ/t+cBqt2aTpR
         LZXE4woZoYRf+n0249b9ASkhcnBiVGPHAzDEgLuTWkox2/nNFkqCFjx0l13uDXBAZtVB
         4j2qmeD8+cruEuiKqEBOFY6wLV2CSzJ0+kf/H8qVZBboqDrEXuWGdYULxE9EbT5JpaJc
         6W1wORsibqme80dLohkzxeAXkHaaPNuxowNrAlpkRaXCU3o2D4cWGKVlMCQzwcIHHR50
         goVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: AHQUAuYnrr45Bccf7A6v8Ste6X2j/DcLywjq7RUMWMxOW7ZM68Osevu4
	jmxW4vAxLgGQ3+UsOTSvks3H+/8FvuX/x9CU8VuYR/dRzCW/o1gLLybVCBvTFwf7g5g0/4s/38h
	IJ1Cu1rOBN6CZoaw5D36yZaV73Ze++dLUyk4pMVlLK+R2v1RFTS6pm+CNGqGxHmjE8g==
X-Received: by 2002:a17:906:4306:: with SMTP id j6mr17378388ejm.174.1550509518389;
        Mon, 18 Feb 2019 09:05:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ1dLcEiENAkKA7EvKIW2ub2F4FvMnNxBmUi0PrIUzCeGJaGionFWfWeMnf6gPBPqWJ7haF
X-Received: by 2002:a17:906:4306:: with SMTP id j6mr17378341ejm.174.1550509517495;
        Mon, 18 Feb 2019 09:05:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550509517; cv=none;
        d=google.com; s=arc-20160816;
        b=L1XZ7Jd7AI2yIlO4/ysU5+0JH0pLaTjmLGUHM3EHD3OEIuFa4B17Rv0TYq6geEN0nV
         vnv7AVyj34zxVbBfXhoO3efWfjiyTjKPH3FmzHIpLybPFEZCx79ig1GR386FjK/jBtac
         9IFDbpzZ0joHSv9uXnnsx2YxC7j131nar/m+QOPNF+9Poab2YlRQsEtY2H0A/pAOU0WT
         QiWmxJ+9jE3BXcQAOy3NiUWAEcW1jt+pH7Y6p4LCKQFGwmfU0LikKXHy8jLtxdUXtzMQ
         A5pFm7QHEY+cJeVlOPafS8a6Z1igOMrE+iQMeTsWC1+KaKKFdjMcm51EdrJ4pUksRGao
         3txg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zRxzq5NcWzVfKHAtosFBjQ0qO/xhFxoWAoaOoPHqiCY=;
        b=ZsdNYiCQHTBYM3esnato5TU3oZ9rW/5bn2+agtGp6MCeIuuCcNbRD/J2gl3HiBKsay
         BfNITFu/NeUJIT6l7ZSQjWIF8z8iUugb4hlC1z47USKkwFG8md/cvc6Wcak06c+yXt2T
         n5Xr4QEbx9zVYlhnf8BG+j+6TSyR4mEhCjqC6q9uaJQDxbixfSfeVUtPT7ydbpda1Gyy
         /JUXrFD8Ug+kC6/Ryljp4/RMlhQT1oRz3XXQxcGB8vD1j682nmRg/ejlZ4YJ/rDRFJFG
         xomLCYkyWKok8vF5Bj5OG9TcoALucE1Vkt+arurZUy03tpKRVDHiS1c3p/vfHGl7x1q9
         h/Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z11si4379566edx.149.2019.02.18.09.05.05
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 09:05:17 -0800 (PST)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 28F431BB0;
	Mon, 18 Feb 2019 09:05:02 -0800 (PST)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2FE863F675;
	Mon, 18 Feb 2019 09:04:54 -0800 (PST)
Date: Mon, 18 Feb 2019 17:04:51 +0000
From: Mark Rutland <mark.rutland@arm.com>
To: Steven Price <steven.price@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
	Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH 01/13] arm64: mm: Add p?d_large() definitions
Message-ID: <20190218170451.GB10145@lakrids.cambridge.arm.com>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-2-steven.price@arm.com>
 <20190218112922.GT32477@hirez.programming.kicks-ass.net>
 <fe36ed1c-b90d-8062-f7a9-e52d940733c4@arm.com>
 <20190218142951.GA10145@lakrids.cambridge.arm.com>
 <20190218150657.GU32494@hirez.programming.kicks-ass.net>
 <eb7e0203-db08-743b-dbed-a7032b352ded@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eb7e0203-db08-743b-dbed-a7032b352ded@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 03:30:38PM +0000, Steven Price wrote:
> On 18/02/2019 15:06, Peter Zijlstra wrote:
> > On Mon, Feb 18, 2019 at 02:29:52PM +0000, Mark Rutland wrote:
> >> I think that Peter means p?d_huge(x) should imply p?d_large(x), e.g.
> >>
> >> #define pmd_large(x) \
> >> 	(pmd_sect(x) || pmd_huge(x) || pmd_trans_huge(x))
> >>
> >> ... which should work regardless of CONFIG_HUGETLB_PAGE.
> > 
> > Yep, that.
> 
> I'm not aware of a situation where pmd_huge(x) is true but pmd_sect(x)
> isn't. Equally for pmd_huge(x) and pmd_trans_huge(x).
> 
> What am I missing?

Having dug for a bit, I think you're right in asserting that pmd_sect()
should cover those.

I had worried that wouldn't cater for contiguous pmd entries, but those
have to be contiguous section entries, so they get picked up.

That said, do we have any special handling for contiguous PTEs? We use
those in kernel mappings regardless of hugetlb support, and I didn't
spot a pte_large() helper.

Thanks,
Mark.

