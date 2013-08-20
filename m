Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 3CF286B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 13:06:33 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id el20so516836lab.40
        for <linux-mm@kvack.org>; Tue, 20 Aug 2013 10:06:31 -0700 (PDT)
Date: Tue, 20 Aug 2013 21:06:29 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH -mm] docs: Document soft dirty behaviour for freshly created
 memory regions, v2
Message-ID: <20130820170629.GN18673@moon>
References: <20130820153132.GK18673@moon>
 <5213A002.7020408@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5213A002.7020408@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Here is updated one, thanks again.

---
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH] docs: Document soft dirty behaviour for freshly created memory regions

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
Cc: Randy Dunlap <rdunlap@infradead.org>
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
+there is still a scenario when we can lose soft dirty bits -- a task
+unmaps a previously mapped memory region and then maps a new one at exactly
+the same place. When unmap is called, the kernel internally clears PTE values
+including soft dirty bits. To notify user space application about such
+memory region renewal the kernel always marks new memory regions (and
+expanded regions) as soft dirty.
 
   This feature is actively used by the checkpoint-restore project. You
 can find more details about it on http://criu.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
