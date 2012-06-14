Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 02C016B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:50:39 -0400 (EDT)
Date: Thu, 14 Jun 2012 10:50:35 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/compaction: cleanup on compaction_deferred
Message-ID: <20120614085034.GO1761@cmpxchg.org>
References: <1339636753-12519-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339636753-12519-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

On Thu, Jun 14, 2012 at 09:19:13AM +0800, Gavin Shan wrote:
> When CONFIG_COMPACTION is enabled, compaction_deferred() tries
> to recalculate the deferred limit again, which isn't necessary.
> 
> When CONFIG_COMPACTION is disabled, compaction_deferred() should
> return "true" or "false" since it has "bool" for its return value.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
