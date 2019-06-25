Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09A49C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 10:31:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C19B4214DA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 10:31:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C19B4214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E5CA6B0003; Tue, 25 Jun 2019 06:31:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 698428E0003; Tue, 25 Jun 2019 06:31:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55E788E0002; Tue, 25 Jun 2019 06:31:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 09B986B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 06:31:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i44so24988794eda.3
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:31:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yxjlWw6xOfojYDfhZ7dgKC7gao4AUS3Lw+SqvYZI4v8=;
        b=LPv3OeBw7uevIIrRD7Gy6NYWrNFIG/ZdRe9/XTWtVEBuTe/AEOeQTJNXgcmsErNYNv
         xzOrs8mr4tW6HsVP7jBCI6GSdw40wb4qc+XgYPVtJe/LrNo01MN0hC6j7R3qc/5XFqAh
         /slbbwqWOH03K+h3zs6NwMIINx9YESQaF5ygas0OHs6JgpsMrWW0aoCswhuBCYTallZu
         YsZZLw3NxaFxJV21otuEskrpTfvNlIbtkkMG4JMZMmIqDCNCSt9lhRxj+/jFWQqUq3lq
         TdZ1h9UUdFy0QH8IcUF+r6VgNbV5zSd8+HkPDgHXEfg/Ax8605pUEYL1ngfmdmQ96MJx
         WR5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAX5qBW83ufMJrrpBxmxLG5IzTpt+fUOxBoAlQqRecVZWNHmwNSY
	3Z4QqB+fpgw50J1Js+Yh0ejrKo6VKQtHSNISmSrZ8eXw3w2xp6Fv2xyE1YFdtL7XCfpD7G2jYdE
	5zhTOswVshTXAGNzkU2nZQOh1Ec3K5XdqDaHtq7KT5Xrxx/PuQ4/kSXrUsXicE5uOGA==
X-Received: by 2002:aa7:ce91:: with SMTP id y17mr112516814edv.56.1561458699473;
        Tue, 25 Jun 2019 03:31:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysFQEEEd72Om//hWu+edacYUTvsfGaGoWv5wdo1EZqKWr8HfAQ8T1t34uLr7g60K6iq1yw
X-Received: by 2002:aa7:ce91:: with SMTP id y17mr112516745edv.56.1561458698729;
        Tue, 25 Jun 2019 03:31:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561458698; cv=none;
        d=google.com; s=arc-20160816;
        b=UiX0OaVZfYqy+TyTnxRVNaTeBtxPh6w64xzSL8H/PoKe0uGkIStaskt0zSA0B/PTBW
         b/+iK8IN3oA7+tZBPIUrTSDpZV8LiJTDCMe2Cknxa1V/s+9b/nIF3O7gpy2/I1ZJwIJh
         /jkLs3RUTzkmIcjIr1ddgXvyvxuOpIEfTxgT8RuIFDxWyQns6EsRpgO9Nrc5US7oJrCm
         axawOEt1jomDUMJH4npLicZ2k7TUNv//XXv4nywv+B4OqUGtQj25b+kwVTUXVpDTzk5D
         EQx1I4Dr6rToeMUNTzCoQtHnb/m21YLE0iBh8D0+L+5YQkGbrCK0riOxCACcmWqWatYG
         bDww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yxjlWw6xOfojYDfhZ7dgKC7gao4AUS3Lw+SqvYZI4v8=;
        b=DRieWD0o1exEbOHhXyfGW1oB7i9EDQuY76VWs3d8a7NaYIruvHRWk2w9qfPEBB3m2H
         j6ipwc+1DesexilcMF4k5FuhVQEJ8BnPTV4t2nxNiKwz5HFZxPafIwFRifKk3x+x61cF
         GkzzRLcbC5hj/rrf88mCEd6SpONuxLv+0lZCxAQju7I5VsMO3Piu0wSR5y+8jsAvNRPw
         de6OiwUvrjeYcUoVMqu+O4qhv5M8VI8oTk4tfYR6HfLuEN+2w/mBitrpTcL0DBFcmg6P
         orXTYRyASXPh5i85XllKMgimjrMv3/+0m5et7yDDWL8FsmADRccNXOxnC22XDOiAMaYk
         9RUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id m19si59077ejq.178.2019.06.25.03.31.38
        for <linux-mm@kvack.org>;
        Tue, 25 Jun 2019 03:31:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 80371360;
	Tue, 25 Jun 2019 03:31:37 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 91F543F71E;
	Tue, 25 Jun 2019 03:31:34 -0700 (PDT)
