Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E96A36B013A
	for <linux-mm@kvack.org>; Wed, 13 May 2009 19:01:54 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n4DN1qaD008836
	for <linux-mm@kvack.org>; Thu, 14 May 2009 00:01:52 +0100
Received: from wa-out-1112.google.com (wafl35.prod.google.com [10.114.188.35])
	by zps37.corp.google.com with ESMTP id n4DN1nnw008158
	for <linux-mm@kvack.org>; Wed, 13 May 2009 16:01:50 -0700
Received: by wa-out-1112.google.com with SMTP id l35so331817waf.24
        for <linux-mm@kvack.org>; Wed, 13 May 2009 16:01:49 -0700 (PDT)
Date: Wed, 13 May 2009 16:01:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/6] mm, PM/Freezer: Disable OOM killer when tasks are
 frozen
In-Reply-To: <20090513154726.0786a27d.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.0905131558010.26966@chino.kir.corp.google.com>
References: <200905070040.08561.rjw@sisk.pl> <200905101548.57557.rjw@sisk.pl> <200905131032.53624.rjw@sisk.pl> <200905131037.50011.rjw@sisk.pl> <alpine.DEB.2.00.0905131534530.25680@chino.kir.corp.google.com>
 <20090513154726.0786a27d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: rjw@sisk.pl, linux-pm@lists.linux-foundation.org, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, pavel@ucw.cz, nigel@tuxonice.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009, Andrew Morton wrote:

> > This allows __GFP_NOFAIL allocations to fail.
> 
> I think that's OK - oom_killer_disable() and __GFP_NOFAIL are
> fundamentally incompatible, and __GFP_NOFAIL is a crock.
> 

Ok, so we need some documentation of that or some notification that we're 
allowing an allocation to fail that has been specified to "retry 
infinitely [because] the caller cannot handle allocation failures."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
