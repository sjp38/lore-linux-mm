Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5494F6B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 17:38:27 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id x3so1796970qcv.2
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 14:38:27 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g66si6598389yhc.18.2014.09.17.14.38.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 14:38:26 -0700 (PDT)
Message-ID: <5419FF2F.4000705@oracle.com>
Date: Wed, 17 Sep 2014 17:37:51 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in unmap_page_range
References: <54082B25.9090600@oracle.com> <20140908171853.GN17501@suse.de> <540DEDE7.4020300@oracle.com> <20140909213309.GQ17501@suse.de> <540F7D42.1020402@oracle.com> <alpine.LSU.2.11.1409091903390.10989@eggly.anvils> <20140910124732.GT17501@suse.de> <alpine.LSU.2.11.1409101210520.1744@eggly.anvils> <54110C62.4030702@oracle.com> <alpine.LSU.2.11.1409110356280.2116@eggly.anvils> <20140911162827.GZ17501@suse.de> <5412246E.109@oracle.com>
In-Reply-To: <5412246E.109@oracle.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On 09/11/2014 06:38 PM, Sasha Levin wrote:
> On 09/11/2014 12:28 PM, Mel Gorman wrote:
>> > Agreed. If 3.17-rc4 looks stable with the VM_BUG_ON then it would be
>> > really nice if you could bisect 3.17-rc4 to linux-next carrying the
>> > VM_BUG_ON(!(val & _PAGE_PRESENT)) check at each bisection point. I'm not
>> > 100% sure if I'm seeing the same corruption as you or some other issue and
>> > do not want to conflate numerous different problems into one. I know this
>> > is a pain in the ass but if 3.17-rc4 looks stable then a bisection might
>> > be faster overall than my constant head scratching :(
> The good news are that 3.17-rc4 seems to be stable. I'll start the bisection,
> which I suspect would take several days. I'll update when I run into something.

I might need a bit of a help here. The bisection is going sideways because I
can't reliably reproduce the issue.

We don't know what's causing this issue, but we know what the symptoms are. Is
there a VM_BUG_ON we could add somewhere so that it would be more likely to
trigger?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
