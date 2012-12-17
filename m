Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 1EB6E6B005A
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 14:44:38 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id ds1so1903411wgb.2
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 11:44:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1212170318110.21139@chino.kir.corp.google.com>
References: <1355708488-2913-1-git-send-email-tangchen@cn.fujitsu.com>
	<1355708488-2913-3-git-send-email-tangchen@cn.fujitsu.com>
	<alpine.DEB.2.00.1212170318110.21139@chino.kir.corp.google.com>
Date: Mon, 17 Dec 2012 11:44:36 -0800
Message-ID: <CA+55aFwuT1aQt5HDTTLjk2HfyTK7jK=SAVxuQZiDfq-yS7D9BA@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] memory-hotplug: Disable CONFIG_MOVABLE_NODE option
 by default.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=e89a8f13eaf874cb9204d1119c36
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, wency@cn.fujitsu.com, mel@csn.ul.ie, mingo@elte.hu, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linux-kernel@vger.kernel.org

--e89a8f13eaf874cb9204d1119c36
Content-Type: text/plain; charset=ISO-8859-1

The only thing broken about it was the condign option and the lack of docs,
so...

     Linus
On Dec 17, 2012 3:19 AM, "David Rientjes" <rientjes@google.com> wrote:

> On Mon, 17 Dec 2012, Tang Chen wrote:
>
> > This patch set CONFIG_MOVABLE_NODE to "default n" instead of
> > "depends on BROKEN".
> >
> > Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> > Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>
> It's fine to change the default, but what's missing here is a rationale
> for no longer making it depend on CONFIG_BROKEN.
>

--e89a8f13eaf874cb9204d1119c36
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">The only thing broken about it was the condign option and th=
e lack of docs, so...</p>
<p dir=3D"ltr">=A0=A0=A0=A0 Linus</p>
<div class=3D"gmail_quote">On Dec 17, 2012 3:19 AM, &quot;David Rientjes&qu=
ot; &lt;<a href=3D"mailto:rientjes@google.com">rientjes@google.com</a>&gt; =
wrote:<br type=3D"attribution"><blockquote class=3D"gmail_quote" style=3D"m=
argin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
On Mon, 17 Dec 2012, Tang Chen wrote:<br>
<br>
&gt; This patch set CONFIG_MOVABLE_NODE to &quot;default n&quot; instead of=
<br>
&gt; &quot;depends on BROKEN&quot;.<br>
&gt;<br>
&gt; Signed-off-by: Tang Chen &lt;<a href=3D"mailto:tangchen@cn.fujitsu.com=
">tangchen@cn.fujitsu.com</a>&gt;<br>
&gt; Reviewed-by: Yasuaki Ishimatsu &lt;<a href=3D"mailto:isimatu.yasuaki@j=
p.fujitsu.com">isimatu.yasuaki@jp.fujitsu.com</a>&gt;<br>
<br>
It&#39;s fine to change the default, but what&#39;s missing here is a ratio=
nale<br>
for no longer making it depend on CONFIG_BROKEN.<br>
</blockquote></div>

--e89a8f13eaf874cb9204d1119c36--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
