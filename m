Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 6C2166B0070
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 06:47:03 -0400 (EDT)
Date: Tue, 3 Jul 2012 12:45:39 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 04/40] xen: document Xen is using an unused bit for the
 pagetables
Message-ID: <20120703104539.GR3726@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-5-git-send-email-aarcange@redhat.com>
 <20120630044700.GA3975@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120630044700.GA3975@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hi Konrad,

On Sat, Jun 30, 2012 at 12:47:18AM -0400, Konrad Rzeszutek Wilk wrote:
> On Thu, Jun 28, 2012 at 02:55:44PM +0200, Andrea Arcangeli wrote:
> > Xen has taken over the last reserved bit available for the pagetables
> 
> Some time ago when I saw this patch I asked about it (if there is way
> to actually stop using this bit) and you mentioned it is not the last
> bit available for pagemaps. Perhaps you should alter the comment
> in this description?

As far as I can tell the comment is correct, it is the last bit
available. Simply I don't need to use it anymore. There are 3 reserved
bits, one is used by Xen, the second is used by SPECIAL the third is
used by kmemcheck.

> > which is set through ioremap, this documents it and makes the code
> 
> It actually is through ioremap, gntdev (to map another guest memory),
> and on pfns which fall in E820 on the non-RAM and gap sections.

Well I dropped this patch, there's too much other important work to
do, this is only a documentation improvement and a cleanup and I don't
need it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
