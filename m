Message-ID: <C78C149684DAD311B757009027AA5CDC094DA2A9@xboi02.boi.hp.com>
From: "LUTZ,TODD (HP-Boise,ex1)" <tlutz@hp.com>
Subject: RE: Ideas for adding physically contiguous memory support to mmap
	()??
Date: Tue, 10 Apr 2001 20:39:06 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'Benjamin C.R. LaHaise'" <blah@kvack.org>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > I would like to be able to extend mmap() (in 2.4.2) to 
> support returning
> > physically contiguous memory as shared memory.
> 
> > Here are some requirements:
> 
> > 1. Able to specify any size that is a multiple of PAGE_SIZE 
> (not just powers
> > of 2).
> 
> First off: why do you need this functionality?

The short answer...

I have an embedded application that wants to manage most of memory in the
system and wants it to be shared between processes.  The application starts,
determines the amount of free memory, leaves a little for the OS, then
allocates the rest as shared memory.  It needs to be physically contiguous
because not all of our DMAs support scatter-gather.

-- Todd
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
