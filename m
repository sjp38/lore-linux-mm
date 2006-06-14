Date: Wed, 14 Jun 2006 11:18:47 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: vfork implementation...
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMGEEECPAA.abum@aftek.com>
Message-ID: <Pine.LNX.4.64.0606141110330.2059@skynet.skynet.ie>
References: <BKEKJNIHLJDCFGDBOHGMGEEECPAA.abum@aftek.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jun 2006, Abu M. Muttalib wrote:

> This mail is intended for Robert Love, I hope I can find him on the list.
>
> Please refer to Pg 24 of chapter 2 of Linux Kernel Development.
>
> As mentioned in the description of vfork call, it is said that child is not
> allowed to write to the address space,

>From the vfork() manpage;

 	The vfork() function has the same
        effect as fork(), except that the behaviour is undefined if the process
        created  by  vfork()  either modifies any data other than a variable of
        type pid_t used to store the return value from vfork(), or returns from
        the  function  in which vfork() was called, or calls any other function
        before successfully calling _exit() or one  of  the  exec()  family  of
        functions.

In other words, the child created by vfork() may be *able* to change the 
address space, but it *should not* because the behaviour is undefined. 
IIRC, there is no guarantee that the parent will even run again until the 
child calls exit or exec so a child cannot depend on any behavior from the 
parent or it could deadlock.

Historically, the point of vfork() is to create a process that 
immediately called exec(). It does not create a copy of the parent address 
space which was an important optimisation later replaced by Copy-On-Write.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
