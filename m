Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1BA6B0257
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 16:45:35 -0400 (EDT)
Received: by qged69 with SMTP id d69so61980173qge.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 13:45:35 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id 35si13903882qkw.127.2015.08.06.13.45.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 06 Aug 2015 13:45:34 -0700 (PDT)
Date: Thu, 6 Aug 2015 15:45:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: page-flags behavior on compound pages: a worry
In-Reply-To: <alpine.LSU.2.11.1508061121120.7500@eggly.anvils>
Message-ID: <alpine.DEB.2.11.1508061542200.8172@east.gentwo.org>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com> <1426784902-125149-5-git-send-email-kirill.shutemov@linux.intel.com> <alpine.LSU.2.11.1508052001350.6404@eggly.anvils> <20150806153259.GA2834@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1508061121120.7500@eggly.anvils>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 6 Aug 2015, Hugh Dickins wrote:

> > I know a patchset which solves this! ;)
>
> Oh, and I know a patchset which avoids these problems completely,
> by not using compound pages at all ;)

Another dumb idea: Stop the insanity of splitting pages on the fly?
Splitting pages should work like page migration: Lock everything down and
ensure no one is using the page and then do it. That way the compound pages
and its metadata are as stable as a regular page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
