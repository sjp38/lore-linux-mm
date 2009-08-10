Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 88BA06B004D
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 12:59:19 -0400 (EDT)
Message-ID: <1703.77.126.199.142.1249923286.squirrel@webmail.cs.biu.ac.il>
In-Reply-To: <4A803F62.2050006@redhat.com>
References: <4353.132.70.1.75.1249546446.squirrel@webmail.cs.biu.ac.il>
    <1249548768.32113.68.camel@twins>
    <1466.77.126.168.195.1249763409.squirrel@webmail.cs.biu.ac.il>
    <4A7E03B4.8010503@redhat.com>
    <1085.77.126.199.142.1249842457.squirrel@webmail.cs.biu.ac.il>
    <4A803F62.2050006@redhat.com>
Date: Mon, 10 Aug 2009 19:54:46 +0300 (IDT)
Subject: Re: New patch for Linux
From: "Yair Wiseman" <wiseman@macs.biu.ac.il>
Reply-To: wiseman@macs.biu.ac.il
MIME-Version: 1.0
Content-Type: text/plain;charset=windows-1255
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: wiseman@macs.biu.ac.il, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

It will work for larger amounts of memory. We just have to choose a longer time slice. I will try to find a newer
version, but I do not see the difference in this case. We just suggest to replace the LRU-token approach.

-Yair.
-------------------------------------------------------------------------
Dr. Yair Wiseman, Ph.D.
Computer Science Department
Bar-Ilan University
Ramat-Gan 52900
Israel
Tel: 972-3-5317015
Fax: 972-3-7384056
http://www.cs.biu.ac.il/~wiseman

>From the keyboard of Rik van Riel
> Yair Wiseman wrote:
>> We tried to find his code and we found just the code of 2.4.20. I put it at:
>> http://u.cs.biu.ac.il/~wiseman/moses.html
>>
>> Thanks for considering our patch,
>
> Ummm no.  It's for an ancient version of Linux and not even a
> patch.  There really isn't a whole lot to consider, beyond an
> idea - which you admitted may not even work well on systems
> with larger amounts of memory.
>
> --
> All rights reversed.
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
