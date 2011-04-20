Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E235F8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:50:21 -0400 (EDT)
Date: Wed, 20 Apr 2011 08:50:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <20110420115804.461E.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104200847240.8634@router.home>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com> <1303267733.11237.42.camel@mulgrave.site> <20110420115804.461E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>

On Wed, 20 Apr 2011, KOSAKI Motohiro wrote:

> >                  from arch/parisc/kernel/asm-offsets.c:31:
> > include/linux/topology.h: In function 'numa_node_id':
> > include/linux/topology.h:255: error: implicit declaration of function 'cpu_to_node'
>
> Sorry about that. I'll see more carefully the code later. Probably long
> time discontig-mem uninterest made multiple level breakage. Grr. ;-)

True. Someone needs to go through discontig and make it work right with a
!NUMA configuration. Many pieces of the core code assume that there will
be no node on a !NUMA config today. I guess that was different in ages
past.

Maybe we should make DISCONTIG broken under !NUMA until that time?

Tejon was working on getting rid of DISCONTIG. SPARSEMEM is the favored
alternative today. So we could potentially change the arches to use SPARSE
configs in the !NUMA case.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
