Received: from toip5.srvr.bell.ca ([209.226.175.88])
          by tomts5-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20071204193037.TODX17217.tomts5-srv.bellnexxia.net@toip5.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 4 Dec 2007 14:30:37 -0500
Date: Tue, 4 Dec 2007 14:25:37 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [RFC PATCH] LTTng instrumentation mm (updated)
Message-ID: <20071204192537.GC31752@Krystal>
References: <20071128140953.GA8018@Krystal> <1196268856.18851.20.camel@localhost> <20071129023421.GA711@Krystal> <1196317552.18851.47.camel@localhost> <20071130161155.GA29634@Krystal> <1196444801.18851.127.camel@localhost> <20071130170516.GA31586@Krystal> <1196448122.19681.16.camel@localhost> <20071130191006.GB3955@Krystal> <y0mve7ez2y3.fsf@ton.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <y0mve7ez2y3.fsf@ton.toronto.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Frank Ch. Eigler" <fche@redhat.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

* Frank Ch. Eigler (fche@redhat.com) wrote:
> Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> writes:
> 
> > [...]
> >> > We would like to be able to tell which swap file the information has
> >> > been written to/read from at any given time during the trace.
> >> 
> >> Oh, tracing is expected to be on at all times?  I figured someone would
> >> encounter a problem, then turn it on to dig down a little deeper, then
> >> turn it off.
> >
> > Yep, it can be expected to be on at all times, especially on production
> > systems using "flight recorder" tracing to record information in a
> > circular buffer [...]
> 
> Considering how early in the boot sequence swap partitions are
> activated, it seems optimistic to assume that the monitoring equipment
> will always start up in time to catch the initial swapons.  It would
> be more useful if a marker parameter was included in the swap events
> to let a tool/user map to /proc/swaps or a file name.
> 
> - FChE

Not early at all ? We have userspace processes running.. this is _late_
in the boot sequence! ;)

Anyhow, that I have now is a combination including your proposal :

- I dump the swapon/swapoff events.
- I also dump the equivalent of /proc/swaps (with kernel internal
  information) at trace start to know what swap files are currently
  used.

Does it sound fair ?

Mathieu

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
