Subject: Re: Linux I/O performance in 2.3.99pre
References: <Pine.LNX.4.21.0005222148310.3101-100000@inspiron.random>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 24 May 2000 11:17:30 +0200
In-Reply-To: Andrea Arcangeli's message of "Mon, 22 May 2000 22:08:11 -0700 (PDT)"
Message-ID: <dnd7mc8fyt.fsf@magla.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> writes:

> On 22 May 2000, Zlatko Calusic wrote:
> 
> >Question for Andrea: is it possible to get back to the old speeds with
> >tha new elevator code, or is the speed drop unfortunate effect of the
> >"non-starvation" logic, and thus can't be cured?
> 
> If you don't mind about I/O scheduling latencies then just use elvtune and
> set read/write latency to a big number (for example 1000000) and set the
> write-bomb logic value to 128. However in misc usage you care about
> responsiveness as well as latency so you probably don't want to disable
> the I/O scheduler completly. The write bomb logic defaul value is too
> strict probably and we may want to enlarge it to 32 or 64 to allow SCSI
> to be more effective.
>

Yes, you are right. I tested performance with different parameters to
elvtune, and it definitely improves rewriting speed if I put bigger
numbers. In fact with 1000000/1000000/128 it is back to 2.3.42 results
(rewriting speed ~9.2MB/s).

While at it, could you explain what are write bomb logic and latency
numbers? What do they define?

> About the bad VM performance of the latest kernels please try again with
> pre9-1 + classzone-28.
> 

I did a test with pre8 + classzone28 (didn't have 9-1 at the moment,
but there was only one easily resolvable conflict in vmscan.c). And I
must admit that I'm completely satisfied with its behaviour. System is
definitely working right AND fast. It reads, writes and swaps with
full speed and the system survived all tests I made against it. With
classzone patch applied, VM/IO balance/behaviour seems perfect.

Too bad the patch is not going to make it to the Linus kernel tree,
but hey, there's always a possibility of applying a patch for better
performance. Assuming you continue porting the patch to forthcoming
kernels, of course (that's to say I tried to port it to the pre9-4 and
failed :)).

Regards,
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
