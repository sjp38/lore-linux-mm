Date: Wed, 17 Sep 2003 21:48:03 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: 2.6.0-test5-mm2
Message-ID: <20030917194803.GA12177@mars.ravnborg.org>
References: <20030914234843.20cea5b3.akpm@osdl.org> <1063646389.1311.0.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1063646389.1311.0.camel@teapot.felipe-alfaro.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 15, 2003 at 07:19:50PM +0200, Felipe Alfaro Solana wrote:
> On Mon, 2003-09-15 at 08:48, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test5/2.6.0-test5-mm2/
> 
> > Changes since 2.6.0-test5-mm1:
> 
> Hmmm...
> 
> "make rpm" support is broken in 2.6.0-test5-mm2. However, it works fine
> with 2.6.0-test5-bk3.

I broke that as part of the separate output directory patch.
The following should fix it.

Andrew, I will come up with a better patch tomorrow.

	Sam

===== Makefile 1.428 vs edited =====
--- 1.428/Makefile	Thu Sep 11 12:01:23 2003
+++ edited/Makefile	Wed Sep 17 21:46:41 2003
@@ -97,7 +97,7 @@
 # We process the rest of the Makefile if this is the final invocation of make
 ifeq ($(skip-makefile),)
 
-srctree		:= $(if $(KBUILD_SRC),$(KBUILD_SRC),.)
+srctree		:= $(if $(KBUILD_SRC),$(KBUILD_SRC),$(CURDIR))
 TOPDIR		:= $(srctree)
 # FIXME - TOPDIR is obsolete, use srctree/objtree
 objtree		:= $(CURDIR)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
