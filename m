Received: by uproxy.gmail.com with SMTP id h2so639917ugf
        for <linux-mm@kvack.org>; Mon, 20 Mar 2006 05:37:30 -0800 (PST)
Message-ID: <bc56f2f0603200537t234d75aau@mail.gmail.com>
Date: Mon, 20 Mar 2006 08:37:30 -0500
From: "Stone Wang" <pwstone@gmail.com>
Subject: [PATCH][4/8] Documentation/vm: minor corrections
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Minor corrections of vm documentation.

Signed-off-by: Shaoping Wang <pwstone@gmail.com>

--
 hugetlbpage.txt |    2 +-
 locking         |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -urN  linux-2.6.15.orig/Documentation/vm/hugetlbpage.txt
linux-2.6.15/Documentation/vm/hugetlbpage.txt
--- linux-2.6.15.orig/Documentation/vm/hugetlbpage.txt	2006-01-02
22:21:10.000000000 -0500
+++ linux-2.6.15/Documentation/vm/hugetlbpage.txt	2006-03-06
06:30:06.000000000 -0500
@@ -59,7 +59,7 @@

 This command will try to configure 20 hugepages in the system.  The success
 or failure of allocation depends on the amount of physically contiguous
-memory that is preset in system at this time.  System administrators may want
+memory that is present in system at this time.  System administrators may want
 to put this command in one of the local rc init file.  This will enable the
 kernel to request huge pages early in the boot process (when the possibility
 of getting physical contiguous pages is still very high).
diff -urN  linux-2.6.15.orig/Documentation/vm/locking
linux-2.6.15/Documentation/vm/locking
--- linux-2.6.15.orig/Documentation/vm/locking	2006-01-02
22:21:10.000000000 -0500
+++ linux-2.6.15/Documentation/vm/locking	2006-03-07 03:43:44.000000000 -0500
@@ -37,7 +37,7 @@
 4. The exception to this rule is expand_stack, which just
    takes the read lock and the page_table_lock, this is ok
    because it doesn't really modify fields anybody relies on.
-5. You must be able to guarantee that while holding page_table_lock
+5. You must be able to guarantee that while holding mmap_sem
    or page_table_lock of mm A, you will not try to get either lock
    for mm B.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
