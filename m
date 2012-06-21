Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 347B86B0078
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 03:29:54 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so278564ghr.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 00:29:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120531180834.GP21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	<20120529133627.GA7637@shutemov.name>
	<20120529154308.GA10790@dhcp-27-244.brq.redhat.com>
	<20120531180834.GP21339@redhat.com>
Date: Thu, 21 Jun 2012 15:29:52 +0800
Message-ID: <CAGjg+kHNe4RkhHKt5JYKDnE2oqs0ZBNUkL_XYOwfDK1S5cxjvw@mail.gmail.com>
Subject: Re: AutoNUMA15
From: Alex Shi <lkml.alex@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Petr Holasek <pholasek@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>

> I released an AutoNUMA15 branch that includes all pending fixes:
>
> git clone --reference linux -b autonuma15 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
>

I did a quick testing on our
specjbb2005/oltp/hackbench/tbench/netperf-loop/fio/ffsb on NHM EP/EX,
Core2 EP, Romely EP machine, In generally no clear performance change
found. Is this results expected for this patch set?

Regards!
Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
