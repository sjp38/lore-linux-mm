Date: Mon, 22 Sep 2003 14:48:13 +0100
From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: 2.6.0-test5-mm4
Message-ID: <20030922134813.GF7665@parcelfarce.linux.theplanet.co.uk>
References: <20030922013548.6e5a5dcf.akpm@osdl.org> <200309221317.42273.alistair@devzero.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200309221317.42273.alistair@devzero.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alistair J Strachan <alistair@devzero.co.uk>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 22, 2003 at 01:17:42PM +0100, Alistair J Strachan wrote:
> One possible explanation is that I have devfs compiled into my kernel. I do 
> not, however, have it automatically mounting on boot. It overlays /dev (which 
> is populated with original style device nodes) after INIT has loaded.

Amazingly idiotic typo.  And yes, it gets hit only if devfs is configured.

diff -u B5-real32/init/do_mounts.h B5-current/init/do_mounts.h
--- B5-real32/init/do_mounts.h	Sun Sep 21 21:22:33 2003
+++ B5-current/init/do_mounts.h	Mon Sep 22 09:41:21 2003
@@ -53,7 +53,7 @@
 static inline u32 bstat(char *name)
 {
 	struct stat64 stat;
-	if (!sys_stat64(name, &stat) != 0)
+	if (sys_stat64(name, &stat) != 0)
 		return 0;
 	if (!S_ISBLK(stat.st_mode))
 		return 0;
@@ -65,7 +65,7 @@
 static inline u32 bstat(char *name)
 {
 	struct stat stat;
-	if (!sys_newstat(name, &stat) != 0)
+	if (sys_newstat(name, &stat) != 0)
 		return 0;
 	if (!S_ISBLK(stat.st_mode))
 		return 0;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
