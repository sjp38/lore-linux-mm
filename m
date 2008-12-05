Message-Id: <6.2.5.6.2.20081205135900.01c3ec18@binnacle.cx>
Date: Fri, 05 Dec 2008 14:04:59 -0500
From: starlight@binnacle.cx
Subject: Re: [Bug 12134] New: can't shmat() 1GB hugepage segment
    from second process more than one time
In-Reply-To: <1228503462.13428.36.camel@localhost.localdomain>
References: <bug-12134-27@http.bugzilla.kernel.org/>
 <20081201181459.49d8fcca.akpm@linux-foundation.org>
 <1228245880.13482.19.camel@localhost.localdomain>
 <6.2.5.6.2.20081203221021.01cf8e88@binnacle.cx>
 <1228497450.13428.26.camel@localhost.localdomain>
 <6.2.5.6.2.20081205124907.01c38670@binnacle.cx>
 <1228503462.13428.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, Andy Whitcroft <apw@shadowen.org>, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>

At 12:57 12/5/2008 -0600, Adam Litke wrote:
>Great.  I was going to ask you to disable mlock() as well.  Is this the
>same machine that was running your workload on RHEL4 successfully?

No, that was a an old Athlon 4800+ dev box.

>One theory I've been contemplating is that, with all of the mlocking and
>threads, you might be running out of memory for page tables and that
>perhaps the hugetlb code is not handling that case correctly.

Seems unlikely.  Have 13GB of free RAM.

>When do
>the bad pmd messages appear?  When the daemon starts?  When the first
>separate process attaches?  When the second one does?  or later?

Only after a starting, stopping and attempting to restart the
server daemon.  The 'dmesg' errors don't appear synchronously
with the initial failure.

>
>> >If so, I could quickly bisect the kernel and identify the guilty 
>> >patch.  Without the program, I am left stabbing in the dark. 
>> >Could you try on a 2.6.18 kernel to see if it works or not?  
>> >Thanks.
>> 
>> Any particular version of 2.6.18?
>
>Nothing specific.  You could try 2.6.18.8 (latest -stable).  We could
>probably bisect this with approximately 8 kernel build-boot-test cycles
>if you are willing to engage on that.  I am looking forward to your
>disabled-mlock() results.

Ok, but this could take awhile.  Can only spare a few hours
a week on it.  Hopefully my suspicion of the fork() call is
on target.  Forking a 3GB process seems like an extreme
operation to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
