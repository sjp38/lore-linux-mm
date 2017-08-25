Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4446810C8
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 13:46:16 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id b76so5238120itb.0
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 10:46:16 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id v66si6649384iov.15.2017.08.25.10.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 10:46:14 -0700 (PDT)
Date: Fri, 25 Aug 2017 12:46:12 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2 v2] sched/wait: Break up long wake list walk
In-Reply-To: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1708251243270.6323@nuc-kabylake>
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 25 Aug 2017, Tim Chen wrote:

> for a long time.  It is a result of the numa balancing migration of hot
> pages that are shared by many threads.

I think that would also call for some work to limit numa balacing of hot
shared pages. The cache lines of hot pages are likely in present the low
level processor caches anyways so moving them would not cause a
performance benefit. Limiting the migration there could stop wasting a lot
of effort.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
