Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 994F882F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 11:44:13 -0400 (EDT)
Received: by iofb144 with SMTP id b144so81266755iof.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 08:44:13 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id o201si11144299ioe.22.2015.09.24.08.44.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 24 Sep 2015 08:44:12 -0700 (PDT)
Date: Thu, 24 Sep 2015 10:44:00 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 01/16] page-flags: trivial cleanup for PageTrans*
 helpers
In-Reply-To: <1443106264-78075-2-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1509241043500.20701@east.gentwo.org>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org> <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com> <1443106264-78075-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 24 Sep 2015, Kirill A. Shutemov wrote:

> Use TESTPAGEFLAG_FALSE() to get it a bit cleaner.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
