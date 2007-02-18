Received: by nf-out-0910.google.com with SMTP id b2so1964548nfe
        for <linux-mm@kvack.org>; Sun, 18 Feb 2007 03:31:24 -0800 (PST)
Message-ID: <45a44e480702180331t7e76c396j1a9861f689d4186b@mail.gmail.com>
Date: Sun, 18 Feb 2007 06:31:23 -0500
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: [PATCH 2.6.20 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
In-Reply-To: <20070217135922.GA15373@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070217104215.GB25512@localhost> <1171715652.5186.7.camel@lappy>
	 <45a44e480702170525n9a15fafpb370cb93f1c1fcba@mail.gmail.com>
	 <20070217135922.GA15373@linux-sh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/17/07, Paul Mundt <lethal@linux-sh.org> wrote:
> On Sat, Feb 17, 2007 at 08:25:07AM -0500, Jaya Kumar wrote:
> > On 2/17/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > >And, as Andrew suggested last time around, could you perhaps push this
> > >fancy new idea into the FB layer so that more drivers can make us of it?
> >
> > I would like to do that very much. I have some ideas how it could work
> > for devices that support clean partial updates by tracking touched
> > pages. But I wonder if it is too early to try to abstract this out.
> > James, Geert, what do you think?
> >
> This would also provide an interesting hook for setting up chained DMA
> for the real framebuffer updates when there's more than a couple of pages
> that have been touched, which would also be nice to have. There's more
> than a few drivers that could take advantage of that.
>

Hi Paul,

I could benefit from knowing which driver and display device you are
considering to be applicable.

I was thinking the method used in hecubafb would only be useful to
devices with very slow update paths, where "losing" some of the
display activity is not an issue since the device would not have been
able to update fast enough to show that activity anyway.

What you described with chained DMA sounds different to this. I
suppose one could use this technique to coalesce framebuffer IO to get
better performance/utilization even for fast display devices. Sounds
interesting to try. Did I understand you correctly?

Thanks,
jaya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
