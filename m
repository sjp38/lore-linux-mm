Date: Mon, 10 Dec 2001 18:18:09 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: ext3 writeback mode slower than ordered mode?
Message-ID: <20011210181809.J1919@redhat.com>
References: <871yi5wh93.fsf@atlas.iskon.hr> <3C12C57C.FF93FAC0@zip.com.au> <877krwch39.fsf@atlas.iskon.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877krwch39.fsf@atlas.iskon.hr>; from zlatko.calusic@iskon.hr on Sun, Dec 09, 2001 at 08:46:02PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Andrew Morton <akpm@zip.com.au>, sct@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Dec 09, 2001 at 08:46:02PM +0100, Zlatko Calusic wrote:

> To sumarize:
> 
> ext2            0.01s user 1.86s system 98% cpu 1.893 total
> ext3/ordered    0.07s user 3.50s system 99% cpu 3.594 total
> ext3/writeback  0.00s user 6.05s system 98% cpu 6.129 total
> 
> What is strange is that not always I've been able to get different
> results for writeback case (comparing to ordered), but when I get it,
> it is repeatable.

So it could be something as basic as disk layout or allocation
pattern.  Hmm.

Could you profile the kernel and see where writeback is spending all
the time, in that case?

Thanks,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
