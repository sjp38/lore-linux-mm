Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 90AAE6B0035
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 01:32:40 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lf10so8129949pab.34
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 22:32:40 -0800 (PST)
Received: from psmtp.com ([74.125.245.116])
        by mx.google.com with SMTP id yj4si12831694pac.282.2013.11.04.22.32.39
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 22:32:39 -0800 (PST)
Received: by mail-oa0-f47.google.com with SMTP id k1so141207oag.6
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 22:32:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxj81TRhe1+FJWqER7VVH_z_Sk0+hwtHvniA0ATsF_eKw@mail.gmail.com>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
	<CA+55aFxj81TRhe1+FJWqER7VVH_z_Sk0+hwtHvniA0ATsF_eKw@mail.gmail.com>
Date: Mon, 4 Nov 2013 22:32:37 -0800
Message-ID: <CAF7GXvonU7k96GxU70wwkEMK1M5ZD0Wyvd8CCbYNe4=3uuS4NA@mail.gmail.com>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
From: "Figo.zhang" <figo1802@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c25700dc144704ea68326d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>

--001a11c25700dc144704ea68326d
Content-Type: text/plain; charset=ISO-8859-1

> Yeah, I think we default to a 10% "dirty background memory" (and
> allows up to 20% dirty), so on your 16GB machine, we allow up to 1.6GB
> of dirty memory for writeout before we even start writing, and twice
> that before we start *waiting* for it.
>
> On 32-bit x86, we only count the memory in the low 1GB (really
> actually up to about 890MB), so "10% dirty" really means just about
> 90MB of buffering (and a "hard limit" of ~180MB of dirty).
>
=> On 32-bit system, the page cache also can use the high memory, so  the
size of 10% "dirty background memory" maybe 1.6GB for this case.

>
>

--001a11c25700dc144704ea68326d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border=
-left:1px #ccc solid;padding-left:1ex"><div class=3D"im"><br>
</div>Yeah, I think we default to a 10% &quot;dirty background memory&quot;=
 (and<br>
allows up to 20% dirty), so on your 16GB machine, we allow up to 1.6GB<br>
of dirty memory for writeout before we even start writing, and twice<br>
that before we start *waiting* for it.<br>
<br>
On 32-bit x86, we only count the memory in the low 1GB (really<br>
actually up to about 890MB), so &quot;10% dirty&quot; really means just abo=
ut<br>
90MB of buffering (and a &quot;hard limit&quot; of ~180MB of dirty).<br></b=
lockquote><div>=3D&gt; On 32-bit system, the page cache also can use the hi=
gh memory, so =A0the size of 10% &quot;dirty background memory&quot; maybe =
1.6GB for this case.</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><br></blockquote></div></div></div>

--001a11c25700dc144704ea68326d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
