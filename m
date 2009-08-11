Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9626B004F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 01:02:11 -0400 (EDT)
Message-ID: <2844.77.125.85.118.1249966912.squirrel@webmail.cs.biu.ac.il>
In-Reply-To: <4A805FFF.7090805@redhat.com>
References: <4353.132.70.1.75.1249546446.squirrel@webmail.cs.biu.ac.il>
    <1249548768.32113.68.camel@twins>
    <1466.77.126.168.195.1249763409.squirrel@webmail.cs.biu.ac.il>
    <4A7E03B4.8010503@redhat.com>
    <1085.77.126.199.142.1249842457.squirrel@webmail.cs.biu.ac.il>
    <4A803F62.2050006@redhat.com>
    <1703.77.126.199.142.1249923286.squirrel@webmail.cs.biu.ac.il>
    <4A805FFF.7090805@redhat.com>
Date: Tue, 11 Aug 2009 08:01:52 +0300 (IDT)
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

We discussed interactive processes in sections 4.5 and 5.5 of our paper and show that it works well, so there is no
problem to have even slice time of one minute.

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
>> It will work for larger amounts of memory. We just have to choose a longer time slice.
>
> Sounds simple, but in practice you will run into the fact that users
> don't really mind a 1 second latency during thrashing, but the 1 minute
> (or more) latencies that may be required for this scheme to scale to
> very large memory systems may be totally unacceptable.
>
>> I will try to find a newer
>> version, but I do not see the difference in this case.
>  > We just suggest to replace the LRU-token approach.
>
> I have no problem with replacing the LRU-token, if we can find
> something that is shown to work better.  BSD style process
> suspension has been tried many times on Linux and it never seemed
> to work right.
>
> Maybe your approach can be made to automatically work right on
> machines of all memory sizes, but it would be good to demonstrate
> that before committing to such a change.
>
> --
> All rights reversed.
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
