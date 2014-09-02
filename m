Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 86B666B0035
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 06:39:23 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id h18so13956203igc.12
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 03:39:23 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id ez4si8137473icb.59.2014.09.02.03.39.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 03:39:22 -0700 (PDT)
Received: by mail-ie0-f175.google.com with SMTP id y20so7378687ier.20
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 03:39:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140902012222.GA21405@infradead.org>
References: <CAEp=YLgzsLbmEfGB5YKVcHP4CQ-_z1yxnZ0tpo7gjKZ2e1ma5g@mail.gmail.com>
	<20140902000822.GA20473@dastard>
	<20140902012222.GA21405@infradead.org>
Date: Tue, 2 Sep 2014 06:39:22 -0400
Message-ID: <CAA8KC9L4u7uhOFnY3tA44ow2NRZGtYqG7zjZ0zA4OLqNMomLoQ@mail.gmail.com>
Subject: Re: ext4 vs btrfs performance on SSD array
From: Zack Coffey <clickwir@gmail.com>
Content-Type: multipart/alternative; boundary=089e0111d4208b1977050212bb8b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-btrfs@vger.kernel.org, linux-mm@kvack.org, linux-raid@vger.kernel.org, linux-fsdevel@vger.kernel.org

--089e0111d4208b1977050212bb8b
Content-Type: text/plain; charset=UTF-8

While I'm sure some of those settings were selected with good reason, maybe
there can be a few options (2 or 3) that have some basic intelligence at
creation to pick a more sane option.

Some checks to see if an option or two might be better suited for the fs.
Like the RAID5 stripe size. Leave the default as is, but maybe a quick
speed test to automatically choose from a handful of the most common
values. If they fail or nothing better is found, then apply the default
value just like it would now.
On Sep 1, 2014 9:23 PM, "Christoph Hellwig" <hch@infradead.org> wrote:

> On Tue, Sep 02, 2014 at 10:08:22AM +1000, Dave Chinner wrote:
> > Pretty obvious difference: avgrq-sz. btrfs is doing 512k IOs, ext4
> > and XFS are doing is doing 128k IOs because that's the default block
> > device readahead size.  'blockdev --setra 1024 /dev/sdd' before
> > mounting the filesystem will probably fix it.
>
> Btw, it's really getting time to make Linux storage fs work out the
> box.  There's way to many things that are stupid by default and we
> require everyone to fix up manually:
>
>  - the ridiculously low max_sectors default
>  - the very small max readahead size
>  - replacing cfq with deadline (or noop)
>  - the too small RAID5 stripe cache size
>
> and probably a few I forgot about.  It's time to make things perform
> well out of the box..
> --
> To unsubscribe from this list: send the line "unsubscribe linux-btrfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--089e0111d4208b1977050212bb8b
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">While I&#39;m sure some of those settings were selected with=
 good reason, maybe there can be a few options (2 or 3) that have some basi=
c intelligence at creation to pick a more sane option.</p>
<p dir=3D"ltr">Some checks to see if an option or two might be better suite=
d for the fs. Like the RAID5 stripe size. Leave the default as is, but mayb=
e a quick speed test to automatically choose from a handful of the most com=
mon values. If they fail or nothing better is found, then apply the default=
 value just like it would now.</p>

<div class=3D"gmail_quote">On Sep 1, 2014 9:23 PM, &quot;Christoph Hellwig&=
quot; &lt;<a href=3D"mailto:hch@infradead.org">hch@infradead.org</a>&gt; wr=
ote:<br type=3D"attribution"><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
On Tue, Sep 02, 2014 at 10:08:22AM +1000, Dave Chinner wrote:<br>
&gt; Pretty obvious difference: avgrq-sz. btrfs is doing 512k IOs, ext4<br>
&gt; and XFS are doing is doing 128k IOs because that&#39;s the default blo=
ck<br>
&gt; device readahead size.=C2=A0 &#39;blockdev --setra 1024 /dev/sdd&#39; =
before<br>
&gt; mounting the filesystem will probably fix it.<br>
<br>
Btw, it&#39;s really getting time to make Linux storage fs work out the<br>
box.=C2=A0 There&#39;s way to many things that are stupid by default and we=
<br>
require everyone to fix up manually:<br>
<br>
=C2=A0- the ridiculously low max_sectors default<br>
=C2=A0- the very small max readahead size<br>
=C2=A0- replacing cfq with deadline (or noop)<br>
=C2=A0- the too small RAID5 stripe cache size<br>
<br>
and probably a few I forgot about.=C2=A0 It&#39;s time to make things perfo=
rm<br>
well out of the box..<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-btrfs&=
quot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at=C2=A0 <a href=3D"http://vger.kernel.org/majordomo-in=
fo.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><b=
r>
</blockquote></div>

--089e0111d4208b1977050212bb8b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
