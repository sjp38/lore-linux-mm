Date: Thu, 7 Sep 2000 16:31:44 +0200
From: Ralf Baechle <ralf@oss.sgi.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Message-ID: <20000907163144.E6580@bacchus.dhis.org>
References: <200008171920.MAA23931@pizda.ninka.net> <200008171936.MAA31128@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200008171936.MAA31128@google.engr.sgi.com>; from kanoj@google.engr.sgi.com on Thu, Aug 17, 2000 at 12:36:51PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "David S. Miller" <davem@redhat.com>, alan@lxorguk.ukuu.org.uk, sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com
List-ID: <linux-mm.kvack.org>

On Thu, Aug 17, 2000 at 12:36:51PM -0700, Kanoj Sarcar wrote:

> >    Except for the x86 36bit abortion do we need a long long paddr_t on any
> >    32bit platform ?
> > 
> > Sparc32, mips32...
> >
> 
> Not for Indys on mips32. Is there a mips32 port on another machine
> (currently in Linux, or port ongoing) that requires this?

No.  Right now mips32 assumes that all memory is accessible in KSEG0 which
limits it to 512mb - $\epsilon$.  I don't know of any 32-bit CPU
configuration which supports memory than that and for 64-bit processors
the policy should be to use mips64 - it's so much saner.

  Ralf
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
