Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 94A3C6B004D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 03:07:59 -0400 (EDT)
Received: by obbeh20 with SMTP id eh20so13288045obb.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 00:07:58 -0700 (PDT)
Date: Mon, 23 Apr 2012 00:06:41 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH v3 0/9] Fixes for common mistakes w/ for_each_process and
 task->mm
Message-ID: <20120423070641.GA27702@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, patches@linaro.org

Hi all,

This is another resend of several task->mm fixes, the bugs I found
during LMK code audit. Architectures were traverse the tasklist
in an unsafe manner, plus there are a few cases of unsafe access to
task->mm in general.

There were no objections on the previous resend, and the final words
were somewhere along "the patches are fine" line.

In v3:
- Dropped a controversal 'Make find_lock_task_mm() sparse-aware' patch;
- Reword arm and sh commit messages, per Oleg Nesterov's suggestions;
- Added an optimization trick in clear_tasks_mm_cpumask(): take only
  the rcu read lock, no need for the whole tasklist_lock.
  Suggested by Peter Zijlstra.

In v2: 
- introduced a small helper in cpu.c: most arches duplicate the
  same [buggy] code snippet, so it's better to fix it and move the
  logic into a common function.

Thanks,

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
