Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 6CAB76B0062
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 16:08:42 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so7056336vcb.14
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 13:08:41 -0800 (PST)
Date: Tue, 6 Dec 2011 13:08:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] slub: remove unnecessary statistics,
 deactivate_to_head/tail
In-Reply-To: <1322814189-17318-2-git-send-email-alex.shi@intel.com>
Message-ID: <alpine.DEB.2.00.1112061306510.28251@chino.kir.corp.google.com>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com> <1322814189-17318-2-git-send-email-alex.shi@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: cl@linux.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2 Dec 2011, Alex Shi wrote:

> From: Alex Shi <alexs@intel.com>
> 
> Since the head or tail were automaticly decided in add_partial(),
> we didn't need this statistics again.
> 

Umm, we shouldn't need to remove these statistics at all: if there is 
logic in add_partial() to determine whether to add it to the head or tail, 
the stats can still be incremented there appropriately.  It would actually 
be helpful to cite those stats for your netperf benchmarking when 
determining whether patches should be merged or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
