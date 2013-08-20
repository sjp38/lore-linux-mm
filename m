Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 21DEB6B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 14:13:09 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id ev20so576691lab.36
        for <linux-mm@kvack.org>; Tue, 20 Aug 2013 11:13:07 -0700 (PDT)
Date: Tue, 20 Aug 2013 22:13:05 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH -mm] docs: Document soft dirty behaviour for freshly created
 memory regions, v3
Message-ID: <20130820181305.GO18673@moon>
References: <20130820153132.GK18673@moon>
 <5213A002.7020408@infradead.org>
 <20130820170105.GM18673@moon>
 <5213A677.4030203@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5213A677.4030203@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Tue, Aug 20, 2013 at 10:25:11AM -0700, Randy Dunlap wrote:
> 
> Long introductory phrases usually merit a comma after them.

Ah, I see, thanks!
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
 
+  While in most cases tracking memory changes by #PF-s is more than enough,
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
