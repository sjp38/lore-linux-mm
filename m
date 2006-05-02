From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 02 May 2006 15:25:46 +1000
Message-Id: <20060502052546.8990.33000.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
Subject: [RFC 0/3] IA64 Long Format VHPT support
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org, Ian Wienand <ianw@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

Hi,

Following from this message are patches to enable the Long Format VHPT
on IA64, which I am posting in the hope of community review.  They are
against 2.6.17-rc3, and work for machines I have access to.  These
patches have long been a chicken-egg problem, but I believe that there
are now multiple people interested in using LVHPT for dynamic page
size support in some form.

There are two papers which reference this work

Itanium Page Tables and TLB
Matthew Chapman, Ian Wienand, Gernot Heiser
http://citeseer.ist.psu.edu/chapman03itanium.html

Itanium - A System Implementor's Tale
Charles Gray, Matthew Chapman, Peter Chubb, David Mosberger-Tang, Gernot Heiser
http://www.usenix.org/events/usenix05/tech/general/gray/gray_html/index.html

Any comments are welcomed.

-i

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
