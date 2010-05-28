Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 007606B01C3
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:53:37 -0400 (EDT)
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100528035147.GD11364@uudg.org>
References: <20100527180431.GP13035@uudg.org>
	 <20100527183319.GA22313@redhat.com>
	 <20100528090357.7DFB.A69D9226@jp.fujitsu.com>
	 <20100528035147.GD11364@uudg.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 28 May 2010 17:53:27 +0200
Message-ID: <1275062007.27810.9749.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 2010-05-28 at 00:51 -0300, Luis Claudio R. Goncalves wrote:
> +       param.sched_priority =3D MAX_RT_PRIO-1;
> +       sched_setscheduler_nocheck(p, SCHED_FIFO, &param);


Argh, so you got me confused as well.

the sched_param ones are userspace values, so you should be using 1.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
