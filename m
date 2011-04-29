Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 97C37900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:03:51 -0400 (EDT)
Date: Fri, 29 Apr 2011 09:03:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <alpine.DEB.2.00.1104290855060.7776@router.home>
Message-ID: <alpine.DEB.2.00.1104290903230.7776@router.home>
References: <20110421183727.GG15988@htj.dyndns.org> <alpine.DEB.2.00.1104211350310.5741@router.home> <20110421190807.GK15988@htj.dyndns.org> <1303439580.3981.241.camel@sli10-conroe> <20110426121011.GD878@htj.dyndns.org> <1303883009.3981.316.camel@sli10-conroe>
 <20110427102034.GE31015@htj.dyndns.org> <1303961284.3981.318.camel@sli10-conroe> <20110428100938.GA10721@htj.dyndns.org> <1304065171.3981.594.camel@sli10-conroe> <20110429084424.GJ16552@htj.dyndns.org> <alpine.DEB.2.00.1104290855060.7776@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 29 Apr 2011, Christoph Lameter wrote:

> If someone wants more accuracy then we need the ability to dynamically set
> the batch limit similar to what the vm statistics do.

Forget the key point: After these measures it should be possible to remove
_sum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
