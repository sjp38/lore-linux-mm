Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 329CC6B0070
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 14:16:22 -0400 (EDT)
Date: Tue, 23 Oct 2012 14:16:21 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [RFC PATCH v2 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
In-Reply-To: <CACVXFVN+=XH_f5BmRkXeagTNowz0o0-Pd7GcxCneO0FSq8xqEw@mail.gmail.com>
Message-ID: <Pine.LNX.4.44L0.1210231402040.1635-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Tue, 23 Oct 2012, Ming Lei wrote:

> With the problem of non-SMP-safe bitfields access, the power.lock should
> be held, but that is not enough to prevent children from being probed or
> disconnected. Looks another lock is still needed. I think a global lock
> is OK in the infrequent path.

Agreed.

> Got it, thanks for your detailed explanation.
> 
> Looks the problem is worse than above, not only bitfields are affected, the
> adjacent fields might be involved too, see:
> 
>            http://lwn.net/Articles/478657/

Linus made it clear (in various emails at the time) that the kernel
requires the compiler not to do the sort of things discussed in that
article.  But even the restrictions he wanted would not prevent
adjacent bitfields from interfering with each other.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
