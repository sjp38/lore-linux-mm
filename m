Subject: Re: 2.5.64-mm6
From: Shawn <core@enodev.com>
In-Reply-To: <20030313192809.17301709.akpm@digeo.com>
References: <20030313032615.7ca491d6.akpm@digeo.com>
	 <1047572586.1281.1.camel@ixodes.goop.org>
	 <20030313113448.595c6119.akpm@digeo.com>
	 <1047611104.14782.5410.camel@spc1.mesatop.com>
	 <20030313192809.17301709.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1047613609.2848.3.camel@localhost.localdomain>
Mime-Version: 1.0
Date: 13 Mar 2003 21:46:49 -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Steven Cole <elenstev@mesatop.com>, jeremy@goop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2003-03-13 at 21:28, Andrew Morton wrote:
> Steven Cole <elenstev@mesatop.com> wrote:
> >
> > On Thu, 2003-03-13 at 12:34, Andrew Morton wrote:
> > > Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> > > >
> > > > On Thu, 2003-03-13 at 03:26, Andrew Morton wrote:
> > > > >   This means that when an executable is first mapped in, the kernel will
> > > > >   slurp the whole thing off disk in one hit.  Some IO changes were made to
> > > > >   speed this up.
> > > > 
> > > > Does this just pull in text and data, or will it pull any debug sections
> > > > too?  That could fill memory with a lot of useless junk.
> > > > 
> > > 
> > > Just text, I expect.  Unless glibc is mapping debug info with PROT_EXEC ;)
> > > 
> > > It's just a fun hack.  Should be done in glibc.
> > 
> > Well, fun hack or glibc to-do list candidate, I hope it doesn't get
> > forgotten.
> 
> I have to pull the odd party trick to get people to test -mm kernels.

This reminds me of something I've not looked into for some time.

Being an active user of the 2.5 series including -mm, should I have
updated glibc, or is there nothing new enough yet to warrant that?

Maybe I should just ask the glibc people. Wasn't sure what the proper
forum was.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
