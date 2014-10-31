Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 95F48280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 15:13:15 -0400 (EDT)
Received: by mail-qa0-f50.google.com with SMTP id bm13so4067286qab.9
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 12:13:15 -0700 (PDT)
Received: from mail-qa0-x24a.google.com (mail-qa0-x24a.google.com. [2607:f8b0:400d:c00::24a])
        by mx.google.com with ESMTPS id t6si18523436qak.85.2014.10.31.12.13.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 12:13:14 -0700 (PDT)
Received: by mail-qa0-f74.google.com with SMTP id u7so551094qaz.1
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 12:13:14 -0700 (PDT)
Date: Fri, 31 Oct 2014 12:13:12 -0700
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH 3/5] mm: gup: use get_user_pages_unlocked within
 get_user_pages_fast
Message-ID: <20141031191312.GB38315@google.com>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
 <1414600520-7664-4-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414600520-7664-4-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Wed, Oct 29, 2014 at 05:35:18PM +0100, Andrea Arcangeli wrote:
> This allows the get_user_pages_fast slow path to release the mmap_sem
> before blocking.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Peter Feiner <pfeiner@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
