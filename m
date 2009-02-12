Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 173976B005D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 17:11:29 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so291409fgg.4
        for <linux-mm@kvack.org>; Thu, 12 Feb 2009 14:11:27 -0800 (PST)
Date: Fri, 13 Feb 2009 01:17:41 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: What can OpenVZ do?
Message-ID: <20090212221741.GA13861@x200.localdomain>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu> <1234285547.30155.6.camel@nimitz> <20090211141434.dfa1d079.akpm@linux-foundation.org> <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1234475483.30155.194.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, mingo@elte.hu, torvalds@linux-foundation.org, tglx@linutronix.de, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 12, 2009 at 01:51:23PM -0800, Dave Hansen wrote:
> On Thu, 2009-02-12 at 11:42 -0800, Andrew Morton wrote:
> > On Thu, 12 Feb 2009 13:30:35 -0600
> > Matt Mackall <mpm@selenic.com> wrote:
> > 
> > > On Thu, 2009-02-12 at 10:11 -0800, Dave Hansen wrote:
> > > 
> > > > > - In bullet-point form, what features are missing, and should be added?
> > > > 
> > > >  * support for more architectures than i386
> > > >  * file descriptors:
> > > >   * sockets (network, AF_UNIX, etc...)
> > > >   * devices files
> > > >   * shmfs, hugetlbfs
> > > >   * epoll
> > > >   * unlinked files
> > > 
> > > >  * Filesystem state
> > > >   * contents of files
> > > >   * mount tree for individual processes
> > > >  * flock
> > > >  * threads and sessions
> > > >  * CPU and NUMA affinity
> > > >  * sys_remap_file_pages()
> > > 
> > > I think the real questions is: where are the dragons hiding? Some of
> > > these are known to be hard. And some of them are critical checkpointing
> > > typical applications. If you have plans or theories for implementing all
> > > of the above, then great. But this list doesn't really give any sense of
> > > whether we should be scared of what lurks behind those doors.
> > 
> > How close has OpenVZ come to implementing all of this?  I think the
> > implementatation is fairly complete?
> 
> I also believe it is "fairly complete".  At least able to be used
> practically.
> 
> > If so, perhaps that can be used as a guide.  Will the planned feature
> > have a similar design?  If not, how will it differ?  To what extent can
> > we use that implementation as a tool for understanding what this new
> > implementation will look like?
> 
> Yes, we can certainly use it as a guide.  However, there are some
> barriers to being able to do that:
> 
> dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | diffstat | tail -1
>  628 files changed, 59597 insertions(+), 2927 deletions(-)
> dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | wc 
>   84887  290855 2308745

	git-diff -- kernel/cpt/

should give more realistic picture.

> Unfortunately, the git tree doesn't have that great of a history.  It
> appears that the forward-ports are just applications of huge single
> patches which then get committed into git.  This tree has also
> historically contained a bunch of stuff not directly related to
> checkpoint/restart like resource management.

> We'd be idiots not to take a hard look at what has been done in OpenVZ.
> But, for the time being, we have absolutely no shortage of things that
> we know are important and know have to be done.  Our largest problem is
> not finding things to do, but is our large out-of-tree patch that is
> growing by the day. :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
