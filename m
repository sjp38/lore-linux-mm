Subject: Re: The 4GB memory thing
References: <199911041848.KAA55976@google.engr.sgi.com>
From: Andrea Arcangeli <andrea@suse.de>
Date: 05 Nov 1999 00:41:39 +0100
In-Reply-To: kanoj@google.engr.sgi.com's message of "Thu, 4 Nov 1999 10:48:20 -0800 (PST)"
Message-ID: <m37ljx25ak.fsf@alpha.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: nconway.list@ukaea.org.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:

> I don't see a README.gz under 
>  http://www.kernel.org/pub/linux/kernel/people/andrea/tools/apply-patches/

lftp> pwd
ftp://ftp.it.kernel.org/pub/linux/kernel/people/andrea/tools/apply-patches
lftp> ls README.gz
-rw-r--r--   1 ftp      daemon        875 Oct 25 00:43 README.gz
lftp> 

> In any case, did you a have a small technical README on how rawio works
> on bigmem in 2.2.13aa3? Btw, I haven't seen the rawio 2.2 port, I am 

As first you can have a look at the rawio patch.

        ftp://ftp.it.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.2/2.2.13aa3/z-bigmem-rawio-2.2.13aa2-1.gz

The above patch includes all the necessary stuff to make rawio working
fine on bigmem pages.

Basically the code uses regular pages as bounce buffers to do the I/O
on bigmem pages.

> assuming its very similar to 2.3 ... where brw_kiovec() refuses to 
> accept PageHighMem pages. I didn't see anything in
> z-bigmem-2.2.13aa3-7

No. The z-bigmem-rawio-2.2.13aa2-1.gz in 2.2.13aa3 allows brw_kiovec
to do I/O on bigmem pages.

> that tinkers either with fs/buffer.c.

I take the bigmem stuff separated from rawio. The rawio patch (pointed
out above) included in 2.2.13aa3 is an incremental patch that goes on the top of
bigmem. I take all the patches separated to allow everybody out there to merge
easily my stuff and to see the only related necessary changes on
topic.

-- 
Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
