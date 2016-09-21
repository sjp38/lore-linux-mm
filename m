Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF726B0284
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 15:22:05 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y6so19102879lff.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 12:22:05 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id jo2si34960743wjc.103.2016.09.21.12.22.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 12:22:03 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id b184so10301105wma.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 12:22:03 -0700 (PDT)
Date: Wed, 21 Sep 2016 21:22:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/1] memory offline issues with hugepage size > memory
 block size
Message-ID: <20160921192201.GL24210@dhcp22.suse.cz>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
 <bc000c05-3186-da92-e868-f2dbf0c28a98@oracle.com>
 <20160921182054.GK24210@dhcp22.suse.cz>
 <57E2D124.9000108@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E2D124.9000108@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>

On Wed 21-09-16 11:27:48, Dave Hansen wrote:
> On 09/21/2016 11:20 AM, Michal Hocko wrote:
> > I would even question the per page block offlining itself. Why would
> > anybody want to offline few blocks rather than the whole node? What is
> > the usecase here?
> 
> The original reason was so that you could remove a DIMM or a riser card
> full of DIMMs, which are certainly a subset of a node.

OK, I see, thanks for the clarification! I was always thinking more in
node rather than physical memory range hot-remove. I do agree that it
makes sense to free the whole gigantic huge page if we encounter a tail
page for the above use case because losing the gigantic page is
justified when the whole dim goes away.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
