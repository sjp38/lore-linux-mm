Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 970A26B006C
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 14:38:44 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <svaidy@linux.vnet.ibm.com>;
	Sat, 7 Jul 2012 00:08:41 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q66Icb2Y12976560
	for <linux-mm@kvack.org>; Sat, 7 Jul 2012 00:08:37 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q67099cD023954
	for <linux-mm@kvack.org>; Sat, 7 Jul 2012 10:09:11 +1000
Date: Sat, 7 Jul 2012 00:08:28 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
Message-ID: <20120706183828.GB7807@dirshya.in.ibm.com>
Reply-To: svaidy@linux.vnet.ibm.com
References: <20120629125517.GD32637@gmail.com>
 <4FEDDD0C.60609@redhat.com>
 <1340995260.28750.103.camel@twins>
 <4FEDF81C.1010401@redhat.com>
 <1340996224.28750.116.camel@twins>
 <1340996586.28750.122.camel@twins>
 <4FEDFFB5.3010401@redhat.com>
 <20120702165714.GA10952@dirshya.in.ibm.com>
 <20120705165606.GA11296@dirshya.in.ibm.com>
 <CAJd=RBDAtm_9TiFgsGC=DxFxtDRP7GLeA5xAs5e6_oYS1t46rg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <CAJd=RBDAtm_9TiFgsGC=DxFxtDRP7GLeA5xAs5e6_oYS1t46rg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

* Hillf Danton <dhillf@gmail.com> [2012-07-06 21:04:56]:

> Hi Vaidy,
> 
> On Fri, Jul 6, 2012 at 12:56 AM, Vaidyanathan Srinivasan
> <svaidy@linux.vnet.ibm.com> wrote:
> > --- a/mm/autonuma.c
> > +++ b/mm/autonuma.c
> > @@ -26,7 +26,7 @@ unsigned long autonuma_flags __read_mostly =
> >  #ifdef CONFIG_AUTONUMA_DEFAULT_ENABLED
> >         (1<<AUTONUMA_FLAG)|
> >  #endif
> > -       (1<<AUTONUMA_SCAN_PMD_FLAG);
> > +       (0<<AUTONUMA_SCAN_PMD_FLAG);
> >
> 
> Let X86 scan pmd by default, agree?

Sure, yes.  This patch just lists the changes required to get the
framework running on powerpc so that we know the location of code
changes.

We will need an arch specific default flags and leave this ON for x86.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
