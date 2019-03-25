Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0A85C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 17:44:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 306A0207DD
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 17:44:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=armlinux.org.uk header.i=@armlinux.org.uk header.b="DyF2Uyqz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 306A0207DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=armlinux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A54496B0003; Mon, 25 Mar 2019 13:44:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DCCC6B0006; Mon, 25 Mar 2019 13:44:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 808FC6B0007; Mon, 25 Mar 2019 13:44:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id F0DEE6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 13:44:14 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id t82so5216929wmg.8
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:44:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent:sender;
        bh=jWEinYgmGbQKUHdBvEzNF5ywyZ1MDga7YL3I2dfZYXA=;
        b=AoE2Ked7/j7nPRpUMQSmxKc71KGPl+O/ex2eY46Ck8mJpAJiSYeDF/6kSsD/hT92x5
         P7MkVy/RogJ4znTw5KAtSF+4eQU3Q4W/qeT6qzRSaS0HaS1r6Z8x/O2Z2RECrHLG2jAm
         DoR8mNDyQc15oY5yRxdpuqK5WUA+8AHNUDO3plC3A1gKZbtwFOTE7cCdVMFjnZwFWSId
         VhOQqzKWizPZgjpIqr4s39msK49V+jSZMjJlmxF+6s0RklZEWhVe5FaYyA9GhBinxuuB
         QNYvdtkxnDbGYtasNz7L5og2GHTa76hGXhTRmkATdOPCnppxzpkR4ocHhJqvWplzwPYV
         K+SA==
X-Gm-Message-State: APjAAAWY1dzd4NleYLIj0GuLFe/Y/tfCtAKsEoRX4wyFmelAiKKiMQqQ
	HOYJadMkFhZM3jj5DvWREgxJA35LP6UJflwx53oYjp2W6H+O8jR1nDLoUyGbnhtanVIRTY9VK41
	LIy3EF3vJkIQSMI9Zh9GNKrP9AY4Z8j19RxbSiByI8Ges+XoKz8A272yWcUyjF2Gbdw==
X-Received: by 2002:adf:e692:: with SMTP id r18mr17787162wrm.231.1553535854362;
        Mon, 25 Mar 2019 10:44:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzug/EOMMm+hA2nXZJCuLA/omfPsDbXtANTl+hUCiBTaBJBh+wmak6LgzuURcuEPSh9DLbk
X-Received: by 2002:adf:e692:: with SMTP id r18mr17787005wrm.231.1553535850944;
        Mon, 25 Mar 2019 10:44:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553535850; cv=none;
        d=google.com; s=arc-20160816;
        b=AV9ywvG+Q+4MVgBCwUijz/8JGmlvwYG7INPYK6OMYMOuq8aeA1EieeuBwnJZNdhwuT
         FHuosw/6VB4XhxE+px9AGn2tttztHn5a7dKhp9IwGVwHg9P6amiV6qM+80wBlV94jyNG
         qzRHYMvFJGgIJnrh3Q9fHp2VIqd1brw8friR6JbxjbVM7OWEklW4dLxdJ6+7xS3sB/O+
         YdFlsDSPWJvC/vV5b9WufjjPPoksDKBE8D3+Y1U32zm5TPEWVSubz0TvokwP6d0S1trk
         HKG+x7T+OkcmDputY5s8UMHvkaW4FvfYSgWSJALSjuyr9g7cm1hNbOt5VqYJJ8z+VOpP
         wyqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date:dkim-signature;
        bh=jWEinYgmGbQKUHdBvEzNF5ywyZ1MDga7YL3I2dfZYXA=;
        b=PPqJDeVaOpPyfTGk/oNiz5P03wziwPq33OdrL7nhqOyOSiH5Ms27EsjQlwonCCM3Wm
         vX/RNx2sNgVYMoMTrVGoHNHmcg9rA08FrG+1FNwmSbi15H/3cfZy9bIzZv6xnNP7hjiR
         H+ODvri5eOIr2rLN8WPpeuQ4OlC/yEG+Fw3mvq/zphWCjKlxRBt1pLNjckG0HPse2Wvp
         e7uLc6Ocs48xbpq7vHfIdBIqHzVuT4RWn2iGWPhY9LKsp5A7pCpwIWd4s1Qyfi0Le2fg
         9DmB8rgHW3aPw4MksES5J00c3iFhnOURmFN/BYZlSiUfxVumxJeMrouoxFuLTIXSGzsv
         aPlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass (test mode) header.i=@armlinux.org.uk header.s=pandora-2019 header.b=DyF2Uyqz;
       spf=pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) smtp.mailfrom="linux+linux-mm=kvack.org@armlinux.org.uk";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=armlinux.org.uk
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id t66si10663356wmb.153.2019.03.25.10.44.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 10:44:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) client-ip=2001:4d48:ad52:3201:214:fdff:fe10:1be6;
Authentication-Results: mx.google.com;
       dkim=pass (test mode) header.i=@armlinux.org.uk header.s=pandora-2019 header.b=DyF2Uyqz;
       spf=pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) smtp.mailfrom="linux+linux-mm=kvack.org@armlinux.org.uk";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=armlinux.org.uk
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=armlinux.org.uk; s=pandora-2019; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=jWEinYgmGbQKUHdBvEzNF5ywyZ1MDga7YL3I2dfZYXA=; b=DyF2UyqzghOGogXnmo4ig625o
	QhH4N/7P1sxjxnFZer1YK+/MDtymXsrKaMDZ8CMXB3Wbly2d+RevXf+utDfh6eTXuBc9rUX39LFC9
	Q21tEopKEeB/H4jlA+aOaiTS0NsjdwuUMWdQ1wQMr1MVAhXcvjWBM+0PCh0dihXvfhy04y7aMwLZK
	+j7Wqoii5QUxZgpPz/xOs9yz0d3pEDehsoy0B0nf5x9amrp8j+3Wrd+qzzIf/V1gEb1bKO9bP56TU
	U/QhNen5OoGmUC16RBJk+UyrW9e5MgkNnDGkDpgoYzXdG7X+hSNKybXSfKWEyWPjMcb1pM1nVD5mE
	mn2zkCEdw==;
Received: from shell.armlinux.org.uk ([2001:4d48:ad52:3201:5054:ff:fe00:4ec]:55212)
	by pandora.armlinux.org.uk with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <linux@armlinux.org.uk>)
	id 1h8Tda-0003xS-Hk; Mon, 25 Mar 2019 17:43:54 +0000
Received: from linux by shell.armlinux.org.uk with local (Exim 4.89)
	(envelope-from <linux@shell.armlinux.org.uk>)
	id 1h8TdW-0003Ho-Js; Mon, 25 Mar 2019 17:43:50 +0000
Date: Mon, 25 Mar 2019 17:43:50 +0000
From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: Peter Chen <hzpeterchen@gmail.com>, peter.chen@nxp.com,
	fugang.duan@nxp.com, linux-usb@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	Marek Szyprowski <m.szyprowski@samsung.com>
