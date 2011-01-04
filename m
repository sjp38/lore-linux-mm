Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3D5BB6B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 05:21:48 -0500 (EST)
Date: Tue, 4 Jan 2011 05:21:46 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1343872597.121624.1294136506889.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <20110104095641.GA8651@tiehlicka.suse.cz>
Subject: Re: [RFC]
 /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> > 3) overcommit 2gb hugepages.
> > mmap(NULL, 18446744071562067968, PROT_READ|PROT_WRITE, MAP_SHARED,
> > 3, 0) = -1 ENOMEM (Cannot allocate memory)
> 
> Hmm, you are trying to reserve/mmap a lot of memory (17179869182 1GB
> huge pages).
That is strange - the test code merely did this,
addr = mmap(ADDR, 2<<30, PROTECTION, FLAGS, fd, 0);

Do you know if overcommit was designed for 1GB pages? At least, read this
from Documentation/kernel-parameters.txt,

hugepagesz=
              ...
             Note that 1GB pages can only be allocated at boot time
             using hugepages= and not freed afterwards.

How does it allow to be overcommitted for only being able to allocate at
boot time?

> > Also, nr_overcommit_hugepages was overwritten with such a strange
> > value after overcommit failure. Should we just remove this file from
> > sysfs for simplicity?
> 
> This is strange. The value is set only in hugetlb_overcommit_handler
> which is a sysctl handler.
> 
> Are you sure that you are not changing the value by the /sys interface
> somewhere (there is no check for the value so you can set what-ever
> value you like)? I fail to see any mmap code path which would change
> this value.
I could double-check here, but it is not important if the fact is that
overcommit is not supported for 1GB pages.

> Btw. which kernel version are you using.
mmotm 2010-12-02-16-34 version 2.6.37-rc4-mm1+. This problem is also present
in 2.6.18.

Thanks.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
