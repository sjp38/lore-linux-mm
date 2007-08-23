Date: Wed, 22 Aug 2007 19:06:26 -0600
From: Valerie Henson <val@nmt.edu>
Subject: [ANNOUNCE] ebizzy 0.2 released
Message-ID: <20070823010626.GC11402@rainbow>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Rodrigo Rubira Branco <rrbranco@br.ibm.com>, Brian Twichell <twichell@us.ibm.com>, Yong Cai <ycai@us.ibm.com>
List-ID: <linux-mm.kvack.org>

ebizzy is designed to generate a workload resembling common web
application server workloads.  It is especially useful for testing
changes to memory management, and whenever a highly threaded
application with a large working set and many vmas is needed.

This is release 0.2 of ebizzy.  It reports a rate of transactions per
second, compiles on Solaris, and scales better.  Thanks especially to
Rodrigo Rubira Branco, Brian Twichell, and Yong Cai for their work on
this release.

Available for download at the fancy new Sourceforge site:

http://sourceforge.net/projects/ebizzy/

ChangeLog below.

-VAL

2008-08-15 Valerie Henson <val@nmt.edu>

        * Release 0.2.

        * Started reporting a rate of transactions per second rather than
                just measuring the time.

        * Solaris compatibility, thanks to Rodrigo Rubira Branco
                <rrbranco@br.ibm.com> for frequent patches and testing.

        * rand() was limiting scalability, use cheap dumb inline "random"
                function to avoid that.  Thanks to Brian Twichell
                <twichell@us.ibm.com> for finding it and Yong Cai
                <ycai@us.ibm.com> for testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
