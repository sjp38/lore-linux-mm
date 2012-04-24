Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 203D46B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 20:35:08 -0400 (EDT)
Message-ID: <4F95F553.5030301@kernel.org>
Date: Tue, 24 Apr 2012 09:35:31 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: Over-eager swapping
References: <20120423092730.GB20543@alpha.arachsys.com>
In-Reply-To: <20120423092730.GB20543@alpha.arachsys.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Chris Webb <chris@arachsys.com>

On 04/23/2012 06:27 PM, Richard Davies wrote:

> We run a number of relatively large x86-64 hosts with twenty or so qemu-kvm
> virtual machines on each of them, and I'm have some trouble with over-eager
> swapping on some of the machines. This is resulting in load spikes during the
> swapping and customer reports of very poor response latency from the virtual
> machines which have been swapped out, despite the hosts apparently having
> large amounts of free memory, and running fine if swap is turned off.
> 
> 
> All of the hosts are currently running a 3.1.4 or 3.2.2 kernel and have ksm
> enabled with 64GB of RAM and 2x eight-core AMD Opteron 6128 processors.
> However, we have seen this same problem since 2010 on a 2.6.32.7 kernel and
> older hardware - see http://marc.info/?l=linux-mm&m=128075337008943
> (previous helpful contributors cc:ed here - thanks).
> 
> We have /proc/sys/vm/swappiness set to 0. The kernel config is here:
> http://users.org.uk/config-3.1.4


Although you set swappiness to 0, kernel can swap out anon pages in
current implementation. I think it's a severe problem.

Couldn't this patch help you?
http://permalink.gmane.org/gmane.linux.kernel.mm/74824
It can prevent anon pages's swap out until few page cache remain.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
