Subject: Re: 2.5.64-mm6
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <20030313113448.595c6119.akpm@digeo.com>
References: <20030313032615.7ca491d6.akpm@digeo.com>
	<1047572586.1281.1.camel@ixodes.goop.org>
	<20030313113448.595c6119.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 13 Mar 2003 20:04:48 -0700
Message-Id: <1047611104.14782.5410.camel@spc1.mesatop.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2003-03-13 at 12:34, Andrew Morton wrote:
> Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> >
> > On Thu, 2003-03-13 at 03:26, Andrew Morton wrote:
> > >   This means that when an executable is first mapped in, the kernel will
> > >   slurp the whole thing off disk in one hit.  Some IO changes were made to
> > >   speed this up.
> > 
> > Does this just pull in text and data, or will it pull any debug sections
> > too?  That could fill memory with a lot of useless junk.
> > 
> 
> Just text, I expect.  Unless glibc is mapping debug info with PROT_EXEC ;)
> 
> It's just a fun hack.  Should be done in glibc.

Well, fun hack or glibc to-do list candidate, I hope it doesn't get
forgotten.  I am happy to confirm that it did speed up the initial
launch time of Open Office from 20 seconds (2.5-bk) to 11 seconds (-mm6)
and Mozilla from 10 seconds (2.5-bk) to 6 seconds (-mm6).

I did run 2.5.64-mm6 with mem=64M under stress for several hours and it
took a beating and kept on ticking, although quite slowly.

Steven


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