Date: Tue, 25 Jun 2019 11:31:29 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Steve Capper <Steve.Capper@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	Will Deacon <Will.Deacon@arm.com>,
	"mhocko@suse.com" <mhocko@suse.com>,
	"ira.weiny@intel.com" <ira.weiny@intel.com>,
	"david@redhat.com" <david@redhat.com>, "cai@lca.pw" <cai@lca.pw>,
	"logang@deltatee.com" <logang@deltatee.com>,
	James Morse <James.Morse@arm.com>,
	"cpandya@codeaurora.org" <cpandya@codeaurora.org>,
	"arunks@codeaurora.org" <arunks@codeaurora.org>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"osalvador@suse.de" <osalvador@suse.de>,
	Ard Biesheuvel <Ard.Biesheuvel@arm.com>, nd <nd@arm.com>
Subject: Re: [PATCH V6 3/3] arm64/mm: Enable memory hot remove
Message-ID: <20190625103128.GA12207@lakrids.cambridge.arm.com>
References: <1560917860-26169-1-git-send-email-anshuman.khandual@arm.com>
 <1560917860-26169-4-git-send-email-anshuman.khandual@arm.com>
 <20190621143540.GA3376@capper-debian.cambridge.arm.com>
 <20190624165148.GA9847@lakrids.cambridge.arm.com>
 <48f39fa1-c369-c8e2-4572-b7e016dca2d6@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48f39fa1-c369-c8e2-4572-b7e016dca2d6@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 10:57:07AM +0530, Anshuman Khandual wrote:
> On 06/24/2019 10:22 PM, Mark Rutland wrote:
> > On Fri, Jun 21, 2019 at 03:35:53PM +0100, Steve Capper wrote:
> >> On Wed, Jun 19, 2019 at 09:47:40AM +0530, Anshuman Khandual wrote:
> >>> +static void free_hotplug_page_range(struct page *page, size_t size)
> >>> +{
> >>> +	WARN_ON(!page || PageReserved(page));
> >>> +	free_pages((unsigned long)page_address(page), get_order(size));
> >>> +}
> >>
> >> We are dealing with power of 2 number of pages, it makes a lot more
> >> sense (to me) to replace the size parameter with order.
> >>
> >> Also, all the callers are for known compile-time sizes, so we could just
> >> translate the size parameter as follows to remove any usage of get_order?
> >> PAGE_SIZE -> 0
> >> PMD_SIZE -> PMD_SHIFT - PAGE_SHIFT
> >> PUD_SIZE -> PUD_SHIFT - PAGE_SHIFT
> > 
> > Now that I look at this again, the above makes sense to me.
> > 
> > I'd requested the current form (which I now realise is broken), since
> > back in v2 the code looked like:
> > 
> > static void free_pagetable(struct page *page, int order)
> > {
> > 	...
> > 	free_pages((unsigned long)page_address(page), order);
> > 	...
> > }
> > 
> > ... with callsites looking like:
> > 
> > free_pagetable(pud_page(*pud), get_order(PUD_SIZE));
> > 
> > ... which I now see is off by PAGE_SHIFT, and we inherited that bug in
> > the current code, so the calculated order is vastly larger than it
> > should be. It's worrying that doesn't seem to be caught by anything in
> > testing. :/
> 
> get_order() returns the minimum page allocation order for a given size
> which already takes into account PAGE_SHIFT i.e get_order(PAGE_SIZE)
> returns 0.

Phew.

Let's leave this as is then -- it's clearer/simpler than using the SHIFT
constants, performance isn't a major concern in this path, and it's very
likely that GCC will inline and constant-fold this away regardless.

Sorry for the noise, and thanks for correcting me.

Mark.

