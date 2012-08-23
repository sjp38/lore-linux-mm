Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 16DF16B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 00:16:31 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <svaidy@linux.vnet.ibm.com>;
	Thu, 23 Aug 2012 09:46:27 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7N4GMFq2490686
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 09:46:22 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7N4GKlZ027981
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 14:16:22 +1000
Date: Thu, 23 Aug 2012 09:45:57 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: Re: [PATCH 33/36] autonuma: powerpc port
Message-ID: <20120823041557.GA24519@dirshya.in.ibm.com>
Reply-To: svaidy@linux.vnet.ibm.com
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
 <1345647560-30387-34-git-send-email-aarcange@redhat.com>
 <1345672907.2617.44.camel@pasglop>
 <1345676194.13399.1.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1345676194.13399.1.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Andrea Arcangeli <aarcange@redhat.com>

* Benjamin Herrenschmidt <benh@kernel.crashing.org> [2012-08-23 08:56:34]:

> On Thu, 2012-08-23 at 08:01 +1000, Benjamin Herrenschmidt wrote:
> > On Wed, 2012-08-22 at 16:59 +0200, Andrea Arcangeli wrote:
> > > From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
> > > 
> > >     * PMD flaging is not required in powerpc since large pages
> > >       are tracked in ptes.
> > >     * Yet to be tested with large pages
> > >     * This is an initial patch that partially works
> > >     * knuma_scand and numa hinting page faults works
> > >     * Page migration is yet to be observed/verified
> > > 
> > > Signed-off-by: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
> > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > I don't like this.
> 
> What I mean here is that it's fine as a proof of concept ;-) I don't
> like it being in a series aimed at upstream...

I agree.  My intend was to get the ppc64 discussions started and also
see what it takes to get autonuma to a new arch.

> We can try to flush out the issues, but as it is, the patch isn't
> upstreamable imho.

Yes.  The patch is still in RFC phase and good only for
review/testing.

> As for finding PTE bits, I have a few ideas we need to discuss, but
> nothing simple I'm afraid.

Sure Ben, lets try them and find the better fit.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
