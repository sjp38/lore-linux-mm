Date: Fri, 7 Apr 2000 23:44:13 +0200
Message-Id: <200004072144.XAA00646@agnes.bagneux.maison>
From: JF Martinez <jfm2@club-internet.fr>
Subject: Re: Is Linux kernel 2.2.x Pageable?
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Renaud.Lottiaux@irisa.fr, ebiederm+eric@ccr.net
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Renaud Lottiaux <Renaud.Lottiaux@irisa.fr> writes:
> 
> > Rik van Riel wrote:
> > > 
> > > On Tue, 4 Apr 2000 pnilesh@in.ibm.com wrote:
> > > 
> > > > Is Linux kernel 2.2.x pageable ?
> > > >
> > > > Is Linux kernel 2.3.x pageable ?
> > > 
> > > no
> > 
> > May you be a bit more specific about this ?
> > Can not any part of the kernel be swapped ? Even Modules ?
> > Why ? Just an implementation problem or a deeper reason ?
> 
> Modules can be removed.
> Pageable kernels are stupid, slow, & dangerous.
> 
> If you need a pageable kernel you have other problems.
> 

This is silly.  To begin with one of those slow, stupid & dangerous
kernels called VM was able to host 41400 Linux virtual machines on a
single mainframe.  Second: one of those slow, stupid and dangerous
kernels called MVS probably holds the world record for reliability and
in the 60s/70s was already managing entire BIG companies on boxes who
by today sxtandards are ridiculously underpowered.

However paging the Linux kernel would not be a good idea.  The reason
is that it is not big enough to give significant benefits so better
keep it simple.  During the eighties your average MVS had to manege
several hundred of interactive users plus some batch plus some
databases plus transactional processing.  Just holding the data
startuctures for all this load meant MVS grew until it used 8 Megs of
RAM.  The box had only 16 Megs of it.  Thus being able to page out
data structures associated with sleeping processes was mandatory.

Today on a 128 megs box a properly compiled and modularized Linux
kernel will be about 2 megs.  That is 1.5% of the memory.  It will be
bigger on bigger boxes (due to larger page tables) but it will still
use only a tiny fraction of the RAM.  It will grow when you add
processes but not enough to justify implementing a pageable kernel in
our days when RAM is so cheap.

-- 
			Jean Francois Martinez

Project Independence: Linux for the Masses
http://www.independence.seul.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
