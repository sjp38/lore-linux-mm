Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 84B856B0038
	for <linux-mm@kvack.org>; Thu, 29 May 2014 09:24:46 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id pv20so189777lab.13
        for <linux-mm@kvack.org>; Thu, 29 May 2014 06:24:45 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id q6si1005261lag.91.2014.05.29.06.24.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 May 2014 06:24:44 -0700 (PDT)
Date: Thu, 29 May 2014 14:23:21 +0100
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140529142321.6ac951d3@alan.etchedpixels.co.uk>
In-Reply-To: <20140528092717.GA17220@pd.tnic>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<20140528092717.GA17220@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, rusty@rustcorp.com.au, mst@redhat.com, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

> Hmm, stupid question: what happens when 16K is not enough too, do we
> increase again? When do we stop increasing? 1M, 2M... ?

It's not a stupid question, it's IMHO the most important question

> Sounds like we want to make it a config option with a couple of sizes
> for everyone to be happy. :-)

At the moment it goes bang if you freakily get three layers of recursion
through allocations. But show me the proof we can't already hit four, or
five, or six  ....

We don't *need* to allocate tons of stack memory to each task just because
we might recursively allocate. We don't solve the problem by doing so
either. We at best fudge over it.

Why is *any* recursive memory allocation not ending up waiting for other
kernel worker threads to free up memory (beyond it being rather hard to
go and retrofit) ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
