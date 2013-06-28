Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 0C3C76B004D
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 22:15:05 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id k13so3146422iea.32
        for <linux-mm@kvack.org>; Thu, 27 Jun 2013 19:15:05 -0700 (PDT)
Date: Fri, 28 Jun 2013 10:14:54 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH 01/02] swap: discard while swapping only if
 SWAP_FLAG_DISCARD_PAGES
Message-ID: <20130628021454.GA16423@kernel.org>
References: <cover.1369529143.git.aquini@redhat.com>
 <537407790857e8a5d4db5fb294a909a61be29687.1369529143.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <537407790857e8a5d4db5fb294a909a61be29687.1369529143.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, kzak@redhat.com, jmoyer@redhat.com, kosaki.motohiro@gmail.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de

On Sun, May 26, 2013 at 01:31:55AM -0300, Rafael Aquini wrote:
> This patch introduces SWAP_FLAG_DISCARD_PAGES and SWAP_FLAG_DISCARD_ONCE
> new flags to allow more flexibe swap discard policies being flagged through
> swapon(8). The default behavior is to keep both single-time, or batched, area
> discards (SWAP_FLAG_DISCARD_ONCE) and fine-grained discards for page-clusters
> (SWAP_FLAG_DISCARD_PAGES) enabled, in order to keep consistentcy with older
> kernel behavior, as well as maintain compatibility with older swapon(8).
> However, through the new introduced flags the best suitable discard policy 
> can be selected accordingly to any given swap device constraint.

I'm sorry to response this thread so later. I thought if we just want to
discard the swap partition once at swapon, we really should do it in swapon
tool. The swapon tool can detect the swap device supports discard, any swap
partition is empty at swapon, and we have ioctl to do discard in userspace, so
we have no problem to do discard at the tool. If we don't want to do discard at
all, let the tool handles the option. Kernel is not the place to handle the
complexity.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
