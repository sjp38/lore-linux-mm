Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4982F6B02CA
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 18:12:22 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id w63so305088766oiw.4
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 15:12:22 -0800 (PST)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id r132si4009998oig.2.2016.12.19.15.12.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 15:12:21 -0800 (PST)
Received: by mail-it0-x242.google.com with SMTP id c20so12039668itb.0
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 15:12:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
References: <20161219225826.F8CB356F@viggo.jf.intel.com> <CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 19 Dec 2016 15:12:20 -0800
Message-ID: <CA+55aFx9gZ0qDeD=1-jh+DYnSiteO4fEM-jvA0xbnrzL8hS8Hg@mail.gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Content-Type: multipart/alternative; boundary=94eb2c04abb843da0105440b0d29
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, luto@kernel.org, agruenba@redhat.com, peterz@infradead.org, mgorman@techsingularity.net, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--94eb2c04abb843da0105440b0d29
Content-Type: text/plain; charset=UTF-8

On Dec 19, 2016 3:07 PM, "Linus Torvalds" <torvalds@linux-foundation.org>
wrote:


Part of the problem with the old coffee ..


Traveling. My phone always thinks I mean coffee when I swipe "code".

I can't blame it on not enough coffee this time. I should just double-check
the autocorrect more.

     Linus

--94eb2c04abb843da0105440b0d29
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><div class=3D"gmail_extra"><br><div class=3D"gma=
il_quote">On Dec 19, 2016 3:07 PM, &quot;Linus Torvalds&quot; &lt;<a href=
=3D"mailto:torvalds@linux-foundation.org">torvalds@linux-foundation.org</a>=
&gt; wrote:<blockquote class=3D"quote" style=3D"margin:0 0 0 .8ex;border-le=
ft:1px #ccc solid;padding-left:1ex"><div dir=3D"auto"><div class=3D"quoted-=
text"><div dir=3D"auto"><br></div></div><div dir=3D"auto">Part of the probl=
em with the old coffee ..</div></div></blockquote></div></div></div><div di=
r=3D"auto"><br></div><div dir=3D"auto">Traveling. My phone always thinks I =
mean coffee when I swipe &quot;code&quot;.=C2=A0</div><div dir=3D"auto"><br=
></div><div dir=3D"auto">I can&#39;t blame it on not enough coffee this tim=
e. I should just double-check the autocorrect more.=C2=A0</div><div dir=3D"=
auto"><br></div><div dir=3D"auto">=C2=A0 =C2=A0 =C2=A0Linus</div><div dir=
=3D"auto"></div></div>

--94eb2c04abb843da0105440b0d29--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
