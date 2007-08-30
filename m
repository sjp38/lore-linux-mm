Date: Thu, 30 Aug 2007 14:38:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm PATCH] Memory controller improve user interface
Message-Id: <20070830143859.e9d3511a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <46D5F517.1080809@linux.vnet.ibm.com>
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
	<1188413148.28903.113.camel@localhost>
	<46D5ED5C.9030405@linux.vnet.ibm.com>
	<1188425894.28903.140.camel@localhost>
	<6599ad830708291520t2bc9ea20m2bdcd9e042b3a423@mail.gmail.com>
	<1188426352.28903.143.camel@localhost>
	<46D5F517.1080809@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Dave Hansen <haveblue@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Aug 2007 04:07:11 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 1. Several people recommended it
> 2. Herbert mentioned that they've moved to that interface and it
>    was working fine for them.
> 

I have no strong opinion. But how about Mega bytes ? (too big ?)
There will be no rounding up/down problem.

-Kame.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
