Message-ID: <08a601c28bbb$2f6182a0$760010ac@edumazet>
From: "dada1" <dada1@cosmosbay.com>
References: <Pine.LNX.4.44L.0211132239370.3817-100000@imladris.surriel.com>
Subject: Re: [patch] remove hugetlb syscalls
Date: Thu, 14 Nov 2002 09:52:33 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Benjamin LaHaise <bcrl@redhat.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I beg to differ.

I already use the syscalls.

The patch doesnt change Documentation/vm/hugetlbpage.txt

How one is supposed to use hugetlbfs ? That's not documented.

Before dropping support for syscalls, please change the Documentation.

Thanks

----- Original Message -----
From: "Rik van Riel" <riel@conectiva.com.br>
To: "Benjamin LaHaise" <bcrl@redhat.com>
Cc: "Andrew Morton" <akpm@digeo.com>; <linux-mm@kvack.org>;
<linux-kernel@vger.kernel.org>
Sent: Thursday, November 14, 2002 1:42 AM
Subject: Re: [patch] remove hugetlb syscalls


> On Wed, 13 Nov 2002, Benjamin LaHaise wrote:
>
> > Since the functionality of the hugetlb syscalls is now available via
> > hugetlbfs with better control over permissions, could you apply the
> > following patch that gets rid of a lot of duplicate and unnescessary
> > code by removing the two hugetlb syscalls?
>
> #include <massive_applause.h>
>
> Yes, lets get rid of this ugliness before somebody actually
> finds a way to use these syscalls...
>
> regards,
>
> Rik
> --
> Bravely reimplemented by the knights who say "NIH".
> http://www.surriel.com/ http://guru.conectiva.com/
> Current spamtrap:  <a
href=mailto:"october@surriel.com">october@surriel.com</a>
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
