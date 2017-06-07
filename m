Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 221516B0338
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 16:56:04 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t126so8524584pgc.9
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 13:56:04 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y1sor2262906pli.2.2017.06.07.13.56.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Jun 2017 13:56:03 -0700 (PDT)
Date: Wed, 7 Jun 2017 13:56:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Sleeping BUG in khugepaged for i586
In-Reply-To: <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
Message-ID: <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net> <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org> <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz> <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net>
 <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 7 Jun 2017, Vlastimil Babka wrote:

> >> Hmm I'd expect such spin lock to be reported together with mmap_sem in
> >> the debugging "locks held" message?
> > 
> > My bisection of the problem is about half done. My latest good version is commit 
> > 7b8cd33 and the latest bad one is 2ea659a. Only about 7 steps to go.
> 
> Hmm, your bisection will most likely just find commit 338a16ba15495
> which added the cond_resched() at mm/khugepaged.c:655. CCing David who
> added it.
> 

I agree it's probably going to bisect to 338a16ba15495 since it's the 
cond_resched() at the line number reported, but I think there must be 
something else going on.  I think the list of locks held by khugepaged is 
correct because it matches with the implementation.  The preempt_count(), 
as suggested by Andrew, does not.  If this is reproducible, I'd like to 
know what preempt_count() is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
