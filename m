Date: Wed, 11 Apr 2001 11:00:50 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: RE: Ideas for adding physically contiguous memory support to mmap ()??
In-Reply-To: <C78C149684DAD311B757009027AA5CDC094DA2A9@xboi02.boi.hp.com>
Message-ID: <Pine.LNX.3.96.1010411105705.27917A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "LUTZ,TODD (HP-Boise,ex1)" <tlutz@hp.com>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2001, LUTZ,TODD (HP-Boise,ex1) wrote:

> The short answer...
> 
> I have an embedded application that wants to manage most of memory in the
> system and wants it to be shared between processes.  The application starts,
> determines the amount of free memory, leaves a little for the OS, then
> allocates the rest as shared memory.  It needs to be physically contiguous
> because not all of our DMAs support scatter-gather.

Stop building broken hardware -- seriously!  But if you must, just use the
bigmem patches to reserve a chunk of memory and then mmap it via /dev/mem
(or even boot with a mem= map that leaves memory unused).  That doesn't
require any kernel changes and is much faster to implement. 

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
