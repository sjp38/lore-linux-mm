Received: by wx-out-0506.google.com with SMTP id s8so177999wxc
        for <linux-mm@kvack.org>; Wed, 24 Jan 2007 06:22:43 -0800 (PST)
Message-ID: <6d6a94c50701240622n30f1092cq4570f84160fe87f7@mail.gmail.com>
Date: Wed, 24 Jan 2007 22:22:43 +0800
From: "Aubrey Li" <aubreylee@gmail.com>
Subject: Re: [RFC] Limit the size of the pagecache
In-Reply-To: <1169625333.4493.16.camel@taijtu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
	 <1169625333.4493.16.camel@taijtu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Frysinger, Michael" <Michael.Frysinger@analog.com>, Bryan Wu <cooloney.lkml@gmail.com>, "Hennerich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 1/24/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Tue, 2007-01-23 at 16:49 -0800, Christoph Lameter wrote:
> > This is a patch using some of Aubrey's work plugging it in what is IMHO
> > the right way. Feel free to improve on it. I have gotten repeatedly
> > requests to be able to limit the pagecache. With the revised VM statistics
> > this is now actually possile. I'd like to know more about possible uses of
> > such a feature.
> >
> >
> >
> >
> > It may be useful to limit the size of the page cache for various reasons
> > such as
> >
> > 1. Insure that anonymous pages that may contain performance
> >    critical data is never subject to swap.
>
> This is what we have mlock for, no?
>
> > 2. Insure rapid turnaround of pages in the cache.
>
> This sounds like we either need more fadvise hints and/or understand why
> the VM doesn't behave properly.
>
> > 3. Reserve memory for other uses? (Aubrey?)
>
> He wants to make a nommu system act like a mmu system; this will just
> never ever work.

Nope. Actually my nommu system works great with some of patches made by us.
What let you think this will never work?

>Memory fragmentation is a real issue not some gimmick
> thought up by the hardware folks to sell these mmu chips.
>
I totally disagree. Memory fragmentations is the issue not only on
nommu, it's also on mmu chips. That's not the reason mmu chips can be
sold.

-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
