From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14517.8311.194809.598957@dukat.scot.redhat.com>
Date: Thu, 24 Feb 2000 12:13:43 +0000 (GMT)
Subject: Re: mmap/munmap semantics
In-Reply-To: <20000224033502.B6548@pcep-jamie.cern.ch>
References: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de>
	<14516.11124.729025.321352@dukat.scot.redhat.com>
	<20000224033502.B6548@pcep-jamie.cern.ch>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Richard Guenther <richard.guenther@student.uni-tuebingen.de>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 24 Feb 2000 03:35:02 +0100, Jamie Lokier
<lk@tantalophile.demon.co.uk> said:

> I don't think MADV_DONTNEED actually drops privately modified data does
> it?  

Yes, it does.  From the DU man pages:

      MADV_DONTNEED
                      Do not need these pages

                      The system will free any whole pages in the specified
                      region.  All modifications will be lost and any swapped
                      out pages will be discarded.  Subsequent access to the
                      region will result in a zero-fill-on-demand fault as
                      though it is being accessed for the first time.
                      Reserved swap space is not affected by this call.

Regarding the other half of the problem --- zeroing out a portion of a
file without further IO --- the splice code I hope to have using kiobufs
in 2.5 will allow this to be done very easily.  You'll be able to take a
region of /dev/zero and splice it into your open file with zero-copy.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
