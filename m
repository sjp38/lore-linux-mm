Date: Wed, 06 Nov 2002 13:20:45 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: 2.5.46-mm1
Message-ID: <192390000.1036610445@baldur.austin.ibm.com>
In-Reply-To: <20021106171249.GB29935@stingr.net>
References: <3DC8D423.DAD2BF1A@digeo.com>
 <20021106171249.GB29935@stingr.net>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1039320887=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul P Komkoff Jr <i@stingr.net>, lkml <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@zip.com.au>
List-ID: <linux-mm.kvack.org>

--==========1039320887==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--On Wednesday, November 06, 2002 20:12:50 +0300 Paul P Komkoff Jr
<i@stingr.net> wrote:

> Why sharepte is dependent on highmem now ?

It's not supposed to be.  I'm guessing it's a conversion error in the move
to Kconfig.  A patch to fix it is attached.

> I thought I will benefit from it on forkloads on lowmem too ...

It's definitely a benefit for all sizes of memory.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1039320887==========
Content-Type: text/plain; charset=us-ascii; name="shpte-2.5.46-mm1-1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="shpte-2.5.46-mm1-1.diff"; size=425

--- 2.5.46-mm1/arch/i386/Kconfig	2002-11-06 13:17:20.000000000 -0600
+++ 2.5.46-mm1-shsent/arch/i386/Kconfig	2002-11-06 11:38:50.000000000 -0600
@@ -722,7 +722,6 @@
 
 config SHAREPTE
 	bool "Share 3rd-level pagetables between processes"
-	depends on HIGHMEM4G || HIGHMEM64G
 	help
 	  Normally each address space has its own complete page table for all
 	  its mappings.  This can mean many mappings of a set of shared data

--==========1039320887==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
