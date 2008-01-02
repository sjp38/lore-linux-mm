Date: Wed, 2 Jan 2008 22:23:34 -0000
From: "Rodrigo Rubira Branco (BSDaemon)" <rodrigo@kernelhacking.com>
Reply-to: "Rodrigo Rubira Branco (BSDaemon)" <rodrigo@kernelhacking.com>
Subject: [ANNOUNCE] ebizzy 0.3 released
Content-Transfer-Encoding: 7BIT
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Message-Id: <20080103002334.58FC78BD86@mail.fjaunet.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tech-kern@netbsd.org, "linux-kernel@vger.kernel.org"@fjaunet.com.br, "linux-mm@kvack.org"@fjaunet.com.br
List-ID: <linux-mm.kvack.org>

ebizzy is designed to generate a workload resembling common web application
server workloads.  It is especially useful for testing
changes to memory management, and whenever a highly threaded application
with a large working set and many vmas is needed.

This is release 0.3 of ebizzy.  It reports a rate of transactions per
second, compiles on Linux/Solaris/FreeBSD/HPUX, and scales better.

Available for download at:

http://ebizzy.sf.net



Rodrigo (BSDaemon).

--
http://www.kernelhacking.com/rodrigo

Kernel Hacking: If i really know, i can hack

GPG KeyID: 1FCEDEA1



________________________________________________
Message sent using UebiMiau 2.7.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
