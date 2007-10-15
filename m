Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9F95xjw263626
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 09:05:59 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9F95x782293890
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 11:05:59 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9F95xmu012147
	for <linux-mm@kvack.org>; Mon, 15 Oct 2007 11:05:59 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH resend] ramdisk: fix zeroed ramdisk pages on memory pressure
Date: Mon, 15 Oct 2007 11:05:57 +0200
References: <200710151028.34407.borntraeger@de.ibm.com> <200710160006.19735.nickpiggin@yahoo.com.au>
In-Reply-To: <200710160006.19735.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710151105.57442.borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

Am Montag, 15. Oktober 2007 schrieb Nick Piggin:
> On Monday 15 October 2007 18:28, Christian Borntraeger wrote:
> > Andrew, this is a resend of a bugfix patch. Ramdisk seems a bit
> > unmaintained, so decided to sent the patch to you :-).
> > I have CCed Ted, who did work on the code in the 90s. I found no current
> > email address of Chad Page.
> 
> This really needs to be fixed...

I obviously agree ;-)
We have seen this problem happen several times. 

> I can't make up my mind between the approaches to fixing it.
> 
> On one hand, I would actually prefer to really mark the buffers
> dirty (as in: Eric's fix for this problem[*]) than this patch,
> and this seems a bit like a bandaid...

I have never seen these patches, so I cannot comment on them.
> 
> On the other hand, the wound being covered by the bandaid is
> actually the code in the buffer layer that does this latent
> "cleaning" of the page because it sadly doesn't really keep
> track of the pagecache state. But it *still* feels like we
> should be marking the rd page's buffers dirty which should
> avoid this problem anyway.

Yes, that would solve the problem as well. As long as we fix
the problem, I am happy. On the other hand, do you see any
obvious problem with this "bandaid"?

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
