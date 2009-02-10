Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5725D6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 11:10:31 -0500 (EST)
Date: Tue, 10 Feb 2009 17:09:53 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmscan: initialize sc->nr_reclaimed properly take2
Message-ID: <20090210160952.GA2371@cmpxchg.org>
References: <20090210213502.7007.KOSAKI.MOTOHIRO@jp.fujitsu.com> <28c262360902100440v765d3f7bnd56cc4b5510349c0@mail.gmail.com> <20090210215718.700D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090210215718.700D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 09:58:04PM +0900, KOSAKI Motohiro wrote:
> 
> How about this?

I agree, this is the better solution.

Thank you, Kosaki-san.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
