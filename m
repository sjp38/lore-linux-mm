Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8436B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 10:18:59 -0500 (EST)
Date: Fri, 6 Nov 2009 16:18:50 +0100
Subject: Re: OOM killer, page fault
Message-ID: <20091106151850.GC3816@gamma.logic.tuwien.ac.at>
References: <20091102155543.E60E.A69D9226@jp.fujitsu.com> <20091102140216.02567ff8.kamezawa.hiroyu@jp.fujitsu.com> <20091102141917.GJ2116@gamma.logic.tuwien.ac.at> <28c262360911020640k3f9dfcdct2cac6cc1d193144d@mail.gmail.com> <20091105132109.GA12676@gamma.logic.tuwien.ac.at> <loom.20091105T213323-393@post.gmane.org> <28c262360911051418r1aefbff6oa54a63d887c0ea48@mail.gmail.com> <20091106000113.GE22289@gamma.logic.tuwien.ac.at> <20091106133833.GA23151@gamma.logic.tuwien.ac.at> <28c262360911060714h16cf55dfibbecc090c76341ab@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360911060714h16cf55dfibbecc090c76341ab@mail.gmail.com>
From: Norbert Preining <preining@logic.at>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Jody Belka <jody+lkml@jj79.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

recompiling and retrying ...

On Sa, 07 Nov 2009, Minchan Kim wrote:
> +           printk(KERN_DEBUG "fault handler : 0x%lx\n", vma->vm_ops->fault);

BTW:
	m/memory.c:2722: warning: format a??%lxa?? expects type a??long unsigned inta??, but argument 2 has type a??int (* const)(struct vm_area_struct *, struct vm_fault *)a??

Best wishes

Norbert

-------------------------------------------------------------------------------
Dr. Norbert Preining                                        Associate Professor
JAIST Japan Advanced Institute of Science and Technology   preining@jaist.ac.jp
Vienna University of Technology                               preining@logic.at
Debian Developer (Debian TeX Task Force)                    preining@debian.org
gpg DSA: 0x09C5B094      fp: 14DF 2E6C 0307 BE6D AD76  A9C0 D2BF 4AA3 09C5 B094
-------------------------------------------------------------------------------
LOWTHER (vb.)
(Of a large group of people who have been to the cinema together.) To
stand aimlessly about on the pavement and argue about whatever to go
and eat either a Chinese meal nearby or an Indian meal at a restaurant
which somebody says is very good but isn't certain where it is, or
have a drink and think about it, or just go home, or have a Chinese
meal nearby - until by the time agreement is reached everything is
shut.
			--- Douglas Adams, The Meaning of Liff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
