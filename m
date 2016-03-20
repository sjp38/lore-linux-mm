Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 74D35830AE
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:54:57 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id ig19so72011027igb.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:54:57 -0700 (PDT)
Received: from mail-ig0-x241.google.com (mail-ig0-x241.google.com. [2607:f8b0:4001:c05::241])
        by mx.google.com with ESMTPS id ga4si5992435igd.34.2016.03.20.11.54.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Mar 2016 11:54:56 -0700 (PDT)
Received: by mail-ig0-x241.google.com with SMTP id nt3so8186244igb.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:54:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1458499278-1516-2-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1458499278-1516-2-git-send-email-kirill.shutemov@linux.intel.com>
Date: Sun, 20 Mar 2016 11:54:56 -0700
Message-ID: <CA+55aFzSqbT+wQFmpaF+g8snk4AZ7oW7dheOUeqJq2qA5tytrw@mail.gmail.com>
Subject: Re: [PATCH 01/71] arc: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=001a1134b8202a3f78052e7f84e4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Vineet Gupta <vgupta@synopsys.com>, linux-mm <linux-mm@kvack.org>

--001a1134b8202a3f78052e7f84e4
Content-Type: text/plain; charset=UTF-8

I'm OK with this, but let's not do this as a hundred small patches, OK?

It doesn't help legibility or testing, so let's just do it in one big go.

    Linus

On Mar 20, 2016 11:41 AM, "Kirill A. Shutemov" <
kirill.shutemov@linux.intel.com> wrote:
>
> PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
> with promise that one day it will be possible to implement page cache with
> bigger chunks than PAGE_SIZE.
>
> This promise never materialized. And unlikely will.

--001a1134b8202a3f78052e7f84e4
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">I&#39;m OK with this, but let&#39;s not do this as a hundred=
 small patches, OK? </p>
<p dir=3D"ltr">It doesn&#39;t help legibility or testing, so let&#39;s just=
 do it in one big go.</p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0 Linus</p>
<p dir=3D"ltr">On Mar 20, 2016 11:41 AM, &quot;Kirill A. Shutemov&quot; &lt=
;<a href=3D"mailto:kirill.shutemov@linux.intel.com">kirill.shutemov@linux.i=
ntel.com</a>&gt; wrote:<br>
&gt;<br>
&gt; PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time =
ago<br>
&gt; with promise that one day it will be possible to implement page cache =
with<br>
&gt; bigger chunks than PAGE_SIZE.<br>
&gt;<br>
&gt; This promise never materialized. And unlikely will.<br>
</p>

--001a1134b8202a3f78052e7f84e4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
