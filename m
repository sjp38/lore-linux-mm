Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 0DC3A6B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 13:38:56 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so3757954wgb.26
        for <linux-mm@kvack.org>; Tue, 29 May 2012 10:38:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120529163849.GF21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-14-git-send-email-aarcange@redhat.com> <1338297385.26856.74.camel@twins>
 <20120529163849.GF21339@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 May 2012 10:38:34 -0700
Message-ID: <CA+55aFwmhM2a2HjB_MEjVDDL-AP4j-t202ozmHgT0azSptjnoA@mail.gmail.com>
Subject: Re: [PATCH 13/35] autonuma: add page structure fields
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Tue, May 29, 2012 at 9:38 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Tue, May 29, 2012 at 03:16:25PM +0200, Peter Zijlstra wrote:
>> 24 bytes per page.. or ~0.6% of memory gone. This is far too great a
>> price to pay.
>
> I don't think it's too great, memcg uses for half of that and yet
> nobody is booting with cgroup_disable=memory even on not-NUMA servers
> with less RAM.

A big fraction of one percent is absolutely unacceptable.

Our "struct page" is one of our biggest memory users, there's no way
we should cavalierly make it even bigger.

It's also a huge performance sink, the cache miss on struct page tends
to be one of the biggest problems in managing memory. We may not ever
fix that, but making struct page bigger certainly isn't going to help
the bad cache behavior.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
