Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DA16F9000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 19:15:47 -0400 (EDT)
Date: Thu, 22 Sep 2011 16:15:39 -0700
From: Andrew Morton <akpm@google.com>
Subject: Re: [PATCH 7/8] kstaled: add histogram sampling functionality
Message-Id: <20110922161539.d947e014.akpm@google.com>
In-Reply-To: <1316230753-8693-8-git-send-email-walken@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	<1316230753-8693-8-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 16 Sep 2011 20:39:12 -0700
Michel Lespinasse <walken@google.com> wrote:

> add statistics for pages that have been idle for 1,2,5,15,30,60,120 or
> 240 scan intervals into /dev/cgroup/*/memory.idle_page_stats

Why?  What's the use case for this feature?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
