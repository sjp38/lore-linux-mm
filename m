Date: Sat, 17 Feb 2007 22:59:22 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 2.6.20 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
Message-ID: <20070217135922.GA15373@linux-sh.org>
References: <20070217104215.GB25512@localhost> <1171715652.5186.7.camel@lappy> <45a44e480702170525n9a15fafpb370cb93f1c1fcba@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45a44e480702170525n9a15fafpb370cb93f1c1fcba@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 17, 2007 at 08:25:07AM -0500, Jaya Kumar wrote:
> On 2/17/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> >And, as Andrew suggested last time around, could you perhaps push this
> >fancy new idea into the FB layer so that more drivers can make us of it?
> 
> I would like to do that very much. I have some ideas how it could work
> for devices that support clean partial updates by tracking touched
> pages. But I wonder if it is too early to try to abstract this out.
> James, Geert, what do you think?
> 
This would also provide an interesting hook for setting up chained DMA
for the real framebuffer updates when there's more than a couple of pages
that have been touched, which would also be nice to have. There's more
than a few drivers that could take advantage of that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
