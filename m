Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id E71C96B0099
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 16:32:20 -0400 (EDT)
Received: by mail-da0-f51.google.com with SMTP id g27so2047691dan.24
        for <linux-mm@kvack.org>; Mon, 29 Apr 2013 13:32:20 -0700 (PDT)
Date: Mon, 29 Apr 2013 13:32:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Add a sysctl for numa_balancing.
In-Reply-To: <20130429084113.GI2144@suse.de>
Message-ID: <alpine.DEB.2.02.1304291331570.31525@chino.kir.corp.google.com>
References: <1366847784-29386-1-git-send-email-andi@firstfloor.org> <20130429084113.GI2144@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On Mon, 29 Apr 2013, Mel Gorman wrote:

> On Wed, Apr 24, 2013 at 04:56:24PM -0700, Andi Kleen wrote:
> > From: Andi Kleen <ak@linux.intel.com>
> > 
> > As discussed earlier, this adds a working sysctl to enable/disable
> > automatic numa memory balancing at runtime.
> > 
> > This was possible earlier through debugfs, but only with special
> > debugging options set. Also fix the boot message.
> > 
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> 

Acked-by: David Rientjes <rientjes@google.com>

> Would you like to merge the following patch with it to remove the TBD?
> 
> ---8<---
> mm: numa: Document remaining automatic NUMA balancing sysctls
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
