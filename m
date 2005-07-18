Received: from p6.trlp.com (p6.trlp.com [192.168.1.66])
	by gw.trlp.com (8.11.6/8.11.6) with SMTP id j6IJKcL12527
	for <linux-mm@kvack.org>; Mon, 18 Jul 2005 12:20:38 -0700
Date: Mon, 18 Jul 2005 12:21:01 -0700
From: James Washer <washer@trlp.com>
Subject: Question about OOM-Killer
Message-Id: <20050718122101.751125ef.washer@trlp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm chasing down a system problem where the DMA memory (x86-64, god knows why it is using DMA memory) drops below the minimum, and the OOM-Killer is fired off.

It just strikes me odd that the OOM-Killer would be called at all for DMA memory. What's the chance of regaining DMA memory by killing user land processes?

I'll admit, I know very little about linux VM, so perhaps I'm missing how oom killing can be helpful here. 

 - jim
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
