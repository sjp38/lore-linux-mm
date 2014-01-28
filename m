Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f48.google.com (mail-bk0-f48.google.com [209.85.214.48])
	by kanga.kvack.org (Postfix) with ESMTP id C40056B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 19:13:16 -0500 (EST)
Received: by mail-bk0-f48.google.com with SMTP id ej10so18433bkb.7
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 16:13:16 -0800 (PST)
Received: from mail-vb0-x22d.google.com (mail-vb0-x22d.google.com [2607:f8b0:400c:c02::22d])
        by mx.google.com with ESMTPS id nm6si15882852bkb.306.2014.01.27.16.13.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 16:13:15 -0800 (PST)
Received: by mail-vb0-f45.google.com with SMTP id m10so3872888vbh.18
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 16:13:14 -0800 (PST)
Date: Mon, 27 Jan 2014 16:13:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.14] mm, mempolicy: fix mempolicy printing in
 numa_maps
In-Reply-To: <20140127130914.GI4963@suse.de>
Message-ID: <alpine.DEB.2.02.1401271610230.17114@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1401251902180.3140@chino.kir.corp.google.com> <20140127105011.GB11314@laptop.programming.kicks-ass.net> <20140127130914.GI4963@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 27 Jan 2014, Mel Gorman wrote:

> > Should we also consider printing the MOF and MORON states so we get a
> > better view of what the actual policy is?
> > 
> 
> MOF and MORON are separate issues because MOF is exposed to the userspace
> API but not the policies that make up MORON. For MORON, I concluded that
> we should not expose that via numa_maps unless it can be controlled from
> userspace.
> 

We print the possible flags for set_mempolicy() which is pretty simple 
since there's only one possible flag at any given time, but we don't print 
any possible flags for mbind().  If we are to start printing lazy 
migrate-on-fault then we should probably print the other flags as well, I 
just don't know how long we want lines in numa_maps to be.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
