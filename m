Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 281BA6B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 12:37:25 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fu12so37799825pac.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 09:37:25 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o6si5428217pan.251.2016.09.14.09.37.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 09:37:23 -0700 (PDT)
Subject: Re: [PATCH] memory-hotplug: Fix bad area access on
 dissolve_free_huge_pages()
References: <1473755948-13215-1-git-send-email-rui.teng@linux.vnet.ibm.com>
 <57D83821.4090804@linux.intel.com>
 <a789f3ef-bd49-8811-e1df-e949f0758ad1@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57D97CAF.7080005@linux.intel.com>
Date: Wed, 14 Sep 2016 09:37:03 -0700
MIME-Version: 1.0
In-Reply-To: <a789f3ef-bd49-8811-e1df-e949f0758ad1@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>

On 09/14/2016 09:33 AM, Rui Teng wrote:
> 
> How about return the size of page freed from dissolve_free_huge_page(),
> and jump such step on pfn?

That would be a nice improvement.

But, as far as describing the initial problem, can you explain how the
tail pages still ended up being PageHuge()?  Seems like dissolving the
huge page should have cleared that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
