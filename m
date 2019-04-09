Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5780AC282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 20:23:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D041218FC
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 20:23:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D041218FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96E786B000D; Tue,  9 Apr 2019 16:23:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91DA06B0266; Tue,  9 Apr 2019 16:23:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80ED86B0269; Tue,  9 Apr 2019 16:23:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 493AB6B000D
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 16:23:23 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d16so10264106pll.21
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 13:23:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=i4yADXzCMNvYz8lRNdAdNhgp4MzJd0c8PhSjkHCdFIg=;
        b=pNdC9SKL2QpsdjvTiWPO5ippkqs9UW4Lk/SF8e6coZobDmd/n/eHk6lXPE7laURvWQ
         XGA0UmUQsYqeXhsXOpmM6M4P5qdeW7epLKoJxzwQmbloFsmsqo5PxRrbFoCDpkGnfr6T
         mwl6WwHf1OFVdfpZipSLk+OXl8gkf7waDPTWH9m4wJlQEEYVlpKDMqE/Y/DVgIoTyWQm
         Iif6oVF50ItbKQWTcTLsZqxHfsk6asbcoSU42GwnvdjKJ013WhcrNbmg8FpTuLYSsGAE
         aKY7zwAWShv6nRQT6dku9CLCfP0lY1la0VLBkqu9UGpNh0dCQM8XAvKjcxQ2Fg8422MT
         TefA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVE5lLPgnu3806fydH1Blc6YUk9Wk2E3AIiBeWGYt9wEC+6EpBm
	kgdhU4p1iyWerkoxtFxxk32YElI7Y3gTy7srXUjgnKxUoqwGvVTLvd9vIXy55vd1lqx0nlZVKe0
	YXi9P1ljaz4xYa00GUrbSWRSyHzJwFxMTkHmpKSfVlG8n9z7PWP0t0RAseNgXWaZN5A==
X-Received: by 2002:a65:5682:: with SMTP id v2mr37348328pgs.100.1554841402885;
        Tue, 09 Apr 2019 13:23:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzr8mv0zm7ySpKX5SxQVDyWG9xzjevUUOAZAfdVwLDPAZ9ePdsRs5waG5hwKEhRrW2V4lYu
X-Received: by 2002:a65:5682:: with SMTP id v2mr37348272pgs.100.1554841402145;
        Tue, 09 Apr 2019 13:23:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554841402; cv=none;
        d=google.com; s=arc-20160816;
        b=fQjeOHb/n3PXb/rqTMLjRQwuaj+PPYG99FOqP456yFf8/DaU8BtG8aDmUnLztyePLt
         jv+h/RMpA8eUo0ZZ4+IQsmWsjtKSP25fb9DHwF8naiSdRbcao2JbBbWeZ84zrB1PVOGb
         q+sUUMscbtTR7Ga8oxbb/pSpjTmqqA18X4XYVVYnD2QRxmjYwjZFP67kWMMsDVdTf976
         z5z8DG919Gre69UrEtxWbpBLypyzy+xFUz8TL2D2YmcXBpfDBPdQF5k5yuwsLUj2LLXG
         KYGJqByWTI1JhwKQTqsMRyjbTKWtjScYvw3+dVU66+oroF4R8I+OmFwGEpy6ZGiGfT1F
         WdSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=i4yADXzCMNvYz8lRNdAdNhgp4MzJd0c8PhSjkHCdFIg=;
        b=ENsx30KMdvuCl7xmzbFmTClKgHKZ716d2eaTD5Sc56kyKOBmWBNvO10PAr446MuZ4+
         VH/DK//qGv+ihcC4Bxhr9T8RjCO0G1P3Vlv16nzWxtkIec57QgUbkMXRxMdau9onD2or
         FKVV23diifbr4LRASrfcFuL2W7glZEyyhGBKDurbFjU7Ps7SeAu/dZw68SaAgt7F/vxI
         cNoMrFeoYCYZJ4wN3V/VeehuRp5UxP6BrYbIzFjtMcWMEccVMX9OfxepZCgyoALHcIv+
         kiyCjMrrYJhH6OvX9JzjMXsYtKKocYJ5gwrbOKqg2HRSCfeJbG6v2stbPOezp8yhW7LX
         52Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f64si20738477pfc.168.2019.04.09.13.23.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 13:23:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Apr 2019 13:23:21 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,330,1549958400"; 
   d="scan'208";a="141425019"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 09 Apr 2019 13:23:21 -0700
