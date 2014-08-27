Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id B28396B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 14:22:32 -0400 (EDT)
Received: by mail-yh0-f47.google.com with SMTP id f10so642562yha.6
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 11:22:32 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a9si1394567yhb.17.2014.08.27.11.22.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 11:22:32 -0700 (PDT)
Message-ID: <53FE21A8.4000908@oracle.com>
Date: Wed, 27 Aug 2014 14:21:28 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in unmap_page_range
References: <53DD5F20.8010507@oracle.com> <alpine.LSU.2.11.1408040418500.3406@eggly.anvils> <20140805144439.GW10819@suse.de> <alpine.LSU.2.11.1408051649330.6591@eggly.anvils> <53E17F06.30401@oracle.com> <53E989FB.5000904@oracle.com> <53FD4D9F.6050500@oracle.com> <20140827152622.GC12424@suse.de>
In-Reply-To: <20140827152622.GC12424@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On 08/27/2014 11:26 AM, Mel Gorman wrote:
> Sasha, how long does it typically take to trigger this? Are you
> using any particular switches for trinity that would trigger the bug
> faster?

It took couple of weeks (I've been running with it since the beginning
of August). I don't have any special trinity options, just the default
fuzzing. Do you think that focusing on any of the mm syscalls would
increase the odds of hitting it?

There's always the chance that this is a fluke due to corruption somewhere
else. I'll keep running it with the new debug patch and if it won't reproduce
any time soon we can probably safely assume that.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
