Received: from d1o87.telia.com (d1o87.telia.com [213.65.232.241])
	by mailg.telia.com (8.12.8/8.12.8) with ESMTP id h2DKCYSI017141
	for <linux-mm@kvack.org>; Thu, 13 Mar 2003 21:12:35 +0100 (CET)
Received: from jeloin.localnet (h98n2fls32o87.telia.com [213.67.57.98])
	by d1o87.telia.com (8.10.2/8.10.1) with ESMTP id h2DKCY001159
	for <linux-mm@kvack.org>; Thu, 13 Mar 2003 21:12:34 +0100 (CET)
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: 2.5.64-mm6
Date: Thu, 13 Mar 2003 21:07:51 +0100
References: <20030313032615.7ca491d6.akpm@digeo.com> <1047572586.1281.1.camel@ixodes.goop.org> <20030313113448.595c6119.akpm@digeo.com>
In-Reply-To: <20030313113448.595c6119.akpm@digeo.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Message-Id: <200303132107.51483.roger.larsson@norran.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 13 March 2003 20:34, Andrew Morton wrote:
> Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> >
> > On Thu, 2003-03-13 at 03:26, Andrew Morton wrote:
> > >   This means that when an executable is first mapped in, the kernel will
> > >   slurp the whole thing off disk in one hit.  Some IO changes were made 
> > >   to speed this up.
> > 
> > Does this just pull in text and data, or will it pull any debug sections
> > too?  That could fill memory with a lot of useless junk.
> > 
> 
> Just text, I expect.  Unless glibc is mapping debug info with PROT_EXEC ;)
> 
> It's just a fun hack.  Should be done in glibc.
> 

Are you sure? This is most useful during startup of system/programs, at that 
time you usually have LOTS of free memory. Later when there are less free
memory or your computer is on a memory budget it should not load it all.

Can the application decide? Should it?

/RogerL

-- 
Roger Larsson
Skelleftea
Sweden

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
