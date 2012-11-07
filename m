Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 526F46B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 05:38:06 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id k6so1407024lbo.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 02:38:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAEwNFnAA+PNh0OT7vdv5k5u3TXeBUDJZX75TQg_Si4yFnE6e-g@mail.gmail.com>
References: <1351840367-4152-1-git-send-email-minchan@kernel.org>
	<20121106153213.03e9cc9f.akpm@linux-foundation.org>
	<CAEwNFnAA+PNh0OT7vdv5k5u3TXeBUDJZX75TQg_Si4yFnE6e-g@mail.gmail.com>
Date: Wed, 7 Nov 2012 19:38:04 +0900
Message-ID: <CAEwNFnD9tVywtb6s3YGMs7vcndCVZNZ0wU=RnOeVnG9UEXnmWQ@mail.gmail.com>
Subject: Re: [PATCH v4 0/3] zram/zsmalloc promotion
From: Minchan Kim <minchan@kernel.org>
Content-Type: multipart/alternative; boundary=f46d042f94bc3ee74704cde550f3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Jens Axboe <axboe@kernel.dk>, Pekka Enberg <penberg@cs.helsinki.fi>, gaowanlong@cn.fujitsu.com

--f46d042f94bc3ee74704cde550f3
Content-Type: text/plain; charset=UTF-8

Hi Andrew,

On Wed, Nov 7, 2012 at 8:32 AM, Andrew Morton <akpm@linux-foundation.org>
wrote:
> On Fri, 2 Nov 2012 16:12:44 +0900
> Minchan Kim <minchan@kernel.org> wrote:
>
>> This patchset promotes zram/zsmalloc from staging.
>
> The changelogs are distressingly short of *reasons* for doing this!
>
>> Both are very clean and zram have been used by many embedded product
>> for a long time.
>
> Well that's interesting.
>
> Which embedded products? How are they using zram and what benefit are
> they observing from it, in what scenarios?
>

At least, major TV companys have used zram as swap since two years ago and
recently our production team released android smart phone with zram which
is used as swap, too.
And there is trial to use zram as swap in ChromeOS project, too. (Although
they report some problem recently, it was not a problem of zram).
When you google zram, you can find various usecase in xda-developers.

With my experience, the benefit in real practice was to remove jitter of
video application. It would be effect of efficient memory usage by
compression but more issue is whether swap is there or not in the system.
As you know, recent mobile platform have used JAVA so there are lots of
anonymous pages. But embedded system normally doesn't use eMMC or SDCard as
swap because there is wear-leveling issue and latency so we can't reclaim
anymous pages. It sometime ends up making system very slow when it requires
to get contiguous memory and even many file-backed pages are evicted. It's
never what embedded people want it. Zram is one of best solution for that.

It's very hard to type with mobile phone. :(

-- 
Kind regards,
Minchan Kim

--f46d042f94bc3ee74704cde550f3
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p>Hi Andrew,</p>
<p>On Wed, Nov 7, 2012 at 8:32 AM, Andrew Morton &lt;<a href=3D"mailto:akpm=
@linux-foundation.org">akpm@linux-foundation.org</a>&gt; wrote:<br>
&gt; On Fri, 2 Nov 2012 16:12:44 +0900<br>
&gt; Minchan Kim &lt;<a href=3D"mailto:minchan@kernel.org">minchan@kernel.o=
rg</a>&gt; wrote:<br>
&gt;<br>
&gt;&gt; This patchset promotes zram/zsmalloc from staging.<br>
&gt;<br>
&gt; The changelogs are distressingly short of *reasons* for doing this!<br=
>
&gt;<br>
&gt;&gt; Both are very clean and zram have been used by many embedded produ=
ct<br>
&gt;&gt; for a long time.<br>
&gt;<br>
&gt; Well that&#39;s interesting.<br>
&gt;<br>
&gt; Which embedded products? How are they using zram and what benefit are<=
br>
&gt; they observing from it, in what scenarios?<br>
&gt;</p>
<p>At least, major TV companys have used zram as swap since two years ago a=
nd recently our production team released android smart phone with zram whic=
h is used as swap, too.<br>
And there is trial to use zram as swap in ChromeOS project, too. (Although =
they report some problem recently, it was not a problem of zram).<br>
When you google zram, you can find various usecase in xda-developers. </p>
<p>With my experience, the benefit in real practice was to remove jitter of=
 video application. It would be effect of efficient memory usage by compres=
sion but more issue is whether swap is there or not in the system. As you k=
now, recent mobile platform have used JAVA so there are lots of anonymous p=
ages. But embedded system normally doesn&#39;t use eMMC or SDCard as swap b=
ecause there is wear-leveling issue and latency so we can&#39;t reclaim any=
mous pages. It sometime ends up making system very slow when it requires to=
 get contiguous memory and even many file-backed pages are evicted. It&#39;=
s never what embedded people want it. Zram is one of best solution for that=
. </p>

<p>It&#39;s very hard to type with mobile phone. :(<br></p>
<p>-- <br>
Kind regards,<br>
Minchan Kim</p>

--f46d042f94bc3ee74704cde550f3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
