Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 238896B0125
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:30:39 -0400 (EDT)
Date: Mon, 25 Jun 2012 22:31:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/11] memcg: propagate kmem limiting information to
 children
Message-Id: <20120625223136.86ebee05.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1206252224350.30072@chino.kir.corp.google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
	<1340633728-12785-10-git-send-email-glommer@parallels.com>
	<20120625162352.51997c5a.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1206252224350.30072@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Mon, 25 Jun 2012 22:24:44 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> > > +#define KMEM_ACCOUNTED_THIS	0
> > > +#define KMEM_ACCOUNTED_PARENT	1
> > 
> > And then document the fields here.
> > 
> 
> In hex, please?

Well, they're bit numbers, not masks.  Decimal 0-31 is OK, or an enum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
