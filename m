Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7066B0253
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 19:38:27 -0400 (EDT)
Received: by ieru20 with SMTP id u20so22835118ier.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:38:27 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id th17si3995988icb.46.2015.07.08.16.38.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 16:38:26 -0700 (PDT)
Received: by igrv9 with SMTP id v9so180322879igr.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:38:26 -0700 (PDT)
Date: Wed, 8 Jul 2015 16:38:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] mm, oom: organize oom context into struct
In-Reply-To: <1436360661-31928-4-git-send-email-mhocko@suse.com>
Message-ID: <alpine.DEB.2.10.1507081637540.16585@chino.kir.corp.google.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com> <1436360661-31928-4-git-send-email-mhocko@suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Wed, 8 Jul 2015, Michal Hocko wrote:

> From: David Rientjes <rientjes@google.com>
> 
> There are essential elements to an oom context that are passed around to
> multiple functions.
> 
> Organize these elements into a new struct, struct oom_context, that
> specifies the context for an oom condition.
> 
> This patch introduces no functional change.
> 
> [mhocko@suse.cz: s@oom_control@oom_context@]
> [mhocko@suse.cz: do not initialize on stack oom_context with NULL or 0]
> Signed-off-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

I hate to appear to be nacking my own patch, but it was correct when 
included in my series and should be merged as part of the larger cleanup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
