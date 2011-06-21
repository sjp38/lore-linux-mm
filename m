Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B37AB90013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:56:07 -0400 (EDT)
Date: Tue, 21 Jun 2011 15:30:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2 1/4] mm: completely disable THP by
 transparent_hugepage=0
Message-ID: <20110621133053.GO20843@redhat.com>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308643849-3325-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Randy Dunlap <rdunlap@xenotime.net>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 21, 2011 at 04:10:42PM +0800, Amerigo Wang wrote:
> Introduce "transparent_hugepage=0" to totally disable THP.
> "transparent_hugepage=never" means setting THP to be partially
> disabled, we need a new way to totally disable it.
> 

I think I already clarified this is not worth it. Removing sysfs
registration is just pointless. If you really want to save ~8k of RAM,
at most you can try to move the init of the khugepaged slots hash and
the kmem_cache_init to the khugepaged deamon start but even that isn't
so useful. Not registering into sysfs is just pointless and it's a
gratuitous loss of a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
