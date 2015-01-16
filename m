Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 35CE86B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 08:03:44 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id bs8so4257816wib.0
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 05:03:43 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id wo6si8171081wjc.129.2015.01.16.05.03.43
        for <linux-mm@kvack.org>;
        Fri, 16 Jan 2015 05:03:43 -0800 (PST)
Date: Fri, 16 Jan 2015 15:03:10 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 5/5] mm: gup: kvm use get_user_pages_unlocked
Message-ID: <20150116130310.GG29085@node.dhcp.inet.fi>
References: <1421167074-9789-1-git-send-email-aarcange@redhat.com>
 <1421167074-9789-6-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421167074-9789-6-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Tue, Jan 13, 2015 at 05:37:54PM +0100, Andrea Arcangeli wrote:
> Use the more generic get_user_pages_unlocked which has the additional
> benefit of passing FAULT_FLAG_ALLOW_RETRY at the very first page fault
> (which allows the first page fault in an unmapped area to be always
> able to block indefinitely by being allowed to release the mmap_sem).
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
