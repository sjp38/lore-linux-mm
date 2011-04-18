Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8D426900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 08:14:09 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1AF743EE0B5
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:14:06 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0144645DE50
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:14:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DCE4345DE4D
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:14:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC9541DB803F
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:14:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 96C111DB803B
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 21:14:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 0/3] convert mm->cpu_vm_mask into cpumask_var_t
Message-Id: <20110418211455.9359.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 18 Apr 2011 21:14:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com

Recently, I and Hugh discussed about size of mm_struct. And then, I decided
to spend some time to diet it.

Unfortunately, We don't finished to convert cpumask_size() into full
nr_cpu_ids-ism. then, We can't get full benefit of cpumask_var_t yet.
However I expect it will be solved in this or next year.


KOSAKI Motohiro (3):
  mn10300: replace mm->cpu_vm_mask with mm_cpumask
  tile: replace mm->cpu_vm_mask with mm_cpumask()
  mm: convert mm->cpu_vm_cpumask into cpumask_var_t

 Documentation/cachetlb.txt          |    2 +-
 arch/mn10300/kernel/smp.c           |    2 +-
 arch/mn10300/mm/tlb-smp.c           |    6 ++--
 arch/tile/include/asm/mmu_context.h |    4 +-
 arch/tile/kernel/tlb.c              |   12 +++++-----
 include/linux/mm_types.h            |    9 +++++--
 include/linux/sched.h               |    1 +
 init/main.c                         |    2 +
 kernel/fork.c                       |   37 ++++++++++++++++++++++++++++++++--
 mm/init-mm.c                        |    1 -
 10 files changed, 56 insertions(+), 20 deletions(-)

-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
