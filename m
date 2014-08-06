Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 86A276B0035
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 21:04:43 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id wn1so1310963obc.17
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 18:04:43 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y11si7790425oep.28.2014.08.05.18.04.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 05 Aug 2014 18:04:43 -0700 (PDT)
Message-ID: <53E17F06.30401@oracle.com>
Date: Tue, 05 Aug 2014 21:04:06 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in unmap_page_range
References: <53DD5F20.8010507@oracle.com> <alpine.LSU.2.11.1408040418500.3406@eggly.anvils> <20140805144439.GW10819@suse.de> <alpine.LSU.2.11.1408051649330.6591@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1408051649330.6591@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

Thanks Hugh, Mel. I've added both patches to my local tree and will update tomorrow
with the weather.

Also:

On 08/05/2014 08:42 PM, Hugh Dickins wrote:
> One thing I did wonder, though: at first I was reassured by the
> VM_BUG_ON(!pte_present(pte)) you add to pte_mknuma(); but then thought
> it would be better as VM_BUG_ON(!(val & _PAGE_PRESENT)), being stronger
> - asserting that indeed we do not put NUMA hints on PROT_NONE areas.
> (But I have not tested, perhaps such a VM_BUG_ON would actually fire.)

I've added VM_BUG_ON(!(val & _PAGE_PRESENT)) in just as a curiosity, I'll
update how that one looks as well.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
