Date: Sat, 13 Jan 2001 05:41:52 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: swapout selection change in pre1
In-Reply-To: <Pine.LNX.4.10.10101130003270.1262-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0101130502080.11440-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 13 Jan 2001, Linus Torvalds wrote:

> It's the other way around: it used to be _extremely_ unfair towards
> threads, because threads woul dget swapped out _much_ more that
> non-threads. The new "count only nr of mm's" actually fixes a real problem
> in this area: a process with hundreds of threads would just get swapped
> out _way_ too quickly (it used to be counted as "hundreds of VM's", even
> though it's obviously just one VM, and should be swapped out as such).

The point is: Should this VM with hundreds of threads be treaded as a VM
with one thread ?

With the old "per-task" selection scheme (before -prerelease), swap_cnt
used to avoid us from scanning a VM too much (if swap_cnt reached zero the
VM would not be scanned until all other VM's had been scanned).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
