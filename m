Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 86E286B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 09:13:11 -0400 (EDT)
Date: Thu, 12 Jul 2012 15:12:21 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
Message-ID: <20120712131221.GC20382@redhat.com>
References: <4FEDDD0C.60609@redhat.com>
 <1340995260.28750.103.camel@twins>
 <4FEDF81C.1010401@redhat.com>
 <1340996224.28750.116.camel@twins>
 <1340996586.28750.122.camel@twins>
 <4FEDFFB5.3010401@redhat.com>
 <20120702165714.GA10952@dirshya.in.ibm.com>
 <20120705165606.GA11296@dirshya.in.ibm.com>
 <CAJd=RBDAtm_9TiFgsGC=DxFxtDRP7GLeA5xAs5e6_oYS1t46rg@mail.gmail.com>
 <20120706183828.GB7807@dirshya.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120706183828.GB7807@dirshya.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Cc: Hillf Danton <dhillf@gmail.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Sat, Jul 07, 2012 at 12:08:28AM +0530, Vaidyanathan Srinivasan wrote:
> * Hillf Danton <dhillf@gmail.com> [2012-07-06 21:04:56]:
> 
> > Hi Vaidy,
> > 
> > On Fri, Jul 6, 2012 at 12:56 AM, Vaidyanathan Srinivasan
> > <svaidy@linux.vnet.ibm.com> wrote:
> > > --- a/mm/autonuma.c
> > > +++ b/mm/autonuma.c
> > > @@ -26,7 +26,7 @@ unsigned long autonuma_flags __read_mostly =
> > >  #ifdef CONFIG_AUTONUMA_DEFAULT_ENABLED
> > >         (1<<AUTONUMA_FLAG)|
> > >  #endif
> > > -       (1<<AUTONUMA_SCAN_PMD_FLAG);
> > > +       (0<<AUTONUMA_SCAN_PMD_FLAG);
> > >
> > 
> > Let X86 scan pmd by default, agree?
> 
> Sure, yes.  This patch just lists the changes required to get the
> framework running on powerpc so that we know the location of code
> changes.
> 
> We will need an arch specific default flags and leave this ON for x86.

I applied it and added the flag. Let me know if this is ok.

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commitdiff;h=1cf85a3f23326bba89d197e845ab6f7883d0efd3
http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commitdiff;h=0276c4e2f7e9c3fc856f9dd5be319c2db1761cb4

I'm trying to fix all review points before releasing a new autonuma20
but you can follow the current status on the devel origin/autonuma
branch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
