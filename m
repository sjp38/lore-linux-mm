Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5BISQf0022191
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 14:28:26 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5BISLUp159430
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 12:28:21 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5BISL6h019169
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 12:28:21 -0600
Subject: Re: [BUG] 2.6.26-rc5-mm2 - kernel BUG at
	arch/x86/kernel/setup.c:388!
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <485011DF.9050606@linux.vnet.ibm.com>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
	 <485011DF.9050606@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Date: Wed, 11 Jun 2008 11:28:17 -0700
Message-Id: <1213208897.20475.19.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vegard Nossum <vegard.nossum@gmail.com>, Mike Travis <travis@sgi.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-06-11 at 23:26 +0530, Kamalesh Babulal wrote:
> Hi Andrew,
> 
> The 2.6.26-rc5-mm2 kernel panic's, while booting up on the x86_64
> box with the attached .config file.

Just to save everyone the trouble, it looks like this is a new BUG_ON().
i>>?
http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm2/broken-out/fix-x86_64-splat.patch

The machine in question is a single-node machine, but with
CONFIG_NUMA=y.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
