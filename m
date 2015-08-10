Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id C38E66B0255
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 09:50:13 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so69702158igb.1
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 06:50:13 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id c97si14553844iod.17.2015.08.10.06.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 10 Aug 2015 06:50:12 -0700 (PDT)
Date: Mon, 10 Aug 2015 08:50:10 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: page-flags behavior on compound pages: a worry
In-Reply-To: <20150810110955.GA27046@node.dhcp.inet.fi>
Message-ID: <alpine.DEB.2.11.1508100847450.3021@east.gentwo.org>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com> <1426784902-125149-5-git-send-email-kirill.shutemov@linux.intel.com> <alpine.LSU.2.11.1508052001350.6404@eggly.anvils> <20150806153259.GA2834@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1508061121120.7500@eggly.anvils> <alpine.DEB.2.11.1508061542200.8172@east.gentwo.org> <20150807145056.GB12177@node.dhcp.inet.fi> <alpine.DEB.2.11.1508071022160.14912@east.gentwo.org> <20150810110955.GA27046@node.dhcp.inet.fi>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 10 Aug 2015, Kirill A. Shutemov wrote:

> I don't see anything actionable here. Your wish list doesn't cope with
> reality. Compound pages are mapped with PTEs for almost ten years and I
> don't see why we should stop the practice.

Well they have to if they are smaller than huge pages. Treating each PTE
as each having their own state instead of having the whole compound mapped
completely causes the problem. Refcounting in tail pages is not necessary
if the whole compound is either mapped or not mapped at all by a process.
Refcounting in tail pages is only necessary if you allow 4k slices to be
mapped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
