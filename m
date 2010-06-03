Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 791876B0212
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 03:50:45 -0400 (EDT)
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.DEB.2.00.1006021410300.32666@chino.kir.corp.google.com>
References: <20100601173535.GD23428@uudg.org>
	 <alpine.DEB.2.00.1006011347060.13136@chino.kir.corp.google.com>
	 <20100602220429.F51E.A69D9226@jp.fujitsu.com>
	 <alpine.DEB.2.00.1006021410300.32666@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 03 Jun 2010 09:50:49 +0200
Message-ID: <1275551449.27810.34905.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 2010-06-02 at 14:11 -0700, David Rientjes wrote:
>=20
> And that can reduce the runtime of the thread holding a writelock on=20
> mm->mmap_sem, making the exit actually take longer than without the patch=
=20
> if its priority is significantly higher, especially on smaller machines.=20

/me smells an inversion... on -rt we solved those ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
