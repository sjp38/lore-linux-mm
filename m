Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id B2CDA6B006E
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 20:20:06 -0500 (EST)
Date: Mon, 19 Nov 2012 10:27:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 0/3] zram/zsmalloc promotion
Message-ID: <20121119012729.GA7747@bbox>
References: <1351840367-4152-1-git-send-email-minchan@kernel.org>
 <20121106153213.03e9cc9f.akpm@linux-foundation.org>
 <CAEwNFnAA+PNh0OT7vdv5k5u3TXeBUDJZX75TQg_Si4yFnE6e-g@mail.gmail.com>
 <CAEwNFnD9tVywtb6s3YGMs7vcndCVZNZ0wU=RnOeVnG9UEXnmWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEwNFnD9tVywtb6s3YGMs7vcndCVZNZ0wU=RnOeVnG9UEXnmWQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Jens Axboe <axboe@kernel.dk>, Pekka Enberg <penberg@cs.helsinki.fi>, gaowanlong@cn.fujitsu.com

Andrew?

On Wed, Nov 07, 2012 at 07:38:04PM +0900, Minchan Kim wrote:
> Hi Andrew,
> 
> On Wed, Nov 7, 2012 at 8:32 AM, Andrew Morton <akpm@linux-foundation.org>
> wrote:
> > On Fri, 2 Nov 2012 16:12:44 +0900
> > Minchan Kim <minchan@kernel.org> wrote:
> >
> >> This patchset promotes zram/zsmalloc from staging.
> >
> > The changelogs are distressingly short of *reasons* for doing this!
> >
> >> Both are very clean and zram have been used by many embedded product
> >> for a long time.
> >
> > Well that's interesting.
> >
> > Which embedded products? How are they using zram and what benefit are
> > they observing from it, in what scenarios?
> >
> 
> At least, major TV companys have used zram as swap since two years ago and
> recently our production team released android smart phone with zram which
> is used as swap, too.
> And there is trial to use zram as swap in ChromeOS project, too. (Although
> they report some problem recently, it was not a problem of zram).
> When you google zram, you can find various usecase in xda-developers.
> 
> With my experience, the benefit in real practice was to remove jitter of
> video application. It would be effect of efficient memory usage by
> compression but more issue is whether swap is there or not in the system.
> As you know, recent mobile platform have used JAVA so there are lots of
> anonymous pages. But embedded system normally doesn't use eMMC or SDCard as
> swap because there is wear-leveling issue and latency so we can't reclaim
> anymous pages. It sometime ends up making system very slow when it requires
> to get contiguous memory and even many file-backed pages are evicted. It's
> never what embedded people want it. Zram is one of best solution for that.
> 
> It's very hard to type with mobile phone. :(
> 
> -- 
> Kind regards,
> Minchan Kim

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
