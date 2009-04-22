Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E93226B00F4
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:46:24 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3MHhhaC008836
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 11:43:43 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3MHl7m4074556
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 11:47:07 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3MHl5Zi030155
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 11:47:07 -0600
Subject: Re: [PATCH 18/22] Use allocation flags as an index to the zone
	watermark
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090422171451.GG15367@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	 <1240408407-21848-19-git-send-email-mel@csn.ul.ie>
	 <1240420313.10627.85.camel@nimitz>  <20090422171451.GG15367@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 22 Apr 2009 10:47:03 -0700
Message-Id: <1240422423.10627.96.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-04-22 at 18:14 +0100, Mel Gorman wrote:
> Preference of taste really. When I started a conversion to accessors, it
> changed something recognised to something new that looked uglier to me.
> Only one place cares about the union enough to access is via an array so
> why spread it everywhere.

Personally, I'd say for consistency.  Someone looking at both forms
wouldn't necessarily know that they refer to the same variables unless
they know about the union.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
