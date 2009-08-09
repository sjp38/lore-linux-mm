Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5A16D6B004D
	for <linux-mm@kvack.org>; Sun,  9 Aug 2009 14:29:59 -0400 (EDT)
Message-ID: <1085.77.126.199.142.1249842457.squirrel@webmail.cs.biu.ac.il>
In-Reply-To: <4A7E03B4.8010503@redhat.com>
References: <4353.132.70.1.75.1249546446.squirrel@webmail.cs.biu.ac.il>
    <1249548768.32113.68.camel@twins>
    <1466.77.126.168.195.1249763409.squirrel@webmail.cs.biu.ac.il>
    <4A7E03B4.8010503@redhat.com>
Date: Sun, 9 Aug 2009 21:27:37 +0300 (IDT)
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

Dear Rik van Riel,

Thanks for your comments. You indeed have a point. We used 128MB of RAM which is VERY small, so one second would be
enough; therefore I agree that your remark about the small quantum is correct - a common nowadays RAM is larger and
the quantum should be longer.

The first author of the paper was an MSc student of me and the code was at his home-page, but when he left the
university his directory was removed. We tried to find his code and we found just the code of 2.4.20. I put it at:
http://u.cs.biu.ac.il/~wiseman/moses.html

Thanks for considering our patch,

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
>
>> Thanks for your quick response. Our patch is indeed an extension
>  > of the LRU-token approach.
>
> The paper looks very promising, but I have a few questions.
>
> First, why is a 1 second medium timeslice enough when processes
> on modern systems are often hundreds of megabytes in size?
>
> In one second, a disk can handle about 100 seeks, which corresponds
> to 100 truly random swapin IOs. I see that a lot of the testing in
> your paper was done with smaller processes on smaller memory systems,
> which makes me very curious about how your algorithm will perform on
> systems with larger processes.
>
> Second, where can we get the patch? :)
>
> The URL in the first page of the paper appears to no longer exist.
>
> --
> All rights reversed.
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
