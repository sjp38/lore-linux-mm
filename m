Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 808E86B0055
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 14:47:37 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 87F0A82C501
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 15:05:22 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id by064WIGGAYn for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 15:05:22 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4017B82C507
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 15:05:16 -0400 (EDT)
Date: Wed, 17 Jun 2009 14:48:36 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 0/3] Fix malloc() stall in zone_reclaim() and bring
 behaviour more in line with expectations V3
In-Reply-To: <20090617190204.99C6.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0906171447510.30060@gentwo.org>
References: <20090616134423.GD14241@csn.ul.ie> <alpine.DEB.1.10.0906161049180.26093@gentwo.org> <20090617190204.99C6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, fengguang.wu@intel.com, linuxram@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jun 2009, KOSAKI Motohiro wrote:

> hm, At least major two zone reclaim developer disagree my patch. Thus I have to
> agree with you, because I really don't hope to ignore other developer's opnion.
>
> So, as far as I understand, the conclusion of this thread are
>   - Drop my patch
>   - instead, implement improvement patch of (may_unmap && page_mapped()) case
>   - the documentation should be changed
>   - it's my homework(?)
>
> Can you agree this?

As far as I understand you: Yes. Unmapping can occur in more advanced zone
reclaim modes but the default needs to be as lightweight as possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
