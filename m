From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: swapout selection change in pre1
Date: Sun, 14 Jan 2001 20:22:27 -0500
Content-Type: text/plain;
  charset="US-ASCII"
References: <Pine.LNX.4.10.10101130003270.1262-100000@penguin.transmeta.com>
In-Reply-To: <Pine.LNX.4.10.10101130003270.1262-100000@penguin.transmeta.com>
MIME-Version: 1.0
Message-Id: <01011420222701.14309@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 13 January 2001 03:05, Linus Torvalds wrote:
> On Sat, 13 Jan 2001, Marcelo Tosatti wrote:
> > The swapout selection change in pre1 will make the kernel swapout
> > behavior not fair anymore to tasks which are sharing the VM (vfork()).
> >
> > I dont see any clean fix for that problem. Do you?
>
> What?
>
> It's the other way around: it used to be _extremely_ unfair towards
> threads, because threads woul dget swapped out _much_ more that
> non-threads. The new "count only nr of mm's" actually fixes a real problem
> in this area: a process with hundreds of threads would just get swapped
> out _way_ too quickly (it used to be counted as "hundreds of VM's", even
> though it's obviously just one VM, and should be swapped out as such).

Think its gone too far in the other direction now.  Running a heavily 
threaded java program, 35 threads and RSS of 44M a 128M KIII-400 with cpu 
usage of 4-10%, the rest of the system is getting paged out very quickly and 
X feels slugish.  While we may not want to treat each thread as if it was a 
process, I think we need more than one scan per group of threads sharing 
memory.  

Ideas?
Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
