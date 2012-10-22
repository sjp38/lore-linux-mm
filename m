Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 22E9C6B005A
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 15:18:31 -0400 (EDT)
Date: Mon, 22 Oct 2012 15:18:29 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [RFC PATCH v2 4/6] net/core: apply pm_runtime_set_memalloc_noio
 on network devices
In-Reply-To: <1350894794-1494-5-git-send-email-ming.lei@canonical.com>
Message-ID: <Pine.LNX.4.44L0.1210221516280.1724-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, David Decotigny <david.decotigny@google.com>, Tom Herbert <therbert@google.com>, Ingo Molnar <mingo@elte.hu>

On Mon, 22 Oct 2012, Ming Lei wrote:

> Deadlock might be caused by allocating memory with GFP_KERNEL in
> runtime_resume callback of network devices in iSCSI situation, so
> mark network devices and its ancestor as 'memalloc_noio_resume'
> with the introduced pm_runtime_set_memalloc_noio().

Is this really needed?  Even with iSCSI, doesn't register_disk() have
to be called for the underlying block device?  And given your 3/6
patch, wouldn't that mark the network device?

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
