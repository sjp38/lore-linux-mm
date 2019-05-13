Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB3A1C04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 09:12:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 923FC20989
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 09:12:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EvAbLVwU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 923FC20989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39C096B0270; Mon, 13 May 2019 05:12:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34D706B0271; Mon, 13 May 2019 05:12:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 263A76B0272; Mon, 13 May 2019 05:12:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E416E6B0270
	for <linux-mm@kvack.org>; Mon, 13 May 2019 05:12:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d12so9212019pfn.9
        for <linux-mm@kvack.org>; Mon, 13 May 2019 02:12:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FhRnavH5ISIIL5pl8TyT+ztasWjBJfJsuvguEoKrBnk=;
        b=dBOjgEAu6p5MtCsAQfISLnj2Jx6N6J3/cpqJIyfE1iB4ZuyAeMNOaS661g+VTH8PRI
         8YW8JZ8Psh3oWtzqpIgOpx67J8lJ2YMwOMyjCA0PrTWwFD7lAu60b5w5kyU5UxBLQv+u
         K9JvcbicbxyJyApeX9iZwcAvfnxHNKyLJmH1HHS5ycdaiz4Xg8CShH6jVwT9Judu5Av8
         UWPaIFCHhlGtvTQlMw/I6fBH3i3S6c7RBgOKbvXkdH8FhKLZMSbOqUGnplJNEWO5+Nx8
         duHif1I85llb/c847VBPHR9UkX/nSZ9iab8QW4IDerQcH0nSl6PY88wgP6xUPC9sm72H
         8v4A==
X-Gm-Message-State: APjAAAUa2cic6nHv7EtdcUF+nnafK9HVEJMdQ6R+WzLM3nSugIdACGvh
	b08tAOd1DmiCf/yNaJXwc7kzAYHOiiiR79qcPdhxO/HwVk6yE4Qev54/kFXIlCU3RstjwLEi0B/
	V2bJHnobULQRbnYeMQBlE/EOdeTK0CBp7gI6kzoOg3is5SF2SN1rGlgeHEPgNrRKIbg==
X-Received: by 2002:a17:902:bf44:: with SMTP id u4mr28785657pls.171.1557738733452;
        Mon, 13 May 2019 02:12:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeWJZ+Wcuk9AdddIMDthFk5g1lhmVz+aQpTsuJ7IkIofMKRgKe14UgaIq2/YYYx/ePgXV6
X-Received: by 2002:a17:902:bf44:: with SMTP id u4mr28785612pls.171.1557738732829;
        Mon, 13 May 2019 02:12:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557738732; cv=none;
        d=google.com; s=arc-20160816;
        b=SJHBpyewdXkaybE5ehXwn53z5cmEX/MENJvYimEAsosJ8KUgA1eQxFdkxzPGJd6I/Q
         Hjza0qwjJCBI2leCt6vcezd5J4mJ7WMzQtqror0NJt+7EFaj42DUg11WcbZA6Yyp6bsA
         eacqMOgKaztDSnYhBga834eQyXv2z7O7Fk7qT1zEQFbFWE04dT5MS61M6n2ndwYZX8pr
         cQ1T1GeMCzihIoLCNjdbv7/ragugH+E47vspinpI07Sd8yItRBiofDzLdl9j6dGCxj15
         jCF9o88Kpo1IiHInMMnkJZsOpptozcoDzCzRe3bQXCNSOJ20qtzpWfHV9BieBuRORBED
         qQgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FhRnavH5ISIIL5pl8TyT+ztasWjBJfJsuvguEoKrBnk=;
        b=zjBjj/UGEiCSRP1LMII9lALkfsec0LrksOfMUd8GxIiR8Ih09buVEF7kCfrxU7TkmQ
         gx+obEqh+qffkHz79iQJbCGATqkYANRfl30xaaLjJnnZssoWLSS9i+f/2VNltHhzMEp9
         SekqCrsblfx1nCvD49D8TyNpyEXx3WjjvjDd2o0aQhLYVtS1Fvj8+S2/sikrrEG2wO/b
         X6ax3D3hEleYcwCECsCf0IDIwdpE1eCgpnVo1pB8822nh1yD6PPD4O03fOWIueoN5NNF
         Suy1uwXa8ZMzMQ93yB8lc14DprbbKlJ7JcHoK6uDbPN1fq189GfSxwl8PN/AbEouYPiF
         Xobg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EvAbLVwU;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b12si519549pla.126.2019.05.13.02.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 May 2019 02:12:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EvAbLVwU;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=FhRnavH5ISIIL5pl8TyT+ztasWjBJfJsuvguEoKrBnk=; b=EvAbLVwUdc20zwJRefzd8QXJc
	xGFN34vOXzCUBVBHMhCvseLFXe61OQl6jTYmI2IpoiF9NNOUAeidWxIdaXszHhOK2X4r7hDNLaykV
	49pGvyK6Pe3kV8vOdLD5SMVPTkx4njIp7Rjq3/I8BEcLabvbNulz/3l6BHOJmklPrznaTshp+UpOx
	kFaXb295xKAyC0BS5R96yYYxOexobeYwZNvi69E7DTKFRtFrA6aEZjbLlEMYOW6EcWGUYJUNjOC4y
	TQcZWQE/WrzhWeSjXI8wcoe0LHeXtYXIZBSUhs9LnSBw9IViT06alNECta0qlYxO7RU5kHB8K3q93
	RAjmE9aqg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQ70B-0002mG-NM; Mon, 13 May 2019 09:12:07 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id DB1D02029F888; Mon, 13 May 2019 11:12:05 +0200 (CEST)
Date: Mon, 13 May 2019 11:12:05 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Nadav Amit <namit@vmware.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
	"jstancek@redhat.com" <jstancek@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Nick Piggin <npiggin@gmail.com>, Minchan Kim <minchan@kernel.org>,
	Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190513091205.GO2650@hirez.programming.kicks-ass.net>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
 <20190509182435.GA2623@hirez.programming.kicks-ass.net>
 <04668E51-FD87-4D53-A066-5A35ABC3A0D6@vmware.com>
 <20190509191120.GD2623@hirez.programming.kicks-ass.net>
 <7DA60772-3EE3-4882-B26F-2A900690DA15@vmware.com>
 <20190513083606.GL2623@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190513083606.GL2623@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 10:36:06AM +0200, Peter Zijlstra wrote:
> On Thu, May 09, 2019 at 09:21:35PM +0000, Nadav Amit wrote:
> > It may be possible to avoid false-positive nesting indications (when the
> > flushes do not overlap) by creating a new struct mmu_gather_pending, with
> > something like:
> > 
> >   struct mmu_gather_pending {
> >  	u64 start;
> > 	u64 end;
> > 	struct mmu_gather_pending *next;
> >   }
> > 
> > tlb_finish_mmu() would then iterate over the mm->mmu_gather_pending
> > (pointing to the linked list) and find whether there is any overlap. This
> > would still require synchronization (acquiring a lock when allocating and
> > deallocating or something fancier).
> 
> We have an interval_tree for this, and yes, that's how far I got :/
> 
> The other thing I was thinking of is trying to detect overlap through
> the page-tables themselves, but we have a distinct lack of storage
> there.

We might just use some state in the pmd, there's still 2 _pt_pad_[12] in
struct page to 'use'. So we could come up with some tlb generation
scheme that would detect conflict.

