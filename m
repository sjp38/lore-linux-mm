Received: from hermes.rz.uni-sb.de (hermes.rz.uni-sb.de [134.96.7.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA18197
	for <linux-mm@kvack.org>; Thu, 18 Mar 1999 08:02:38 -0500
Message-ID: <36F0F907.7A48D010@stud.uni-sb.de>
Date: Thu, 18 Mar 1999 14:00:55 +0100
From: Manfred Spraul <masp0008@stud.uni-sb.de>
Reply-To: masp0008@stud.uni-sb.de
MIME-Version: 1.0
Subject: Re: weird calloc problem
References: <Pine.LNX.3.95.990317180745.629A-100000@chaos.analogic.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: saraniti@ece.iit.edu
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Mar 1999 19:51:32 -0600 (EST), marco saraniti
<saraniti@neumann.ece.iit.edu> said:
> I'm having a calloc problem that made me waste three weeks, at this point
> I'm out of options, and I was wondering if this can be a kernel- or
> MM-related problem. Furthermore, the system is a relatively big machine and
> I'd like to share my experience with other people who are interested in
> using Linux for number crunching.
>
> The problem is trivial: calloc returns a NULL, even if there is a lot
> of free memory. Yes, both arguments of calloc are always > 0.

you wrote 'the system is a relatively big machine'.
Perhaps you have run out of virtual memory.

How much memory do you try to allocate? (more than 1 Gigabyte?)
How much physical memory do you have?

You Could also pause the process as soon as you calloc returns NULL
(i.e. if(ptr==NULL) while(1) { printf("error!!\n");} )
and look at the informations in /proc/<pid>. The file formats are
described in 'man proc'.

Regards,
	Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
