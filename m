Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id A76E76B0263
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 21:22:55 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id 20so10201041uak.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 18:22:55 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id 89si6687777uab.202.2016.10.24.18.22.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 18:22:55 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id x11so3196062qka.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 18:22:54 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <CAKgT0UfTSmWGBqE0uDG40sAm-LVwCJ6zM1AFJ8o_tWu+XJvfVw@mail.gmail.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
 <20161024120437.16276.68349.stgit@ahduyck-blue-test.jf.intel.com>
 <20161024180934.GA24840@char.us.oracle.com> <CAKgT0UfTSmWGBqE0uDG40sAm-LVwCJ6zM1AFJ8o_tWu+XJvfVw@mail.gmail.com>
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Date: Mon, 24 Oct 2016 21:22:34 -0400
Message-ID: <CAPbh3rsuPWkOHmGK1BM01GeA-5GtZHNVqYALhXxdsPkTqKogLw@mail.gmail.com>
Subject: Re: [net-next PATCH RFC 02/26] swiotlb: Add support for DMA_ATTR_SKIP_CPU_SYNC
Content-Type: multipart/alternative; boundary=94eb2c05b31c0dd7f2053fa6590d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Alexander Duyck <alexander.h.duyck@intel.com>, Netdev <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, David Miller <davem@davemloft.net>

--94eb2c05b31c0dd7f2053fa6590d
Content-Type: text/plain; charset=UTF-8

>
>
> >
> > This too. Why can't that be part of the existing code that was there?
>
> Once again it was a formatting thing.  I was indented too far and
> adding the attribute pushed me over 80 characters so I broke it out to
> a label to avoid the problem.
>

Aah. It is OK to go over the 80 characters. I am not that nit picky.


> - Alex
>

--94eb2c05b31c0dd7f2053fa6590d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blo=
ckquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #c=
cc solid;padding-left:1ex"><div><div class=3D"h5"><br>
&gt;<br>
&gt; This too. Why can&#39;t that be part of the existing code that was the=
re?<br>
<br>
</div></div>Once again it was a formatting thing.=C2=A0 I was indented too =
far and<br>
adding the attribute pushed me over 80 characters so I broke it out to<br>
a label to avoid the problem.<br></blockquote><div><br></div><div>Aah. It i=
s OK to go over the 80 characters. I am not that nit picky.</div><div><br><=
/div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-le=
ft:1px #ccc solid;padding-left:1ex">
<br>
- Alex<br>
</blockquote></div><br></div></div>

--94eb2c05b31c0dd7f2053fa6590d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
