Subject: Re: 2.5.65-mm2
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <200303192327.45883.tomlins@cam.org>
References: <20030319012115.466970fd.akpm@digeo.com>
	<20030319163337.602160d8.akpm@digeo.com>
	<1048117516.1602.6.camel@spc1.esa.lanl.gov>
	<200303192327.45883.tomlins@cam.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 19 Mar 2003 22:04:44 -0700
Message-Id: <1048136698.10011.1736.camel@spc1.mesatop.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2003-03-19 at 21:27, Ed Tomlinson wrote:
> On March 19, 2003 06:45 pm, Steven P. Cole wrote:
> > On Wed, 2003-03-19 at 17:33, Andrew Morton wrote:
> > > "Steven P. Cole" <elenstev@mesatop.com> wrote:
> > > > > Summary: using ext3, the simple window shake and scrollbar wiggle
> > > > > tests were much improved, but really using Evolution left much to be
> > > > > desired.
> > > >
> > > > Replying to myself for a followup,
> > > >
> > > > I repeated the tests with 2.5.65-mm2 elevator=deadline and the
> > > > situation was similar to elevator=as.  Running dbench on ext3, the
> > > > response to desktop switches and window wiggles was improved over
> > > > running dbench on reiserfs, but typing in Evolution was subject to long
> > > > delays with dbench clients greater than 16.
> > >
> > > OK, final question before I get off my butt and find a way to reproduce
> > > this:
> > >
> > > Does reverting
> > >
> > > http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.65/2.5.65-mm2/broken-ou
> > >t/sched-2.5.64-D3.patch
> > >
> > > help?
> >
> > Sorry, didn't have much time for a lot of testing, but no miracles
> > occurred.  With 5 minutes of testing 2.5.65-mm2 and dbench 24 on ext3
> > and that patch reverted (first hunk had to be manually fixed), I don't
> > see any improvement.  Still the same long long delays in trying to use
> > Evolution.
> 
> Steven,
> 
> Do things improve with the patch below applied?  You have to backout the 
> schedule-tuneables patch before appling it.

I take it this is the one to back out?
scheduler-tunables.patch 17-Mar-2003 22:01    11k

> 
> Ed Tomlinson

I'll give it a shot when I get the chance.  Unfortunately, I'm bogged
down with meetings tomorrow morning, so it will be at least 14-15 hours
from now.  Perhaps some other adventurous person can pick up the ball in
the meantime.

My test system is 933Mhz PIII, IDE, 256MB. The apps are Mozilla 1.3 and
Evolution 1.2.2 running under KDE 3.1.

Thanks,
Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
