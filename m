Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4728C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 15:00:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B71F204EC
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 15:00:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B71F204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 397D26B026C; Tue,  2 Apr 2019 11:00:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 344C86B0270; Tue,  2 Apr 2019 11:00:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 235886B0277; Tue,  2 Apr 2019 11:00:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E03386B026C
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 11:00:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m32so6075994edd.9
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 08:00:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6+9I4+PZa8YzIyot5hTknKZCZbBLkGp49vh1/pBqzlk=;
        b=gOI+uwo6WiFw3M05kcYVRSBZMa7kQ8q2sa9ZhB3NpKXBV6RbhZC3Z39dJRtQXlJ6/+
         3anXWE9TUkGn2UO46dqXQ20ewd9bmkffytYEvSFxHQ/KXun3nXXP9GPUDWT7e1fFFH/W
         ZCKMBcSOj2UQBmfH4eKeafpLLQKSa8gZzv74wTguKN2hxgEToVXzhvkapoC2CTqdOeDx
         rs5X+stIHNcWgahzQ1rRxdpNLzNSYhIvAEjpTWz09U9pePWOPmUbTPic3gX0NxQf/v98
         H/4wIiX7zqiZARpTcRu05ItNBD69w+6T1UF9Frf+f2EQvHd8pr5eLJtD/gFU4o9NyXmh
         5eLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVlSvES9NGQSzh/9mIvZm+WBH7y25mQYZxlEzuwZ6nBZEnIw8Le
	xQuaxK/c8xeZ54f2oXDMgNfERICpnIfAEkE0afDWn2XatLpb+mdCLGP8K2NgH8WmjK2KNAO7bz+
	2OP5/YbZKrJweJGzIZgeQOz/EjKqekTC4keAYTm30JCCPIb1gN6h2NjbkUcZOiLFq+Q==
X-Received: by 2002:a17:906:7010:: with SMTP id n16mr359292ejj.271.1554217223477;
        Tue, 02 Apr 2019 08:00:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHH7ckf4y/5fANnpR9AYbGQ5bp2iHsrLWiNZaDlu7jUI5SEOOHuQDdXxA0hIXPjVJ8Pinm
X-Received: by 2002:a17:906:7010:: with SMTP id n16mr359255ejj.271.1554217222784;
        Tue, 02 Apr 2019 08:00:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554217222; cv=none;
        d=google.com; s=arc-20160816;
        b=ltJTJ+t45Ojqsp5RJYEdTTbLpiB4XCEit54er4cVM9UHPoSCALP54QykuPKCrBtOGN
         4iTCGL96YPkT06rcaKUmBU8KYaWCJJBCsUkoV6JOw3gCUaadLggqvnPCNzKJb4EalRwV
         8jrKIv4NesGmlzh48LVJCwWhjxl2OTIqx9tPpDf2ZnYa6G8WFgmGlndaB9QfVIpYH9Wx
         IO6c2KnglxgpJcJ8SW1AP7vheMBN3UwgmNZas9AMHUDgGcVLUL70x9+anwD6r4x2xXps
         MCoRVuaFBzU31eooLCay6gSGkRYtQhnk2Tvmt+1bVI0La4z9eduIT5RlVUuyBGlTYHpn
         7KVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6+9I4+PZa8YzIyot5hTknKZCZbBLkGp49vh1/pBqzlk=;
        b=ahrDoDZkoe/Ff/kKUBdoR+etC1j/8UQrUeZL4/kC4MzDaCo1vNVX99j9M8yxXXRi5M
         5kB2QMmPC8K2YV37XXuibl+rsYnoTTDfOm18DYn1ZteSQcAn+EnJX9GC3JCR1WK+jt3O
         Hb7DBfyKTossFlywNOYj08uA3Az7+Rj1TTUIrlkrbV2ra5V5QH3b6KTmq+s/t/AiXNYB
         DPTFZPcSeHs0IjJe3SMgvBgf5FOFIhIWSn/wkGl38WYhZzy7iN73iotDVY5Mqn487JQG
         rezR1yM9yeo7qmaz/JN1ezztBtA6U36Pc/yTgZO7XtDpCaPUxbi8c8tKC0bYFypbKA6T
         1bUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id j2si4821647ejs.162.2019.04.02.08.00.22
        for <linux-mm@kvack.org>;
        Tue, 02 Apr 2019 08:00:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 6D43E47C9; Tue,  2 Apr 2019 17:00:22 +0200 (CEST)
Date: Tue, 2 Apr 2019 17:00:22 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Linxu Fang <fanglinxu@huawei.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz,
	pavel.tatashin@microsoft.com, linux-mm@kvack.org
Subject: Re: [PATCH] mem-hotplug: fix node spanned pages when we have a node
 with only zone_movable
Message-ID: <20190402150022.fqy53o2tono6afwu@d104.suse.de>
References: <1554178276-10372-1-git-send-email-fanglinxu@huawei.com>
 <20190402145708.7b2xp3cc72vqqlzl@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402145708.7b2xp3cc72vqqlzl@d104.suse.de>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 04:57:11PM +0200, Oscar Salvador wrote:
> On Tue, Apr 02, 2019 at 12:11:16PM +0800, Linxu Fang wrote:
> > commit <342332e6a925> ("mm/page_alloc.c: introduce kernelcore=mirror
> > option") and series patches rewrote the calculation of node spanned
> > pages.
> > commit <e506b99696a2> (mem-hotplug: fix node spanned pages when we have a
> > movable node), but the current code still has problems,
> > when we have a node with only zone_movable and the node id is not zero,
> > the size of node spanned pages is double added.
> > That's because we have an empty normal zone, and zone_start_pfn or
> > zone_end_pfn is not between arch_zone_lowest_possible_pfn and
> > arch_zone_highest_possible_pfn, so we need to use clamp to constrain the
> > range just like the commit <96e907d13602> (bootmem: Reimplement
> > __absent_pages_in_range() using for_each_mem_pfn_range()).
> 
> So, let me see if I understood this correctly:
> 
> When calling zone_spanned_pages_in_node() for any node which is not node 0,
> 
> > *zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
> > *zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
> 
> will actually set zone_start_pfn/zone_end_pfn to the values from node0's
> ZONE_NORMAL?

Of course, I meant when calling it being zone_type == ZONE_NORMAL.

-- 
Oscar Salvador
SUSE L3

