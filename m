Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EBC386B00A0
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:22:11 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id ACF3382C6AF
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:41:26 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id G7fUSNSwfYyf for <linux-mm@kvack.org>;
	Thu, 16 Jul 2009 12:41:26 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D58CA82C753
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:41:04 -0400 (EDT)
Date: Thu, 16 Jul 2009 12:21:34 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mm: count only reclaimable lru pages v2
In-Reply-To: <20090716150901.GA31204@localhost>
Message-ID: <alpine.DEB.1.10.0907161220270.29771@gentwo.org>
References: <20090716133454.GA20550@localhost> <alpine.DEB.1.10.0907160959260.32382@gentwo.org> <20090716142533.GA27165@localhost> <1247754491.6586.23.camel@laptop> <alpine.DEB.1.10.0907161037590.7930@gentwo.org> <4A5F3C70.7010001@redhat.com>
 <20090716150901.GA31204@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Jul 2009, Wu Fengguang wrote:

> /*
>  * The reclaimable count would be mostly accurate.
>  * The less reclaimable pages may be
>  * - mlocked pages, which will be moved to unevictable list when encountered
>  * - mapped pages, which may require several travels to be reclaimed
>  * - dirty pages, which is not "instantly" reclaimable
>  */

ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
