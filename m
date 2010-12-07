Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DCA7D6B0089
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 09:39:14 -0500 (EST)
Date: Tue, 7 Dec 2010 08:39:06 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [thisops uV3 08/18] Taskstats: Use this_cpu_ops
In-Reply-To: <20101206143256.GE3158@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1012070838020.25976@router.home>
References: <20101130190707.457099608@linux.com> <20101130190845.819605614@linux.com> <1291226786.2898.22.camel@holzheu-laptop> <alpine.DEB.2.00.1012011212490.3774@router.home> <20101206143256.GE3158@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Dec 2010, Balbir Singh wrote:

> > Correct. We need to subtract one from that (which will eliminate the minus
> > -1 that the inline this_cpu_inc_return creates).
> >
>
> But that breaks current behaviour, we should probably initialize all
> of the array to -1?

Not necessary. This_cpu_inc() uses an xadd instruction which retrieves
the value and then increments the memory location. Then it adds 1. The -1
eliminates that add.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
