Message-ID: <3D698F4E.93A3DDA2@zip.com.au>
Date: Sun, 25 Aug 2002 19:15:42 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: MM patches against 2.5.31
References: <1030031958.14756.479.camel@spc9.esa.lanl.gov> <2631076918.1030007179@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Steven Cole <elenstev@mesatop.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> > kjournald: page allocation failure. order:0, mode:0x0
> 
> I've seen this before, but am curious how we ever passed
> a gfpmask (aka mode) of 0 to __alloc_pages? Can't see anywhere
> that does this?

Could be anywhere, really.  A network interrupt doing GFP_ATOMIC
while kjournald is executing.  A radix-tree node allocation 
on the add-to-swap path perhaps.  (The swapout failure messages
aren't supposed to come out, but mempool_alloc() stomps on the
caller's setting of PF_NOWARN.)

Or:

mnm:/usr/src/25> grep -r GFP_ATOMIC drivers/scsi/*.c | wc -l
     89
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
