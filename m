Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 3F2316B00F2
	for <linux-mm@kvack.org>; Tue,  8 May 2012 11:34:32 -0400 (EDT)
Date: Tue, 8 May 2012 10:34:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v1 5/6] mm: make vmstat_update periodic run conditional
In-Reply-To: <CAOtvUMf95gmZ4ZTSpTb+5NZdEiDTg_CPtp3L2_notdz+dZWG6A@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205081033450.27713@router.home>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com> <1336056962-10465-6-git-send-email-gilad@benyossef.com> <alpine.DEB.2.00.1205071024550.1060@router.home> <4FA823A7.9000801@gmail.com> <alpine.DEB.2.00.1205071438240.2215@router.home>
 <CAOtvUMf95gmZ4ZTSpTb+5NZdEiDTg_CPtp3L2_notdz+dZWG6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On Tue, 8 May 2012, Gilad Ben-Yossef wrote:

> > But this would still mean that the vmstat update thread would run on an
> > arbitrary cpu. If I have a sacrificial lamb processor for OS processing
> > then I would expect the vmstat update thread to stick to that processor
> > and avoid to run on the other processor that I would like to be as free
> > from OS noise as possible.
> >
>
> OK, what about -
>
> - We pick a scapegoat cpu (the first to come up gets the job).
> - We add a knob to let user designate another cpu for the job.
> - If scapegoat cpus goes offline, the cpu processing the off lining is
> the new scapegoat.
>
> Does this makes better sense?

Sounds good. The first that comes up. If the cpu is isolated then the
first non isolated cpu is picked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
