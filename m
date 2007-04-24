Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3ONx5RG001895
	for <linux-mm@kvack.org>; Tue, 24 Apr 2007 19:59:05 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3ONx4F5127690
	for <linux-mm@kvack.org>; Tue, 24 Apr 2007 17:59:04 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3ONx48t018323
	for <linux-mm@kvack.org>; Tue, 24 Apr 2007 17:59:04 -0600
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <20070424130601.4ab89d54.akpm@linux-foundation.org>
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 24 Apr 2007 16:59:29 -0700
Message-Id: <1177459170.1281.5.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-04-24 at 13:06 -0700, Andrew Morton wrote:
> An amd64 machine is crashing badly.
> 
> http://test.kernel.org/abat/84767/debug/console.log
> 
> VFS: Mounted root (ext3 filesystem) readonly.
> Freeing unused kernel memory: 308k freed
> INIT: version 2.86 booting
> Bad page state in process 'init'
> page:ffff81007e492628 flags:0x0100000000000000 mapping:0000000000000000 mapcount:0 count:1
> Trying to fix it up, but a reboot is needed
> Backtrace:
> 
> Call Trace:
>  [<ffffffff80250d3c>] bad_page+0x74/0x10d
>  [<ffffffff80253090>] free_hot_cold_page+0x8d/0x172
...
> 
> So free_pgd_range() is freeing a refcount=1 page.  Can anyone see what
> might be causing this?  The quicklist code impacts this area more than
> anything else..
> 

Yep. quicklist patches are causing these.

making CONFIG_QUICKLIST=n didn't solve the problem. I had
to back out all quicklist patches to make my machine boot.

Thanks,
Badari


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
