Received: from mailhost.uni-koblenz.de (mailhost.uni-koblenz.de [141.26.64.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA29880
	for <linux-mm@kvack.org>; Sat, 29 May 1999 19:40:39 -0400
Received: from lappi.waldorf-gmbh.de (cacc-23.uni-koblenz.de [141.26.131.23])
	by mailhost.uni-koblenz.de (8.9.1/8.9.1) with ESMTP id BAA20756
	for <linux-mm@kvack.org>; Sun, 30 May 1999 01:40:25 +0200 (MET DST)
Date: Sat, 29 May 1999 17:07:12 +0200
From: Ralf Baechle <ralf@uni-koblenz.de>
Subject: Re: Q: PAGE_CACHE_SIZE?
Message-ID: <19990529170712.D1517@uni-koblenz.de>
References: <Pine.LNX.4.03.9905252213400.25857-100000@mirkwood.nl.linux.org> <E10n8Ic-0003h9-00@the-village.bc.nu> <14159.137.169623.500547@dukat.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <14159.137.169623.500547@dukat.scot.redhat.com>; from Stephen C. Tweedie on Fri, May 28, 1999 at 09:46:01PM +0100
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@nl.linux.org>, ak@muc.de, ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 28, 1999 at 09:46:01PM +0100, Stephen C. Tweedie wrote:


> If we did in fact use the 4k minipage for all kernel get_free_page()
> allocations as usual, but used the larger 32k buddy heap pages for all
> VM allocations, then 8K kernel allocations (eg. stack allocations and
> large NFS packets) become trivial to deal with.
> 
> The biggest problem we have had with these multi-page allocations up to
> now is fragmentation in the VM.  If we populate the _entire_ VM in
> multiples of 8k or more then we can never see such fragmentation at all.
> 8k might actually be a reasonable pagesize even on low memory machines:
> we found in 2.2 that the increased size of the kernel was compensated
> for by more efficient swapping so that things still went faster in low
> memory than under 2.2, and large pages may well have the same tradeoff.

I'm working on Linux/MIPS64 and I intend to cleanup the code such that the
kernel can be built for different page sizes.  I intend to benchmark
things for curiosity.  Maybe it's some viable system tuning option, even
though a compile time one.

  Ralf
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
