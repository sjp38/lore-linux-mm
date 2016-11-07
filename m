Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 826476B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 05:49:22 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id h201so1424773lfg.5
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 02:49:22 -0800 (PST)
Received: from bes.se.axis.com (bes.se.axis.com. [195.60.68.10])
        by mx.google.com with ESMTP id 191si15435502lfz.327.2016.11.07.02.49.20
        for <linux-mm@kvack.org>;
        Mon, 07 Nov 2016 02:49:21 -0800 (PST)
Date: Mon, 7 Nov 2016 11:49:18 +0100
From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: Re: [PATCH 1/2] mm: add locked parameter to get_user_pages()
Message-ID: <20161107104918.GQ30704@axis.com>
References: <20161031100228.17917-1-lstoakes@gmail.com>
 <20161031100228.17917-2-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161031100228.17917-2-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-ia64@vger.kernel.org, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-cris-kernel@axis.com, linux-rdma@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Michal Hocko <mhocko@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-media@vger.kernel.org

On Mon, Oct 31, 2016 at 10:02:27AM +0000, Lorenzo Stoakes wrote:
> This patch adds an int *locked parameter to get_user_pages() to allow
> VM_FAULT_RETRY faulting behaviour similar to get_user_pages_[un]locked().
> 
> It additionally clears the way for get_user_pages_locked() to be removed as its
> sole remaining useful characteristic was to allow for VM_FAULT_RETRY behaviour
> when faulting in pages.
> 
> It should not introduce any functional changes, however it does allow for
> subsequent changes to get_user_pages() callers to take advantage of
> VM_FAULT_RETRY.

For the cris-part:
Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
