From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004111814.LAA74654@google.engr.sgi.com>
Subject: Re: zap_page_range(): TLB flush race
Date: Tue, 11 Apr 2000 11:14:11 -0700 (PDT)
In-Reply-To: <38F364B3.5A4A45D9@colorfullife.com> from "Manfred Spraul" at Apr 11, 2000 07:45:23 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

> 
> Yes. 
> Can we ignore the munmap+access case?
> I'd say that if 2 threads race with munmap+access, then the behaviour is
> undefined.
> Tlb flushes are expensive, I'd like to avoid the second tlb flush as in
> Kanoj's patch.
> 

To handle clones on SMP systems properly, you have to stop at least other
threads from writing to the page during unmap time, and possibly loading
the old translation during translation-changing time. Probably the only
generic way to do this is to twiddle the ptes and flush the tlb's, unless
you start making big chunks of code architecture dependent. Note that in
my patch, in most cases, the tlb flush position has changed, not the 
number of flushes ....

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
