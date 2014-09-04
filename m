Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A2A1D6B0035
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 05:05:35 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id rd3so19816795pab.10
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 02:05:32 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y1si2411229pdd.94.2014.09.04.02.05.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 02:05:31 -0700 (PDT)
Message-ID: <54082B25.9090600@oracle.com>
Date: Thu, 04 Sep 2014 05:04:37 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in unmap_page_range
References: <53DD5F20.8010507@oracle.com> <alpine.LSU.2.11.1408040418500.3406@eggly.anvils> <20140805144439.GW10819@suse.de> <alpine.LSU.2.11.1408051649330.6591@eggly.anvils> <53E17F06.30401@oracle.com> <53E989FB.5000904@oracle.com> <53FD4D9F.6050500@oracle.com> <20140827152622.GC12424@suse.de> <540127AC.4040804@oracle.com>
In-Reply-To: <540127AC.4040804@oracle.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On 08/29/2014 09:23 PM, Sasha Levin wrote:
> On 08/27/2014 11:26 AM, Mel Gorman wrote:
>> > diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
>> > index 281870f..ffea570 100644
>> > --- a/include/asm-generic/pgtable.h
>> > +++ b/include/asm-generic/pgtable.h
>> > @@ -723,6 +723,9 @@ static inline pte_t pte_mknuma(pte_t pte)
>> >  
>> >  	VM_BUG_ON(!(val & _PAGE_PRESENT));
>> >  
>> > +	/* debugging only, specific to x86 */
>> > +	VM_BUG_ON(val & _PAGE_PROTNONE);
>> > +
>> >  	val &= ~_PAGE_PRESENT;
>> >  	val |= _PAGE_NUMA;
> Triggered again, the first VM_BUG_ON got hit, the second one never did.

Okay, this bug has reproduced quite a few times since then that I no longer
suspect it's random memory corruption. I'd be happy to try out more debug
patches if you have any leads.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
