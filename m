Subject: Re: [PATCH] Config.help entry for CONFIG_HUGETLB_PAGE
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <480345900.1031731504@[10.10.2.3]>
References: <1031755731.1990.262.camel@spc9.esa.lanl.gov>
	<480345900.1031731504@[10.10.2.3]>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 11 Sep 2002 09:17:54 -0600
Message-Id: <1031757474.1990.266.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@zip.com.au>, "Seth, Rohit" <rohit.seth@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2002-09-11 at 09:05, Martin J. Bligh wrote:
>  
> > +CONFIG_HUGETLB_PAGE
> > +  This enables support for huge pages (4MB for x86).  User space
> > +  applications can make use of this support with the sys_alloc_hugepages
> > +  and sys_free_hugepages system calls.  If your applications are
> > +  huge page aware and your processor (Pentium or later for x86) supports
> > +  this, then say Y here.
> > +
> > +  Otherwise, say N.
> 
> They're not always 4Mb on x86 ... they're 2Mb if you have PAE 
> turned on ... maybe just leave out the "(4MB for x86)" comment?
> 
> M.

Better?

--- linux-2.5.34-mm1/arch/i386/Config.help.orig	Wed Sep 11 07:54:49 2002
+++ linux-2.5.34-mm1/arch/i386/Config.help	Wed Sep 11 09:14:52 2002
@@ -25,6 +25,15 @@
 
   If you don't know what to do here, say N.
 
+CONFIG_HUGETLB_PAGE
+  This enables support for huge pages.  User space applications
+  can make use of this support with the sys_alloc_hugepages and
+  sys_free_hugepages system calls.  If your applications are
+  huge page aware and your processor (Pentium or later for x86)
+  supports this, then say Y here.
+
+  Otherwise, say N.
+
 CONFIG_PREEMPT
   This option reduces the latency of the kernel when reacting to
   real-time or interactive events by allowing a low priority process to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
