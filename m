Date: Sat, 13 Jan 2001 00:05:14 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: swapout selection change in pre1
In-Reply-To: <Pine.LNX.4.21.0101130122440.11154-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101130003270.1262-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 13 Jan 2001, Marcelo Tosatti wrote:
> 
> The swapout selection change in pre1 will make the kernel swapout behavior
> not fair anymore to tasks which are sharing the VM (vfork()).
> 
> I dont see any clean fix for that problem. Do you? 

What?

It's the other way around: it used to be _extremely_ unfair towards
threads, because threads woul dget swapped out _much_ more that
non-threads. The new "count only nr of mm's" actually fixes a real problem
in this area: a process with hundreds of threads would just get swapped
out _way_ too quickly (it used to be counted as "hundreds of VM's", even
though it's obviously just one VM, and should be swapped out as such).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
