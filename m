Subject: Re: page->offset
References: <CA2568BF.00489645.00@d73mta05.au.ibm.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 12 Apr 2000 10:29:30 -0500
In-Reply-To: pnilesh@in.ibm.com's message of "Wed, 12 Apr 2000 18:34:21 +0530"
Message-ID: <m1aeizban9.fsf@flinx.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

pnilesh@in.ibm.com writes:

> To have your views,
> 
> If a file is opened and from an offset which is not page aligned say from
> offset 10.
Umm.  Files aren't opend with offsets.
The are however mapped at offsets.

> When we read this file into the memory page ,where the first byte will be
> loaded into the memory ?
When you mmap the file?  A read syscall isn't affected?

> In 2.2 the first byte of the page will be the 10th byte of the file.
Nope.  Can't do alignments less the fs blocksize which at least 512 bytes
even in 2.2.  But for the mmap case you are substantailly correct.

> In 2.3 the first byte will be first byte in the file and 10th byte is the
> 10th in the file.
That is what will be in the cache.   The mmap  request will simply be refused.

> This is what I feel.

How does feelings have anything to do with it?

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
