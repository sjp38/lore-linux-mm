Subject: Re: ioremap_nocache problem?
References: <3A6D5D28.C132D416@sangate.com>
        <20010123183847Z131216-18594+636@vger.kernel.org>
From: David Wragg <dpw@doc.ic.ac.uk>
Date: 24 Jan 2001 01:01:29 +0000
Message-ID: <y7rg0i9epau.fsf@sytry.doc.ic.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Timur Tabi <ttabi@interactivesi.com> writes:
> ** Reply to message from Roman Zippel <zippel@fh-brandenburg.de> on
> Tue, 23 Jan 2001 19:12:36 +0100 (MET)
> > ioremap creates a new mapping that shouldn't interfere with MTRR,
> >whereas you can map a MTRR mapped area into userspace. But I'm not
> >sure if it's correct that no flag is set for boot_cpu_data.x86 <=
> >3...
> 
> I was under the impression that the "don't cache" bit that
> ioremap_nocache sets overrides any MTRR.

Nope.  There's a table explaining how page flags and MTRRs interact in
the Intel x86 manual, volume 3 (it's in section 9.5.1 "Precedence of
Cache Controls" in the fairly recent edition I have here).

For example, with PCD set, PWT clear, and the MTRRs saying WC, the
effective memory type is WC.  In addition, there's a note saying this
may change in future models.  So you have to set PCD | PWT if you want
to get uncached in all cases.


David Wragg
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
