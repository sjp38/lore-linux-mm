Received: (from sct@localhost)
	by dukat.scot.redhat.com (8.9.3/8.9.3) id LAA03610
	for linux-mm@kvack.org; Mon, 11 Dec 2000 11:38:49 GMT
Resent-Message-Id: <200012111138.LAA03610@dukat.scot.redhat.com>
From: Ulrich.Weigand@de.ibm.com
Message-ID: <C12569AE.005AF14B.00@d12mta01.de.ibm.com>
Date: Thu, 7 Dec 2000 17:33:17 +0100
Subject: bug: merge_segments vs. lock_vma_mappings?
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Resent-To: linux-mm@kvack.org
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: schwidefsky@de.ibm.com
List-ID: <linux-mm.kvack.org>


Hello,

since test11, the merge_segments() routine assumes that every
VMA that it frees has been locked with lock_vma_mappings().

While most callers have been adapted to perform this locking,
at least two, do_mlock and sys_mprotect, do *not* currently.
This causes a deadlock in certain situations.

What's the correct way to fix this?  In mlock and mprotect,
potentially many segments could be freed; do we need to
call lock_vma_mappings on all of them before calling
merge_segments?


Mit freundlichen Gruessen / Best Regards

Ulrich Weigand

--
  Dr. Ulrich Weigand
  Linux for S/390 Design & Development
  IBM Deutschland Entwicklung GmbH, Schoenaicher Str. 220, 71032 Boeblingen
  Phone: +49-7031/16-3727   ---   Email: Ulrich.Weigand@de.ibm.com


-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
Please read the FAQ at http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
