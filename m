Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D927CC76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 03:43:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A144C21855
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 03:43:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ONSgg6eG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A144C21855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36F8A6B0005; Thu, 18 Jul 2019 23:43:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3209D8E0003; Thu, 18 Jul 2019 23:43:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20EB08E0001; Thu, 18 Jul 2019 23:43:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD27A6B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 23:43:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 6so17908256pfi.6
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 20:43:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=N+BAc5dEs3BdeoYjOo52WEKWHYvzVE7eGNOigH3rcZY=;
        b=iqSwSbyf3sqcs7eTqcUnp6udhG0Ek/B42stCmZitStJN5zLP7ho8n/VEID/P6FvVHA
         3WwTVlnLjDXvRhvJIBseg7bv9rXBa7bExUFlAzjOMaCUtcXmoMLCS3svAIZJ0h9+A36m
         T78bs2ehPfkAW5CY6Nl+/2SP54WZ3mo9g1VWRNenlVgtU+10ZIC6SUB98Eqpi5Eg4fXz
         1O4P4nJGOFzZsujH9psXyrq2eZdVfXZ46m5jVfHMF+VgzcxXWKFPizDSx1sfJMhXWUqQ
         aSjNl7LbBkEHYelwMzWjl2i8WoPBRoRW6WvgFgU1WqqIJUXjdCvSFV3+qYADqAU9vBFm
         2lNQ==
X-Gm-Message-State: APjAAAU+W9oINkg7L0NtXPPnjBhGMRlRRbJxBLqvafN/H8NvdPUlL8OT
	orGnTG+FgEwBf2nANTkVjLGgzq0ghzE+sYocKGt17rQjsSr40AQhCURrN2zS2e66HxupHuYqgsP
	ghyjHLm/i0kAnzCZOlxpBWZNxoOri7sMcnnekB17AYbM7zhzGJSxeDX/ncmTfLwo0JA==
X-Received: by 2002:a17:902:aa5:: with SMTP id 34mr56091195plp.166.1563507802483;
        Thu, 18 Jul 2019 20:43:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1VAllR+zclE46FjQGaQxKoK78nojMGPaD+ZM5J/rttI+jF9Qfzyxf5xhZCOqHtnL/uu8j
X-Received: by 2002:a17:902:aa5:: with SMTP id 34mr56091127plp.166.1563507801538;
        Thu, 18 Jul 2019 20:43:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563507801; cv=none;
        d=google.com; s=arc-20160816;
        b=hS1upL/JiNg/SBcfsCGI0g1vD3pofrvqIKvUN/siHrWtI0A0pzzqbn8mK2uUv3prH+
         DiZjX3XVlDc3xMd1KqvVIyvb8rLU7ppXazccuMO3/K+ePQLewHhPWfp/3fftvFYWfZS5
         hBfNS8ACPhMok1rqxvLMK4VkozKCqsahWdeTKkUhuWyzvbs2EamRtUkCyRA01c3zYccH
         1SAzNLsTZrj+PTyj3tc50AVUf1SaNNuUt1iLfdqpBcp2AZaCYIr5y6zOXSHmM7ime7+a
         1VmCDDsab2g5hPZ0BrINx0eE/bo56GiTzip4tS4iKJps6jBYdERFEyuIOKO/BWeTZfj3
         0Rmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=N+BAc5dEs3BdeoYjOo52WEKWHYvzVE7eGNOigH3rcZY=;
        b=zSYrYRvseyrRh4pDW7Yv5wbIXKGQY8RHFv/4mM5y22Lc3FJGbvoYDkQKLXUv0QNNzP
         4k9X1EQ5NFH95p7jsNmbza2tT0YnAW+vPeR0v6bjU1p5x4NEmig0N2Bw3gx3bYhZyHXE
         FPnZHLpY/0hVIpY9ttSsUg3zP0ADUGogOFTwPuUFOygjAlYuDLTGAObJ6BNec1DykNiH
         5KNaClPvystf8u//2g0OkGJRnVadCwk3PF0pUhCFwEjO1Ak2XuKdNawsGBQy3E9RDJwt
         BdDmiufYF+AUrlj6LoZ/RuLs6XV9Ho2E1vmD2+XktIVuEN2+Z2SiQew49SFNW7B3PaW7
         mqmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ONSgg6eG;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x4si3554489pjn.93.2019.07.18.20.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 20:43:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ONSgg6eG;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (p91006-ipngnfx01marunouchi.tokyo.ocn.ne.jp [153.156.43.6])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C959F2184E;
	Fri, 19 Jul 2019 03:43:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563507801;
	bh=HrhZEcSQN51KrMKglwqRrsI7E3xr0hfIM76XucbZx14=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ONSgg6eG0qjUubfHx/upW/n7ZzF0rISIrx3M1JZezpE4qOCH/Lf0l4vUANH5zTV3j
	 H6KAhSFBU/qvFzAJbfVnIEgME7//1ByAI1I8+SiwNAKmx+FmrLmO8pPulV3xNHJvUy
	 Cezf9XIDjEsLNGSrrF/1dS85E8+n7shWLJfyruHU=
