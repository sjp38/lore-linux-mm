Date: Thu, 27 Jan 2005 09:02:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: A scrub daemon (prezeroing)
In-Reply-To: <1106831669.19262.75.camel@hades.cambridge.redhat.com>
Message-ID: <Pine.LNX.4.58.0501270900590.9985@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
 <1106828124.19262.45.camel@hades.cambridge.redhat.com>
 <20050127131228.GB31288@lnx-holt.americas.sgi.com>
 <1106831669.19262.75.camel@hades.cambridge.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jan 2005, David Woodhouse wrote:

> On Thu, 2005-01-27 at 07:12 -0600, Robin Holt wrote:
> > An earlier proposal that Christoph pushed would have used the BTE on
> > sn2 for this.  Are you thinking of using the BTE on sn0/sn1 mips?
>
> I wasn't being that specific. There's spare DMA engines on a lot of
> PPC/ARM/FRV/SH/MIPS and other machines, to name just the ones sitting
> around my desk.

If you look at the patch you will find a function call to register a
hardware driver for zeroing. I did not include the driver in this patch
because there was no change. Look at my other posts regarding prezeroing.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
