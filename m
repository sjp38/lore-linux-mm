Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 7609E6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 16:13:09 -0500 (EST)
Date: Fri, 22 Feb 2013 21:13:08 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] fadvise: perform WILLNEED readahead in a workqueue
Message-ID: <20130222211308.GA13037@dcvr.yhbt.net>
References: <20121215005448.GA7698@dcvr.yhbt.net>
 <20121216024520.GH9806@dastard>
 <5127A0A3.6040904@ubuntu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5127A0A3.6040904@ubuntu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Phillip Susi <psusi@ubuntu.com> wrote:
> > On Sat, Dec 15, 2012 at 12:54:48AM +0000, Eric Wong wrote:
> >> "strace -T" timing on an uncached, one gigabyte file:
> >> 
> >> Before: fadvise64(3, 0, 0, POSIX_FADV_WILLNEED) = 0 <2.484832> 
> >> After: fadvise64(3, 0, 0, POSIX_FADV_WILLNEED) = 0 <0.000061>
> 
> It shouldn't take 2 seconds to queue up some async reads.  Are you
> using ext3?  The blocks have to be mapped in order to queue the reads,
> and without ext4 extents, this means the indirect blocks have to be
> read and can cause fadvise to block.

You're right, I originally tested on ext3.

I just tested an unpatched 3.7.9 kernel with ext4 and is much faster
(~250ms).  I consider ~250ms acceptable for my needs.  Will migrate
the rest of my setup to ext4 soon, thanks for the tip!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
