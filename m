Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 022136B0072
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 11:04:57 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 11 Jan 2013 11:04:28 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 74684C90078
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 11:04:10 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0BG46C326673224
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 11:04:06 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0BG45Zr016740
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 11:04:06 -0500
Message-ID: <50F037F2.8040301@linux.vnet.ibm.com>
Date: Fri, 11 Jan 2013 08:04:02 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] Reproducible OOM with partial workaround
References: <201301110146.r0B1kF4T032208@como.maths.usyd.edu.au>
In-Reply-To: <201301110146.r0B1kF4T032208@como.maths.usyd.edu.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/10/2013 05:46 PM, paul.szabo@sydney.edu.au wrote:
>> > ... I don't believe 64GB of RAM has _ever_ been booted on a 32-bit
>> > kernel without either violating the ABI (3GB/1GB split) or doing
>> > something that never got merged upstream ...
> Sorry to be so contradictory:
> 
> psz@como:~$ uname -a
> Linux como.maths.usyd.edu.au 3.2.32-pk06.10-t01-i386 #1 SMP Sat Jan 5 18:34:25 EST 2013 i686 GNU/Linux
> psz@como:~$ free -l
>              total       used       free     shared    buffers     cached
> Mem:      64446900    4729292   59717608          0      15972     480520
> Low:        375836     304400      71436
> High:     64071064    4424892   59646172
> -/+ buffers/cache:    4232800   60214100
> Swap:    134217724          0  134217724

Hey, that's pretty cool!  I would swear that the mem_map[] overhead was
such that they wouldn't boot, but perhaps those brain cells died on me.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