Subject: Re: Why CMA allocater fails if there is a signal pending?
Message-ID: <20190325174350.jvgbjyywbyrlknut@shell.armlinux.org.uk>
References: <CAL411-pwHq4Df-FsBu=Vzd4CR6Pzee2yR579hHeZuh8T7fBNJA@mail.gmail.com>
 <20190325102633.v6hkvda6q7462wza@shell.armlinux.org.uk>
 <7905eeb4-51ce-956b-31ed-33313bcfe7eb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7905eeb4-51ce-956b-31ed-33313bcfe7eb@gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 09:44:17AM -0700, Florian Fainelli wrote:
> On 3/25/19 3:26 AM, Russell King - ARM Linux admin wrote:
> > On Mon, Mar 25, 2019 at 04:37:09PM +0800, Peter Chen wrote:
> >> Hi Michal & Marek,
> >>
> >> I meet an issue that the DMA (CMA used) allocation failed if there is a user
> >> signal, Eg Ctrl+C, it causes the USB xHCI stack fails to resume due to
> >> dma_alloc_coherent
> >> failed. It can be easy to reproduce if the user press Ctrl+C at
> >> suspend/resume test.
> > 
> > It has been possible in the past for cma_alloc() to take seconds or
> > longer to allocate, depending on the size of the CMA area and the
> > number of pinned GFP_MOVABLE pages within the CMA area.  Whether that
> > is true of today's CMA or not, I don't know.
> > 
> > It's probably there to allow such a situation to be recoverable, but
> > is not a good idea if we're expecting dma_alloc_*() not to fail in
> > those scenarios.
> > 
> 
> This is a known issue that was discussed here before:
> 
> http://lists.infradead.org/pipermail/linux-arm-kernel/2014-November/299265.html
> 
> one issue is that the process that is responsible for putting the system
> asleep and is being resumed (which can be as simple as your shell doing
> an 'echo "standby" > /sys/power/state' can be killed, and that
> propagates throughout dpm_resume(). It is debatable whether the signal
> should be ignored or not, probably not.
> 
> You can work around this by wrapping your echo to /sys/power/state with
> a shell script that trap the signal and say, does an exit 1. AFAIR there
> are many places where a dma_alloc_* allocation can fail, and not all
> drivers are designed to recover correctly.

The case I was referring to is during normal system operation, when
pages have been allocated with GFP_MOVABLE but are pinned.  Below is
something I wrote in June 2015 when I encountered the issue, after
diagnosing what was going on and finding how inefficient CMA was at
the time.  Some of this may no longer be relevant, but it shows why
having pinned GFP_MOVABLE pages are bad for CMA:


Some of the quotes in this are long; please search for "--- end quote n ---"
to skip over them, where 'n' is the quote number.

There have been various postings about various issues with the CMA
allocator, and its performance.  One of the recent posts is on LWN:
https://lwn.net/Articles/636234/

However, this fails to take account of some basic code analysis.

What's the performance problem?  The problem is that cma_alloc() can
take a long time to allocate or fail to allocate a block of memory.
As an example, trying to allocate a 720p YUYV frame (around 1800kB,
or 450 pages) can take over a second.  This can happen with a CMA
area of 256MB of which only 10% is in use.

Some analysis of the code behaviour reveals some causes of this.
Let's take an example of what happens with a 1280x736 YUYV image,
which requires 460 pages - this is with some useful debug in
cma_alloc():

			--- start quote 1 ---
cma: cma_alloc(cma c07b1ea8, count 460, align 4)
cma: cma_alloc(mask 0x0000000f offset 0 maxno 65536 count 460)
cma: cma_alloc: bitmap_no = 5792 (pfn 0x2f2a0)
cma: cma_alloc(): memory range at pfn 0x2f2a0 is busy, retrying
cma: cma_alloc: bitmap_no = 5808 (pfn 0x2f2b0)
cma: cma_alloc(): memory range at pfn 0x2f2b0 is busy, retrying
cma: cma_alloc: bitmap_no = 5824 (pfn 0x2f2c0)
cma: cma_alloc(): memory range at pfn 0x2f2c0 is busy, retrying
cma: cma_alloc: bitmap_no = 5840 (pfn 0x2f2d0)
cma: cma_alloc(): memory range at pfn 0x2f2d0 is busy, retrying
cma: cma_alloc: bitmap_no = 5856 (pfn 0x2f2e0)
cma: cma_alloc(): memory range at pfn 0x2f2e0 is busy, retrying
cma: cma_alloc: bitmap_no = 5872 (pfn 0x2f2f0)
cma: cma_alloc(): memory range at pfn 0x2f2f0 is busy, retrying
cma: cma_alloc: bitmap_no = 5888 (pfn 0x2f300)
cma: cma_alloc(): returned e6e1f000 (pfn 0x2f300)
			--- end quote 1 ---

This isn't an extreme example - such a case would be where we had
a block of allocated CMA at the start of the 256MB region, and we
iterated 16 pages at a time over the entire CMA region before
failing.

This is clearly very wasteful, but it gets worse when we look inside
alloc_contig_range(), and it's called functions:

			--- start quote 2 ---
cma: cma_alloc(cma c07b1ea8, count 460, align 4)
cma: cma_alloc(mask 0x0000000f offset 0 maxno 65536 count 460)
cma: cma_alloc: bitmap_no = 5792 (pfn 0x2f2a0)
__alloc_contig_migrate_range: pfn 0x0002f2a0 end 0x0002f46c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f44e
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 6
__alloc_contig_migrate_range: pfn 0x0002f44e end 0x0002f46c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 6
__alloc_contig_migrate_range: pfn 0x0002f44e end 0x0002f46c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 6
__alloc_contig_migrate_range: pfn 0x0002f44e end 0x0002f46c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 6
__alloc_contig_migrate_range: pfn 0x0002f44e end 0x0002f46c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 6
__alloc_contig_migrate_range: pfn 0x0002f44e end 0x0002f46c, tries 4
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f2a0 is busy, retrying
cma: cma_alloc: bitmap_no = 5808 (pfn 0x2f2b0)
__alloc_contig_migrate_range: pfn 0x0002f2b0 end 0x0002f47c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f468
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f47c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f47c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f47c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f47c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f47c, tries 4
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f2b0 is busy, retrying
cma: cma_alloc: bitmap_no = 5824 (pfn 0x2f2c0)
__alloc_contig_migrate_range: pfn 0x0002f2c0 end 0x0002f48c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f468
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f48c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f48c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f48c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f48c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f48c, tries 4
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f2c0 is busy, retrying
cma: cma_alloc: bitmap_no = 5840 (pfn 0x2f2d0)
__alloc_contig_migrate_range: pfn 0x0002f2d0 end 0x0002f49c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f468
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f49c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f49c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f49c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f49c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f49c, tries 4
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f2d0 is busy, retrying
cma: cma_alloc: bitmap_no = 5856 (pfn 0x2f2e0)
__alloc_contig_migrate_range: pfn 0x0002f2e0 end 0x0002f4ac, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f468
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4ac, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4ac, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4ac, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4ac, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4ac, tries 4
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f2e0 is busy, retrying
cma: cma_alloc: bitmap_no = 5872 (pfn 0x2f2f0)
__alloc_contig_migrate_range: pfn 0x0002f2f0 end 0x0002f4bc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f468
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4bc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4bc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4bc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4bc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4bc, tries 4
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f2f0 is busy, retrying
cma: cma_alloc: bitmap_no = 5888 (pfn 0x2f300)
__alloc_contig_migrate_range: pfn 0x0002f300 end 0x0002f4cc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f468
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4cc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4cc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4cc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4cc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 0
__alloc_contig_migrate_range: pfn 0x0002f468 end 0x0002f4cc, tries 4
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f4cc
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 9
__alloc_contig_migrate_range: migrate_pages ret 0
cma: cma_alloc(): returned e6e1f000 (pfn 0x2f300)
			--- end quote 2 ---

What's going on here is that isolate_migratepages_range() stops working
after it hits 32 pages to be migrated, and it returns the end of the
region it's scanned before it hit these 32 pages.

However, what we see is that for allocations starting at bitmap position
5808 up to 5888, we seem to be hitting the same 32 pages which are
preventing the allocation.

So, the obvious question is this: why are we stepping up only 16 pages
at a time - it would surely be more efficient if we knew where to start
the next attempt.

The other interesting behaviour here is that we see
__alloc_contig_migrate_range() looping five times before deciding
failure, except for the last attempt where it seems we suddenly are able
to migrate these same 32 pages away on the very last attempt.

So, let's look at the extreme case (although it's not that extreme, I've
seen it happen multiple times during local testing), where we have 230MB
of 256MB of CMA used, and random pages pinned through the rest of the
zone preventing these 460 pages being allocated.  It'll take cma_alloc()
14720 iterations to walk through the entire region, calling
alloc_contig_range() on each.  Each of those ends up calling
reclaim_clean_pages_from_list() and migrate_pages() five times.  So
that's a total of 73600 calls to each of those functions... is it no
wonder why allocations can take a long time?

