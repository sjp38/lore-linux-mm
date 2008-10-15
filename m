From: "Wildman, Tom" <tom.wildman@hp.com>
Date: Wed, 15 Oct 2008 01:51:30 +0000
Subject: Superpages Project  -  sourceforge.net/projects/linuxsuperpages
Message-ID: <F9E7AD49A6823D4AA5A36E1DE32F0F9B27570B8CBC@GVW1092EXB.americas.hpqcorp.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "alan@redhat.com" <alan@redhat.com>
List-ID: <linux-mm.kvack.org>

A new project has been created at SourceForge with an implementation of the Rice University's Superpages FreeBSD prototype that has been ported to the 2.6 Linux kernel for IA64, x86-64, and x86-32.

The project can be found at:  http://sourceforge.net/projects/linuxsuperpages

The major benefit of supporting Superpages is increased memory reach of the processor's TLB, which reduces the number of TLB misses in applications that have large data sets.  Some benchmarks have been improved 20% in execution time.

Reference www.cs.rice.edu/~jnavarro/superpages/ for more information about the Rice University's Superpages project.

The project is being made available to the Open Source community to share the implementation and knowledge.  With the enhancements to the x86 architectures to support multiple and large page sizes there should be increased interest in this functionality.

/Tom

Tom Wildman
Hewlett-Packard Company
200 Forest Street                    Phone: 978.841.7648
Marlboro, MA  01752                  Email: tom.wildman@hp.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
