Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 161726B0098
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 10:04:30 -0500 (EST)
Received: by vbbfa15 with SMTP id fa15so2189228vbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 07:04:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326811093.3467.41.camel@lenny>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	<1326811093.3467.41.camel@lenny>
Date: Tue, 17 Jan 2012 17:04:28 +0200
Message-ID: <CAOJsxLG6Q=zr8kqcds7jWzpGqqy2GV10YERb9njMzM8y7kS55A@mail.gmail.com>
Subject: Re: [RFC 0/3] low memory notify
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Walters <walters@verbum.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>

On Tue, Jan 17, 2012 at 4:38 PM, Colin Walters <walters@verbum.org> wrote:
> So what you really want to be investigating here is integration between
> a garbage collector and the system VM. =A0Your test program looks nothing
> like a garbage collector. =A0I'd expect most of the performance tradeoffs
> to be similar between these runtimes. =A0The Azul people have been doing
> something like this: http://www.managedruntime.org/

The interraction isn't all that complex, really. I'd expect most VMs
to simply wake up the GC thread when poll() returns. GCs that are able
to compact the heap can madvise(MADV_DONTNEED) or even munmap() unused
parts of the heap.

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
