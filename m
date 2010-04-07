Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C12AC6B01F2
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 03:18:47 -0400 (EDT)
Date: Wed, 07 Apr 2010 00:18:48 -0700 (PDT)
Message-Id: <20100407.001848.257489037.davem@davemloft.net>
Subject: Re: Arch specific mmap attributes
From: David Miller <davem@davemloft.net>
In-Reply-To: <20100407161203.FB81.A69D9226@jp.fujitsu.com>
References: <20100407095145.FB70.A69D9226@jp.fujitsu.com>
	<20100407.000343.181989028.davem@davemloft.net>
	<20100407161203.FB81.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: kosaki.motohiro@jp.fujitsu.com
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed,  7 Apr 2010 16:14:29 +0900 (JST)

>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Date: Wed,  7 Apr 2010 15:03:45 +0900 (JST)
>> 
>> > I'm not against changing kernel internal. I only disagree mmu
>> > attribute fashion will be become used widely.
>> 
>> Desktop already uses similar features via PCI mmap
>> attributes and such, not to mention MSR settings on
>> x86.
> 
> Probably I haven't catch your mention. Why userland process
> need to change PCI mmap attribute by mmap(2)? It seems kernel issue.

It uses PCI specific fd ioctls to change the attributes.

It's the same thing as extending the mmap() attribute space, but in a
device specific way.

I think evice and platform specific mmap() attributes are basically
inevitable, at any level, embedded or desktop or whatever.  The
fact that we've hacked around the issue with device specific
interfaces like the PCI device ioctls, is no excuse to not
tackle the issue directly and come up with something usable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
