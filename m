Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 0C2EF6B0044
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 06:27:20 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so4262776bkw.14
        for <linux-mm@kvack.org>; Sat, 24 Mar 2012 03:27:19 -0700 (PDT)
Date: Sat, 24 Mar 2012 14:26:12 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH v2 0/10] Fixes for common mistakes w/ for_each_process and
 task->mm
Message-ID: <20120324102609.GA28356@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

Hi all,

This is a reincarnation of the task->mm fixes. Several architectures
were traverse the tasklist in an unsafe manner, plus there are a
few cases of unsafe access to task->mm.

In v2 I decided to introduce a small helper in cpu.c: most arches
duplicate the same [buggy] code snippet, so it's better to fix it
and move the logic into a common function.

Thanks!

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
