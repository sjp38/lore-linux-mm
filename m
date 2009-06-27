Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 813046B004D
	for <linux-mm@kvack.org>; Sat, 27 Jun 2009 14:34:45 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090627125412.GA1667@cmpxchg.org>
References: <20090627125412.GA1667@cmpxchg.org> <3901.1245848839@redhat.com> <20090624023251.GA16483@localhost> <20090620043303.GA19855@localhost> <32411.1245336412@redhat.com> <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com> <20090618095729.d2f27896.akpm@linux-foundation.org> <7561.1245768237@redhat.com> <26537.1246086769@redhat.com> 
Subject: Re: Found the commit that causes the OOMs
Date: Sat, 27 Jun 2009 19:35:26 +0100
Message-ID: <28486.1246127726@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: dhowells@redhat.com, Wu Fengguang <fengguang.wu@intel.com>, "riel@redhat.com" <riel@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> wrote:

> This is from your OOM-run dmesg, David:
> 
>   Adding 32k swap on swapfile22.  Priority:-21 extents:1 across:32k
>   Adding 32k swap on swapfile23.  Priority:-22 extents:1 across:32k
>   Adding 32k swap on swapfile24.  Priority:-23 extents:3 across:44k
>   Adding 32k swap on swapfile25.  Priority:-24 extents:1 across:32k
> 
> So we actually have swap?  Or are those removed again before the OOM?

That's merely a transient situation caused by the LTP swapfile tests.
Ordinarily, my test machine does not have swap.  At the time the OOMs occur
there is no swapspace and the msgctl9 or msgctl11 tests are usually being run.

> The following patch should improve on that.

I can give it a spin when I get home later.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
