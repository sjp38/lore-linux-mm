Received: from manet.magma-da.com (manet.magma-da.com [10.1.1.173])
	by magma-da.com (8.9.3+Sun/8.9.3) with ESMTP id CAA05848
	for <linux-mm@kvack.org>; Sat, 25 Nov 2000 02:45:05 -0800 (PST)
Date: Sat, 25 Nov 2000 02:45:05 -0800 (PST)
Message-Id: <200011251045.CAA07659@manet.magma-da.com>
From: Raymond Nijssen <raymond.nijssen@Magma-DA.COM>
Subject: Re: max memory limits ??? 
In-Reply-To: <3A1BCC05.4080608@SANgate.com>; from gabriel@SANgate.com on Wed, Nov 22, 2000 at 03:37:09PM +0200 
References: <3A1BCC05.4080608@SANgate.com> 
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>Matti Aarnio <matti.aarnio@zmailer.org> wrote:
>On Wed, Nov 22, 2000 at 03:37:09PM +0200, BenHanokh Gabriel wrote:

>> can some1 explain the memory limits on the 2.4 kernel

>> - what is the limit for user-space apps ?

>        At 32 bit systems:  3.5 GB with extreme tricks, 3 GB for more usual.


What are those tricks?   Do they involve changing TASK_SIZE ?

And why do programs get mapped at 0x08000000 instead of 0x00001000 ?
This is wasting another 5% of the addressing space.

Please CC me on your reply.

Thanks,
-Raymond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
