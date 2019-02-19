Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61593C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:56:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14422217D9
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 12:56:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HpNL3RAH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14422217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 930158E0003; Tue, 19 Feb 2019 07:56:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E19D8E0002; Tue, 19 Feb 2019 07:56:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D0338E0003; Tue, 19 Feb 2019 07:56:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3962F8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:56:24 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id a5so12873727pfn.2
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 04:56:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dNnoJF5z3YPMcWSyBEpmYmJYxRPnyE5bqoQcnXKlBxk=;
        b=f/1Pnu8E5WyMFoHTUHo3Lq1Tilbx1Od4DbKngXIkgeXfYqeUyZ31hwpEWq0um/iErz
         Kzwe8GBeD0irxHl8HlP96o3g8gUgYijN4cj8aYpW0cvSsiFg+vHpffuvr/QHC0qTmrtz
         iQLA5WqI4pKBV5wYoeV6qyn2qt2NzVJy+MdVZxHV95KhE0o3oMwpPQX7EVC40TaRJIwW
         PBZckbqcyPm2p61VGlEk0n+egDZxbV+8cgs+B18KAPEbQSWROKO9X7OOzdjKqmwrvA2T
         NnflhG4YWquMto1ID9r1D1iNfTzLQ0PCVE5trHr6DWCZ7ksJ3/EKkdC26PNLo7fIzRS6
         SlWw==
X-Gm-Message-State: AHQUAuYQ5ybxddZDGwOZCVsvJfN+GbPaur+Z9+T+aPRXWXWE/OGPbFLf
	SkeeEo+HWkYnjbsJ8TbanxEPO8SrGx71Ftk0TTBHzZ0gbWNCmHTvgA4TX5bPT+htRKABHdfXUdL
	fTWXzN/qaUn0Qt7Z9GEL4mW5eVfIg6oLmfU/sRo+cZUN2dGYmLXi5vnPNoU+6mYqRxQ==
X-Received: by 2002:a17:902:ab8f:: with SMTP id f15mr30729385plr.218.1550580983815;
        Tue, 19 Feb 2019 04:56:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbsyJxqQ+RPoYNWLMFwmRJs0E+BZEsGS5W2Q7EQuapmQZOfv+ea3mqJ4zn9Hh+0HTHh8jbv
X-Received: by 2002:a17:902:ab8f:: with SMTP id f15mr30729342plr.218.1550580983082;
        Tue, 19 Feb 2019 04:56:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550580983; cv=none;
        d=google.com; s=arc-20160816;
        b=dA8NmqXmmfpxvA2nVBAe8Nx9F9JTv73jXvOLkIMyeVJUhTJPsNCGH99EVISIksfefx
         DlAbGVFyyNfnkYzd5l5t13YVkyiJYcYKNhqp3T4WjyL98PTKsfsc0BEkq0ivPE6ezjrj
         PL79YKOnemRfEtnodP6i9iPIyFQJIP0nkrAWoT3wKxsXBghkIVt8WbKbTt4Ik1j+LE+c
         p/SXbIwq7klGYRvnxuqkk2M9z4loFX5HCkoVkNKpRw+R4IGx7XiRY+YYwVr521KYb8WN
         SUUrz8bHtOt2GQ+k2Gfpn/8lSnlZTIIKktW06YPeW8pLKYm9JLLI8vG2NrJID7tkNU3s
         azEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dNnoJF5z3YPMcWSyBEpmYmJYxRPnyE5bqoQcnXKlBxk=;
        b=najH3BiSznL0DYSN64HG4qraevpPChTvCAYvhb56m39J4UK/NUlkV9U5Kn+RLGBNcr
         dOsIeqOih5iQhvABif2I284/nxIPcDZLlr189W4Je1HCtc5AOJiwWh1mk5MlaWajvWOH
         D0Hf+xRbJhKU+jWnjzMj8TVixFSNwU/rS9j+ebspHYpBYNDBp5mDNEMmMmjmoTBx/zN8
         O9yyU6AKIyFcm1DZ6dSdD4W7teWMSLyJy5YR9i5Ukjd7nKJfR5ISa1lkyHxiu/GjoN+0
         qkX4+cqEvFNj1ehAJ8sW8fvHEqx7jsH19rEGtciqXvRkabrKmoKzVYrZ7ngwCCSLHuTv
         +cZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HpNL3RAH;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s2si13375988pfm.289.2019.02.19.04.56.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 04:56:22 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HpNL3RAH;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=dNnoJF5z3YPMcWSyBEpmYmJYxRPnyE5bqoQcnXKlBxk=; b=HpNL3RAHgekvGBpoVraNsM2Zb
	Mu2RxvHy1PMkUNEQTOAfvHd42wifxahAOU/cLmja0FsxUAOoW9TZrMvAhuEykwqxEEojC02ekMzoG
	qIGKNyeLp7q8XEsrDeXfWm4kibkXUZm8Wimgu532uAVvRafwcM6RBsEf2FZTQwjtRZZkWO6GdPhEA
	ouhtIH4Qe5Zy5LtHrpiT2Cj5z1RSdupe39mc8IYnj+X6aKPyzU7ob738qG6Hkuxyv2wJ48VeEpv/1
	GRJ0PBua69SP1ajzfcv8l+GeKe+xLk8v8//mK7CdoqZcsvCP2fWqARRzom+HI/2zgM0LqWmu1FOoH
	pWhs6vbeQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw4wd-0002QY-Rl; Tue, 19 Feb 2019 12:56:19 +0000
Date: Tue, 19 Feb 2019 04:56:19 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Zi Yan <ziy@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>
Subject: Re: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange
 two lists of pages.
Message-ID: <20190219125619.GA12668@bombadil.infradead.org>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <20190215220856.29749-2-zi.yan@sent.com>
 <20190217112943.GP12668@bombadil.infradead.org>
 <65A1FFA0-531C-4078-9704-3F44819C3C07@nvidia.com>
 <2630a452-8c53-f109-1748-36b98076c86e@suse.cz>
 <53690FCD-B0BA-4619-8DF1-B9D721EE1208@nvidia.com>
 <20190218175224.GT12668@bombadil.infradead.org>
 <C84D2490-B6C6-4C7C-870F-945E31719728@nvidia.com>
 <1ce6ae99-4865-df62-5f20-cb07ebb95327@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1ce6ae99-4865-df62-5f20-cb07ebb95327@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 01:12:07PM +0530, Anshuman Khandual wrote:
> But the location of this temp page matters as well because you would like to
> saturate the inter node interface. It needs to be either of the nodes where
> the source or destination page belongs. Any other node would generate two
> internode copy process which is not what you intend here I guess.

That makes no sense.  It should be allocated on the local node of the CPU
performing the copy.  If the CPU is in node A, the destination is in node B
and the source is in node C, then you're doing 4k worth of reads from node C,
4k worth of reads from node B, 4k worth of writes to node C followed by
4k worth of writes to node B.  Eventually the 4k of dirty cachelines on
node A will be written back from cache to the local memory (... or not,
if that page gets reused for some other purpose first).

If you allocate the page on node B or node C, that's an extra 4k of writes
to be sent across the inter-node link.

