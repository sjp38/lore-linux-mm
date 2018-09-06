Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0FC6B78CC
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:45:07 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j15-v6so5833298pfi.10
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:45:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u20-v6si5113732plq.210.2018.09.06.05.45.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 05:45:06 -0700 (PDT)
Date: Thu, 6 Sep 2018 14:45:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH V2 2/4] mm: Add get_user_pages_cma_migrate
Message-ID: <20180906124504.GW14951@dhcp22.suse.cz>
References: <20180906054342.25094-1-aneesh.kumar@linux.ibm.com>
 <20180906054342.25094-2-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180906054342.25094-2-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu 06-09-18 11:13:40, Aneesh Kumar K.V wrote:
> This helper does a get_user_pages_fast and if it find pages in the CMA area
> it will try to migrate them before taking page reference. This makes sure that
> we don't keep non-movable pages (due to page reference count) in the CMA area.
> Not able to move pages out of CMA area result in CMA allocation failures.

Again, there is no user so it is hard to guess the intention completely.
There is no documentation to describe the expected context and
assumptions about locking etc.

As noted in the previous email. You should better describe why you are
bypassing hugetlb pools. I assume that the reason is to guarantee a
forward progress because those might be sitting in the CMA pools
already, right?
-- 
Michal Hocko
SUSE Labs
