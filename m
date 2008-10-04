Received: by ik-out-1112.google.com with SMTP id c21so1578665ika.6
        for <linux-mm@kvack.org>; Sat, 04 Oct 2008 14:49:52 -0700 (PDT)
Date: Sun, 5 Oct 2008 01:52:28 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC PATCH] Report the shmid backing a VMA in maps
Message-ID: <20081004215228.GA20048@x200.localdomain>
References: <1223052415-18956-1-git-send-email-mel@csn.ul.ie> <1223052415-18956-3-git-send-email-mel@csn.ul.ie> <20081004205650.CE47.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081004205650.CE47.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 04, 2008 at 09:04:03PM +0900, KOSAKI Motohiro wrote:
> In the other hand, huge page is often used via ipc shm, not mmap.
> So, administrator often want to know relationship of memory region and shmid.
> 
> Then, To add shmid attribute in /proc/{pid}/maps is useful.
> 
> 
> In addition, shmid information is not only useful for huge page, but also for normal shm.
> Then, this patch works well on normal shm.

> 2000000000500000-2000000000900000 rw-s 00000000 00:09 0                  /SYSV00000000 (deleted) (shmid=0)
> 2000000000900000-2000000000d00000 rw-s 00000000 00:09 32769              /SYSV00000000 (deleted) (shmid=32769)
							^^^^^						  ^^^^^

shmid is already in place, and no, it's not a coincidence ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
