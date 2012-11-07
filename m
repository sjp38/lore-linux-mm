Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 3E6EF6B002B
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 11:40:17 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id c11so1435752qad.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 08:40:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAEwNFnD9tVywtb6s3YGMs7vcndCVZNZ0wU=RnOeVnG9UEXnmWQ@mail.gmail.com>
References: <1351840367-4152-1-git-send-email-minchan@kernel.org>
	<20121106153213.03e9cc9f.akpm@linux-foundation.org>
	<CAEwNFnAA+PNh0OT7vdv5k5u3TXeBUDJZX75TQg_Si4yFnE6e-g@mail.gmail.com>
	<CAEwNFnD9tVywtb6s3YGMs7vcndCVZNZ0wU=RnOeVnG9UEXnmWQ@mail.gmail.com>
Date: Wed, 7 Nov 2012 08:40:16 -0800
Message-ID: <CAA25o9S=XiO7b-HNbx1GHr+ETrA_p11WU+FUprMn_VhjU=jjvw@mail.gmail.com>
Subject: Re: [PATCH v4 0/3] zram/zsmalloc promotion
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Jens Axboe <axboe@kernel.dk>, Pekka Enberg <penberg@cs.helsinki.fi>, gaowanlong@cn.fujitsu.com

Since Chrome OS was mentioned: the main reason why we don't use swap
to a disk (rotating or SSD) is because it doesn't degrade gracefully
and leads to a bad interactive experience.  Generally we prefer to
manage RAM at a higher level, by transparently killing and restarting
processes.  But we noticed that zram is fast enough to be competitive
with the latter, and it lets us make more efficient use of the
available RAM.

As Minchan said, the zram module in itself appears to work fine.  We
are hitting other mm issues (one of which was recently fixed) which
most likely are exposed by the different patterns of memory allocation
when using zram.

On Wed, Nov 7, 2012 at 2:38 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hi Andrew,
>
> On Wed, Nov 7, 2012 at 8:32 AM, Andrew Morton <akpm@linux-foundation.org>
> wrote:
>> On Fri, 2 Nov 2012 16:12:44 +0900
>> Minchan Kim <minchan@kernel.org> wrote:
>>
>>> This patchset promotes zram/zsmalloc from staging.
>>
>> The changelogs are distressingly short of *reasons* for doing this!
>>
>>> Both are very clean and zram have been used by many embedded product
>>> for a long time.
>>
>> Well that's interesting.
>>
>> Which embedded products? How are they using zram and what benefit are
>> they observing from it, in what scenarios?
>>
>
> At least, major TV companys have used zram as swap since two years ago and
> recently our production team released android smart phone with zram which is
> used as swap, too.
> And there is trial to use zram as swap in ChromeOS project, too. (Although
> they report some problem recently, it was not a problem of zram).
> When you google zram, you can find various usecase in xda-developers.
>
> With my experience, the benefit in real practice was to remove jitter of
> video application. It would be effect of efficient memory usage by
> compression but more issue is whether swap is there or not in the system. As
> you know, recent mobile platform have used JAVA so there are lots of
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
