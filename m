Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 43A5D6B0039
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:25:20 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id uq10so3072767igb.4
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 07:25:20 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id uh2si2062107igc.34.2014.09.10.07.25.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 07:25:19 -0700 (PDT)
Message-ID: <54105F28.1000506@oracle.com>
Date: Wed, 10 Sep 2014 10:24:40 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Trinity and mbind flags (WAS: Re: mm: BUG in unmap_page_range)
References: <53E989FB.5000904@oracle.com> <53FD4D9F.6050500@oracle.com> <20140827152622.GC12424@suse.de> <540127AC.4040804@oracle.com> <54082B25.9090600@oracle.com> <20140908171853.GN17501@suse.de> <540DEDE7.4020300@oracle.com> <20140909213309.GQ17501@suse.de> <540F7D42.1020402@oracle.com> <alpine.LSU.2.11.1409091903390.10989@eggly.anvils> <20140910124732.GT17501@suse.de>
In-Reply-To: <20140910124732.GT17501@suse.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On 09/10/2014 08:47 AM, Mel Gorman wrote:
> That site should have checked PROT_NONE but it can't be the same bug
> that trinity is seeing. Minimally trinity is unaware of MPOL_MF_LAZY
> according to git grep of the trinity source.

Actually, if I'm reading it correctly I think that Trinity handles mbind()
calls wrong. It passes the wrong values for mode flags and actual flags.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
