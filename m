Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 143866B0038
	for <linux-mm@kvack.org>; Wed, 28 May 2014 19:24:22 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id r20so4602690wiv.7
        for <linux-mm@kvack.org>; Wed, 28 May 2014 16:24:22 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id eu11si35435598wjc.119.2014.05.28.16.24.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 May 2014 16:24:21 -0700 (PDT)
Message-ID: <53866F8D.6030809@zytor.com>
Date: Wed, 28 May 2014 16:21:49 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
References: <1401260039-18189-1-git-send-email-minchan@kernel.org> <1401260039-18189-2-git-send-email-minchan@kernel.org> <20140528101401.43853563@gandalf.local.home> <f00f9b56-704d-4d03-ad0e-ec3ba2d122fd@email.android.com> <20140528221118.GN8554@dastard> <5386664A.5060304@zytor.com> <20140528231708.GE6677@dastard>
In-Reply-To: <20140528231708.GE6677@dastard>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, rusty@rustcorp.com.au, mst@redhat.com, Dave Hansen <dave.hansen@intel.com>

On 05/28/2014 04:17 PM, Dave Chinner wrote:
>>
>> You were the one calling it a canary.
> 
> That doesn't mean it's to blame. Don't shoot the messenger...
> 

Fair enough.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
