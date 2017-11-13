Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1FAD16B0069
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 14:11:13 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n74so3791935wmi.3
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 11:11:13 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 57si3065966edz.9.2017.11.13.11.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 Nov 2017 11:11:11 -0800 (PST)
Date: Mon, 13 Nov 2017 14:10:56 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: show stats for non-default hugepage sizes in
 /proc/meminfo
Message-ID: <20171113191056.GA28749@cmpxchg.org>
References: <20171113160302.14409-1-guro@fb.com>
 <8aa63aee-cbbb-7516-30cf-15fcf925060b@intel.com>
 <20171113181105.GA27034@castle>
 <c716ac71-f467-dcbe-520f-91b007309a4d@intel.com>
 <2579a26d-81d1-732e-ef57-33bb4c293cd6@oracle.com>
 <20171113184454.GA18531@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171113184454.GA18531@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon, Nov 13, 2017 at 06:45:01PM +0000, Roman Gushchin wrote:
> Or, at least, some total counter, e.g. how much memory is consumed
> by hugetlb pages?

I'm not a big fan of the verbose breakdown for every huge page size.
As others have pointed out such detail exists elswhere.

But I do think we should have a summary counter for memory consumed by
hugetlb that lets you know how much is missing from MemTotal. This can
be large parts of overall memory, and right now /proc/meminfo will
give the impression we are leaking those pages.

Maybe a simple summary counter for everything set aside by the hugetlb
subsystem - default and non-default page sizes, whether they're used
or only reserved etc.?

Hugetlb 12345 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
