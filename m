From: Thomas Schlichter <schlicht@uni-mannheim.de>
Subject: Re: 2.6.0-test3-mm1
Date: Sun, 10 Aug 2003 19:41:30 +0200
References: <20030809203943.3b925a0e.akpm@osdl.org>
In-Reply-To: <20030809203943.3b925a0e.akpm@osdl.org>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_NPoN/S4mXf8+x09"
Message-Id: <200308101941.33530.schlicht@uni-mannheim.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, george@mvista.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-00=_NPoN/S4mXf8+x09
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

> kgdb-ga.patch
>   kgdb stub for ia32 (George Anzinger's one)
>   kgdbL warning fix

that patch sets DEBUG_INFO to y by default, even if whether DEBUG_KERNEL nor 
KGDB is enabled. The attached patch changes this to enable DEBUG_INFO by 
default only if KGDB is enabled.

Please apply...

Best regards
   Thomas Schlichter

--Boundary-00=_NPoN/S4mXf8+x09
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="fix_debug_info.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="fix_debug_info.diff"

--- linux-2.6.0-test3-mm1/arch/i386/Kconfig.orig	Sun Aug 10 14:25:13 2003
+++ linux-2.6.0-test3-mm1/arch/i386/Kconfig	Sun Aug 10 14:25:56 2003
@@ -1462,6 +1462,7 @@
 
 config DEBUG_INFO
 	bool
+	depends on KGDB
 	default y
 
 config KGDB_MORE

--Boundary-00=_NPoN/S4mXf8+x09--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
