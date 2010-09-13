Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ECCA96B007B
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 17:25:53 -0400 (EDT)
Date: Mon, 13 Sep 2010 14:24:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] writeback: Reporting dirty thresholds in
 /proc/vmstat
Message-Id: <20100913142412.dc0f6950.akpm@linux-foundation.org>
In-Reply-To: <1284357493-20078-6-git-send-email-mrubin@google.com>
References: <1284357493-20078-1-git-send-email-mrubin@google.com>
	<1284357493-20078-6-git-send-email-mrubin@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, david@fromorbit.com, kosaki.motohiro@jp.fujitsu.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Sun, 12 Sep 2010 22:58:13 -0700
Michael Rubin <mrubin@google.com> wrote:

> The kernel already exposes the user desired thresholds in /proc/sys/vm
> with dirty_background_ratio and background_ratio. But the kernel may
> alter the number requested without giving the user any indication that
> is the case.
> 
> Knowing the actual ratios the kernel is honoring can help app developers
> understand how their buffered IO will be sent to the disk.
> 
>         $ grep threshold /proc/vmstat
>         nr_dirty_threshold 409111
>         nr_dirty_background_threshold 818223
> 

Yes, I think /proc/vmstat is a decent place to put these.  The needed
infrastructural support is minimal and although these numbers are
closely tied to the implementation-of-the-day, people should expect
individual fields in /proc/vmstat to appear and disappear at random as
kernel versions change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
