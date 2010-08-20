Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 198626B02B0
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 22:51:17 -0400 (EDT)
Date: Fri, 20 Aug 2010 10:51:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] writeback: Adding pages_dirtied and
 pages_entered_writeback
Message-ID: <20100820025111.GB5502@localhost>
References: <1282251447-16937-1-git-send-email-mrubin@google.com>
 <1282251447-16937-3-git-send-email-mrubin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282251447-16937-3-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, npiggin@suse.de, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 01:57:26PM -0700, Michael Rubin wrote:
> To help developers and applications gain visibility into writeback
> behaviour adding four read only sysctl files into /proc/sys/vm.
> These files allow user apps to understand writeback behaviour over time
> and learn how it is impacting their performance.
> 
>    # cat /proc/sys/vm/pages_dirtied
>    3747
>    # cat /proc/sys/vm/pages_entered_writeback
>    3618

As Rik said, /proc/sys is not a suitable place.

Frankly speaking I've worked on writeback for years and never felt
the need to add these counters. What I often do is:

$ vmmon -d 1 nr_writeback nr_dirty nr_unstable

     nr_writeback         nr_dirty      nr_unstable
            68738                0            39568
            66051                0            42255
            63406                0            44900
            60643                0            47663
            57954                0            50352
            55264                0            53042
            52592                0            55715
            49922                0            58385
That is what I get when copying /dev/zero to NFS.

You can find vmmon.c in Andrew Morton's ext3-tools package.
Also attached for your convenience.

I'm very interested in Google's use case for this patch, and why
the simple /proc/vmstat based vmmon tool is not enough.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
