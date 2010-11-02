Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C99976B00B2
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 07:47:32 -0400 (EDT)
Message-ID: <E1PDFKe-0005sq-2D@approx.mit.edu>
Subject: Re: 2.6.36 io bring the system to its knees
In-Reply-To: Your message of "Thu, 28 Oct 2010 13:01:32 EDT."
             <20101028170132.GY27796@think>
Date: Tue, 2 Nov 2010 07:47:15 -0400
From: Sanjoy Mahajan <sanjoy@olin.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter.Zijl@MIT.EDU
List-ID: <linux-mm.kvack.org>

Chris Mason <chris.mason@oracle.com> wrote:

> > This has the appearance of some really bad IO or VM latency
> > problem. Unfixed and present in stable kernel versions going from
> > years ago all the way to v2.6.36.
> 
> Hmmm, the workload you're describing here has two special parts.
> First it dramatically overloads the disk, and then it has guis doing
> things waiting for the disk.

I think I see this same issue every few days when I back up my hard
drive to a USB hard drive using rsync.  While the backup is running, the
interactive response is bad.  A reproducible measurement of the badness
is starting an rxvt with F8 (bound to "rxvt &" in my .twmrc).  Often it
takes 8 seconds for the window to appear (as it just did about 2 minutes
ago)!  (Starting a subsequent rxvt is quick.)

The command for running the backup:

  rsync -av --delete /etc /home /media/usbdrive/bak > /tmp/homebackup.log

The hardware is a T60 w/ Intel graphics and wireless, 1.5GB RAM, 5400rpm
160GB harddrive w/ ext3 filesystems, and it's running vanilla 2.6.36.
There's not much memory pressure.  The swap is mostly empty, and there's
usually a Firefox eating 500MB of RAM.  Even Emacs at 50MB is in the
noise compared to the Firefox.

Here's the 'free' output:

             total       used       free     shared    buffers     cached
Mem:       1545292    1500288      45004          0      92848     713988
-/+ buffers/cache:     693452     851840
Swap:      2000088      22680    1977408

What tests or probes are worth running when the problem reappears in
order to find the root cause?

-Sanjoy

`Until lions have their historians, tales of the hunt shall always
 glorify the hunters.'  --African Proverb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
