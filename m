Date: Wed, 10 Sep 2008 15:31:46 -0700 (PDT)
Message-Id: <20080910.153146.143573430.davem@davemloft.net>
Subject: Re: [Approach #2] [RFC][PATCH] Remove cgroup member from struct
 page
From: David Miller <davem@davemloft.net>
In-Reply-To: <1221085260.6781.69.camel@nimitz>
References: <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com>
	<20080910012048.GA32752@balbir.in.ibm.com>
	<1221085260.6781.69.camel@nimitz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Wed, 10 Sep 2008 15:21:00 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: dave@linux.vnet.ibm.com
Cc: balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, nickpiggin@yahoo.com.au, akpm@linux-foundation.org, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> This will really suck for sparse memory machines.  Imagine a machine
> with 1GB of memory at 0x0 and another 1GB of memory at 1TB up in the
> address space.

You just described the workstation I am typing this from :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
