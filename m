Message-Id: <20060117194942.647145000@klappe.arndb.de>
Date: Tue, 17 Jan 2006 20:49:42 +0100
From: Arnd Bergmann <arnd@arndb.de>
Subject: [RFC/PATCH 0/3] cell/spufs: new experimental features
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc64-dev@ozlabs.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jordi_caubet@es.ibm.com, Mark Nutter <mnutter@us.ibm.com>
List-ID: <linux-mm.kvack.org>

These three patches implement features that are
desired by many of the cell/spufs users in order
to improve performance and functionality of cell
specific applications.

Since they all touch very sensitive parts of the
kernel (memory management and system calls), I
would at least like a thorough review before
declaring the interfaces stable and submitting the
patches for inclusion.

	Arnd <><
-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
