Message-ID: <3B853EEA.6D445E0E@pp.inet.fi>
Date: Thu, 23 Aug 2001 20:35:38 +0300
From: Jari Ruusu <jari.ruusu@pp.inet.fi>
MIME-Version: 1.0
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
References: <Pine.LNX.4.21.0108221526170.2651-100000@freak.distro.conectiva> <3B84BE0A.C9082E87@pp.inet.fi>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jari Ruusu wrote:
> Marcelo Tosatti wrote:
> > 2) Did you tried with older kernels or 2.4.9?
> 
> Linus' 2.4.9 survived about 7 hours of VM torture, and then I got ext2
> filesystem corruption (just once, dunno if it is repeatable). No "swap
> offset" problems with 2.4.9 so far. Haven't tortured older kernels yet.

Update:

Stock Linus' 2.4.7
~~~~~~~~~~~~~~~~~~
Box didn't die but I stopped VM torture test after this appeared:

Unused swap offset entry in swap_dup 003d6b00
VM: Bad swap entry 003d6b00
Unused swap offset entry in swap_count 003d6b00
VM: Bad swap entry 003d6b00

Stock Linus' 2.4.8
~~~~~~~~~~~~~~~~~~
bzip2 decompress + tar failed (twice, but at different place):
> tar: Skipping to next header
> 
> bzip2: Caught a SIGSEGV or SIGBUS whilst decompressing,
>         which probably indicates that the compressed data
>         is corrupted.
>         Input file = (stdin), output file = (stdout)
> 
> It is possible that the compressed file(s) have become corrupted.
> You can use the -tvv option to test integrity of such files.
> 
> You can use the `bzip2recover' program to *attempt* to recover
> data from undamaged sections of corrupted files.
> 
> tar: 360 garbage bytes ignored at end of archive
> tar: Child returned status 2
> tar: Error exit delayed from previous errors

glibc compile failed:
> make[2]: *** [math/subdir_install] Segmentation fault

Note: previously mentioned ext2 filesystem corruption (with kernel 2.4.9)
was in bzip2 decompress + tar restored directory hierarchy, so above bzip2
decompress + tar failure can explain that too. Maybe something went
similarly wrong and bzip2 outputted garbage to tar instead of terminating
with SIGSEGV.

6 hours of VM torture, 3 incidents where a process died with SIGSEGV. No
"swap offset" problems with 2.4.8 so far.

Regards,
Jari Ruusu <jari.ruusu@pp.inet.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