Date: Fri, 19 Jul 2019 12:43:18 +0900
From: Greg KH <gregkh@linuxfoundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Liu Bo <bo.liu@linux.alibaba.com>, stable <stable@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
	Peng Tao <tao.peng@linux.alibaba.com>,
	Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH] mm: fix livelock caused by iterating multi order entry
Message-ID: <20190719034318.GA7886@kroah.com>
References: <1563495160-25647-1-git-send-email-bo.liu@linux.alibaba.com>
 <CAPcyv4jR3vscppooTFBEU=Kp4CNVfthNNz1pV6jxwyg2bmdBjg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jR3vscppooTFBEU=Kp4CNVfthNNz1pV6jxwyg2bmdBjg@mail.gmail.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 07:53:42PM -0700, Dan Williams wrote:
> [ add Sasha for -stable advice ]
> 
> On Thu, Jul 18, 2019 at 5:13 PM Liu Bo <bo.liu@linux.alibaba.com> wrote:
> >
> > The livelock can be triggerred in the following pattern,
> >
> >         while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
> >                                 min(end - index, (pgoff_t)PAGEVEC_SIZE),
> >                                 indices)) {
> >                 ...
> >                 for (i = 0; i < pagevec_count(&pvec); i++) {
> >                         index = indices[i];
> >                         ...
> >                 }
> >                 index++; /* BUG */
> >         }
> >
> > multi order exceptional entry is not specially considered in
> > invalidate_inode_pages2_range() and it ended up with a livelock because
> > both index 0 and index 1 finds the same pmd, but this pmd is binded to
> > index 0, so index is set to 0 again.
> >
> > This introduces a helper to take the pmd entry's length into account when
> > deciding the next index.
> >
> > Note that there're other users of the above pattern which doesn't need to
> > fix,
> >
> > - dax_layout_busy_page
> > It's been fixed in commit d7782145e1ad
> > ("filesystem-dax: Fix dax_layout_busy_page() livelock")
> >
> > - truncate_inode_pages_range
> > This won't loop forever since the exceptional entries are immediately
> > removed from radix tree after the search.
> >
> > Fixes: 642261a ("dax: add struct iomap based DAX PMD support")
> > Cc: <stable@vger.kernel.org> since 4.9 to 4.19
> > Signed-off-by: Liu Bo <bo.liu@linux.alibaba.com>
> > ---
> >
> > The problem is gone after commit f280bf092d48 ("page cache: Convert
> > find_get_entries to XArray"), but since xarray seems too new to backport
> > to 4.19, I made this fix based on radix tree implementation.
> 
> I think in this situation, since mainline does not need this change
> and the bug has been buried under a major refactoring, is to send a
> backport directly against the v4.19 kernel. Include notes about how it
> replaces the fix that was inadvertently contained in f280bf092d48
> ("page cache: Convert find_get_entries to XArray"). Do you have a test
> case that you can include in the changelog?

Yes, I need a _TON_ of documentation, and signed off by from all of the
developers involved in this part of the kernel, before I can take this
not-in-mainline patch.

thanks,

greg k-h

