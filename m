Date: Sun, 11 Feb 2001 00:05:43 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: mmap002 execution time doubled... good or bad sign?
In-Reply-To: <01021023231906.02374@dox>
Message-ID: <Pine.LNX.4.21.0102110001130.27734-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 10 Feb 2001, Roger Larsson wrote:

> Hi,
> 
> I have been running various stress tests on disk for some time.
> streaming write, copy, read, diff, dbench and mmap002
> 
> This is what I have seen:
> 
> >From 2.4.0 to 2.4.1 with Marcelos patch write were above 10 MB/s
> and read >13 MB/s, dbench > 10 MB/s, mmap took around 2m30.
> 
> After 2.4.1-pre8 (did not test anything in between)
> Write is at 9-10 [lost 1 MB/s] read is down to 11-12 MB/s [lost 2 MB/s]
> dbench > 9 MB/s [one MB/s there too]
> 
> But the really strange one - mmap002 now takes > 4m30
> Is this expected / good behaviour? mmap002 abuses mmaps...

These are probably Jens modifications to the block queuing mechanisms
since there were no VM changes from 2.4.1-pre8 to now in Linus tree.

Its not necessarily a bad thing, since Jens modifications make processes
throttle on IO sooner. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
