Date: Mon, 10 Mar 2003 11:50:59 +0530
From: Anand Gurumurthy <anand@rttsindia.com>
Subject: Problem with mmap( ) in linux ppc!
Message-Id: <20030310115059.2862dfb1.anand@rttsindia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,
	We have a driver for a communication card which has memory mapped IO.We are using redhat 2.2.14 kernel on intel p3 processor. The driver has an mmap entry point to map device memory into the user space using remap_page_range(). It works fine with intel P3. When we try to use the same driver with ppc linux 2.2.17 kernel, the mmap system call does not map the proper device memory.Is there anything extra  required for using mmap with ppc? Please help me with your suggestions.

Thanks,
Anand Gurumurthy. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
