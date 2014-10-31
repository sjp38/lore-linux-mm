Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4171F280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 15:16:56 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id n8so2198732qaq.19
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 12:16:56 -0700 (PDT)
Received: from mail-qa0-x249.google.com (mail-qa0-x249.google.com. [2607:f8b0:400d:c00::249])
        by mx.google.com with ESMTPS id r10si18513103qat.106.2014.10.31.12.16.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 12:16:55 -0700 (PDT)
Received: by mail-qa0-f73.google.com with SMTP id f12so551586qad.4
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 12:16:55 -0700 (PDT)
Date: Fri, 31 Oct 2014 12:16:53 -0700
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH 5/5] mm: gup: kvm use get_user_pages_unlocked
Message-ID: <20141031191653.GD38315@google.com>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
 <1414600520-7664-6-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414600520-7664-6-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Wed, Oct 29, 2014 at 05:35:20PM +0100, Andrea Arcangeli wrote:
> Use the more generic get_user_pages_unlocked which has the additional
> benefit of passing FAULT_FLAG_ALLOW_RETRY at the very first page fault
> (which allows the first page fault in an unmapped area to be always
> able to block indefinitely by being allowed to release the mmap_sem).
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Peter Feiner <pfeiner@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
