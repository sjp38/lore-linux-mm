Date: Tue, 6 May 2003 16:35:33 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: 2.5.68-mm4
Message-ID: <20030506143533.GA22907@averell>
References: <1051905879.2166.34.camel@spc9.esa.lanl.gov> <20030502133405.57207c48.akpm@digeo.com> <1051908541.2166.40.camel@spc9.esa.lanl.gov> <20030502140508.02d13449.akpm@digeo.com> <1051910420.2166.55.camel@spc9.esa.lanl.gov> <Pine.LNX.4.55.0305030014130.1304@jester.mews> <20030502164159.4434e5f1.akpm@digeo.com> <20030503025307.GB1541@averell> <Pine.LNX.4.55.0305030800140.1304@jester.mews> <Pine.LNX.4.55.0305061511020.3237@r2-pc.dcs.qmul.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.55.0305061511020.3237@r2-pc.dcs.qmul.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Bernstein <mb--lkml@dcs.qmul.ac.uk>
Cc: Andi Kleen <ak@muc.de>, Andrew Morton <akpm@digeo.com>, elenstev@mesatop.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2003 at 04:15:55PM +0200, Matt Bernstein wrote:
> Is this helpful?

What I really need is an probably decoded with ksymoops oops, not jpegs.

Also you seem to be the only one with the problem so just to avoid
any weird build problems do a make distclean and rebuild from scratch
and reinstall the modules.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
