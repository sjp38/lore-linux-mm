Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF6E9000BD
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 23:44:31 -0400 (EDT)
Subject: Re: [PATCH 1/8] page_referenced: replace vm_flags parameter with
 struct pr_info
From: Joe Perches <joe@perches.com>
Date: Fri, 16 Sep 2011 20:44:28 -0700
In-Reply-To: <1316230753-8693-2-git-send-email-walken@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	 <1316230753-8693-2-git-send-email-walken@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1316231069.27917.28.camel@Joe-Laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

On Fri, 2011-09-16 at 20:39 -0700, Michel Lespinasse wrote:
> Introduce struct pr_info, passed into page_referenced() family of functions,

pr_info is a pretty commonly used function/macro.
Perhaps pageref_info instead?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
