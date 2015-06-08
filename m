Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2AEE66B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 13:59:35 -0400 (EDT)
Received: by iesa3 with SMTP id a3so103532791ies.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 10:59:34 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id k25si2582069iod.103.2015.06.08.10.59.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 10:59:34 -0700 (PDT)
Received: by iesa3 with SMTP id a3so103532635ies.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 10:59:34 -0700 (PDT)
Date: Mon, 8 Jun 2015 10:59:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: split out forced OOM killer
In-Reply-To: <557187F9.8020301@gmail.com>
Message-ID: <alpine.DEB.2.10.1506081059200.10521@chino.kir.corp.google.com>
References: <1433235187-32673-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.10.1506041557070.16555@chino.kir.corp.google.com> <557187F9.8020301@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 5 Jun 2015, Austin S Hemmelgarn wrote:

> > I'm not sure what the benefit of this is, and it's adding more code.
> > Having multiple pathways and requirements, such as constrained_alloc(), to
> > oom kill a process isn't any clearer, in my opinion.  It also isn't
> > intended to be optimized since the oom killer called from the page
> > allocator and from sysrq aren't fastpaths.  To me, this seems like only a
> > source code level change and doesn't make anything more clear but rather
> > adds more code and obfuscates the entry path.
> 
> At the very least, it does make the semantics of sysrq-f much nicer for admins
> (especially the bit where it ignores the panic_on_oom setting, if the admin
> wants the system to panic, he'll use sysrq-c).  There have been times I've had
> to hit sysrq-f multiple times to get to actually kill anything, and this looks
> to me like it would eliminate that rather annoying issue as well.
> 

Are you saying there's a functional change with this patch/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
