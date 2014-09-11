Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 490146B00A3
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 10:34:41 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id k14so5333830wgh.22
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 07:34:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cw8si1671970wjb.156.2014.09.11.07.34.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Sep 2014 07:34:35 -0700 (PDT)
Date: Thu, 11 Sep 2014 10:33:52 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: mm: BUG in unmap_page_range
Message-ID: <20140911143352.GA3008@redhat.com>
References: <20140908171853.GN17501@suse.de>
 <540DEDE7.4020300@oracle.com>
 <20140909213309.GQ17501@suse.de>
 <540F7D42.1020402@oracle.com>
 <alpine.LSU.2.11.1409091903390.10989@eggly.anvils>
 <20140910124732.GT17501@suse.de>
 <alpine.LSU.2.11.1409101210520.1744@eggly.anvils>
 <54110C62.4030702@oracle.com>
 <alpine.LSU.2.11.1409110356280.2116@eggly.anvils>
 <5411B032.7050205@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5411B032.7050205@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On Thu, Sep 11, 2014 at 10:22:42AM -0400, Sasha Levin wrote:

 > > The fixed trinity may be counter-productive for now, since we think
 > > there is an understandable pte_mknuma() bug coming from that direction,
 > > but have not posted a patch for it yet.
 > 
 > I'm still seeing the bug with fixed trinity, it was a matter of adding more flags
 > to mbind.
 
What did I miss ? Anything not in the MPOL_MF_VALID mask should be -EINVAL

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
