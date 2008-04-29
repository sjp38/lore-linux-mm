From: Arnd Bergmann <arnd@arndb.de>
Subject: nfs shared mmap performance regression against 2.6.23
Date: Tue, 29 Apr 2008 17:18:09 +0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200804291718.10462.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, brad.benton@us.ibm.com, jroth@linux.vnet.ibm.com, mkistler@us.ibm.com, adetsch@br.ibm.com, lxie@us.ibm.com, mijo@linux.vnet.ibm.com, gerhard.stenzel@de.ibm.com, uweigand@de.ibm.com, brokensh@us.ibm.com, hannsj_uhl@de.ibm.com, brianh@linux.ibm.com, tstaudt@de.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Trond,

We had an application writer report a performance regression between
2.6.23 and later kernels that we ultimately tracked down to your
patch 94387fb1aa, "NFS: Add the helper nfs_vm_page_mkwrite". It turns
out the application was accidentally using a writable shared mmap
between two processes on an NFS mount instead of tmpfs.

The setup is fixed now, but I'm still surprised by the 7x slowdown
caused by this patch for application runtime when the mmap is shared
between two processes writing to it. If there is only one process
that maps the file, there is no measureable slowdown.

Is that an expected side-effect of your patch, or something that
should not have happened?

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
