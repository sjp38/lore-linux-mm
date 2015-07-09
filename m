Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9A66B0254
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 04:56:07 -0400 (EDT)
Received: by wgck11 with SMTP id k11so217481147wgc.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 01:56:07 -0700 (PDT)
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id eb5si7975711wic.46.2015.07.09.01.56.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 01:56:06 -0700 (PDT)
Received: by wgxm20 with SMTP id m20so33981394wgx.3
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 01:56:05 -0700 (PDT)
Date: Thu, 9 Jul 2015 10:56:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm, oom: organize oom context into struct
Message-ID: <20150709085602.GC13872@dhcp22.suse.cz>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com>
 <1436360661-31928-4-git-send-email-mhocko@suse.com>
 <alpine.DEB.2.10.1507081637540.16585@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507081637540.16585@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 08-07-15 16:38:25, David Rientjes wrote:
> On Wed, 8 Jul 2015, Michal Hocko wrote:
> 
> > From: David Rientjes <rientjes@google.com>
> > 
> > There are essential elements to an oom context that are passed around to
> > multiple functions.
> > 
> > Organize these elements into a new struct, struct oom_context, that
> > specifies the context for an oom condition.
> > 
> > This patch introduces no functional change.
> > 
> > [mhocko@suse.cz: s@oom_control@oom_context@]
> > [mhocko@suse.cz: do not initialize on stack oom_context with NULL or 0]
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> I hate to appear to be nacking my own patch, but it was correct when 
> included in my series

What is incorrect in this patch?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
