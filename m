Date: Tue, 19 Aug 2003 16:30:51 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: 2.6.0-test3-mm3
Message-ID: <20030819143051.GA1261@mars.ravnborg.org>
References: <20030819013834.1fa487dc.akpm@osdl.org> <1061287775.5995.7.camel@defiant.flameeyes> <20030819032350.55339908.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030819032350.55339908.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Flameeyes <daps_mls@libero.it>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sam Ravnborg <sam@ravnborg.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2003 at 03:23:50AM -0700, Andrew Morton wrote:
> > there's a problem with make xconfig:
The following patch fixes it.
I will submit to Linus in separate mail.

	Sam

===== scripts/kconfig/Makefile 1.7 vs edited =====
--- 1.7/scripts/kconfig/Makefile	Sun Aug 17 00:17:57 2003
+++ edited/scripts/kconfig/Makefile	Tue Aug 19 16:27:03 2003
@@ -65,12 +65,20 @@
 conf-objs	:= conf.o  libkconfig.so
 mconf-objs	:= mconf.o libkconfig.so
 
-ifeq ($(MAKECMDGOALS),$(obj)/qconf)
+ifeq ($(MAKECMDGOALS),xconfig)
+	qconf-target := 1
+endif
+ifeq ($(MAKECMDGOALS),gconfig)
+	gconf-target := 1
+endif
+
+
+ifeq ($(qconf-target),1)
 qconf-cxxobjs	:= qconf.o
 qconf-objs	:= kconfig_load.o
 endif
 
-ifeq ($(MAKECMDGOALS),$(obj)/gconf)
+ifeq ($(gconf-target),1)
 gconf-objs	:= gconf.o kconfig_load.o
 endif
 
@@ -91,7 +99,7 @@
 
 $(obj)/qconf.o: $(obj)/.tmp_qtcheck
 
-ifeq ($(MAKECMDGOALS),$(obj)/qconf)
+ifeq ($(qconf-target),1)
 MOC = $(QTDIR)/bin/moc
 -include $(obj)/.tmp_qtcheck
 
@@ -121,7 +129,7 @@
 
 $(obj)/gconf.o: $(obj)/.tmp_gtkcheck
 
-ifeq ($(MAKECMDGOALS),$(obj)/gconf)
+ifeq ($(gconf-target),1)
 -include $(obj)/.tmp_gtkcheck
 
 # GTK needs some extra effort, too...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
