Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id A5B67280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 15:15:03 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id l6so6311152qcy.8
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 12:15:03 -0700 (PDT)
Received: from mail-qg0-x249.google.com (mail-qg0-x249.google.com. [2607:f8b0:400d:c04::249])
        by mx.google.com with ESMTPS id t8si18583246qai.44.2014.10.31.12.15.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 12:15:03 -0700 (PDT)
Received: by mail-qg0-f73.google.com with SMTP id z107so464217qgd.0
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 12:15:02 -0700 (PDT)
Date: Fri, 31 Oct 2014 12:15:00 -0700
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH 2/5] mm: gup: add __get_user_pages_unlocked to customize
 gup_flags
Message-ID: <20141031191500.GC38315@google.com>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
 <1414600520-7664-3-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414600520-7664-3-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Wed, Oct 29, 2014 at 05:35:17PM +0100, Andrea Arcangeli wrote:
> Some caller (like KVM) may want to set the gup_flags like
> FOLL_HWPOSION to get a proper -EHWPOSION retval instead of -EFAULT to
> take a more appropriate action if get_user_pages runs into a memory
> failure.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Peter Feiner <pfeiner@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
