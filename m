Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 780A36B004D
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:16:21 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4A57682C31A
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:34:31 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 3qZVOgC8pfM2 for <linux-mm@kvack.org>;
	Wed,  1 Jul 2009 13:34:31 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E9F5F82C595
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:34:22 -0400 (EDT)
Date: Wed, 1 Jul 2009 13:16:27 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH v2] Show kernel stack usage to /proc/meminfo and OOM
 log
In-Reply-To: <10604.1246459458@redhat.com>
Message-ID: <alpine.DEB.1.10.0907011315540.9522@gentwo.org>
References: <20090701103622.85CD.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0906301011210.6124@gentwo.org> <20090701082531.85C2.A69D9226@jp.fujitsu.com> <10604.1246459458@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes,                         Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Jul 2009, David Howells wrote:

> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>
> > +	int pages = THREAD_SIZE / PAGE_SIZE;
>
> Bad assumption.  On FRV, for example, THREAD_SIZE is 8K and PAGE_SIZE is 16K.

Guess that means we need arch specific accounting for this counter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
