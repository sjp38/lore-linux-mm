Date: Sat, 12 Jul 2008 16:15:55 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUG] 2.6.26-rc8-mm1 - sleeping function called from invalid context at include/linux/pagemap.h:291
In-Reply-To: <48737CBE.4010301@linux.vnet.ibm.com>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org> <48737CBE.4010301@linux.vnet.ibm.com>
Message-Id: <20080712161058.F6A5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-testers@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andy Whitcroft <apw@shadowen.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Kamalesh,

> Hi Andrew,
> 
> While booting up and shutting down, x86 machine with 2.6.26-rc8-mm1 kernel,
> kernel bug call trace is shows up in the logs

That is known bug.
please turn off CONFIG_UNEVICTABLE_LRU.

and see below thread.

	[-mm] BUG: sleeping function called from invalid context at include/linux/pagemap.h:290





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
