Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03D19C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 22:54:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA9CD20896
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 22:54:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA9CD20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 415576B0003; Fri, 10 May 2019 18:54:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C56B6B0005; Fri, 10 May 2019 18:54:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B4E16B0006; Fri, 10 May 2019 18:54:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E8FFE6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 18:54:21 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id k22so5085065pfg.18
        for <linux-mm@kvack.org>; Fri, 10 May 2019 15:54:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6aBorz213tpxEtN7PrDVgXkjkPQXEbd5tcw9DSH2CNs=;
        b=gporxYxkk9agukVVYy5AIh4G9CWbOZ4psIqHv0k4eu2vZ7Z/wAvg1CZbZw5juITbgM
         sHlpyxd8WwT1YcVm8xdHkRrfdAzi0qS1hJWPXPlkOalyh5YR1avIRADe2rKnlfAo585B
         f9n9tm9ARjK5rJPDBMHapScz2efNCGO7Krz3+XKYIPisp23Nq0eZSoFmVG39rIzBkIRw
         1aAHZILWuYHcX3YULq1fSYI6QbWSqACXw56Bh5C9Gbm6V2FwUNtOcWvvR3AnYjAgm8OK
         Dopcg98OA4CrHFn6XUwr84O7xsbbWsDoTiIOztqgsvORsFiFXTw7uGVmmxLuljUQNYOy
         O0Rg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVRcQAC7lJv/1CBACYxSL5tiTh3EXG9qbxbh5ZdhnvWRYjt7K+B
	c9hmIs3Sq1bDlD+cZEBS3WdWNar2hpTbyK4Du8xsiAdsbiacOg/eV90hEqtdgKutgBWec1XaI3/
	hS1sU3Rii24CJu5iemwRDvLDFy3UevRI+diE6++r6Rbz6iXeynrJebQ5UGn4FS4g/9A==
X-Received: by 2002:a17:902:6842:: with SMTP id f2mr16217525pln.189.1557528861579;
        Fri, 10 May 2019 15:54:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhw2SSFIHebsQYwgV+TJGGM0uOqq6UEnLPfcc/6UgyXFgNllnxHMJROM3MifAxwELGQlQU
X-Received: by 2002:a17:902:6842:: with SMTP id f2mr16217483pln.189.1557528860869;
        Fri, 10 May 2019 15:54:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557528860; cv=none;
        d=google.com; s=arc-20160816;
        b=rYtTjmTr2DL+oUz+jCUWnirtczZ2lLDCyrR+SJKU2t3psb9TxVmFIlk7R5m02I3Tsq
         J2UCFbUsR+oWm2Eq56Fw+MtKul5szqZAZ6pa7+ca5IircGxe1+y7/236HImDB7WF5bl0
         U2bIca4EvtfTcwLNyi7Hentmzk6zIq2lgHy8/9JrKBz6ray/OPSSfhcJs8u3vOwsDIuv
         9PpYk/n561+gUINbqRlzb+ZA0B5I8m9UICCTse8NM6cAb8lEMP0ADcQ3eJByipjxg737
         X5TkozIxWYyGy7s871P9yllhnByBUBbm7XY6tAWFbSmRpdT52yLOiziV22IeWP3Fl7wM
         0XEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6aBorz213tpxEtN7PrDVgXkjkPQXEbd5tcw9DSH2CNs=;
        b=ID5mEK6wd/q4o8enyDHxVYlbED488HeJAo8kYbtcoKFglRhg5RAg700ZlL5vHBvihq
         0fKFFMDQedgU1oUR/D/EFHyEOVcNyz6r+QZszyMNW7wTy+BAEMqacMdAwydp8mWeVtbs
         IH+VAG2r/gicqpFeP/+K+v64lrYuNcgeXa8E/tvfmlXbjxdX10fZfRat46+g7i2n7Z/Y
         2ZpLVqG3CzJdqiHYUsTwvMp6GUFNRZtnqQlsPRpfsk/mzCLpNR0JPZ/zyRQeLgT6oXPd
         rpCcOsY02etGAsH/IqkO0Luun0M/mS3VWerPS6ka6GSresVoHfDIO0aN8CZhFER8TTym
         e5YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id n78si9329400pfb.206.2019.05.10.15.54.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 15:54:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 May 2019 15:54:20 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 10 May 2019 15:54:20 -0700
Date: Fri, 10 May 2019 15:54:56 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Huang, Ying" <ying.huang@intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org,
	mhocko@suse.com, mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com, hughd@google.com,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
Message-ID: <20190510225456.GA13529@iweiny-DESK2.sc.intel.com>
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
 <87y33fjbvr.fsf@yhuang-dev.intel.com>
 <20190510163612.GA23417@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190510163612.GA23417@bombadil.infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 09:36:12AM -0700, Matthew Wilcox wrote:
> On Fri, May 10, 2019 at 10:12:40AM +0800, Huang, Ying wrote:
> > > +		nr_reclaimed += (1 << compound_order(page));
> > 
> > How about to change this to
> > 
> > 
> >         nr_reclaimed += hpage_nr_pages(page);
> 
> Please don't.  That embeds the knowledge that we can only swap out either 
> normal pages or THP sized pages.  I'm trying to make the VM capable of 
> supporting arbitrary-order pages, and this would be just one more place
> to fix.
> 
> I'm sympathetic to the "self documenting" argument.  My current tree has
> a patch in it:
> 
>     mm: Introduce compound_nr
>     
>     Replace 1 << compound_order(page) with compound_nr(page).  Minor
>     improvements in readability.
> 
> It goes along with this patch:
> 
>     mm: Introduce page_size()
> 
>     It's unnecessarily hard to find out the size of a potentially huge page.
>     Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).
> 
> Better suggestions on naming gratefully received.  I'm more happy with 
> page_size() than I am with compound_nr().  page_nr() gives the wrong
> impression; page_count() isn't great either.

Stupid question : what does 'nr' stand for?

Ira