Date: Tue, 9 Apr 2019 13:23:16 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Huang Shijie <sjhuang@iluvatar.ai>
Cc: Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org,
	william.kucharski@oracle.com, palmer@sifive.com, axboe@kernel.dk,
	keescook@chromium.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] mm/gup.c: fix the wrong comments
Message-ID: <20190409202316.GA22989@iweiny-DESK2.sc.intel.com>
References: <20190408023746.16916-1-sjhuang@iluvatar.ai>
 <20190408141313.GU22763@bombadil.infradead.org>
 <20190409010832.GA28081@hsj-Precision-5520>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190409010832.GA28081@hsj-Precision-5520>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 09:08:33AM +0800, Huang Shijie wrote:
> On Mon, Apr 08, 2019 at 07:13:13AM -0700, Matthew Wilcox wrote:
> > On Mon, Apr 08, 2019 at 10:37:45AM +0800, Huang Shijie wrote:
> > > When CONFIG_HAVE_GENERIC_GUP is defined, the kernel will use its own
> > > get_user_pages_fast().
> > > 
> > > In the following scenario, we will may meet the bug in the DMA case:
> > > 	    .....................
> > > 	    get_user_pages_fast(start,,, pages);
> > > 	        ......
> > > 	    sg_alloc_table_from_pages(, pages, ...);
> > > 	    .....................
> > > 
> > > The root cause is that sg_alloc_table_from_pages() requires the
> > > page order to keep the same as it used in the user space, but
> > > get_user_pages_fast() will mess it up.
> > 
> > I don't understand how get_user_pages_fast() can return the pages in a
> > different order in the array from the order they appear in userspace.
> > Can you explain?
> Please see the code in gup.c:
> 
> 	int get_user_pages_fast(unsigned long start, int nr_pages,
> 				unsigned int gup_flags, struct page **pages)
> 	{
> 		.......
> 		if (gup_fast_permitted(start, nr_pages)) {
> 			local_irq_disable();
> 			gup_pgd_range(addr, end, gup_flags, pages, &nr);               // The @pages array maybe filled at the first time.
> 			local_irq_enable();
> 			ret = nr;
> 		}
> 		.......
> 		if (nr < nr_pages) {
> 			/* Try to get the remaining pages with get_user_pages */
> 			start += nr << PAGE_SHIFT;
> 			pages += nr;                                                  // The @pages is moved forward.
> 
> 			if (gup_flags & FOLL_LONGTERM) {
> 				down_read(&current->mm->mmap_sem);
> 				ret = __gup_longterm_locked(current, current->mm,      // The @pages maybe filled at the second time
>

Neither this nor the get_user_pages_unlocked is filling the pages a second
time.  It is adding to the page array having moved start and the page array
forward.

Are you doing a FOLL_LONGTERM GUP?  Or are you in the else clause below when
you get this bug?

Ira

> 							    start, nr_pages - nr,
> 							    pages, NULL, gup_flags);
> 				up_read(&current->mm->mmap_sem);
> 			} else {
> 				/*
> 				 * retain FAULT_FOLL_ALLOW_RETRY optimization if
> 				 * possible
> 				 */
> 				ret = get_user_pages_unlocked(start, nr_pages - nr,    // The @pages maybe filled at the second time.
> 							      pages, gup_flags);
> 			}
> 		}
> 
> 
> 		.....................
> 
> BTW, I do not know why we mess up the page order. It maybe used in some special case.
> 
> Thanks
> Huang Shijie
> 

