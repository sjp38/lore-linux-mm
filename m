Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 581B56B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:29:31 -0500 (EST)
Date: Tue, 10 Nov 2009 22:29:28 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 5/6] mm: stop ptlock enlarging struct page
In-Reply-To: <1257891277.4108.498.camel@laptop>
Message-ID: <Pine.LNX.4.64.0911102227080.7826@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
 <Pine.LNX.4.64.0911102200480.2816@sister.anvils> <1257891277.4108.498.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Nov 2009, Peter Zijlstra wrote:
> 
> fwiw, in -rt we carry this, because there spinlock_t is huge even
> without lockdep.

Thanks, I may want to consider that; but I'm not keen on darting
off to another cacheline even for the non-debug spinlock case.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
