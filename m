Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 90B446B003D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 09:49:19 -0500 (EST)
Date: Fri, 4 Dec 2009 15:49:08 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-ID: <20091204144908.GJ28697@random.random>
References: <20091202125501.GD28697@random.random>
 <20091203134610.586E.A69D9226@jp.fujitsu.com>
 <20091204135938.5886.A69D9226@jp.fujitsu.com>
 <20091204141617.f4c491e7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091204141617.f4c491e7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 04, 2009 at 02:16:17PM +0900, KAMEZAWA Hiroyuki wrote:
> Hmm, can't we use ZERO_PAGE we have now ?
> If do so,
>  - no mapcount check
>  - never on LRU
>  - don't have to maintain shared information because ZERO_PAGE itself has
>    copy-on-write nature.

The zero page could be added to the stable tree always to avoid a
memcmp and we could try to merge anon pages into it, instead of
merging it into ksmpages, but it's not a ksm page so it would require
special handling with branches. We considered doing a magic on
zeropage but we though it's not worth it. We need CPU to be efficient
on very shared pages not just zero page without magics, and the memory
saving is just 4k system-wide (all zero pages of all windows are
already shared).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
