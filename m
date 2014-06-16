Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id D308A6B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 17:00:22 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so5923999wib.5
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 14:00:22 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id uy7si21025680wjc.123.2014.06.16.14.00.21
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 14:00:21 -0700 (PDT)
Date: Mon, 16 Jun 2014 23:59:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, thp: move invariant bug check out of loop in
 __split_huge_page_map
Message-ID: <20140616205946.GB14208@node.dhcp.inet.fi>
References: <1402947348-60655-1-git-send-email-Waiman.Long@hp.com>
 <20140616204934.GA14208@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140616204934.GA14208@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <Waiman.Long@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>

On Mon, Jun 16, 2014 at 11:49:34PM +0300, Kirill A. Shutemov wrote:
> On Mon, Jun 16, 2014 at 03:35:48PM -0400, Waiman Long wrote:
> > In the __split_huge_page_map() function, the check for
> > page_mapcount(page) is invariant within the for loop. Because of the
> > fact that the macro is implemented using atomic_read(), the redundant
> > check cannot be optimized away by the compiler leading to unnecessary
> > read to the page structure.

And atomic_read() is *not* atomic operation. It's implemented as
dereferencing though cast to volatile, which suppress compiler
optimization, but doesn't affect what CPU can do with the variable.

So I doubt difference will be measurable anywhere.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
