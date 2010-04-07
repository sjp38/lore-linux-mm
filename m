Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 20B306B01F0
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 03:03:43 -0400 (EDT)
Date: Wed, 07 Apr 2010 00:03:43 -0700 (PDT)
Message-Id: <20100407.000343.181989028.davem@davemloft.net>
Subject: Re: Arch specific mmap attributes
From: David Miller <davem@davemloft.net>
In-Reply-To: <20100407095145.FB70.A69D9226@jp.fujitsu.com>
References: <20100406185246.7E63.A69D9226@jp.fujitsu.com>
	<1270592111.13812.88.camel@pasglop>
	<20100407095145.FB70.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: kosaki.motohiro@jp.fujitsu.com
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed,  7 Apr 2010 15:03:45 +0900 (JST)

> I'm not against changing kernel internal. I only disagree mmu
> attribute fashion will be become used widely.

Desktop already uses similar features via PCI mmap
attributes and such, not to mention MSR settings on
x86.

So I disagree with your assesment that this is some
HPC/embedded issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
