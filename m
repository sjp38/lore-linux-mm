Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B72196B004D
	for <linux-mm@kvack.org>; Sat, 20 Jun 2009 04:24:06 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090620043303.GA19855@localhost>
References: <20090620043303.GA19855@localhost> <32411.1245336412@redhat.com> <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com> <20090618095729.d2f27896.akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class citizen
Date: Sat, 20 Jun 2009 09:24:22 +0100
Message-ID: <29847.1245486262@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang <fengguang.wu@intel.com> wrote:

> David, could you try running this when it occurred again?
> 
>         make Documentation/vm/page-types
>         Documentation/vm/page-types --raw  # run as root

On the faulting box?  No.  It's pretty much dead.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
