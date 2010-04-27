Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 15DA16B01F2
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 12:19:48 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <8ea19b02-d4d8-4000-9842-fec7f5bcf90d@default>
Date: Tue, 27 Apr 2010 09:19:30 -0700 (PDT)
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: linux-next: April 27 (mm/page-writeback)
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Linux-Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Linux-Next <linux-next@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

When CONFIG_BLOCK is not enabled:

mm/page-writeback.c:707: error: dereferencing pointer to incomplete type
mm/page-writeback.c:708: error: dereferencing pointer to incomplete type

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
