Date: Sat, 3 May 2003 04:53:07 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: 2.5.68-mm4
Message-ID: <20030503025307.GB1541@averell>
References: <20030502020149.1ec3e54f.akpm@digeo.com> <1051905879.2166.34.camel@spc9.esa.lanl.gov> <20030502133405.57207c48.akpm@digeo.com> <1051908541.2166.40.camel@spc9.esa.lanl.gov> <20030502140508.02d13449.akpm@digeo.com> <1051910420.2166.55.camel@spc9.esa.lanl.gov> <Pine.LNX.4.55.0305030014130.1304@jester.mews> <20030502164159.4434e5f1.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030502164159.4434e5f1.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Matt Bernstein <mb--lkml@dcs.qmul.ac.uk>, Andi Kleen <ak@muc.de>, elenstev@mesatop.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, May 03, 2003 at 01:41:59AM +0200, Andrew Morton wrote:
> Matt Bernstein <mb--lkml@dcs.qmul.ac.uk> wrote:
> >
> > On May 2 Steven Cole wrote:
> > 
> > >Here is a snippet from dmesg output for a successful kexec e100 boot:
> > 
> > Bizarrely I have a nasty crash on modprobing e100 *without* kexec (having
> > previously modprobed unix, af_packet and mii) and then trying to modprobe
> > serio (which then deadlocks the machine).
> > 
> > 	http://www.dcs.qmul.ac.uk/~mb/oops/
> > 
> 
> Andi, it died in the middle of modprobe->apply_alternatives()

The important part of the oops - the first lines are missing in the .png.

What is the failing address? And can you send me your e100.o ?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
