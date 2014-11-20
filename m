Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id C7B3E6B0069
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 15:06:59 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id c9so2671465qcz.24
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 12:06:59 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id m8si3817617qac.60.2014.11.20.12.06.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 12:06:57 -0800 (PST)
Date: Thu, 20 Nov 2014 14:06:53 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 06/19] mm: store mapcount for compound page separate
In-Reply-To: <20141119130050.GA29884@node.dhcp.inet.fi>
Message-ID: <alpine.DEB.2.11.1411201405140.14867@gentwo.org>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com> <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com> <546C761D.6050407@redhat.com> <20141119130050.GA29884@node.dhcp.inet.fi>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jerome Marchand <jmarchan@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 19 Nov 2014, Kirill A. Shutemov wrote:

> I don't think we want to bloat struct page description: nobody outside of
> helpers should use it direcly. And it's exactly what we did to store
> compound page destructor and compound page order.

This is more like a description what overloading is occurring. Either
add the new way of using it there including a comment explainng things or
please do not overload the field.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
