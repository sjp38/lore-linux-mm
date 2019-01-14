Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02EEFC43612
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 16:41:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C057D20883
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 16:41:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C057D20883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66F7A8E0010; Mon, 14 Jan 2019 11:41:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61F588E0002; Mon, 14 Jan 2019 11:41:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 535868E0010; Mon, 14 Jan 2019 11:41:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 154AF8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:41:31 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 202so12916639pgb.6
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:41:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4LiKk4JcuNJxxjh0VoGPy3n1N8PPCVZxeGV3BR7wHkE=;
        b=tkwTNc2kVLf5uEUzl0ttTYs7RD7ZIU/LggoOOyaoF0FLGhkVZh9dfHs+AZASRWLFbt
         vku5X/mpon7OzpNMVcXis9qo+OSgZ8+hhaR1iILs7FEwjmffleiqXt8VfSClr0P6YhC+
         4Khw6yEGlkWf0cLfVpHXxQlHdu2STgKYgbqF8Vc+4ahd/U2zSBrOQ0WIHDxy9htj0vjM
         oVHRpeOAE4EFHkJlOKwr7XgyV2cM2mUbT6cT9E0Pk5SPMPA7SPe0IgQQN28kHyS4xTVt
         8yjqhK0UB1A/DsVM57uMWH5iucxIfuKG243V7brl8gCka0wvHRnYP8BoxweRi8azWgTA
         qHFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukc/gkvCVR0s8qxW8kRLu5WDSFWFXVjmxX7QWoBCo5vHvAdJjJS0
	Vxs9bHmqRBlXFt6drvQQB0Iv+aVjJdnUR4bGCBjfj4qMhfAaFrAowNViogWLLFSITaK31024X3D
	PVdcnomnjMn6JCYx4Pigi+YWbLgchf9AMA3k1xJRCFJpLmTbfS2/81D5JBCvpfSJI9Q==
X-Received: by 2002:a17:902:2b84:: with SMTP id l4mr26377804plb.191.1547484090744;
        Mon, 14 Jan 2019 08:41:30 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6etSZU8o62fap88u/3QAI4H0cMO8qsblTOQRYoU1dhu6viMj86f0MQnZyfJj+oOzAGJR76
X-Received: by 2002:a17:902:2b84:: with SMTP id l4mr26377754plb.191.1547484089961;
        Mon, 14 Jan 2019 08:41:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547484089; cv=none;
        d=google.com; s=arc-20160816;
        b=fkde0NDuhFNtvugsvtAtR570zReBzTgXLGBPLtwXkJI/MwDh6Rr4373a9vwwS9bE6e
         cGwvZoZ+QpoieceXnTEB8g8oCwGDxBUtgNRU1+PhqNXAbx9nuxp+Vw2lzCDRuDZ/DRm1
         LNouhOAJX1G6lG1rz38mQ/qLfyF9KmZoBjGvYjJgKfHY2OAJ5VLH8jjr+dTE79QXVEry
         2vyz/Dx7C5EjF/Jwu83ynX2dF90/lGRIXE6Mzk44aYQ+ZdfMfL0Rnex5wtsAyGrlTS94
         6LCZl5Dflj88kuCIsqQZ2kTPl8h9zev0islRv3vWMb+13+BKeC2ODRPh5v+GCXx5lYKd
         bdTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=4LiKk4JcuNJxxjh0VoGPy3n1N8PPCVZxeGV3BR7wHkE=;
        b=ThYMiv/tzZKcxyqf8V9cwUNO+yJpBj2HzscW0y+qFyHZy5nYKlRJmKGxfBqQlnDic8
         K9LMFCQyHu3/WjP1JRU8qamdCGmE9YHTQ1rNgvWziZo0JG+WzLWe5MFmHWfp7O47jAsm
         JasdJgV4kx3JkvpTMRCHArkrxqqKbvxrKEONcPx9KXYEDCJ8mdAemrQ7DSi77IlH9T1r
         +0StPWiSDqnYr/2nArmQ13U+Hvby7nkaYu0l2tDtfz8EX2pRdeTTnYnkJGu2xj6lPAE2
         zZWoD6IssnuoNpYxl1gGNY0R/4/yq+XZJpMVhNqtDLqhzdyjm01bbUD//ehVcpcekzWD
         KuTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d90si719093pld.148.2019.01.14.08.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 08:41:29 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jan 2019 08:41:29 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,478,1539673200"; 
   d="scan'208";a="109783390"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008.jf.intel.com with ESMTP; 14 Jan 2019 08:41:29 -0800
