Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id AA27E6B0044
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 17:41:00 -0400 (EDT)
Received: by weys10 with SMTP id s10so39418wey.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2012 14:40:59 -0700 (PDT)
Date: Wed, 22 Aug 2012 23:40:48 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/36] AutoNUMA24
Message-ID: <20120822214048.GA3092@gmail.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
 <5035325C.3070909@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5035325C.3070909@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>


* Rik van Riel <riel@redhat.com> wrote:

> On 08/22/2012 10:58 AM, Andrea Arcangeli wrote:
> >Hello everyone,
> >
> >Before the Kernel Summit, I think it's good idea to post a new
> >AutoNUMA24 and to go through a new review cycle. The last review cycle
> >has been fundamental in improving the patchset. Thanks!
> 
> Thanks for improving the code and incorporating all our 
> feedback. The AutoNUMA codebase is now in a state where I can 
> live with it.
> 
> I hope the code will be acceptable to others, too.

Lots of scheduler changes. Has all of peterz's review feedback 
been addressed?

Hm, he isn't even Cc:-ed, how is that supposed to work?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
