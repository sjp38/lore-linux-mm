Message-ID: <3DC38CF4.1060301@pobox.com>
Date: Sat, 02 Nov 2002 03:29:40 -0500
From: Jeff Garzik <jgarzik@pobox.com>
MIME-Version: 1.0
Subject: Re: Huge TLB pages always physically continious?
References: <20021101235620.A5263@nightmaster.csn.tu-chemnitz.de> <3DC30CD6.D92D0F9F@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Now that hugetlbfs is merged, can we remove the hugetlb syscalls? 
 Pretty please?  ;-)

What I've heard in the background is that all the Big Users(tm) of 
hugetlbs greatly prefer the existing syscalls (a.k.a. hugetlbfs) to 
adding support to new ones in the various userland portability layers in 
use...

    Jeff




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
