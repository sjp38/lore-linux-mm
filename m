Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9834B90015D
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 01:41:29 -0400 (EDT)
Message-ID: <4E018060.3050607@redhat.com>
Date: Wed, 22 Jun 2011 13:40:48 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/4] mm: make the threshold of enabling THP configurable
References: <1308643849-3325-1-git-send-email-amwang@redhat.com> <1308643849-3325-2-git-send-email-amwang@redhat.com> <alpine.DEB.2.00.1106211817340.5205@chino.kir.corp.google.com> <4E015C36.2050005@redhat.com> <alpine.DEB.2.00.1106212024210.8712@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1106212024210.8712@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, dave@linux.vnet.ibm.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??22ae?JPY 11:29, David Rientjes a??e??:
>
> Either way, this patch isn't needed since it has no benefit over doing it
> through an init script.

If you were right, CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not needed,
you can do it through an init script.

If you were right, the 512M limit is not needed neither, you have
transparent_hugepage=never boot parameter and do the check of
512M later in an init script. (Actually, moving the 512M check to
user-space is really more sane to me.)

I am quite sure you have lots of other things which both have a Kconfig
and a boot parameter, why do we have it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
