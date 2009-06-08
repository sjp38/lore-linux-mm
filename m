Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 069666B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 09:13:49 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5E35582C4E8
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 10:47:41 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id C8kqgFUhdkNy for <linux-mm@kvack.org>;
	Mon,  8 Jun 2009 10:47:41 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DA9B382C4E9
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 10:47:34 -0400 (EDT)
Date: Mon, 8 Jun 2009 10:32:12 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/3] Do not unconditionally treat zones that fail
 zone_reclaim() as full
In-Reply-To: <1244466090-10711-4-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0906081030280.21954@gentwo.org>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-4-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Ok this patch addresses a bug in zone reclaim introduced by Paul Jackson
in commit 9276b1bc96a132f4068fdee00983c532f43d3a26. Before that commit
zone reclaim would not mark a zone as full if it failed but simply
continue scanning.

Acked-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
