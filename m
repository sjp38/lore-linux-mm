Message-ID: <005401c28bf3$da8183f0$760010ac@edumazet>
From: "dada1" <dada1@cosmosbay.com>
References: <Pine.LNX.4.44L.0211132239370.3817-100000@imladris.surriel.com> <08a601c28bbb$2f6182a0$760010ac@edumazet> <20021114141310.A25747@infradead.org> <002b01c28bf0$751a3960$760010ac@edumazet> <20021114103147.A17468@redhat.com>
Subject: Re: [patch] remove hugetlb syscalls
Date: Thu, 14 Nov 2002 16:38:15 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Please look again into my mail :)

 ptr = mmap(0, nbp*BIGSZ, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0) ;
        if (ptr == (char *)-1)
                ptr = mmap(0, nbp*BIGSZ, PROT_READ|PROT_WRITE, MAP_PRIVATE,
fd, 0);

mmap2(NULL, 4194304, PROT_READ|PROT_WRITE, MAP_SHARED, 3, 0) = -1 EINVAL

mmap2(NULL, 4194304, PROT_READ|PROT_WRITE, MAP_PRIVATE, 3, 0) = -1 EINVAL

I tried the two versions. MAP_SHARED and MAP_PRIVATE



From: "Benjamin LaHaise" <bcrl@redhat.com>
> On Thu, Nov 14, 2002 at 04:13:56PM +0100, dada1 wrote:
> > Thanks Christoph
> >
> > If I asked, this is because I tried the obvious and it doesnt work.
>
> It's a file.  You need to use MAP_SHARED.
>
> -ben
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
