Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4EAC96B005A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 04:33:43 -0400 (EDT)
Date: Wed, 17 Jun 2009 10:31:23 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: remove task assumptions from swap token
Message-ID: <20090617083123.GA1879@cmpxchg.org>
References: <Pine.LNX.4.64.0906162152250.12770@sister.anvils> <1245189037-22961-2-git-send-email-hannes@cmpxchg.org> <20090617110034.db01479b.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090617110034.db01479b.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 17, 2009 at 11:00:34AM +0900, Minchan Kim wrote:
> Hi, Hannes. 
> 
> How about adding Hugh's comment ?

Sorry, I misinterpreted Hugh's reply to me that got into my inbox
directly and totally missed that he had already done the exact same
thing in the lkml thread until much later.

We should probably just use his version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
