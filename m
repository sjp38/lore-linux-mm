Date: Sat, 24 Mar 2001 13:39:26 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: Reduce Linux memory requirements for an Embedded PC
Message-ID: <20010324133926.A1584@fred.local>
References: <3ABC7008.B9EB4047@razdva.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3ABC7008.B9EB4047@razdva.cz>; from pdusil@razdva.cz on Sat, Mar 24, 2001 at 10:59:36AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Petr Dusil <pdusil@razdva.cz>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 24, 2001 at 10:59:36AM +0100, Petr Dusil wrote:
> Hello All,
> 
> I am developing a Linux distribution for a Jumptec Embedded PC. It is
> targeted to an I486, 16MB DRAM, 16MB DiskOnChip. I have decided to use
> Redhat 6.2  (2.2.14 kernel) and to reduce its size to fit the EPC. I
> have simplified the kernel (removed support of all unwanted hardware),
> init scripts and amount of apps I will really need. I do not have
> problems with its size on disk (8MB), but I do see a problem in its
> memory requirements. It takes now about 11MB. It is too much. I tried to
> replace init by sulogin to get bash shell and look into the system
> memory as soon as possible, but again without starting any daemon only
> with bash running I got 7MB. I am asking you, is there any option to
> tell Linux kernel "save the memory" or what are the general
> recommendations to minimize amount of memory the kernel consumes?

One way is to go back to a 2.0 kernel, which uses somewhat less memory.
I did that on a 4MB box. There are also ways to reduce memory usage further
for both 2.0 and 2.2, but it requires a bit of source patching. Basically
you go through nm --size-sort -t d vmlinux and try to reduce all big symbols,
like the static super block array and reducing sizes of preallocated hash
tables (e.g. buffer and networking hash is very big in 2.2) 
There are other ways, e.g. with some patching the memory usage of a select()
using program can be significantly reduced. Easiest way is probably to try
2.0 first.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
