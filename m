Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id C0AD66B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 12:36:13 -0400 (EDT)
Received: by wijp15 with SMTP id p15so55778308wij.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 09:36:13 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id pu2si6634302wjc.109.2015.08.05.09.36.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 09:36:12 -0700 (PDT)
Date: Wed, 5 Aug 2015 18:36:09 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
Message-ID: <20150805163609.GE25159@twins.programming.kicks-ass.net>
References: <55C18D2E.4030009@rjmx.net>
 <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org>
 <20150805162436.GD25159@twins.programming.kicks-ass.net>
 <alpine.DEB.2.11.1508051131580.29823@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1508051131580.29823@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Ron Murray <rjmx@rjmx.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>

On Wed, Aug 05, 2015 at 11:32:31AM -0500, Christoph Lameter wrote:
> On Wed, 5 Aug 2015, Peter Zijlstra wrote:
> 
> > I'll go have a look; but the obvious question is, what's the last known
> > good kernel?
> 
> 4.0.9 according to the original report.

Weird, there have been no changes to this area in v4.0..v4.1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
