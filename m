Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id EFEB96B003B
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 11:55:48 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so5964431wiv.7
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 08:55:48 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id g3si3944378wiy.17.2014.04.28.08.55.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Apr 2014 08:55:46 -0700 (PDT)
Date: Mon, 28 Apr 2014 17:55:40 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH RFC 2/2] mm: introdule compound_head_by_tail()
Message-ID: <20140428155540.GJ27561@twins.programming.kicks-ass.net>
References: <c232030f96bdc60aef967b0d350208e74dc7f57d.1398605516.git.nasa4836@gmail.com>
 <2c87e00d633153ba7b710bab12710cc3a58704dd.1398605516.git.nasa4836@gmail.com>
 <20140428145440.GB7839@dhcp22.suse.cz>
 <CAHz2CGUueeXR2UdLXBRihVN3R8qEUR8wWhpxYjA6pu3ONO0cJA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHz2CGUueeXR2UdLXBRihVN3R8qEUR8wWhpxYjA6pu3ONO0cJA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Rik van Riel <riel@redhat.com>, Jiang Liu <liuj97@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, sasha.levin@oracle.com, liwanp@linux.vnet.ibm.com, khalid.aziz@oracle.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 28, 2014 at 11:53:28PM +0800, Jianyu Zhan wrote:
> Actually, I checked the assembled code, the compiler is _not_
> so smart to recognize this case. It just does optimization as
> the hint unlikely() told it.

What version, and why didn't your changelog include this useful
information?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
