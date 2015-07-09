Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id C944E6B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 17:09:15 -0400 (EDT)
Received: by ietj16 with SMTP id j16so11740104iet.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 14:09:15 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id s13si804201ign.70.2015.07.09.14.09.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 14:09:15 -0700 (PDT)
Received: by iggp10 with SMTP id p10so22802219igg.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 14:09:15 -0700 (PDT)
Date: Thu, 9 Jul 2015 14:09:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] mm, oom: organize oom context into struct
In-Reply-To: <20150709085602.GC13872@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1507091407530.17177@chino.kir.corp.google.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com> <1436360661-31928-4-git-send-email-mhocko@suse.com> <alpine.DEB.2.10.1507081637540.16585@chino.kir.corp.google.com> <20150709085602.GC13872@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 9 Jul 2015, Michal Hocko wrote:

> > > From: David Rientjes <rientjes@google.com>
> > > 
> > > There are essential elements to an oom context that are passed around to
> > > multiple functions.
> > > 
> > > Organize these elements into a new struct, struct oom_context, that
> > > specifies the context for an oom condition.
> > > 
> > > This patch introduces no functional change.
> > > 
> > > [mhocko@suse.cz: s@oom_control@oom_context@]
> > > [mhocko@suse.cz: do not initialize on stack oom_context with NULL or 0]
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > 
> > I hate to appear to be nacking my own patch, but it was correct when 
> > included in my series
> 
> What is incorrect in this patch?

Nothing, the statement is quite clear that it is also correct in my series 
which is much cleaner, reduces stack usage, removes more lines of code 
than yours, and organizes the oom killer code to avoid passing so many 
formals which should have been done long ago.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
