Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F20C38D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 19:30:26 -0500 (EST)
Date: Thu, 3 Mar 2011 16:18:26 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: stable: mm: vmstat: use a single setter function and callback
 for adjusting percpu thresholds
Message-ID: <20110304001826.GA2429@kroah.com>
References: <20110303110324.GH14162@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110303110324.GH14162@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, "Nadolski, Edmund" <edmund.nadolski@intel.com>, Greg KH <gregkh@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, stable@kernel.org, linux-mm@kvack.org

On Thu, Mar 03, 2011 at 11:03:24AM +0000, Mel Gorman wrote:
> Edmund Nadolski reported the same problem Kosaki did against the commit
> [88f5acf8: mm: page allocator: adjust the per-cpu counter threshold when
> memory is low] whereby kswapd was in an inconsistent locking state due
> to calling get_online_cpus(): See https://lkml.org/lkml/2011/3/2/398 for
> details. This is already fixed upstream by commit [b44129b3: mm: vmstat: use
> a single setter function and callback for adjusting percpu thresholds]. Unless
> there is an objection, can this be picked up for 2.6.37-stable please?
> Ideally it would apply against 2.6.36.x as well but that release is no
> longer maintained.

Now queued up, thanks.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
