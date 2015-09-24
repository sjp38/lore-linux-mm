Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2C59482F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 12:13:24 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so31594623qkc.3
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 09:13:23 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id u1si9399129qge.12.2015.09.24.09.13.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 24 Sep 2015 09:13:23 -0700 (PDT)
Date: Thu, 24 Sep 2015 11:13:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 00/16] Refreshed page-flags patchset
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1509241111590.21022@east.gentwo.org>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org> <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 24 Sep 2015, Kirill A. Shutemov wrote:

> As requested, here's reworked version of page-flags patchset.
> Updated version should fit more naturally into current code base.

This is certainly great for specialized debugging hunting for improper
handling of page flags for compound pages but a regular debug
kernel will get a mass of VM_BUG_ON(s) at numerous page flag uses in the
code. Is that really useful in general for a debug kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