What we need is some way for cma_alloc() to know where would be a good
place to re-start scanning from, rather than merely incrementing by the
alignment size.

__alloc_contig_migrate_range() has the ability to provide some input
on this.  Let's take a block of pages, with the pages needing to be
migrated marked as 'U'.  Arbitary number of pages along the length
of the bar.

start                                                        end
  v                                                           v
  +-----------------------------------------------------------+
  |         U            U          U U           U           |
  +-----------------------------------------------------------+
     ^a  ^b  ^c           ^d            ^e         ^f

Currently, the way cma_alloc() behaves, it picks the next starting
point 'a', which could be no better than the current starting point.
Same with 'b'.  What would be better would be to pick 'c' as a
starting point, in case the problem page is the first page which
failed to migrate, in the hope that the remaining will do so.

However, what makes 'c' better than 'd' to 'f'?  That's a good question,
one which I have no answer for without digging more into the Linux MM
subsystem.  I'm sure that there are experts on the Linux MM subsystem
that could provide an answer.

What is obvious though is that 'c' would be better than trying 'a' and
then 'b' before then trying 'c'.

Here's another run which shows the problem - I've left the list of
pages-to-be-migrated in, because it's important to illustrate what's
happening:

			--- start quote 3 ---
cma: cma_alloc(cma c07b1ea8, count 460, align 4)
cma: cma_alloc(mask 0x0000000f offset 0 maxno 65536 count 460)
cma: cma_alloc: bitmap_no = 7136 (pfn 0x2f7e0)
__alloc_contig_migrate_range: pfn 0x0002f7e0 end 0x0002f9ac, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f8d9
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 21
__alloc_contig_migrate_range: pfn 0x0002f8d9 end 0x0002f9ac, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 21
__alloc_contig_migrate_range: pfn 0x0002f8d9 end 0x0002f9ac, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 21
__alloc_contig_migrate_range: pfn 0x0002f8d9 end 0x0002f9ac, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 21
__alloc_contig_migrate_range: pfn 0x0002f8d9 end 0x0002f9ac, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 21
__alloc_contig_migrate_range: pfn 0x0002f8d9 end 0x0002f9ac, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f898
__alloc_contig_migrate_range:  migrate page pfn 0x2f890
__alloc_contig_migrate_range:  migrate page pfn 0x2f888
__alloc_contig_migrate_range:  migrate page pfn 0x2f878
__alloc_contig_migrate_range:  migrate page pfn 0x2f868
__alloc_contig_migrate_range:  migrate page pfn 0x2f858
__alloc_contig_migrate_range:  migrate page pfn 0x2f850
__alloc_contig_migrate_range:  migrate page pfn 0x2f848
__alloc_contig_migrate_range:  migrate page pfn 0x2f838
__alloc_contig_migrate_range:  migrate page pfn 0x2f830
__alloc_contig_migrate_range:  migrate page pfn 0x2f828
__alloc_contig_migrate_range:  migrate page pfn 0x2f818
__alloc_contig_migrate_range:  migrate page pfn 0x2f810
__alloc_contig_migrate_range:  migrate page pfn 0x2f800
__alloc_contig_migrate_range:  migrate page pfn 0x2f7e0
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f7e0 is busy, retrying
cma: cma_alloc: bitmap_no = 7152 (pfn 0x2f7f0)
__alloc_contig_migrate_range: pfn 0x0002f7f0 end 0x0002f9bc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f939
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 27
__alloc_contig_migrate_range: pfn 0x0002f939 end 0x0002f9bc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 27
__alloc_contig_migrate_range: pfn 0x0002f939 end 0x0002f9bc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 27
__alloc_contig_migrate_range: pfn 0x0002f939 end 0x0002f9bc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 27
__alloc_contig_migrate_range: pfn 0x0002f939 end 0x0002f9bc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 27
__alloc_contig_migrate_range: pfn 0x0002f939 end 0x0002f9bc, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f898
__alloc_contig_migrate_range:  migrate page pfn 0x2f890
__alloc_contig_migrate_range:  migrate page pfn 0x2f888
__alloc_contig_migrate_range:  migrate page pfn 0x2f878
__alloc_contig_migrate_range:  migrate page pfn 0x2f868
__alloc_contig_migrate_range:  migrate page pfn 0x2f858
__alloc_contig_migrate_range:  migrate page pfn 0x2f850
__alloc_contig_migrate_range:  migrate page pfn 0x2f848
__alloc_contig_migrate_range:  migrate page pfn 0x2f838
__alloc_contig_migrate_range:  migrate page pfn 0x2f830
__alloc_contig_migrate_range:  migrate page pfn 0x2f828
__alloc_contig_migrate_range:  migrate page pfn 0x2f818
__alloc_contig_migrate_range:  migrate page pfn 0x2f810
__alloc_contig_migrate_range:  migrate page pfn 0x2f800
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f7f0 is busy, retrying
cma: cma_alloc: bitmap_no = 7168 (pfn 0x2f800)
__alloc_contig_migrate_range: pfn 0x0002f800 end 0x0002f9cc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f961
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002f961 end 0x0002f9cc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002f961 end 0x0002f9cc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002f961 end 0x0002f9cc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002f961 end 0x0002f9cc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002f961 end 0x0002f9cc, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f898
__alloc_contig_migrate_range:  migrate page pfn 0x2f890
__alloc_contig_migrate_range:  migrate page pfn 0x2f888
__alloc_contig_migrate_range:  migrate page pfn 0x2f878
__alloc_contig_migrate_range:  migrate page pfn 0x2f868
__alloc_contig_migrate_range:  migrate page pfn 0x2f858
__alloc_contig_migrate_range:  migrate page pfn 0x2f850
__alloc_contig_migrate_range:  migrate page pfn 0x2f848
__alloc_contig_migrate_range:  migrate page pfn 0x2f838
__alloc_contig_migrate_range:  migrate page pfn 0x2f830
__alloc_contig_migrate_range:  migrate page pfn 0x2f828
__alloc_contig_migrate_range:  migrate page pfn 0x2f818
__alloc_contig_migrate_range:  migrate page pfn 0x2f810
__alloc_contig_migrate_range:  migrate page pfn 0x2f800
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f800 is busy, retrying
cma: cma_alloc: bitmap_no = 7184 (pfn 0x2f810)
__alloc_contig_migrate_range: pfn 0x0002f810 end 0x0002f9dc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f979
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f979 end 0x0002f9dc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f979 end 0x0002f9dc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f979 end 0x0002f9dc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f979 end 0x0002f9dc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f979 end 0x0002f9dc, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f898
__alloc_contig_migrate_range:  migrate page pfn 0x2f890
__alloc_contig_migrate_range:  migrate page pfn 0x2f888
__alloc_contig_migrate_range:  migrate page pfn 0x2f878
__alloc_contig_migrate_range:  migrate page pfn 0x2f868
__alloc_contig_migrate_range:  migrate page pfn 0x2f858
__alloc_contig_migrate_range:  migrate page pfn 0x2f850
__alloc_contig_migrate_range:  migrate page pfn 0x2f848
__alloc_contig_migrate_range:  migrate page pfn 0x2f838
__alloc_contig_migrate_range:  migrate page pfn 0x2f830
__alloc_contig_migrate_range:  migrate page pfn 0x2f828
__alloc_contig_migrate_range:  migrate page pfn 0x2f818
__alloc_contig_migrate_range:  migrate page pfn 0x2f810
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f810 is busy, retrying
cma: cma_alloc: bitmap_no = 7200 (pfn 0x2f820)
__alloc_contig_migrate_range: pfn 0x0002f820 end 0x0002f9ec, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f991
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f991 end 0x0002f9ec, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f991 end 0x0002f9ec, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f991 end 0x0002f9ec, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f991 end 0x0002f9ec, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f991 end 0x0002f9ec, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f898
__alloc_contig_migrate_range:  migrate page pfn 0x2f890
__alloc_contig_migrate_range:  migrate page pfn 0x2f888
__alloc_contig_migrate_range:  migrate page pfn 0x2f878
__alloc_contig_migrate_range:  migrate page pfn 0x2f868
__alloc_contig_migrate_range:  migrate page pfn 0x2f858
__alloc_contig_migrate_range:  migrate page pfn 0x2f850
__alloc_contig_migrate_range:  migrate page pfn 0x2f848
__alloc_contig_migrate_range:  migrate page pfn 0x2f838
__alloc_contig_migrate_range:  migrate page pfn 0x2f830
__alloc_contig_migrate_range:  migrate page pfn 0x2f828
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f820 is busy, retrying
cma: cma_alloc: bitmap_no = 7216 (pfn 0x2f830)
__alloc_contig_migrate_range: pfn 0x0002f830 end 0x0002f9fc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f9a1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9a1 end 0x0002f9fc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9a1 end 0x0002f9fc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9a1 end 0x0002f9fc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9a1 end 0x0002f9fc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9a1 end 0x0002f9fc, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f898
__alloc_contig_migrate_range:  migrate page pfn 0x2f890
__alloc_contig_migrate_range:  migrate page pfn 0x2f888
__alloc_contig_migrate_range:  migrate page pfn 0x2f878
__alloc_contig_migrate_range:  migrate page pfn 0x2f868
__alloc_contig_migrate_range:  migrate page pfn 0x2f858
__alloc_contig_migrate_range:  migrate page pfn 0x2f850
__alloc_contig_migrate_range:  migrate page pfn 0x2f848
__alloc_contig_migrate_range:  migrate page pfn 0x2f838
__alloc_contig_migrate_range:  migrate page pfn 0x2f830
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f830 is busy, retrying
cma: cma_alloc: bitmap_no = 7232 (pfn 0x2f840)
__alloc_contig_migrate_range: pfn 0x0002f840 end 0x0002fa0c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f9b9
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f9b9 end 0x0002fa0c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f9b9 end 0x0002fa0c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f9b9 end 0x0002fa0c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f9b9 end 0x0002fa0c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 32
__alloc_contig_migrate_range: pfn 0x0002f9b9 end 0x0002fa0c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f898
__alloc_contig_migrate_range:  migrate page pfn 0x2f890
__alloc_contig_migrate_range:  migrate page pfn 0x2f888
__alloc_contig_migrate_range:  migrate page pfn 0x2f878
__alloc_contig_migrate_range:  migrate page pfn 0x2f868
__alloc_contig_migrate_range:  migrate page pfn 0x2f858
__alloc_contig_migrate_range:  migrate page pfn 0x2f850
__alloc_contig_migrate_range:  migrate page pfn 0x2f848
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f840 is busy, retrying
cma: cma_alloc: bitmap_no = 7248 (pfn 0x2f850)
__alloc_contig_migrate_range: pfn 0x0002f850 end 0x0002fa1c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f9c1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9c1 end 0x0002fa1c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9c1 end 0x0002fa1c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9c1 end 0x0002fa1c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9c1 end 0x0002fa1c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9c1 end 0x0002fa1c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f898
__alloc_contig_migrate_range:  migrate page pfn 0x2f890
__alloc_contig_migrate_range:  migrate page pfn 0x2f888
__alloc_contig_migrate_range:  migrate page pfn 0x2f878
__alloc_contig_migrate_range:  migrate page pfn 0x2f868
__alloc_contig_migrate_range:  migrate page pfn 0x2f858
__alloc_contig_migrate_range:  migrate page pfn 0x2f850
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f850 is busy, retrying
cma: cma_alloc: bitmap_no = 7264 (pfn 0x2f860)
__alloc_contig_migrate_range: pfn 0x0002f860 end 0x0002fa2c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f9d9
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9d9 end 0x0002fa2c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9d9 end 0x0002fa2c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9d9 end 0x0002fa2c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9d9 end 0x0002fa2c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 31
__alloc_contig_migrate_range: pfn 0x0002f9d9 end 0x0002fa2c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f898
__alloc_contig_migrate_range:  migrate page pfn 0x2f890
__alloc_contig_migrate_range:  migrate page pfn 0x2f888
__alloc_contig_migrate_range:  migrate page pfn 0x2f878
__alloc_contig_migrate_range:  migrate page pfn 0x2f868
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f860 is busy, retrying
cma: cma_alloc: bitmap_no = 7280 (pfn 0x2f870)
__alloc_contig_migrate_range: pfn 0x0002f870 end 0x0002fa3c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002f9e9
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002f9e9 end 0x0002fa3c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 30
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002f9e9 end 0x0002fa3c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 30
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002f9e9 end 0x0002fa3c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 30
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002f9e9 end 0x0002fa3c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 30
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002f9e9 end 0x0002fa3c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f898
__alloc_contig_migrate_range:  migrate page pfn 0x2f890
__alloc_contig_migrate_range:  migrate page pfn 0x2f888
__alloc_contig_migrate_range:  migrate page pfn 0x2f878
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f870 is busy, retrying
cma: cma_alloc: bitmap_no = 7296 (pfn 0x2f880)
__alloc_contig_migrate_range: pfn 0x0002f880 end 0x0002fa4c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fa01
__alloc_contig_migrate_range: nr_reclaimed 1, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002fa01 end 0x0002fa4c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 31
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002fa01 end 0x0002fa4c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 31
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002fa01 end 0x0002fa4c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 31
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002fa01 end 0x0002fa4c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 31
__alloc_contig_migrate_range: migrate_pages ret 30
__alloc_contig_migrate_range: pfn 0x0002fa01 end 0x0002fa4c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f898
__alloc_contig_migrate_range:  migrate page pfn 0x2f890
__alloc_contig_migrate_range:  migrate page pfn 0x2f888
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f880 is busy, retrying
cma: cma_alloc: bitmap_no = 7312 (pfn 0x2f890)
__alloc_contig_migrate_range: pfn 0x0002f890 end 0x0002fa5c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fa19
__alloc_contig_migrate_range: nr_reclaimed 3, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 29
__alloc_contig_migrate_range: pfn 0x0002fa19 end 0x0002fa5c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 29
__alloc_contig_migrate_range: migrate_pages ret 29
__alloc_contig_migrate_range: pfn 0x0002fa19 end 0x0002fa5c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 29
__alloc_contig_migrate_range: migrate_pages ret 29
__alloc_contig_migrate_range: pfn 0x0002fa19 end 0x0002fa5c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 29
__alloc_contig_migrate_range: migrate_pages ret 29
__alloc_contig_migrate_range: pfn 0x0002fa19 end 0x0002fa5c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 29
__alloc_contig_migrate_range: migrate_pages ret 29
__alloc_contig_migrate_range: pfn 0x0002fa19 end 0x0002fa5c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f898
__alloc_contig_migrate_range:  migrate page pfn 0x2f890
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f890 is busy, retrying
cma: cma_alloc: bitmap_no = 7328 (pfn 0x2f8a0)
__alloc_contig_migrate_range: pfn 0x0002f8a0 end 0x0002fa6c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fa41
__alloc_contig_migrate_range: nr_reclaimed 3, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 27
__alloc_contig_migrate_range: pfn 0x0002fa41 end 0x0002fa6c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 29
__alloc_contig_migrate_range: migrate_pages ret 27
__alloc_contig_migrate_range: pfn 0x0002fa41 end 0x0002fa6c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 29
__alloc_contig_migrate_range: migrate_pages ret 27
__alloc_contig_migrate_range: pfn 0x0002fa41 end 0x0002fa6c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 29
__alloc_contig_migrate_range: migrate_pages ret 27
__alloc_contig_migrate_range: pfn 0x0002fa41 end 0x0002fa6c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 29
__alloc_contig_migrate_range: migrate_pages ret 27
__alloc_contig_migrate_range: pfn 0x0002fa41 end 0x0002fa6c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8a8
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f8a0 is busy, retrying
cma: cma_alloc: bitmap_no = 7344 (pfn 0x2f8b0)
__alloc_contig_migrate_range: pfn 0x0002f8b0 end 0x0002fa7c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fa71
__alloc_contig_migrate_range: nr_reclaimed 5, nr_migratepages 32
__alloc_contig_migrate_range: migrate_pages ret 26
__alloc_contig_migrate_range: pfn 0x0002fa71 end 0x0002fa7c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 27
__alloc_contig_migrate_range: migrate_pages ret 26
__alloc_contig_migrate_range: pfn 0x0002fa71 end 0x0002fa7c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 27
__alloc_contig_migrate_range: migrate_pages ret 26
__alloc_contig_migrate_range: pfn 0x0002fa71 end 0x0002fa7c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 27
__alloc_contig_migrate_range: migrate_pages ret 26
__alloc_contig_migrate_range: pfn 0x0002fa71 end 0x0002fa7c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 27
__alloc_contig_migrate_range: migrate_pages ret 26
__alloc_contig_migrate_range: pfn 0x0002fa71 end 0x0002fa7c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8b0
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f8b0 is busy, retrying
cma: cma_alloc: bitmap_no = 7360 (pfn 0x2f8c0)
__alloc_contig_migrate_range: pfn 0x0002f8c0 end 0x0002fa8c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fa8c
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 27
__alloc_contig_migrate_range: migrate_pages ret 24
__alloc_contig_migrate_range: pfn 0x0002fa8c end 0x0002fa8c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 25
__alloc_contig_migrate_range: migrate_pages ret 24
__alloc_contig_migrate_range: pfn 0x0002fa8c end 0x0002fa8c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 25
__alloc_contig_migrate_range: migrate_pages ret 24
__alloc_contig_migrate_range: pfn 0x0002fa8c end 0x0002fa8c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 25
__alloc_contig_migrate_range: migrate_pages ret 24
__alloc_contig_migrate_range: pfn 0x0002fa8c end 0x0002fa8c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 25
__alloc_contig_migrate_range: migrate_pages ret 24
__alloc_contig_migrate_range: pfn 0x0002fa8c end 0x0002fa8c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
__alloc_contig_migrate_range:  migrate page pfn 0x2f8c8
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f8c0 is busy, retrying
cma: cma_alloc: bitmap_no = 7376 (pfn 0x2f8d0)
__alloc_contig_migrate_range: pfn 0x0002f8d0 end 0x0002fa9c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fa9c
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 25
__alloc_contig_migrate_range: migrate_pages ret 23
__alloc_contig_migrate_range: pfn 0x0002fa9c end 0x0002fa9c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 23
__alloc_contig_migrate_range: migrate_pages ret 23
__alloc_contig_migrate_range: pfn 0x0002fa9c end 0x0002fa9c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 23
__alloc_contig_migrate_range: migrate_pages ret 23
__alloc_contig_migrate_range: pfn 0x0002fa9c end 0x0002fa9c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 23
__alloc_contig_migrate_range: migrate_pages ret 23
__alloc_contig_migrate_range: pfn 0x0002fa9c end 0x0002fa9c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 23
__alloc_contig_migrate_range: migrate_pages ret 23
__alloc_contig_migrate_range: pfn 0x0002fa9c end 0x0002fa9c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8d0
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f8d0 is busy, retrying
cma: cma_alloc: bitmap_no = 7392 (pfn 0x2f8e0)
__alloc_contig_migrate_range: pfn 0x0002f8e0 end 0x0002faac, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002faac
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 23
__alloc_contig_migrate_range: migrate_pages ret 21
__alloc_contig_migrate_range: pfn 0x0002faac end 0x0002faac, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 21
__alloc_contig_migrate_range: migrate_pages ret 21
__alloc_contig_migrate_range: pfn 0x0002faac end 0x0002faac, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 21
__alloc_contig_migrate_range: migrate_pages ret 21
__alloc_contig_migrate_range: pfn 0x0002faac end 0x0002faac, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 21
__alloc_contig_migrate_range: migrate_pages ret 21
__alloc_contig_migrate_range: pfn 0x0002faac end 0x0002faac, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 21
__alloc_contig_migrate_range: migrate_pages ret 21
__alloc_contig_migrate_range: pfn 0x0002faac end 0x0002faac, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
__alloc_contig_migrate_range:  migrate page pfn 0x2f8e8
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f8e0 is busy, retrying
cma: cma_alloc: bitmap_no = 7408 (pfn 0x2f8f0)
__alloc_contig_migrate_range: pfn 0x0002f8f0 end 0x0002fabc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fabc
__alloc_contig_migrate_range: nr_reclaimed 1, nr_migratepages 22
__alloc_contig_migrate_range: migrate_pages ret 20
__alloc_contig_migrate_range: pfn 0x0002fabc end 0x0002fabc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 21
__alloc_contig_migrate_range: migrate_pages ret 20
__alloc_contig_migrate_range: pfn 0x0002fabc end 0x0002fabc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 21
__alloc_contig_migrate_range: migrate_pages ret 20
__alloc_contig_migrate_range: pfn 0x0002fabc end 0x0002fabc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 21
__alloc_contig_migrate_range: migrate_pages ret 20
__alloc_contig_migrate_range: pfn 0x0002fabc end 0x0002fabc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 21
__alloc_contig_migrate_range: migrate_pages ret 20
__alloc_contig_migrate_range: pfn 0x0002fabc end 0x0002fabc, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
__alloc_contig_migrate_range:  migrate page pfn 0x2f8f8
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f8f0 is busy, retrying
cma: cma_alloc: bitmap_no = 7424 (pfn 0x2f900)
__alloc_contig_migrate_range: pfn 0x0002f900 end 0x0002facc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002facc
__alloc_contig_migrate_range: nr_reclaimed 1, nr_migratepages 21
__alloc_contig_migrate_range: migrate_pages ret 19
__alloc_contig_migrate_range: pfn 0x0002facc end 0x0002facc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 20
__alloc_contig_migrate_range: migrate_pages ret 19
__alloc_contig_migrate_range: pfn 0x0002facc end 0x0002facc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 20
__alloc_contig_migrate_range: migrate_pages ret 19
__alloc_contig_migrate_range: pfn 0x0002facc end 0x0002facc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 20
__alloc_contig_migrate_range: migrate_pages ret 19
__alloc_contig_migrate_range: pfn 0x0002facc end 0x0002facc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 20
__alloc_contig_migrate_range: migrate_pages ret 19
__alloc_contig_migrate_range: pfn 0x0002facc end 0x0002facc, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
__alloc_contig_migrate_range:  migrate page pfn 0x2f908
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f900 is busy, retrying
cma: cma_alloc: bitmap_no = 7440 (pfn 0x2f910)
__alloc_contig_migrate_range: pfn 0x0002f910 end 0x0002fadc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fadc
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 20
__alloc_contig_migrate_range: migrate_pages ret 18
__alloc_contig_migrate_range: pfn 0x0002fadc end 0x0002fadc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 18
__alloc_contig_migrate_range: migrate_pages ret 18
__alloc_contig_migrate_range: pfn 0x0002fadc end 0x0002fadc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 18
__alloc_contig_migrate_range: migrate_pages ret 18
__alloc_contig_migrate_range: pfn 0x0002fadc end 0x0002fadc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 18
__alloc_contig_migrate_range: migrate_pages ret 18
__alloc_contig_migrate_range: pfn 0x0002fadc end 0x0002fadc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 18
__alloc_contig_migrate_range: migrate_pages ret 18
__alloc_contig_migrate_range: pfn 0x0002fadc end 0x0002fadc, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
__alloc_contig_migrate_range:  migrate page pfn 0x2f918
__alloc_contig_migrate_range:  migrate page pfn 0x2f910
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f910 is busy, retrying
cma: cma_alloc: bitmap_no = 7456 (pfn 0x2f920)
__alloc_contig_migrate_range: pfn 0x0002f920 end 0x0002faec, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002faec
__alloc_contig_migrate_range: nr_reclaimed 1, nr_migratepages 18
__alloc_contig_migrate_range: migrate_pages ret 16
__alloc_contig_migrate_range: pfn 0x0002faec end 0x0002faec, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 17
__alloc_contig_migrate_range: migrate_pages ret 16
__alloc_contig_migrate_range: pfn 0x0002faec end 0x0002faec, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 17
__alloc_contig_migrate_range: migrate_pages ret 16
__alloc_contig_migrate_range: pfn 0x0002faec end 0x0002faec, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 17
__alloc_contig_migrate_range: migrate_pages ret 16
__alloc_contig_migrate_range: pfn 0x0002faec end 0x0002faec, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 17
__alloc_contig_migrate_range: migrate_pages ret 16
__alloc_contig_migrate_range: pfn 0x0002faec end 0x0002faec, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
__alloc_contig_migrate_range:  migrate page pfn 0x2f928
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f920 is busy, retrying
cma: cma_alloc: bitmap_no = 7472 (pfn 0x2f930)
__alloc_contig_migrate_range: pfn 0x0002f930 end 0x0002fafc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fafc
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 17
__alloc_contig_migrate_range: migrate_pages ret 15
__alloc_contig_migrate_range: pfn 0x0002fafc end 0x0002fafc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 15
__alloc_contig_migrate_range: migrate_pages ret 15
__alloc_contig_migrate_range: pfn 0x0002fafc end 0x0002fafc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 15
__alloc_contig_migrate_range: migrate_pages ret 15
__alloc_contig_migrate_range: pfn 0x0002fafc end 0x0002fafc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 15
__alloc_contig_migrate_range: migrate_pages ret 15
__alloc_contig_migrate_range: pfn 0x0002fafc end 0x0002fafc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 15
__alloc_contig_migrate_range: migrate_pages ret 15
__alloc_contig_migrate_range: pfn 0x0002fafc end 0x0002fafc, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
__alloc_contig_migrate_range:  migrate page pfn 0x2f938
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f930 is busy, retrying
cma: cma_alloc: bitmap_no = 7488 (pfn 0x2f940)
__alloc_contig_migrate_range: pfn 0x0002f940 end 0x0002fb0c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fb0c
__alloc_contig_migrate_range: nr_reclaimed 1, nr_migratepages 16
__alloc_contig_migrate_range: migrate_pages ret 14
__alloc_contig_migrate_range: pfn 0x0002fb0c end 0x0002fb0c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 15
__alloc_contig_migrate_range: migrate_pages ret 14
__alloc_contig_migrate_range: pfn 0x0002fb0c end 0x0002fb0c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 15
__alloc_contig_migrate_range: migrate_pages ret 14
__alloc_contig_migrate_range: pfn 0x0002fb0c end 0x0002fb0c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 15
__alloc_contig_migrate_range: migrate_pages ret 14
__alloc_contig_migrate_range: pfn 0x0002fb0c end 0x0002fb0c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 15
__alloc_contig_migrate_range: migrate_pages ret 14
__alloc_contig_migrate_range: pfn 0x0002fb0c end 0x0002fb0c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
__alloc_contig_migrate_range:  migrate page pfn 0x2f948
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f940 is busy, retrying
cma: cma_alloc: bitmap_no = 7504 (pfn 0x2f950)
__alloc_contig_migrate_range: pfn 0x0002f950 end 0x0002fb1c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fb1c
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 15
__alloc_contig_migrate_range: migrate_pages ret 13
__alloc_contig_migrate_range: pfn 0x0002fb1c end 0x0002fb1c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 13
__alloc_contig_migrate_range: migrate_pages ret 13
__alloc_contig_migrate_range: pfn 0x0002fb1c end 0x0002fb1c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 13
__alloc_contig_migrate_range: migrate_pages ret 13
__alloc_contig_migrate_range: pfn 0x0002fb1c end 0x0002fb1c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 13
__alloc_contig_migrate_range: migrate_pages ret 13
__alloc_contig_migrate_range: pfn 0x0002fb1c end 0x0002fb1c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 13
__alloc_contig_migrate_range: migrate_pages ret 13
__alloc_contig_migrate_range: pfn 0x0002fb1c end 0x0002fb1c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
__alloc_contig_migrate_range:  migrate page pfn 0x2f958
__alloc_contig_migrate_range:  migrate page pfn 0x2f950
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f950 is busy, retrying
cma: cma_alloc: bitmap_no = 7520 (pfn 0x2f960)
__alloc_contig_migrate_range: pfn 0x0002f960 end 0x0002fb2c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fb2c
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 13
__alloc_contig_migrate_range: migrate_pages ret 11
__alloc_contig_migrate_range: pfn 0x0002fb2c end 0x0002fb2c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 11
__alloc_contig_migrate_range: migrate_pages ret 11
__alloc_contig_migrate_range: pfn 0x0002fb2c end 0x0002fb2c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 11
__alloc_contig_migrate_range: migrate_pages ret 11
__alloc_contig_migrate_range: pfn 0x0002fb2c end 0x0002fb2c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 11
__alloc_contig_migrate_range: migrate_pages ret 11
__alloc_contig_migrate_range: pfn 0x0002fb2c end 0x0002fb2c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 11
__alloc_contig_migrate_range: migrate_pages ret 11
__alloc_contig_migrate_range: pfn 0x0002fb2c end 0x0002fb2c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
__alloc_contig_migrate_range:  migrate page pfn 0x2f968
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f960 is busy, retrying
cma: cma_alloc: bitmap_no = 7536 (pfn 0x2f970)
__alloc_contig_migrate_range: pfn 0x0002f970 end 0x0002fb3c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fb3c
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 12
__alloc_contig_migrate_range: migrate_pages ret 10
__alloc_contig_migrate_range: pfn 0x0002fb3c end 0x0002fb3c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 10
__alloc_contig_migrate_range: migrate_pages ret 10
__alloc_contig_migrate_range: pfn 0x0002fb3c end 0x0002fb3c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 10
__alloc_contig_migrate_range: migrate_pages ret 10
__alloc_contig_migrate_range: pfn 0x0002fb3c end 0x0002fb3c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 10
__alloc_contig_migrate_range: migrate_pages ret 10
__alloc_contig_migrate_range: pfn 0x0002fb3c end 0x0002fb3c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 10
__alloc_contig_migrate_range: migrate_pages ret 10
__alloc_contig_migrate_range: pfn 0x0002fb3c end 0x0002fb3c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
__alloc_contig_migrate_range:  migrate page pfn 0x2f978
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f970 is busy, retrying
cma: cma_alloc: bitmap_no = 7552 (pfn 0x2f980)
__alloc_contig_migrate_range: pfn 0x0002f980 end 0x0002fb4c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fb4c
__alloc_contig_migrate_range: nr_reclaimed 1, nr_migratepages 11
__alloc_contig_migrate_range: migrate_pages ret 9
__alloc_contig_migrate_range: pfn 0x0002fb4c end 0x0002fb4c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 10
__alloc_contig_migrate_range: migrate_pages ret 9
__alloc_contig_migrate_range: pfn 0x0002fb4c end 0x0002fb4c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 10
__alloc_contig_migrate_range: migrate_pages ret 9
__alloc_contig_migrate_range: pfn 0x0002fb4c end 0x0002fb4c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 10
__alloc_contig_migrate_range: migrate_pages ret 9
__alloc_contig_migrate_range: pfn 0x0002fb4c end 0x0002fb4c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 10
__alloc_contig_migrate_range: migrate_pages ret 9
__alloc_contig_migrate_range: pfn 0x0002fb4c end 0x0002fb4c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
__alloc_contig_migrate_range:  migrate page pfn 0x2f988
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f980 is busy, retrying
cma: cma_alloc: bitmap_no = 7568 (pfn 0x2f990)
__alloc_contig_migrate_range: pfn 0x0002f990 end 0x0002fb5c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fb5c
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 10
__alloc_contig_migrate_range: migrate_pages ret 8
__alloc_contig_migrate_range: pfn 0x0002fb5c end 0x0002fb5c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 8
__alloc_contig_migrate_range: migrate_pages ret 8
__alloc_contig_migrate_range: pfn 0x0002fb5c end 0x0002fb5c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 8
__alloc_contig_migrate_range: migrate_pages ret 8
__alloc_contig_migrate_range: pfn 0x0002fb5c end 0x0002fb5c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 8
__alloc_contig_migrate_range: migrate_pages ret 8
__alloc_contig_migrate_range: pfn 0x0002fb5c end 0x0002fb5c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 8
__alloc_contig_migrate_range: migrate_pages ret 8
__alloc_contig_migrate_range: pfn 0x0002fb5c end 0x0002fb5c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
__alloc_contig_migrate_range:  migrate page pfn 0x2f998
__alloc_contig_migrate_range:  migrate page pfn 0x2f990
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f990 is busy, retrying
cma: cma_alloc: bitmap_no = 7584 (pfn 0x2f9a0)
__alloc_contig_migrate_range: pfn 0x0002f9a0 end 0x0002fb6c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fb6c
__alloc_contig_migrate_range: nr_reclaimed 1, nr_migratepages 8
__alloc_contig_migrate_range: migrate_pages ret 6
__alloc_contig_migrate_range: pfn 0x0002fb6c end 0x0002fb6c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 7
__alloc_contig_migrate_range: migrate_pages ret 6
__alloc_contig_migrate_range: pfn 0x0002fb6c end 0x0002fb6c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 7
__alloc_contig_migrate_range: migrate_pages ret 6
__alloc_contig_migrate_range: pfn 0x0002fb6c end 0x0002fb6c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 7
__alloc_contig_migrate_range: migrate_pages ret 6
__alloc_contig_migrate_range: pfn 0x0002fb6c end 0x0002fb6c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 7
__alloc_contig_migrate_range: migrate_pages ret 6
__alloc_contig_migrate_range: pfn 0x0002fb6c end 0x0002fb6c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
__alloc_contig_migrate_range:  migrate page pfn 0x2f9a8
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f9a0 is busy, retrying
cma: cma_alloc: bitmap_no = 7600 (pfn 0x2f9b0)
__alloc_contig_migrate_range: pfn 0x0002f9b0 end 0x0002fb7c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fb7c
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 7
__alloc_contig_migrate_range: migrate_pages ret 5
__alloc_contig_migrate_range: pfn 0x0002fb7c end 0x0002fb7c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 5
__alloc_contig_migrate_range: migrate_pages ret 5
__alloc_contig_migrate_range: pfn 0x0002fb7c end 0x0002fb7c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 5
__alloc_contig_migrate_range: migrate_pages ret 5
__alloc_contig_migrate_range: pfn 0x0002fb7c end 0x0002fb7c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 5
__alloc_contig_migrate_range: migrate_pages ret 5
__alloc_contig_migrate_range: pfn 0x0002fb7c end 0x0002fb7c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 5
__alloc_contig_migrate_range: migrate_pages ret 5
__alloc_contig_migrate_range: pfn 0x0002fb7c end 0x0002fb7c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9b0
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f9b0 is busy, retrying
cma: cma_alloc: bitmap_no = 7616 (pfn 0x2f9c0)
__alloc_contig_migrate_range: pfn 0x0002f9c0 end 0x0002fb8c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fb8c
__alloc_contig_migrate_range: nr_reclaimed 1, nr_migratepages 5
__alloc_contig_migrate_range: migrate_pages ret 3
__alloc_contig_migrate_range: pfn 0x0002fb8c end 0x0002fb8c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 4
__alloc_contig_migrate_range: migrate_pages ret 3
__alloc_contig_migrate_range: pfn 0x0002fb8c end 0x0002fb8c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 4
__alloc_contig_migrate_range: migrate_pages ret 3
__alloc_contig_migrate_range: pfn 0x0002fb8c end 0x0002fb8c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 4
__alloc_contig_migrate_range: migrate_pages ret 3
__alloc_contig_migrate_range: pfn 0x0002fb8c end 0x0002fb8c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 4
__alloc_contig_migrate_range: migrate_pages ret 3
__alloc_contig_migrate_range: pfn 0x0002fb8c end 0x0002fb8c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
__alloc_contig_migrate_range:  migrate page pfn 0x2f9c8
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f9c0 is busy, retrying
cma: cma_alloc: bitmap_no = 7632 (pfn 0x2f9d0)
__alloc_contig_migrate_range: pfn 0x0002f9d0 end 0x0002fb9c, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fb9c
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 4
__alloc_contig_migrate_range: migrate_pages ret 2
__alloc_contig_migrate_range: pfn 0x0002fb9c end 0x0002fb9c, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 2
__alloc_contig_migrate_range: pfn 0x0002fb9c end 0x0002fb9c, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 2
__alloc_contig_migrate_range: pfn 0x0002fb9c end 0x0002fb9c, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 2
__alloc_contig_migrate_range: pfn 0x0002fb9c end 0x0002fb9c, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 2
__alloc_contig_migrate_range: pfn 0x0002fb9c end 0x0002fb9c, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
__alloc_contig_migrate_range:  migrate page pfn 0x2f9d8
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f9d0 is busy, retrying
cma: cma_alloc: bitmap_no = 7648 (pfn 0x2f9e0)
__alloc_contig_migrate_range: pfn 0x0002f9e0 end 0x0002fbac, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fbac
__alloc_contig_migrate_range: nr_reclaimed 1, nr_migratepages 3
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbac end 0x0002fbac, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbac end 0x0002fbac, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbac end 0x0002fbac, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbac end 0x0002fbac, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbac end 0x0002fbac, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f9e0 is busy, retrying
cma: cma_alloc: bitmap_no = 7664 (pfn 0x2f9f0)
__alloc_contig_migrate_range: pfn 0x0002f9f0 end 0x0002fbbc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fbbc
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 3
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbbc end 0x0002fbbc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 1
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbbc end 0x0002fbbc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 1
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbbc end 0x0002fbbc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 1
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbbc end 0x0002fbbc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 1
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbbc end 0x0002fbbc, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2f9f0 is busy, retrying
cma: cma_alloc: bitmap_no = 7680 (pfn 0x2fa00)
__alloc_contig_migrate_range: pfn 0x0002fa00 end 0x0002fbcc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fbcc
__alloc_contig_migrate_range: nr_reclaimed 1, nr_migratepages 3
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbcc end 0x0002fbcc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbcc end 0x0002fbcc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbcc end 0x0002fbcc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbcc end 0x0002fbcc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: nr_reclaimed 1, nr_migratepages 3
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbcc end 0x0002fbcc, tries 0
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbcc end 0x0002fbcc, tries 1
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbcc end 0x0002fbcc, tries 2
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbcc end 0x0002fbcc, tries 3
__alloc_contig_migrate_range: nr_reclaimed 0, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 1
__alloc_contig_migrate_range: pfn 0x0002fbcc end 0x0002fbcc, tries 4
__alloc_contig_migrate_range:  migrate page pfn 0x2fa00
alloc_contig_range: __alloc_contig_migrate_range() failed
cma: cma_alloc(): memory range at pfn 0x2fa00 is busy, retrying
cma: cma_alloc: bitmap_no = 7696 (pfn 0x2fa10)
__alloc_contig_migrate_range: pfn 0x0002fa10 end 0x0002fbdc, tries 0
__alloc_contig_migrate_range: isolate_migratepages_range ret 0x0002fbdc
__alloc_contig_migrate_range: nr_reclaimed 2, nr_migratepages 2
__alloc_contig_migrate_range: migrate_pages ret 0
cma: cma_alloc(): returned e6e2d200 (pfn 0x2fa10)

			--- end quote 3 ---

