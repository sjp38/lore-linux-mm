Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id EFB946B0036
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 11:31:35 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id er20so429171lab.21
        for <linux-mm@kvack.org>; Tue, 20 Aug 2013 08:31:34 -0700 (PDT)
Date: Tue, 20 Aug 2013 19:31:32 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH -mm] docs: Document soft dirty behaviour for freshly created
 memory regions
Message-ID: <20130820153132.GK18673@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
---
 Documentation/vm/soft-dirty.txt |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-2.6.git/Documentation/vm/soft-dirty.txt
===================================================================
--- linux-2.6.git.orig/Documentation/vm/soft-dirty.txt
+++ linux-2.6.git/Documentation/vm/soft-dirty.txt
@@ -28,6 +28,13 @@ This is so, since the pages are still ma
 the kernel does is finds this fact out and puts both writable and soft-dirty
 bits on the PTE.
 
+  While in most cases tracking memory changes by #PF-s is more than enough
+there is still a scenario when we can loose soft dirty bit -- a task does
+unmap previously mapped memory region and then maps new one exactly at the
+same place. When unmap called the kernel internally clears PTEs values
+including soft dirty bit. To notify user space application about such
+memory region renewal the kernel always mark new memory regions (and
+expanded regions) as soft dirtified.
 
   This feature is actively used by the checkpoint-restore project. You
 can find more details about it on http://criu.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
