Subject: RE: Memory Leak Detection and Kernel Memory monitoring tool
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <05B7784238A51247A0A9FB4B348CECAE01D768E5@PNE-HJN-MBX01.wipro.com>
References: <05B7784238A51247A0A9FB4B348CECAE01D768E5@PNE-HJN-MBX01.wipro.com>
Content-Type: text/plain
Date: Fri, 16 Jun 2006 14:12:32 +0200
Message-Id: <1150459952.28517.2.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kaustav.majumdar@wipro.com
Cc: penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Actually I was trying for 2.6.15.4.

Why don't you develop against the latest kernel, with all the nice new
features you want? This is easier for upstream submission too.

If you really want your kernel-driver to work for this old kernel, back
port it when it proves itself stable.

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
