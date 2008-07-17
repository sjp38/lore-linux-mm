Received: by qb-out-1314.google.com with SMTP id f14so816646qba.4
        for <linux-mm@kvack.org>; Thu, 17 Jul 2008 16:50:26 -0700 (PDT)
Date: Fri, 18 Jul 2008 02:49:01 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 1/4] kmemtrace: Core implementation.
Message-ID: <20080717234901.GA5233@localhost>
References: <cover.1216255034.git.eduard.munteanu@linux360.ro> <4472a3f883b0d9026bb2d8c490233b3eadf9b55e.1216255035.git.eduard.munteanu@linux360.ro> <20080717143434.79b33fe9.rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080717143434.79b33fe9.rdunlap@xenotime.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: penberg@cs.helsinki.fi, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 17, 2008 at 02:34:34PM -0700, Randy Dunlap wrote:
> On Thu, 17 Jul 2008 03:46:45 +0300 Eduard - Gabriel Munteanu wrote:
> 
> > +3) Boot the kmemtrace-enabled kernel if you haven't, preferably in the
> > +'single' runlevel (so that relay buffers don't fill up easily), and run
> > +kmemtrace:
> > +# '$' does not mean user, but root here.
> > +$ mount -t debugfs none /debug
> 
> Please mount at /sys/kernel/debug, i.e., the expected debugfs mount point.
> 

Oh, I did not know that. Thanks, will change accordingly.

> > +$ mount -t proc none /proc
> > +$ cd path/to/kmemtrace-user/
> > +$ ./kmemtraced
> > +Wait a bit, then stop it with CTRL+C.
> > +$ cat /debug/kmemtrace/total_overruns	# Check if we didn't overrun, should
> > +					# be zero.
> > +$ (Optionally) [Run kmemtrace_check separately on each cpu[0-9]*.out file to
> > +		check its correctness]
> > +$ ./kmemtrace-report
> > +
> > +Now you should have a nice and short summary of how the allocator performs.
> 
> 
> Otherwise looks nice.  Thanks.
> 
> ---
> ~Randy
> Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
> http://linuxplumbersconf.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
