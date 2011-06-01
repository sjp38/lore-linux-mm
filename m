Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D63A06B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 20:36:41 -0400 (EDT)
Date: Tue, 31 May 2011 20:36:34 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/14] mm: move vmtruncate_range to truncate.c
Message-ID: <20110601003634.GA4433@infradead.org>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
 <alpine.LSU.2.00.1105301735520.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1105301735520.5482@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, May 30, 2011 at 05:36:57PM -0700, Hugh Dickins wrote:
> You would expect to find vmtruncate_range() next to vmtruncate()
> in mm/truncate.c: move it there.

Sounds fine to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
