Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id B2D786B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 16:58:28 -0500 (EST)
Date: Fri, 11 Jan 2013 08:58:18 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301102158.r0ALwI4i031014@como.maths.usyd.edu.au>
Subject: [RFC] Reproducible OOM with partial workaround
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org

Dear Linux-MM,

On a machine with i386 kernel and over 32GB RAM, an OOM condition is
reliably obtained simply by writing a few files to some local disk
e.g. with:
  n=0; while [ $n -lt 99 ]; do dd bs=1M count=1024 if=/dev/zero of=x$n; ((n=$n+1)); done
Crash usually occurs after 16 or 32 files written. Seems that the
problem may be avoided by using mem=32G on the kernel boot, and that
it occurs with any amount of RAM over 32GB.

I developed a workaround patch for this particular OOM demo, dropping
filesystem caches when about to exhaust lowmem. However, subsequently
I observed OOM when running many processes (as yet I do not have an
easy-to-reproduce demo of this); so as I suspected, the essence of the
problem is not with FS caches.

Could you please help in finding the cause of this OOM bug?

Please see
http://bugs.debian.org/695182
for details, in particular my workaround patch
http://bugs.debian.org/cgi-bin/bugreport.cgi?msg=101;att=1;bug=695182

(Please reply to me directly, as I am not a subscriber to the linux-mm
mailing list.)

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
