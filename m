Subject: Re: Process not given >890MB on a 4MB machine ?????????
References: <Pine.GSO.4.05.10109251335380.23459-100000@aa.eps.jhu.edu>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 26 Sep 2001 01:04:00 -0600
In-Reply-To: <Pine.GSO.4.05.10109251335380.23459-100000@aa.eps.jhu.edu>
Message-ID: <m1n13i5t7j.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: afei@jhu.edu
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Joseph A Knapka <jknapka@earthlink.net>, "Gabriel.Leen" <Gabriel.Leen@ul.ie>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

afei@jhu.edu writes:

> The current Linux MM design is a 3:1 split of 4G virtual/physical memory.
> So a process, under normal condition cannot get beyond 3G memory
> allocated.

The current Linux i386 MM usage is a 3:1 split of 4G virtual
memory. 3GB for the uesr process.  1GB for the kernel.  With all of
the highmem tricks the kernel can access up to 16TB of physical memory
on a 32 bit system but the i386 architeture only provides for a
maximum of 64GB of physical memory.

A user space process is free to implement it's own paging of a file or
a shared memory region in and out of it's address space but that
usually requires code redesign, so few people go for it.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
