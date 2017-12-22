Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 176D26B0069
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 04:48:52 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id f4so16325436wre.9
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 01:48:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q30si11479436wra.151.2017.12.22.01.48.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Dec 2017 01:48:50 -0800 (PST)
Date: Fri, 22 Dec 2017 10:48:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/5] mm, hugetlb: allocation API and migration
 improvements
Message-ID: <20171222094849.GO4831@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7cf6978c-5bf2-cbe4-6f7f-ba09998f482d@ah.jp.nec.com>
 <659e21c7-ebed-8b64-053a-f01a31ef6e25@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 21-12-17 15:35:28, Mike Kravetz wrote:
[...]
> You can add,
> 
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> I had some concerns about transferring huge page state during migration
> not specific to this patch, so I did a bunch of testing.

On Fri 22-12-17 08:58:48, Naoya Horiguchi wrote:
[...]
> Yes, I tested again with additional changes below, and hugetlb migration
> works fine from mbind(2). Thank you very much for your work.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> for the series.

Thanks a lot to both of you! I have added the changelog to the last
patch. I am currently busy as hell so I will unlikely send the whole
thing before new year but please double check the changelog if you find
some more time.
---
