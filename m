Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 4D43F6B005A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 16:10:14 -0400 (EDT)
Date: Wed, 3 Oct 2012 13:10:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, thp: fix mlock statistics
Message-Id: <20121003131012.f88b0d66.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1209271814340.2107@eggly.anvils>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com>
	<alpine.LSU.2.00.1209192021270.28543@eggly.anvils>
	<alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1209261929270.8567@chino.kir.corp.google.com>
	<alpine.LSU.2.00.1209271814340.2107@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Thu, 27 Sep 2012 18:32:33 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> So despite my earlier reluctance, please take this as an Ack on that
> one too (I was testing them together): it'll be odd if one of them goes
> to stable and the other not, but we can sort that out with GregKH later.

Yes, all this code has changed so much since 3.6 that new patches will
need to be prepared for -stable.

The free_page_mlock() hunk gets dropped because free_page_mlock() is
removed.  And clear_page_mlock() doesn't need this treatment.  But
please check my handiwork.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
