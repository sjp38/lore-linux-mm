Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1246B02F3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 21:33:46 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id b184so7936418oih.9
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 18:33:46 -0700 (PDT)
Received: from mail-it0-x235.google.com (mail-it0-x235.google.com. [2607:f8b0:4001:c0b::235])
        by mx.google.com with ESMTPS id r21si3764175oie.418.2017.08.09.18.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 18:33:45 -0700 (PDT)
Received: by mail-it0-x235.google.com with SMTP id m34so6152460iti.1
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 18:33:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <6d20ced6-a7ca-f4b9-81eb-e34517f97644@infradead.org>
References: <20170808132554.141143-1-dancol@google.com> <20170810001557.147285-1-dancol@google.com>
 <6d20ced6-a7ca-f4b9-81eb-e34517f97644@infradead.org>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 9 Aug 2017 18:33:44 -0700
Message-ID: <CAKOZueu3jsD24beRutpATAr3QyxByMv1nJfKT+RRZr83Z+o1qw@mail.gmail.com>
Subject: Re: [PATCH RFC v2] Add /proc/pid/smaps_rollup
Content-Type: multipart/alternative; boundary="001a1143d24ef82bba05565c2fc1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, timmurray@google.com, linux-kernel@vger.kernel.org, joelaf@google.com

--001a1143d24ef82bba05565c2fc1
Content-Type: text/plain; charset="UTF-8"

Thanks for taking a look!

On Aug 9, 2017 6:24 PM, "Randy Dunlap" <rdunlap@infradead.org> wrote:

On 08/09/2017 05:15 PM, Daniel Colascione wrote:
>
> diff --git a/Documentation/ABI/testing/procfs-smaps_rollup
b/Documentation/ABI/testing/procfs-smaps_rollup
> new file mode 100644
> index 000000000000..fd5a3699edf1
> --- /dev/null
> +++ b/Documentation/ABI/testing/procfs-smaps_rollup
> @@ -0,0 +1,34 @@
> +What:                /proc/pid/smaps_Rollup

                                  smaps_rollup



Gah. Thanks.


\although I would prefer smaps_summary. whatever.


I'm open to anything.

--001a1143d24ef82bba05565c2fc1
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><div class=3D"gmail_extra"><div class=3D"gmail_quote=
" dir=3D"auto">Thanks for taking a look!</div><div class=3D"gmail_quote" di=
r=3D"auto"><br></div><div class=3D"gmail_quote">On Aug 9, 2017 6:24 PM, &qu=
ot;Randy Dunlap&quot; &lt;<a href=3D"mailto:rdunlap@infradead.org">rdunlap@=
infradead.org</a>&gt; wrote:<br type=3D"attribution"><blockquote class=3D"q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x"><div class=3D"quoted-text">On 08/09/2017 05:15 PM, Daniel Colascione wro=
te:<br>
&gt;<br>
&gt; diff --git a/Documentation/ABI/testing/<wbr>procfs-smaps_rollup b/Docu=
mentation/ABI/testing/<wbr>procfs-smaps_rollup<br>
&gt; new file mode 100644<br>
&gt; index 000000000000..fd5a3699edf1<br>
&gt; --- /dev/null<br>
&gt; +++ b/Documentation/ABI/testing/<wbr>procfs-smaps_rollup<br>
&gt; @@ -0,0 +1,34 @@<br>
&gt; +What:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /proc/pi=
d/smaps_Rollup<br>
<br>
</div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 smaps_rollup<br></blockqu=
ote></div></div></div><div dir=3D"auto"><br></div><div dir=3D"auto"><br></d=
iv><div dir=3D"auto">Gah. Thanks.</div><div dir=3D"auto"><br></div><div dir=
=3D"auto"><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blockquote=
 class=3D"quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">
<br>
\although I would prefer smaps_summary. whatever.</blockquote></div></div><=
/div><div dir=3D"auto"><br></div><div dir=3D"auto">I&#39;m open to anything=
.</div></div>

--001a1143d24ef82bba05565c2fc1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
