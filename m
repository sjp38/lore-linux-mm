Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id A3EAF82F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 12:08:31 -0400 (EDT)
Received: by oiev17 with SMTP id v17so43853290oie.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 09:08:31 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id 186si7014123oip.55.2015.09.24.09.08.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 24 Sep 2015 09:08:30 -0700 (PDT)
Date: Thu, 24 Sep 2015 11:08:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 04/16] page-flags: define PG_locked behavior on compound
 pages
In-Reply-To: <1443106264-78075-5-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1509241106320.20701@east.gentwo.org>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org> <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com> <1443106264-78075-5-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 24 Sep 2015, Kirill A. Shutemov wrote:

> SLUB uses PG_locked as a bit spin locked.  IIUC, tail pages should never
> appear there.  VM_BUG_ON() is added to make sure that this assumption is
> correct.

Correct. However, VM_BUG_ON is superfluous. If there is a tail page there
then the information in the page will be not as expected (free list
parameter f.e.) and things will fall apart rapidly with segfaults.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
