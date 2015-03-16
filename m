Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0CF6B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 11:39:46 -0400 (EDT)
Received: by qgez64 with SMTP id z64so43455831qge.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 08:39:45 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id 6si10263021qkx.10.2015.03.16.08.39.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 16 Mar 2015 08:39:44 -0700 (PDT)
Date: Mon, 16 Mar 2015 10:39:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH V5] Allow compaction of unevictable pages
In-Reply-To: <alpine.DEB.2.10.1503131613560.7827@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1503161036160.32513@gentwo.org>
References: <1426267597-25811-1-git-send-email-emunson@akamai.com> <550332CE.7040404@redhat.com> <20150313190915.GA12589@akamai.com> <alpine.DEB.2.10.1503131613560.7827@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Eric B Munson <emunson@akamai.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 13 Mar 2015, David Rientjes wrote:

> It would be really disappointing to not enable this by default for !rt
> kernels.  We haven't migrated mlocked pages in the past by way of memory
> compaction because it can theoretically result in consistent minor page
> faults, but I haven't yet heard a !rt objection to enabling this.
>
> If the rt patchset is going to carry a patch to disable this, then the
> question arises: why not just carry an ISOLATE_UNEVICTABLE patch instead?
> I think you've done the due diligence required to allow this to be
> disabled at any time in a very easy way from userspace by the new tunable.
> I think it should be enabled and I'd be very surprised to hear any other
> objection about it other than it's different from the status quo.

Compaction can alrady be disabled and thus you can also disable migration
of mlocked pages. In general low latency requires that no expensive kernel
processing is being done. Thus the rest of compaction processing also
needs to be disabled. That means that allowing compaction handling
mlocked pages would be ok. RT loads and low latency configurations (like
my environment) will selective disable compaction to avoid creating
additional latencies. This could be done only for specific nodes and
processors if necessary.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
