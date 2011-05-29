Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6566B0027
	for <linux-mm@kvack.org>; Sat, 28 May 2011 20:43:41 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p4T0hc0W031601
	for <linux-mm@kvack.org>; Sat, 28 May 2011 17:43:38 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz24.hot.corp.google.com with ESMTP id p4T0hY3J009365
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 28 May 2011 17:43:37 -0700
Received: by pzk2 with SMTP id 2so1396551pzk.37
        for <linux-mm@kvack.org>; Sat, 28 May 2011 17:43:34 -0700 (PDT)
Date: Sat, 28 May 2011 17:43:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix page_lock_anon_vma leaving mutex locked
In-Reply-To: <BANLkTi=9qqiLNuo9qbcLoQtK3CKSPnhn4g@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1105281738530.14374@sister.anvils>
References: <alpine.LSU.2.00.1105281317090.13319@sister.anvils> <1306617270.2497.516.camel@laptop> <alpine.LSU.2.00.1105281437320.13942@sister.anvils> <BANLkTinsq-XJGvRVmBa6kRp0RTj9NqGWtA@mail.gmail.com> <alpine.LSU.2.00.1105281634440.14257@sister.anvils>
 <BANLkTi=9qqiLNuo9qbcLoQtK3CKSPnhn4g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 28 May 2011, Linus Torvalds wrote:
> On Sat, May 28, 2011 at 5:12 PM, Hugh Dickins <hughd@google.com> wrote:
> >
> > Though I think I'm arriving at the conclusion that this patch
> > is correct as is, despite the doubts that have arisen.
> 
> Well, you hopefully saw my second email where I had come to the same conclusion.

Yes, thanks.

> 
> So I applied the third patch as well, after all. I think it's at the
> very least at least "more correct" than what we have now. Whether that
> "page_mapped()" should then be extended to do something else is an
> additional thing, and I suspect it would affect the slow-path case
> too.

Yes, I agree it's certainly more correct (two machines running well
with it for 33 hours now, one of them would hang in 7 or 17 hours).

And I'm increasingly confident that it's complete too, but it will be
interesting to see whether I've persuaded Peter.  It was certainly a
very good point that he raised, that I hadn't thought of at all.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
