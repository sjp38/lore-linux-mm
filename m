Date: Mon, 2 Jun 2003 05:07:53 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: pgcl-2.5.70-bk7-1
Message-ID: <20030602120753.GE20413@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fix some oddities in and around arch/i386/kernel/srat.c, with some
cleanups attached.

Otherwise a brute-force merge to 2.5.70-bk7. Also available as an
incremental diff against pgcl-2.5.70-bk6-1 as pgcl-2.5.70-bk6-2.

Testers, especially x440-based testers, please update to this release.

Still hunting for the sysenter bug. There's also a report of an LTP
regression the tester didn't send in an oops for. Things like fsx would
also be helpful, e.g. on fs's with blocksize > 4KB with MMUPAGES_SIZE
== 4KB, especially with aio and direct io involved.

Unified anonymizing fault handling is also scheduled to happen "soon",
at which point the core performance code should be finalized, modulo
stability regressions to be fixed up as needed and tuning. Then things
should move on to drivers/ and fs/ sweeps.

As usual, available from:
ftp://ftp.kernel.org/pub/linux/kernel/people/wli/vm/pgcl/


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
