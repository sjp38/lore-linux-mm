Subject: Re: mmap/munmap semantics
References: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de> <14516.11124.729025.321352@dukat.scot.redhat.com> <20000224033502.B6548@pcep-jamie.cern.ch> <14517.8311.194809.598957@dukat.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 24 Feb 2000 07:41:45 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Thu, 24 Feb 2000 12:13:43 +0000 (GMT)"
Message-ID: <m166velnty.fsf@flinx.hidden>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, Richard Guenther <richard.guenther@student.uni-tuebingen.de>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On Thu, 24 Feb 2000 03:35:02 +0100, Jamie Lokier
> <lk@tantalophile.demon.co.uk> said:
> 
> > I don't think MADV_DONTNEED actually drops privately modified data does
> > it?  
> 
> Yes, it does.  From the DU man pages:
> 
>       MADV_DONTNEED
>                       Do not need these pages
> 
>                       The system will free any whole pages in the specified
>                       region.  All modifications will be lost and any swapped
>                       out pages will be discarded.  Subsequent access to the
>                       region will result in a zero-fill-on-demand fault as
>                       though it is being accessed for the first time.
>                       Reserved swap space is not affected by this call.

Which is fine but if it works this way on shared memory it is broken,
at least unless all mappings set (MADV_DONTNEED) and you can prove there
was no file-io.  Otherwise you could loose legitimate file writes.

Also from an irix man page:

     MADV_DONTNEED    informs the system that the address range from addr to
                      addr + len will likely not be referenced in the near
                      future.  The memory to which the indicated addresses are
                      mapped will be the first to be reclaimed when memory is
                      needed by the system.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
