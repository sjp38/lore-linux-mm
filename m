Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A75426B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 10:43:19 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090701103622.85CD.A69D9226@jp.fujitsu.com>
References: <20090701103622.85CD.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0906301011210.6124@gentwo.org> <20090701082531.85C2.A69D9226@jp.fujitsu.com>
Subject: Re: [PATCH v2] Show kernel stack usage to /proc/meminfo and OOM log
Date: Wed, 01 Jul 2009 15:44:18 +0100
Message-ID: <10604.1246459458@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: dhowells@redhat.com, Christoph Lameter <cl@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes,
                         Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> +	int pages = THREAD_SIZE / PAGE_SIZE;

Bad assumption.  On FRV, for example, THREAD_SIZE is 8K and PAGE_SIZE is 16K.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
