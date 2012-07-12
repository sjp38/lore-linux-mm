Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 58A526B005C
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 22:36:00 -0400 (EDT)
Message-ID: <4FFE3826.7050706@intel.com>
Date: Thu, 12 Jul 2012 10:36:22 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: AutoNUMA15
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com> <20120529133627.GA7637@shutemov.name> <20120529154308.GA10790@dhcp-27-244.brq.redhat.com> <20120531180834.GP21339@redhat.com> <CAGjg+kHNe4RkhHKt5JYKDnE2oqs0ZBNUkL_XYOwfDK1S5cxjvw@mail.gmail.com> <20120621145552.GG4954@redhat.com> <4FE96A3A.2080307@intel.com> <20120626120325.GA25956@redhat.com>
In-Reply-To: <20120626120325.GA25956@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Alex Shi <lkml.alex@gmail.com>, Petr Holasek <pholasek@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, "Chen, Tim C" <tim.c.chen@intel.com>

>

> Ok the problem is that you must not pin anything. If you hard pin
> AutoNUMA won't do anything on those processes.
> 
> It is impossible to run faster than the raw hard pinning, impossible
> because AutoNUMA has also to migrate memory, hard pinning avoids all
> memory migrations.
> 



> 
> Thanks a lot, and looking forward to see how things goes when you
> remove the hard pins.
> 



Andrea:
I continue testing specjbb2005 for your patch on 2c7535e100805d9,
removed hard pin for openjdk JVM.
On my NHM EP machine 12GB memory 16 LCPUs. Following data use each
scenario's results on 3.5-rc2 as 100% base.

			3.5-rc2 	3.5-rc2+autonuma
2 JVM, each 1GBmem 	 100%		100%
1 JVM with 2GBmem	 100%		100%

2 JVM, each 4GBmem	 100%		98%~100%
1 JVM with 4GB mem	 100%		98%~100%

So, my testing didn't find the benefit from autonuma patch, and when use
bigger memory size, the path introduce more variation and may cause 2%
performance drop. my open jdk option is "-Xmx4g -Xms4g -Xincgc"

I am wondering if the specjbb can show your patch's advantage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
