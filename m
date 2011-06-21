Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC58E6B014E
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 10:44:34 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5LENuIp020334
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 10:23:56 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5LEiU8B118614
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 10:44:30 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5LEiTF2005820
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 11:44:30 -0300
Subject: Re: [PATCH v2 2/4] mm: make the threshold of enabling THP
 configurable
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1308643849-3325-2-git-send-email-amwang@redhat.com>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com>
	 <1308643849-3325-2-git-send-email-amwang@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Jun 2011 07:44:21 -0700
Message-ID: <1308667461.11430.315.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, 2011-06-21 at 16:10 +0800, Amerigo Wang wrote:
> Don't hard-code 512M as the threshold in kernel, make it configruable,
> and set 512M by default.
> 
> And print info when THP is disabled automatically on small systems.
> 
> V2: Add more description in help messages, correct some typos,
> print the mini threshold too.

This seems sane to me.  The printk probably could probably stand by
itself, btw.  But, this is a small enough patch that it's fine.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
