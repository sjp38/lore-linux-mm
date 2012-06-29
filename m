Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 94BB46B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 08:55:23 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so2828787wgb.26
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 05:55:21 -0700 (PDT)
Date: Fri, 29 Jun 2012 14:55:17 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
Message-ID: <20120629125517.GD32637@gmail.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-14-git-send-email-aarcange@redhat.com>
 <1340895238.28750.49.camel@twins>
 <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>


* Hillf Danton <dhillf@gmail.com> wrote:

> On Thu, Jun 28, 2012 at 10:53 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> >
> > Unless you're going to listen to feedback I give you, I'm 
> > going to completely stop reading your patches, I don't give 
> > a rats arse you work for the same company anymore.
> 
> Are you brought up, Peter, in dirty environment with mind 
> polluted?

You do not seem to be aware of the history of this patch-set,
I suspect Peter got "polluted" by Andrea ignoring his repeated 
review feedbacks...

If his multiple rounds of polite (and extensive) review didn't 
have much of an effect then maybe some amount of not so nice 
shouting has more of an effect?

The other option would be to NAK and ignore the patchset, in 
that sense Peter is a lot more constructive and forward looking 
than a polite NAK would be, even if the language is rough.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
