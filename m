Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 33EB96B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 11:48:46 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in __vm_enough_memory
References: <20111013135032.7c2c54cd.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1110131602020.26553@router.home>
	<20111013142434.4d05cbdc.akpm@linux-foundation.org>
	<20111014122506.GB26737@sgi.com> <20111014135055.GA28592@sgi.com>
	<alpine.DEB.2.00.1110140856420.6411@router.home>
	<20111014141921.GC28592@sgi.com>
	<alpine.DEB.2.00.1110140932530.6411@router.home>
	<alpine.DEB.2.00.1110140958550.6411@router.home>
	<20111014161603.GA30561@sgi.com> <20111018134835.GA16222@sgi.com>
Date: Tue, 18 Oct 2011 08:48:44 -0700
In-Reply-To: <20111018134835.GA16222@sgi.com> (Dimitri Sivanich's message of
	"Tue, 18 Oct 2011 08:48:35 -0500")
Message-ID: <m2mxcyz4f7.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@gentwo.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

Dimitri Sivanich <sivanich@sgi.com> writes:
>
> Would it make sense to have the ZVC delta be tuneable (via /proc/sys/vm?), keeping the
> same default behavior as what we currently have?

Tunable is bad. We don't really want a "hundreds of lines magic shell script to
make large systems perform". Please find a way to auto tune.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
