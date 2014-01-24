Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6D26B6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:44:41 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id a1so3094857wgh.4
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 07:44:40 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k10si1629328wiw.87.2014.01.24.07.44.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 07:44:40 -0800 (PST)
Date: Fri, 24 Jan 2014 15:44:38 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 9/9] numa,sched: define some magic numbers
Message-ID: <20140124154438.GC4963@suse.de>
References: <1390342811-11769-1-git-send-email-riel@redhat.com>
 <1390342811-11769-10-git-send-email-riel@redhat.com>
 <20140121185826.26247d89@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140121185826.26247d89@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Tue, Jan 21, 2014 at 06:58:26PM -0500, Rik van Riel wrote:
> On Tue, 21 Jan 2014 17:20:11 -0500
> riel@redhat.com wrote:
> 
> > From: Rik van Riel <riel@redhat.com>
> > 
> > Cleanup suggested by Mel Gorman. Now the code contains some more
> > hints on what statistics go where.
> > 
> > Suggested-by: Mel Gorman <mgorman@suse.de>
> > Signed-off-by: Rik van Riel <riel@redhat.com>
> 
> ... and patch fatigue hit, causing me to mess up this simple
> patch with no functional changes (which is why I did not test
> it yet).
> 
> Here is one that compiles.
> 
> ---8<---
> 
> Subject: numa,sched: define some magic numbers
> 
> Cleanup suggested by Mel Gorman. Now the code contains some more
> hints on what statistics go where.
> 
> Suggested-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
