Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5E8786B0062
	for <linux-mm@kvack.org>; Sat,  8 Aug 2009 19:01:31 -0400 (EDT)
Message-ID: <4A7E03B4.8010503@redhat.com>
Date: Sat, 08 Aug 2009 19:01:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: New patch for Linux
References: <4353.132.70.1.75.1249546446.squirrel@webmail.cs.biu.ac.il>    <1249548768.32113.68.camel@twins> <1466.77.126.168.195.1249763409.squirrel@webmail.cs.biu.ac.il>
In-Reply-To: <1466.77.126.168.195.1249763409.squirrel@webmail.cs.biu.ac.il>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: wiseman@macs.biu.ac.il
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

Yair Wiseman wrote:

> Thanks for your quick response. Our patch is indeed an extension
 > of the LRU-token approach.

The paper looks very promising, but I have a few questions.

First, why is a 1 second medium timeslice enough when processes
on modern systems are often hundreds of megabytes in size?

In one second, a disk can handle about 100 seeks, which corresponds
to 100 truly random swapin IOs. I see that a lot of the testing in
your paper was done with smaller processes on smaller memory systems,
which makes me very curious about how your algorithm will perform on
systems with larger processes.

Second, where can we get the patch? :)

The URL in the first page of the paper appears to no longer exist.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
