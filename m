Date: Sat, 3 May 2003 05:14:44 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: 2.5.68-mm4
Message-ID: <20030503031444.GA1657@averell>
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
> Andi, it died in the middle of modprobe->apply_alternatives()

BTW I just loaded an e100 module with BK-CVS current and there were no
problems.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
