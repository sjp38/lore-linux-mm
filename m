Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 395686B004D
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 04:06:52 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090619055848.GA27802@localhost>
References: <20090619055848.GA27802@localhost> <20090517022327.280096109@intel.com> <32411.1245336412@redhat.com>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class citizen
Date: Fri, 19 Jun 2009 09:06:16 +0100
Message-ID: <4278.1245398776@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, "Wang,
                         Roger" <roger.wang@intel.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Wu Fengguang <fengguang.wu@intel.com> wrote:

> There are plenty of free pages. Is it a page allocator bug? Is it
> stable v2.6.30 or pre 2.6.31-rc1?

Cutting edge Linus after I pulled his new patches yesterday morning:

	commit 65795efbd380a832ae508b04dba8f8e53f0b84d9

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