So, through all the attempts, PFNs from 0x2f7e0 to 0x2fa00 could not be
freed, and we took around 35 attempts to find that out.  However, what
it also shows is that picking the first page as the starting point for
the next attempt probably isn't the best idea either, especially as
many of these pages are only 8 or 16 pages apart (which brings up an
entirely separate question - what's going on there, why aren't odd-
numbered pages being used?)

If we choose the last page in the set of migrate pages, then we would
reach our end goal faster, but penalise the previous case where the
pages do eventually become free (we might never end up trying those
blocks.)  So, we need something adaptive.

A possible idea would be to have alloc_contig_range() fill in a bitmask
of these pages.  The alloc_contig_range() caller can then use this to
decide where a better starting location should be.

For example, it could decide to implement a two pass algorithm:
1. first pass
   - try to allocate a block
   - if it fails, retry the allocation at the last migrate page pfn + 1,
     rounded up to the desired alignment.
   - keep iterating until we hit the end of the region.
2. second pass
   - try to allocate a block
   - if it fails, retry the allocation at the first migrate page pfn + 1,
     rounded up to the desired alignment.
   - keep iterating until we hit the end of the region.
3. fail the allocation, too many CMA pages are pinned.

However, even with this performance issue fixed, the problem referred to
in the above LWN article remains: we are ending up with a lot of pinned
pages in the CMA region, which is preventing CMA reclaiming the pages.

Some of this is most likely down to buggy drivers, such as DRM drivers
which allocate shmem pages, and then pin them for the entire life of
the DRM buffer.  One of the points of shmem-based allocation is to
allow the pages to be swapped out when memory pressure increases, or
indeed migrated out of the movable zone.  Indeed, new_inode() (which
is called via shmem_file_setup()) commentry says:

/**
 *      new_inode       - obtain an inode
 *      @sb: superblock
 *
 *      Allocates a new inode for given superblock. The default gfp_mask
 *      for allocations related to inode->i_mapping is GFP_HIGHUSER_MOVABLE.
 *      If HIGHMEM pages are unsuitable or it is known that pages allocated
 *      for the page cache are not reclaimable or migratable,
 *      mapping_set_gfp_mask() must be called with suitable flags on the
 *      newly created inode's mapping
 */


-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up

