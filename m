Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 28EC2900136
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 17:59:29 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8DLSm26000830
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 17:28:48 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8DLxLfP241296
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 17:59:23 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8DLxAWs030430
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 15:59:11 -0600
Message-ID: <4E6FD232.6030000@linux.vnet.ibm.com>
Date: Tue, 13 Sep 2011 16:59:14 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V9 3/6] mm: frontswap: core frontswap functionality
References: <20110913174026.GA11298@ca-server1.us.oracle.com 4E6FBFC4.1080901@linux.vnet.ibm.com> <f477a147-9948-4bef-973a-1f77bd185da1@default>
In-Reply-To: <f477a147-9948-4bef-973a-1f77bd185da1@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On 09/13/2011 03:50 PM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Subject: Re: [PATCH V9 3/6] mm: frontswap: core frontswap functionality
>>
>> Hey Dan,
>>
>> I get the following compile warnings:
>>
>> mm/frontswap.c: In function 'init_frontswap':
>> mm/frontswap.c:264:5: warning: passing argument 4 of 'debugfs_create_size_t' from incompatible pointer
>> type
>> include/linux/debugfs.h:68:16: note: expected 'size_t *' but argument is of type 'long unsigned int *'
>> mm/frontswap.c:266:5: warning: passing argument 4 of 'debugfs_create_size_t' from incompatible pointer
>> type
>> include/linux/debugfs.h:68:16: note: expected 'size_t *' but argument is of type 'long unsigned int *'
>> mm/frontswap.c:268:5: warning: passing argument 4 of 'debugfs_create_size_t' from incompatible pointer
>> type
>> include/linux/debugfs.h:68:16: note: expected 'size_t *' but argument is of type 'long unsigned int *'
>> mm/frontswap.c:270:5: warning: passing argument 4 of 'debugfs_create_size_t' from incompatible pointer
>> type
>> include/linux/debugfs.h:68:16: note: expected 'size_t *' but argument is of type 'long unsigned int *'
> 
> Thanks for checking on 32-bit!
>  
>> size_t is platform dependent but is generally "unsigned int"
>> for 32-bit and "unsigned long" for 64-bit.
>>
>> I think just typecasting these to size_t * would fix it.
> 
> Actually, I think the best fix is likely to change the variables
> and the debugfs calls to u64 since even on 32-bit, the
> counters may exceed 2**32 on a heavily-loaded long-running
> system.
> 

That was going to be my other suggestion :)  I thought I'd suggest
the route that didn't involve you having to retype the counters.  But
the u64 solution is cleaner and, as Andrew pointed out, less risky.

> I'll give it a day or two to see if anyone else has any feedback
> before I fix this for V10.
> 
> Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
