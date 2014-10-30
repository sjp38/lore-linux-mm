Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id AE13790008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 08:21:53 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id gd6so3049141lab.6
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 05:21:52 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id v3si11704817lal.134.2014.10.30.05.21.51
        for <linux-mm@kvack.org>;
        Thu, 30 Oct 2014 05:21:51 -0700 (PDT)
Date: Thu, 30 Oct 2014 14:21:13 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/5] mm: gup: use get_user_pages_unlocked within
 get_user_pages_fast
Message-ID: <20141030122113.GC31134@node.dhcp.inet.fi>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
 <1414600520-7664-4-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414600520-7664-4-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Wed, Oct 29, 2014 at 05:35:18PM +0100, Andrea Arcangeli wrote:
> This allows the get_user_pages_fast slow path to release the mmap_sem
> before blocking.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
