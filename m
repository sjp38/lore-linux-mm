Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 283486B0069
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 19:09:00 -0400 (EDT)
Received: by mail-yk0-f179.google.com with SMTP id 200so38139ykr.38
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 16:08:59 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 49si32597735yhq.26.2014.10.14.16.08.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Oct 2014 16:08:59 -0700 (PDT)
Message-ID: <543DACFB.2060405@oracle.com>
Date: Tue, 14 Oct 2014 19:08:43 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: verify compound order when freeing a page
References: <1413317800-25450-1-git-send-email-yuzhao@google.com> <1413317800-25450-2-git-send-email-yuzhao@google.com> <20141014202955.GA2889@psi-dev26.jf.intel.com>
In-Reply-To: <20141014202955.GA2889@psi-dev26.jf.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Cohen <david.a.cohen@linux.intel.com>, Yu Zhao <yuzhao@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/14/2014 04:29 PM, David Cohen wrote:
>> +	VM_BUG_ON(PageTail(page));
>> > +	VM_BUG_ON(PageHead(page) && compound_order(page) != order);
> It may be too severe. AFAIU we're not talking about a fatal error.
> How about VM_WARN_ON()?

VM_BUG_ON() should catch anything which is not "supposed" to happen,
and not just the severe stuff. Unlike BUG_ON, VM_BUG_ON only gets
hit with mm debugging enabled.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