Message-ID: <d242b75461b38f4910ed619fabc0f9b52dce7f8b.camel@linux.intel.com>
Subject: Re: [PATCH v9] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Michal Hocko <mhocko@kernel.org>, Arun KS <arunks@codeaurora.org>
Cc: arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, 
	osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	getarunks@gmail.com
Date: Mon, 14 Jan 2019 08:41:29 -0800
In-Reply-To: <20190114143251.GI21345@dhcp22.suse.cz>
References: <1547098543-26452-1-git-send-email-arunks@codeaurora.org>
	 <f65b1b22426855ff261b3af719e58eded576a168.camel@linux.intel.com>
	 <fa3dc06536a8ba980c4434806204017a@codeaurora.org>
	 <20190114143251.GI21345@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190114164129.YR1xAejqS-ZznVp3nvtBWitwfSEWNBA1BKcv_eanwb8@z>

On Mon, 2019-01-14 at 15:32 +0100, Michal Hocko wrote:
> On Mon 14-01-19 19:29:39, Arun KS wrote:
> > On 2019-01-10 21:53, Alexander Duyck wrote:
> 
> [...]
> > > Couldn't you just do something like the following:
> > > 		if ((end - start) >= (1UL << (MAX_ORDER - 1))
> > > 			order = MAX_ORDER - 1;
> > > 		else
> > > 			order = __fls(end - start);
> > > 
> > > I would think this would save you a few steps in terms of conversions
> > > and such since you are already working in page frame numbers anyway so
> > > a block of 8 pfns would represent an order 3 page wouldn't it?
> > > 
> > > Also it seems like an alternative to using "end" would be to just track
> > > nr_pages. Then you wouldn't have to do the "end - start" math in a few
> > > spots as long as you remembered to decrement nr_pages by the amount you
> > > increment start by.
> > 
> > Thanks for that. How about this?
> > 
> > static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
> > {
> >         unsigned long end = start + nr_pages;
> >         int order;
> > 
> >         while (nr_pages) {
> >                 if (nr_pages >= (1UL << (MAX_ORDER - 1)))
> >                         order = MAX_ORDER - 1;
> >                 else
> >                         order = __fls(nr_pages);
> > 
> >                 (*online_page_callback)(pfn_to_page(start), order);
> >                 nr_pages -= (1UL << order);
> >                 start += (1UL << order);
> >         }
> >         return end - start;
> > }
> 
> I find this much less readable so if this is really a big win
> performance wise then make it a separate patch with some nubbers please.

I suppose we could look at simplifying this further. Maybe something
like:
	unsigned long end = start + nr_pages;
	int order = MAX_ORDER - 1;

	while (start < end) {
		if ((end - start) < (1UL << (MAX_ORDER - 1))
			order = __fls(end - start));
		(*online_page_callback)(pfn_to_page(start), order);
		start += 1UL << order;
	}

	return nr_pages;

I would argue it probably doesn't get much more readable than this. The
basic idea is we are chopping off MAX_ORDER - 1 sized chunks and
setting them online until we have to start working our way down in
powers of 2.

In terms of performance the loop itself isn't going to have that much
impact. The bigger issue as I saw it was that we were going through and
converting PFNs to a physical addresses just for the sake of contorting
things to make them work with get_order when we already have the PFN
numbers so all we really need to know is the most significant bit for
the total page count.

