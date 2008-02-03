Date: Sun, 3 Feb 2008 07:41:58 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 0/4] [RFC] EMMU Notifiers V5
Message-ID: <20080203134158.GB3875@sgi.com>
References: <20080201050439.009441434@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080201050439.009441434@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

Great news!  I have taken over Dean's xpmem patch set while he is on
sabbatical.  Before he left, he had his patch mostly working on top of
this patch set.  We had one deadlock.  I have coded for that specific
deadlock and xpmem now passes a simple grant/attach/fault/fork/unmap/map
test.

After analyzing it, I believe we still have a nearly related deadlock
which will require some refactoring of code.  I am certain that the
same mechanism I used for this deadlock break will work in that case,
but it will require too many changes for me to finish this weekend.

For our customer base, this case, in the past, has resulted in termination
of the application and our MPI library specifically states that this
mode of operation is not permitted, so I think we will be able to pass
their regression tests.  I will need to coordinate that early next week.

The good news, at this point, Christoph's version 5 of the mmu_notifiers
appears to work for xpmem.  The mmu_notifier call-outs where the
in_atomic flag is set still result in a BUG_ON.  That is not an issue
for our normal customer as our MPI already states this is not a valid
mode of operation and provides means to avoid those types of mappings.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
