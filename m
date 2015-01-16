Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id B3D1A6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 07:58:45 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id k11so20075045wes.3
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 04:58:45 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id hz2si8069674wjb.173.2015.01.16.04.58.45
        for <linux-mm@kvack.org>;
        Fri, 16 Jan 2015 04:58:45 -0800 (PST)
Date: Fri, 16 Jan 2015 14:58:10 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/5] mm: gup: use get_user_pages_unlocked
Message-ID: <20150116125810.GF29085@node.dhcp.inet.fi>
References: <1421167074-9789-1-git-send-email-aarcange@redhat.com>
 <1421167074-9789-5-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421167074-9789-5-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Tue, Jan 13, 2015 at 05:37:53PM +0100, Andrea Arcangeli wrote:
> This allows those get_user_pages calls to pass FAULT_FLAG_ALLOW_RETRY
> to the page fault in order to release the mmap_sem during the I/O.
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
