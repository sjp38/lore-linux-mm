Received: from pd4mr7so.prod.shaw.ca (pd4mr7so-qfe3.prod.shaw.ca [10.0.141.84])
 by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0J230031OJMHXGD0@l-daemon> for linux-mm@kvack.org; Sat,
 08 Jul 2006 12:06:17 -0600 (MDT)
Received: from pn2ml10so.prod.shaw.ca ([10.0.121.80])
 by pd4mr7so.prod.shaw.ca (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar
 15 2004)) with ESMTP id <0J2300KGSJMH5ED0@pd4mr7so.prod.shaw.ca> for
 linux-mm@kvack.org; Sat, 08 Jul 2006 12:06:17 -0600 (MDT)
Received: from [192.168.1.113] ([70.64.1.86])
 by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0J2300GH7JMGSZ90@l-daemon> for linux-mm@kvack.org; Sat,
 08 Jul 2006 12:06:17 -0600 (MDT)
Date: Sat, 08 Jul 2006 12:06:13 -0600
From: Robert Hancock <hancockr@shaw.ca>
Subject: Re: Commenting out out_of_memory() function in __alloc_pages()
In-reply-to: <fa.AmXizdwfdZtqgKFSMcRp3U0QZXI@ifi.uio.no>
Message-id: <44AFF415.2020305@shaw.ca>
MIME-version: 1.0
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7bit
References: <fa.AmXizdwfdZtqgKFSMcRp3U0QZXI@ifi.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Abu M. Muttalib wrote:
> Hi,
> 
> I am getting the Out of memory.
> 
> To circumvent the problem, I have commented the call to "out_of_memory(),
> and replaced "goto restart" with "goto nopage".
> 
> At "nopage:" lable I have added a call to "schedule()" and then "return
> NULL" after "schedule()".

Bad idea - in the configuration you have, the system may need the 
out-of-memory killer to free up memory, otherwise the system can 
deadlock due to all memory being exhausted.

> 
> I tried the modified kernel with a test application, the test application is
> mallocing memory in a loop. Unlike as expected the process gets killed. On
> second run of the same application I am getting the page allocation failure
> as expected but subsequently the system hangs.
> 
> I am attaching the test application and the log herewith.
> 
> I am getting this exception with kernel 2.6.13. With kernel
> 2.4.19-rmka7-pxa1 there was no problem.
> 
> Why its so? What can I do to alleviate the OOM problem?

Please see Documentation/vm/overcommit-accounting in the kernel source tree.

-- 
Robert Hancock      Saskatoon, SK, Canada
To email, remove "nospam" from hancockr@nospamshaw.ca
Home Page: http://www.roberthancock.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
