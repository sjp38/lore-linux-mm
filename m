Date: Wed, 7 May 2003 14:35:08 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: 2.5.68-mm4
Message-ID: <20030507123508.GA6060@averell>
References: <1051908541.2166.40.camel@spc9.esa.lanl.gov> <20030502140508.02d13449.akpm@digeo.com> <1051910420.2166.55.camel@spc9.esa.lanl.gov> <Pine.LNX.4.55.0305030014130.1304@jester.mews> <20030502164159.4434e5f1.akpm@digeo.com> <20030503025307.GB1541@averell> <Pine.LNX.4.55.0305030800140.1304@jester.mews> <Pine.LNX.4.55.0305061511020.3237@r2-pc.dcs.qmul.ac.uk> <20030506143533.GA22907@averell> <Pine.LNX.4.55.0305071121220.6697@r2-pc.dcs.qmul.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.55.0305071121220.6697@r2-pc.dcs.qmul.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Bernstein <mb/lkml@dcs.qmul.ac.uk>
Cc: Andi Kleen <ak@muc.de>, Andrew Morton <akpm@digeo.com>, elenstev@mesatop.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2003 at 12:27:02PM +0200, Matt Bernstein wrote:
> 
> Will do later today if the above isn't helpful. One other thing I did do 
> was a make -j19 KBUILD_VERBOSE=0 but I've been told this is completely 
> safe these days.

It tries to patch an instruction past the kernel text.

It could be in the discarded .exit.text/.text.exit. With new binutils you should
get an link error when this happens, but perhaps yours are too old for that.

When you comment these entries out from the DISCARD statement in 
arch/i386/vmlinux.lds.S does it go away ? Alternatively use Andrew's
latest 2.5.69-mm*, that has the patch too.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
