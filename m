Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E258A6B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 23:29:37 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so11873619pdj.12
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 20:29:37 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id wh5si6542118pab.120.2014.08.11.20.29.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 20:29:36 -0700 (PDT)
Message-ID: <53E989FB.5000904@oracle.com>
Date: Mon, 11 Aug 2014 23:28:59 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in unmap_page_range
References: <53DD5F20.8010507@oracle.com> <alpine.LSU.2.11.1408040418500.3406@eggly.anvils> <20140805144439.GW10819@suse.de> <alpine.LSU.2.11.1408051649330.6591@eggly.anvils> <53E17F06.30401@oracle.com>
In-Reply-To: <53E17F06.30401@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On 08/05/2014 09:04 PM, Sasha Levin wrote:
> Thanks Hugh, Mel. I've added both patches to my local tree and will update tomorrow
> with the weather.
> 
> Also:
> 
> On 08/05/2014 08:42 PM, Hugh Dickins wrote:
>> One thing I did wonder, though: at first I was reassured by the
>> VM_BUG_ON(!pte_present(pte)) you add to pte_mknuma(); but then thought
>> it would be better as VM_BUG_ON(!(val & _PAGE_PRESENT)), being stronger
>> - asserting that indeed we do not put NUMA hints on PROT_NONE areas.
>> (But I have not tested, perhaps such a VM_BUG_ON would actually fire.)
> 
> I've added VM_BUG_ON(!(val & _PAGE_PRESENT)) in just as a curiosity, I'll
> update how that one looks as well.

Sorry for the rather long delay.

The patch looks fine, the issue didn't reproduce.

The added VM_BUG_ON didn't trigger either, so maybe we should consider adding
it in.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
