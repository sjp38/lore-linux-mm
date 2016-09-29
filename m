Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B58E28024D
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 04:02:13 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 124so38509304itl.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 01:02:13 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id b140si14944015ioe.61.2016.09.29.01.01.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 01:01:37 -0700 (PDT)
Date: Thu, 29 Sep 2016 10:01:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160929080130.GJ3318@worktop.controleur.wifipass.org>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927073055.GM2794@worktop>
 <20160927085412.GD2838@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160927085412.GD2838@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, Sep 27, 2016 at 09:54:12AM +0100, Mel Gorman wrote:
> On Tue, Sep 27, 2016 at 09:30:55AM +0200, Peter Zijlstra wrote:
> Simple is relative unless I drastically overcomplicated things and it
> wouldn't be the first time. 64-bit only side-steps the page flag issue
> as long as we can live with that.

So one problem with the 64bit only pageflags is that they do eat space
from page-flags-layout, we do try and fit a bunch of other crap in
there, and at some point that all will not fit anymore and we'll revert
to worse.

I've no idea how far away from that we are for distro kernels. I suppose
they have fairly large NR_NODES and NR_CPUS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
