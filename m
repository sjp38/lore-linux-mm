Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8AC6B0036
	for <linux-mm@kvack.org>; Sun, 24 Aug 2014 18:13:51 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id lf12so14223509vcb.40
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 15:13:51 -0700 (PDT)
Received: from mail-vc0-x22c.google.com (mail-vc0-x22c.google.com [2607:f8b0:400c:c03::22c])
        by mx.google.com with ESMTPS id f4si15685049vcu.26.2014.08.24.15.13.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 24 Aug 2014 15:13:50 -0700 (PDT)
Received: by mail-vc0-f172.google.com with SMTP id im17so14364243vcb.31
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 15:13:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53FA4DDA.8020106@sr71.net>
References: <20140821202424.7ED66A50@viggo.jf.intel.com>
	<20140822072023.GA7218@gmail.com>
	<53F75B91.2040100@sr71.net>
	<20140824144946.GC9455@gmail.com>
	<53FA4DDA.8020106@sr71.net>
Date: Sun, 24 Aug 2014 15:13:49 -0700
Message-ID: <CA+55aFw0qyB6_+u3iNf23LmK+Yyquu1q_sh+dFJEp70T82Tjxw@mail.gmail.com>
Subject: Re: [PATCH] [v3] warn on performance-impacting configs aka. TAINT_PERFORMANCE
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=001a11c247e489d92c05016762f9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Laura Abbott <lauraa@codeaurora.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Andi Kleen <ak@linux.intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@redhat.com>, Ingo Molnar <mingo@kernel.org>

--001a11c247e489d92c05016762f9
Content-Type: text/plain; charset=UTF-8

On Aug 24, 2014 1:41 PM, "Dave Hansen" <dave@sr71.net> wrote:
>
> Let's say there is 1 "buf_left" and I attempt a 100-byte snprintf().
> Won't snprintf() return 1, and buf_written will then equal buf_len?

No. snprintf() returns turn number of bytes it *would* write, if i it
wasn't truncated. That's so that people can reallocate a buffer of
sufficient size and just try again.

     Linus

--001a11c247e489d92c05016762f9
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Aug 24, 2014 1:41 PM, &quot;Dave Hansen&quot; &lt;<a href=3D"mailto:dave=
@sr71.net">dave@sr71.net</a>&gt; wrote:<br>
&gt;<br>
&gt; Let&#39;s say there is 1 &quot;buf_left&quot; and I attempt a 100-byte=
 snprintf().<br>
&gt; Won&#39;t snprintf() return 1, and buf_written will then equal buf_len=
?</p>
<p dir=3D"ltr">No. snprintf() returns turn number of bytes it *would* write=
, if i it wasn&#39;t truncated. That&#39;s so that people can reallocate a =
buffer of sufficient size and just try again.</p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0=C2=A0 Linus</p>

--001a11c247e489d92c05016762f9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
