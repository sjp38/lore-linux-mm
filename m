Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 053778D0001
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:16:44 -0400 (EDT)
Date: Mon, 25 Oct 2010 21:16:39 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [BUGFIX][PATCH] fix is_mem_section_removable() page_order
 BUG_ON check.
Message-ID: <20101025131639.GA19697@localhost>
References: <20101025153726.2ae9baec.kamezawa.hiroyu@jp.fujitsu.com>
 <20101025074933.GB5452@localhost>
 <20101025131025.GA18570@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101025131025.GA18570@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> I guess this is not necessary as all page_order callers check PageBuddy
> anyway AFAICS.

Sure -- otherwise the VM_BUG_ON() will already go bang :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
