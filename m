Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B138C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 15:49:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE2CA23400
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 15:49:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="L8WPD7dT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE2CA23400
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 481886B0334; Thu, 22 Aug 2019 11:49:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4585A6B0335; Thu, 22 Aug 2019 11:49:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3211F6B0336; Thu, 22 Aug 2019 11:49:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0184.hostedemail.com [216.40.44.184])
	by kanga.kvack.org (Postfix) with ESMTP id 118EB6B0334
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 11:49:18 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id ADB797587
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 15:49:17 +0000 (UTC)
X-FDA: 75850497954.04.farm45_8b4c1bffcea59
X-HE-Tag: farm45_8b4c1bffcea59
X-Filterd-Recvd-Size: 4881
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 15:49:17 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id a21so8567573edt.11
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:49:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DJ/eC3LGuOL6//+DGNThc9YJfZBuiT1PO54o1KGcu30=;
        b=L8WPD7dTrU3n/Wq91GZgxnLyJoEfJzls7dAI7jRFPS2OQUmzaI3fJOHoWKcsrFZaVP
         RvSdHC7FZ1z0sOk8IdvvB29K2NqNten9KEG0gvLCmSqtQFfFJ5uMgD4v43b36IcAv9bX
         KTtYiU4ADpMXlaL5IafhA5DT+coI1u60NzoVzh5Rw8mz0K07RDv2bxZ/AeulQBVIFehw
         kEYLsFZGGD1vqAftG2zGF3XUbDDqHOCP29WxaNddvB8HHtjCJm1SU7vcdk5mJlPG0h9V
         x9uHHr9bupiR3K6DrnD2mLXjtMpcO3ASDogaK2ABY0czTEVx4Z8FVuvhwL6Xr5eg/0q4
         gRHw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=DJ/eC3LGuOL6//+DGNThc9YJfZBuiT1PO54o1KGcu30=;
        b=ua6b4Lllw14bUnEydBdVmz8/dcBowhqM8icHRPJRvj5RwCU40qJijmJbfYV7Htx5Js
         MgSGsp2FZTk7m1IvmYPdmlfxfWonZxpLtzn/7xaAhPyui8/82MeY3kZIgIYPzsmOrCYJ
         AfXTvYDF2t9WRQhDYZPEe9IK+zo7s/4X1tf0ofNoAhLtsDZEnphtySfGqYApKC5pxT59
         vIKe4pdY+CkaiJ0L3UDyRezGOUPnwCou2VV4hkIwBu9RxqweaOmUUsUfLDRTd5an3Dkg
         F8C19uPHf2kTAq1U3SMUbu/v8DNu22ckGZgVbGX6A7hXG7lPugUv7aab/Z6kfo8AQVz1
         ILgA==
X-Gm-Message-State: APjAAAVUwDisjPc/qxm/sXI7BDiL3GbP2HbPPA3RFTFW33WCcsK3nt8r
	1WUsXgNDgHjDtK08M5s/sov8aQ==
X-Google-Smtp-Source: APXvYqzD5H/EuYEoQQqsHvjG6zA2nUnP7NlXkdSM5hi9Tt50tWsVXfctor7rYt6YdvlbkGgeWIoYpQ==
X-Received: by 2002:a05:6402:50a:: with SMTP id m10mr21388362edv.173.1566488955883;
        Thu, 22 Aug 2019 08:49:15 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id p20sm3710384eja.59.2019.08.22.08.49.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Aug 2019 08:49:15 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 7225D100853; Thu, 22 Aug 2019 18:49:14 +0300 (+03)
Date: Thu, 22 Aug 2019 18:49:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, kirill.shutemov@linux.intel.com,
	Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org,
	rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
Message-ID: <20190822154914.gb5clks2tzziobfx@box>
References: <1566410125-66011-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190822080434.GF12785@dhcp22.suse.cz>
 <ee048bbf-3563-d695-ea58-5f1504aee35c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ee048bbf-3563-d695-ea58-5f1504aee35c@suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 02:56:56PM +0200, Vlastimil Babka wrote:
> >> @@ -2816,11 +2821,14 @@ void free_transhuge_page(struct page *page)
> >>  		ds_queue->split_queue_len--;
> >>  		list_del(page_deferred_list(page));
> >>  	}
> >> +	__mod_node_page_state(page_pgdat(page), NR_KERNEL_MISC_RECLAIMABLE,
> >> +			      -page[2].nr_freeable);
> >> +	page[2].nr_freeable = 0;
> 
> Wouldn't it be safer to fully tie the nr_freeable use to adding the page to the
> deffered list? So here the code would be in the if (!list_empty()) { } part above.
> 
> >>  	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
> >>  	free_compound_page(page);
> >>  }
> >>  
> >> -void deferred_split_huge_page(struct page *page)
> >> +void deferred_split_huge_page(struct page *page, unsigned int nr)
> >>  {
> >>  	struct deferred_split *ds_queue = get_deferred_split_queue(page);
> >>  #ifdef CONFIG_MEMCG
> >> @@ -2844,6 +2852,9 @@ void deferred_split_huge_page(struct page *page)
> >>  		return;
> >>  
> >>  	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
> >> +	page[2].nr_freeable += nr;
> >> +	__mod_node_page_state(page_pgdat(page), NR_KERNEL_MISC_RECLAIMABLE,
> >> +			      nr);
> 
> Same here, only do this when adding to the list, below? Or we might perhaps
> account base pages multiple times?

No, it cannot be under list_empty() check. Consider the case when a THP
got unmapped 4k a time. You need to put it on the list once, but account
it every time.

-- 
 Kirill A. Shutemov

