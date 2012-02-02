Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 0D0E16B002C
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 11:30:03 -0500 (EST)
Date: Thu, 2 Feb 2012 10:29:57 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
In-Reply-To: <20120202162420.GE9071@somewhere.redhat.com>
Message-ID: <alpine.DEB.2.00.1202021028120.6221@router.home>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com> <1327591185.2446.102.camel@twins> <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com> <20120201170443.GE6731@somewhere.redhat.com> <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
 <20120202162420.GE9071@somewhere.redhat.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-439244359-1328200202=:6221"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-439244359-1328200202=:6221
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 2 Feb 2012, Frederic Weisbecker wrote:

> > Some pinned timers might be able to get special treatment as well - tak=
e for
> > example the vmstat=A0work being schedule every second, what should we d=
o with
> > it for CPU isolation?
>
> Right, I remember I saw these vmstat timers on my way when I tried to get=
 0
> interrupts on a CPU.
>
> I think all these timers need to be carefully reviewed before doing anyth=
ing.
> But we certainly shouldn't adopt the behaviour of migrating timers by def=
ault.
>
> Some timers really needs to stay on the expected CPU. Note that some
> timers may be shutdown by CPU hotplug callbacks. Those wouldn't be migrat=
ed
> in case of CPU offlining. We need to keep them.
>
> > It makes sense to me to have that stop scheduling itself when we have t=
he tick
> > disabled for both idle and a nohz task.

The vmstat timer only makes sense when the OS is doing something on the
processor. Otherwise if no counters are incremented and the page and slab
allocator caches are empty then there is no need to run the vmstat timer.
---1463811839-439244359-1328200202=:6221--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
