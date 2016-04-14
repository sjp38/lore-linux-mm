Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB27B6B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 05:06:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a125so47030626wmd.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 02:06:19 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id 10si33757853wmm.87.2016.04.14.02.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 02:06:18 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id n3so116002243wmn.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 02:06:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <570F5973.40809@suse.cz>
References: <570F4F5F.6070209@gmail.com>
	<570F5973.40809@suse.cz>
Date: Thu, 14 Apr 2016 11:06:18 +0200
Message-ID: <CAMJBoFO7bORG-uWmCxjvyue4+kLbWPO1-dYApJnsyzkMUVkoCw@mail.gmail.com>
Subject: Re: [PATCH] z3fold: the 3-fold allocator for compressed pages
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: multipart/alternative; boundary=001a11417d3a11b4b505306e35d2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

--001a11417d3a11b4b505306e35d2
Content-Type: text/plain; charset=UTF-8

On Thu, Apr 14, 2016 at 10:48 AM, Vlastimil Babka <vbabka@suse.cz> wrote:

> On 04/14/2016 10:05 AM, Vitaly Wool wrote:
>
>> This patch introduces z3fold, a special purpose allocator for storing
>> compressed pages. It is designed to store up to three compressed pages per
>> physical page. It is a ZBUD derivative which allows for higher compression
>> ratio keeping the simplicity and determinism of its predecessor.
>>
>
> So the obvious question is, why a separate allocator and not extend zbud?
>

Well, as far as I recall Seth was very much for keeping zbud as simple as
possible. I am fine either way but if we have zpool API, why not have
another zpool API user?


> I didn't study the code, nor notice a design/algorithm overview doc, but
> it seems z3fold keeps the idea of one compressed page at the beginning, one
> at the end of page frame, but it adds another one in the middle? Also how
> is the buddy-matching done?
>

Basically yes. There is 'start_middle' variable which point to the start of
the middle page, if any. The matching is done basing on the buddy number.

~vitaly

--001a11417d3a11b4b505306e35d2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Thu, Apr 14, 2016 at 10:48 AM, Vlastimil Babka <span dir=3D"ltr">&lt=
;<a href=3D"mailto:vbabka@suse.cz" target=3D"_blank">vbabka@suse.cz</a>&gt;=
</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .=
8ex;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On 04/14/=
2016 10:05 AM, Vitaly Wool wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
This patch introduces z3fold, a special purpose allocator for storing<br>
compressed pages. It is designed to store up to three compressed pages per<=
br>
physical page. It is a ZBUD derivative which allows for higher compression<=
br>
ratio keeping the simplicity and determinism of its predecessor.<br>
</blockquote>
<br></span>
So the obvious question is, why a separate allocator and not extend zbud?<b=
r></blockquote><div><br></div><div>Well, as far as I recall Seth was very m=
uch for keeping zbud as simple as possible. I am fine either way but if we =
have zpool API, why not have another zpool API user?<br></div><div>=C2=A0</=
div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-lef=
t:1px #ccc solid;padding-left:1ex">
I didn&#39;t study the code, nor notice a design/algorithm overview doc, bu=
t it seems z3fold keeps the idea of one compressed page at the beginning, o=
ne at the end of page frame, but it adds another one in the middle? Also ho=
w is the buddy-matching done?<br></blockquote></div><br></div><div class=3D=
"gmail_extra">Basically yes. There is &#39;start_middle&#39; variable which=
 point to the start of the middle page, if any. The matching is done basing=
 on the buddy number.<br><br></div><div class=3D"gmail_extra">~vitaly<br></=
div></div>

--001a11417d3a11b4b505306e35d2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
