Message-ID: <3D3F842C.BCC5C19A@zip.com.au>
Date: Wed, 24 Jul 2002 21:53:00 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: Limiting pagecaches
References: <20020725132127U.miyoshi@hpc.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: miyoshi@hpc.bs1.fc.nec.co.jp
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

miyoshi@hpc.bs1.fc.nec.co.jp wrote:
> 
> Hi, all
> 
> Is there any way to limit the size of pagecaches?

No.

> I observed that performance of some memory hog benchmark
> does not stable, depending on the pagecache size.
> I think it is natural behavior of VM subsystem,
> but some user care for perfomance stability :-<

If you could tell us what the problem was, and how to
reproduce it then we may be able to fix it or find a tuning
solution.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
