Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id ED4EF6B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 20:01:54 -0400 (EDT)
Message-ID: <4A8B40DD.6020304@redhat.com>
Date: Tue, 18 Aug 2009 20:01:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: New patch for Linux
References: <4353.132.70.1.75.1249546446.squirrel@webmail.cs.biu.ac.il>    <1249548768.32113.68.camel@twins>    <1466.77.126.168.195.1249763409.squirrel@webmail.cs.biu.ac.il>    <4A7E03B4.8010503@redhat.com>    <1085.77.126.199.142.1249842457.squirrel@webmail.cs.biu.ac.il>    <4A803F62.2050006@redhat.com>    <1703.77.126.199.142.1249923286.squirrel@webmail.cs.biu.ac.il>    <4A805FFF.7090805@redhat.com> <2844.77.125.85.118.1249966912.squirrel@webmail.cs.biu.ac.il>
In-Reply-To: <2844.77.125.85.118.1249966912.squirrel@webmail.cs.biu.ac.il>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: wiseman@macs.biu.ac.il
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

Yair Wiseman wrote:
> We discussed interactive processes in sections 4.5 and 5.5 of our paper and show that it works well, so there is no
> problem to have even slice time of one minute.

Makes sense.  Do you, or any of your students or colleagues,
have plans to forward port the code to the current upstream
kernel?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
