Date: Wed, 26 Sep 2007 10:32:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 2.6.23-rc8-mm1 - powerpc memory hotplug link failure
Message-Id: <20070926103205.c72a8e8a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <46F968C2.7080900@linux.vnet.ibm.com>
References: <20070925014625.3cd5f896.akpm@linux-foundation.org>
	<46F968C2.7080900@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 26 Sep 2007 01:30:02 +0530
Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:

> Hi Andrew,
> 
> The 2.6.23-rc8-mm1 kernel linking fails on the powerpc (P5+) box
> 
>   CC      init/version.o
>   LD      init/built-in.o
>   LD      .tmp_vmlinux1
> drivers/built-in.o: In function `memory_block_action':
> /root/scrap/linux-2.6.23-rc8/drivers/base/memory.c:188: undefined reference to `.remove_memory'
> make: *** [.tmp_vmlinux1] Error 1
> 
Maybe my patch is the problem. could you give me your .config ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
