Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D85C290013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 16:17:33 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5LK4Vc9000572
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 14:04:31 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5LKHAZR330532
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 14:17:13 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5LEH83f032604
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 08:17:08 -0600
Subject: Re: [PATCH v2 2/4] mm: make the threshold of enabling THP
 configurable
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1308667461.11430.315.camel@nimitz>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com>
	 <1308643849-3325-2-git-send-email-amwang@redhat.com>
	 <1308667461.11430.315.camel@nimitz>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Jun 2011 13:17:00 -0700
Message-ID: <1308687420.11430.330.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

Urg.  Pasted the wrong thing.  Should be:

Acked-by: Dave Hansen <dave@linux.vnet.ibm.com> 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
