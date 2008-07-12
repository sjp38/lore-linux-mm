Date: Sat, 12 Jul 2008 16:36:49 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 4/5] kmemtrace: SLUB hooks.
Message-ID: <20080712163649.38da0cc8@linux360.ro>
In-Reply-To: <20080712162836.6ea00830@linux360.ro>
References: <1215712946-23572-1-git-send-email-eduard.munteanu@linux360.ro>
	<1215712946-23572-2-git-send-email-eduard.munteanu@linux360.ro>
	<1215712946-23572-3-git-send-email-eduard.munteanu@linux360.ro>
	<1215712946-23572-4-git-send-email-eduard.munteanu@linux360.ro>
	<20080710210617.70975aed@linux360.ro>
	<84144f020807110135w19cb9b5erff143912e5beb78c@mail.gmail.com>
	<487772A3.5040701@linux-foundation.org>
	<20080712162836.6ea00830@linux360.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 12 Jul 2008 16:28:36 +0300
Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro> wrote:

> On Fri, 11 Jul 2008 09:48:03 -0500
> Christoph Lameter <cl@linux-foundation.org> wrote:
> 
> > Pekka Enberg wrote:
> >  
> > > Christoph, can you please take a look at this?
> > 
> > Yeah. I saw it. Is there some high level description as to how this
> > is going to be used?
> 
> Here is the userspace application's git tree:
> http://repo.or.cz/w/kmemtrace-user.git

Basically, you go like this:
1. Boot the kernel, preferably into 'single' runlevel.
2. Mount debugfs and whatever other filesystems.
3. Run kmemtraced, wait a few seconds and stop it.
4*. Check /debug/kmemtrace/total_overruns (debugfs is mounted on /debug)
to see if there were any buffer overruns.
5*. Run kmemtrace-check on all CPU cpu*.out to see if there are any
erroneous events.
6. Run kmemtrace-report with no parameters to get a short summary of
how the allocator performs.

* - you can optionally skip these steps.

To build the userspace app, launch './configure' when running on that
particular kmemtrace-enabled kernel. It should correctly detect the
headers directory. Otherwise, add KERNEL_SOURCES variable as an
argument to configure. Then run 'make'.

BTW, that repo may change, so don't rely on those commits to be
consistent for a long time. I could delete them all and restructure the
project.


	Eduard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
