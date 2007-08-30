Received: from pd3mr4so.prod.shaw.ca
 (pd3mr4so-qfe3.prod.shaw.ca [10.0.141.180]) by l-daemon
 (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0JNK00A43CILSRD0@l-daemon> for linux-mm@kvack.org; Wed,
 29 Aug 2007 19:37:33 -0600 (MDT)
Received: from pn2ml5so.prod.shaw.ca ([10.0.121.149])
 by pd3mr4so.prod.shaw.ca (Sun Java System Messaging Server 6.2-7.05 (built Sep
 5 2006)) with ESMTP id <0JNK001J9CIKQR10@pd3mr4so.prod.shaw.ca> for
 linux-mm@kvack.org; Wed, 29 Aug 2007 19:37:32 -0600 (MDT)
Received: from [192.168.1.113] ([70.64.1.86])
 by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0JNK00K20CIJY080@l-daemon> for linux-mm@kvack.org; Wed,
 29 Aug 2007 19:37:31 -0600 (MDT)
Date: Wed, 29 Aug 2007 19:37:12 -0600
From: Robert Hancock <hancockr@shaw.ca>
Subject: Re: speeding up swapoff
In-reply-to: <fa./NZA3biuO1+qW5pW8ybdZMDWcZs@ifi.uio.no>
Message-id: <46D61F48.5090406@shaw.ca>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
References: <fa.j/pO3mTWDugTdvZ3XNr9XpvgzPQ@ifi.uio.no>
 <fa.ed9fasZXOwVCrbffkPQTX7G3a7g@ifi.uio.no>
 <fa./NZA3biuO1+qW5pW8ybdZMDWcZs@ifi.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Drake <ddrake@brontes3d.com>
Cc: Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Daniel Drake wrote:
> On Wed, 2007-08-29 at 07:30 -0700, Arjan van de Ven wrote:
>>> My experiments show that when there is not much free physical memory,
>>> swapoff moves pages out of swap at a rate of approximately 5mb/sec.
>> sounds like about disk speed (at random-seek IO pattern)
> 
> We are only using 'standard' seagate SATA disks, but I would have
> thought much more performance (40+ mb/sec) would be reachable.

Not if it is doing random seeks..

> 
>> before you go there... is this a "real life" problem? Or just a
>> mostly-artificial corner case? (the answer to that obviously is
>> relevant for the 'should we really care' question)
> 
> It's more-or-less a real life problem. We have an interactive
> application which, when triggered by the user, performs rendering tasks
> which must operate in real-time. In attempt to secure performance, we
> want to ensure everything is memory resident and that nothing might be
> swapped out during the process. So, we run swapoff at that time.
> 
> If there is a decent number of pages swapped out, the user sits for a
> while at a 'please wait' screen, which is not desirable. To throw some
> numbers out there, likely more than a minute for 400mb of swapped pages.
> 
> Sure, we could run the whole interactive application with swap disabled,
> which is pretty much what we do. However we have other non-real-time
> processing tasks which are very memory hungry and do require swap. So,
> there are 'corner cases' where the user can reach the real-time part of
> the interactive application when there is a lot of memory swapped out.

Normally mlockall is what is used in this sort of situation, that way it 
doesn't force all swapped data in for every app. It's possible that 
calling this with lots of swapped pages in the app at the time may have 
the same problem though.

-- 
Robert Hancock      Saskatoon, SK, Canada
To email, remove "nospam" from hancockr@nospamshaw.ca
Home Page: http://www.roberthancock.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
