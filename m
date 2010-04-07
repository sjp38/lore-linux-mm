Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9E5446B01F3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 03:14:34 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o377EVKa023130
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 7 Apr 2010 16:14:31 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6633545DE4C
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 16:14:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 40E5645DE4F
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 16:14:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F69FE08007
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 16:14:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F8EAE08003
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 16:14:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Arch specific mmap attributes
In-Reply-To: <20100407.000343.181989028.davem@davemloft.net>
References: <20100407095145.FB70.A69D9226@jp.fujitsu.com> <20100407.000343.181989028.davem@davemloft.net>
Message-Id: <20100407161203.FB81.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  7 Apr 2010 16:14:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: kosaki.motohiro@jp.fujitsu.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Wed,  7 Apr 2010 15:03:45 +0900 (JST)
> 
> > I'm not against changing kernel internal. I only disagree mmu
> > attribute fashion will be become used widely.
> 
> Desktop already uses similar features via PCI mmap
> attributes and such, not to mention MSR settings on
> x86.

Probably I haven't catch your mention. Why userland process
need to change PCI mmap attribute by mmap(2)? It seems kernel issue.



> So I disagree with your assesment that this is some
> HPC/embedded issue.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
