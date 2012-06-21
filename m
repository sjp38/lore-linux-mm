Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 48A446B004D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 21:25:11 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1757648pbb.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 18:25:10 -0700 (PDT)
Date: Wed, 20 Jun 2012 18:25:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH RESEND 1/2] mm/compaction: cleanup on
 compaction_deferred
In-Reply-To: <1340156348-18875-1-git-send-email-shangw@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1206201824550.3702@chino.kir.corp.google.com>
References: <1340156348-18875-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, minchan@kernel.org, akpm@linux-foundation.org

On Wed, 20 Jun 2012, Gavin Shan wrote:

> When CONFIG_COMPACTION is enabled, compaction_deferred() tries
> to recalculate the deferred limit again, which isn't necessary.
> 
> When CONFIG_COMPACTION is disabled, compaction_deferred() should
> return "true" or "false" since it has "bool" for its return value.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
