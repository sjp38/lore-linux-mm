Date: Mon, 12 Feb 2007 14:50:40 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: build error: allnoconfig fails on mincore/swapper_space
Message-Id: <20070212145040.c3aea56e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2.6.20-git8 on x86_64:


  LD      init/built-in.o
  LD      .tmp_vmlinux1
mm/built-in.o: In function `sys_mincore':
(.text+0xe584): undefined reference to `swapper_space'
make: *** [.tmp_vmlinux1] Error 1

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
