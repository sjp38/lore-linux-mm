Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 66C1382F65
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 16:42:02 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so187740030pac.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 13:42:01 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id yk4si31235804pbb.206.2015.09.28.13.42.01
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 13:42:01 -0700 (PDT)
Subject: Re: [PATCH 25/25] x86, pkeys: Documentation
References: <20150928191817.035A64E2@viggo.jf.intel.com>
 <20150928191827.0BDF3C64@viggo.jf.intel.com>
 <874miez3jz.fsf@tassilo.jf.intel.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5609A615.1000302@sr71.net>
Date: Mon, 28 Sep 2015 13:41:57 -0700
MIME-Version: 1.0
In-Reply-To: <874miez3jz.fsf@tassilo.jf.intel.com>
Content-Type: multipart/mixed;
 boundary="------------090305070201060607020807"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

This is a multi-part message in MIME format.
--------------090305070201060607020807
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

On 09/28/2015 01:34 PM, Andi Kleen wrote:
> Do you have a manpage for the new syscall too?

Yep, I just added it to the mprotect() manpage.

--------------090305070201060607020807
Content-Type: text/x-patch;
 name="mprotect_key.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mprotect_key.patch"

diff --git a/man2/mprotect.2 b/man2/mprotect.2
index ae305f6..5ba6c58 100644
--- a/man2/mprotect.2
+++ b/man2/mprotect.2
@@ -38,16 +38,19 @@
 .\"
 .TH MPROTECT 2 2015-07-23 "Linux" "Linux Programmer's Manual"
 .SH NAME
-mprotect \- set protection on a region of memory
+mprotect, mprotect_key \- set protection on a region of memory
 .SH SYNOPSIS
 .nf
 .B #include <sys/mman.h>
 .sp
 .BI "int mprotect(void *" addr ", size_t " len ", int " prot );
+.BI "int mprotect_key(void *" addr ", size_t " len ", int " prot , " unsigned long " key);
 .fi
 .SH DESCRIPTION
 .BR mprotect ()
-changes protection for the calling process's memory page(s)
+and
+.BR mprotect_key ()
+change protection for the calling process's memory page(s)
 containing any part of the address range in the
 interval [\fIaddr\fP,\ \fIaddr\fP+\fIlen\fP\-1].
 .I addr
@@ -74,10 +77,18 @@ The memory can be modified.
 .TP
 .B PROT_EXEC
 The memory can be executed.
+.PP
+.I key
+is the protection or storage key to assign to the memory.
+The number of keys supported is dependent on the architecture
+and is always at least one.
+The default key is 0.
 .SH RETURN VALUE
 On success,
 .BR mprotect ()
-returns zero.
+and
+.BR mprotect_key ()
+return zero.
 On error, \-1 is returned, and
 .I errno
 is set appropriately.

--------------090305070201060607020807--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
