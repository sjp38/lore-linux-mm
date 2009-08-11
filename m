Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CF7ED6B004D
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 13:42:24 -0400 (EDT)
Date: Tue, 11 Aug 2009 11:39:52 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 5/6] tracing, documentation: Add a document describing
 how to do some performance analysis with tracepoints
Message-ID: <20090811113952.362d1f7d@bike.lwn.net>
In-Reply-To: <20090811113139.20bc276e@bike.lwn.net>
References: <1249918915-16061-1-git-send-email-mel@csn.ul.ie>
	<1249918915-16061-6-git-send-email-mel@csn.ul.ie>
	<20090811113139.20bc276e@bike.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Jonathan Corbet <corbet@lwn.net>
Cc: Mel Gorman <mel@csn.ul.ie>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, Li Ming Chun <macli@brc.ubc.ca>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Aug 2009 11:31:39 -0600
Jonathan Corbet <corbet@lwn.net> wrote:

> > +Documentation/trace/postprocess/trace-pagealloc-postprocess.pl is an example  
> 
> I don't have that file in current git...?

Duh, obviously, that's added by part 4 of the series.  Please ignore
this bit of noise, sorry.

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
