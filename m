Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id AD5556B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 18:45:39 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id l13so7452608iga.6
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 15:45:39 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id j1si1245082igo.8.2014.09.24.15.45.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 15:45:38 -0700 (PDT)
Received: by mail-ig0-f180.google.com with SMTP id a13so7410411igq.1
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 15:45:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140924145927.04e8eb7ba6c1410a797293c7@linux-foundation.org>
References: <1411200187-40896-1-git-send-email-pfeiner@google.com>
	<20140924145927.04e8eb7ba6c1410a797293c7@linux-foundation.org>
Date: Wed, 24 Sep 2014 15:45:38 -0700
Message-ID: <CAM3pwhFy-G+kxRpyFY4bH+zLkCQH+8syEnVx6UC6DJVnUFP7ZA@mail.gmail.com>
Subject: Re: [PATCH] mm: softdirty: keep bit when zapping file pte
From: Peter Feiner <pfeiner@google.com>
Content-Type: multipart/alternative; boundary=bcaec5186b0a5f97750503d771ff
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

--bcaec5186b0a5f97750503d771ff
Content-Type: text/plain; charset=UTF-8

On Sep 24, 2014 2:59 PM, "Andrew Morton" <akpm@linux-foundation.org> wrote:
>
> On Sat, 20 Sep 2014 01:03:07 -0700 Peter Feiner <pfeiner@google.com>
wrote:
>
> > Fixes the same bug as b43790eedd31e9535b89bbfa45793919e9504c34 and
> > 9aed8614af5a05cdaa32a0b78b0f1a424754a958 where the return value of
> > pte_*mksoft_dirty was being ignored.
> >
> > To be sure that no other pte/pmd "mk" function return values were
> > being ignored, I annotated the functions in
> > arch/x86/include/asm/pgtable.h with __must_check and rebuilt.
> >
>
> Grumble.
>
> It is useful to identify preceding similar patches but that isn't a
> good way of describing *this* patch.  What is wrong with the current
> code, how does the patch fix it.
>
> And, particularly, what do you think are the end-user visible effects
> of the bug?  This info helps people to work out which kernel versions
> need the fix.
>

Let me think about this and cook up a test case. I'll submit a v2 with a
better description.

Peter

--bcaec5186b0a5f97750503d771ff
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">On Sep 24, 2014 2:59 PM, &quot;Andrew Morton&quot; &lt;<a hr=
ef=3D"mailto:akpm@linux-foundation.org">akpm@linux-foundation.org</a>&gt; w=
rote:<br>
&gt;<br>
&gt; On Sat, 20 Sep 2014 01:03:07 -0700 Peter Feiner &lt;<a href=3D"mailto:=
pfeiner@google.com">pfeiner@google.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; Fixes the same bug as b43790eedd31e9535b89bbfa45793919e9504c34 an=
d<br>
&gt; &gt; 9aed8614af5a05cdaa32a0b78b0f1a424754a958 where the return value o=
f<br>
&gt; &gt; pte_*mksoft_dirty was being ignored.<br>
&gt; &gt;<br>
&gt; &gt; To be sure that no other pte/pmd &quot;mk&quot; function return v=
alues were<br>
&gt; &gt; being ignored, I annotated the functions in<br>
&gt; &gt; arch/x86/include/asm/pgtable.h with __must_check and rebuilt.<br>
&gt; &gt;<br>
&gt;<br>
&gt; Grumble.<br>
&gt;<br>
&gt; It is useful to identify preceding similar patches but that isn&#39;t =
a<br>
&gt; good way of describing *this* patch.=C2=A0 What is wrong with the curr=
ent<br>
&gt; code, how does the patch fix it.<br>
&gt;<br>
&gt; And, particularly, what do you think are the end-user visible effects<=
br>
&gt; of the bug?=C2=A0 This info helps people to work out which kernel vers=
ions<br>
&gt; need the fix.<br>
&gt;</p>
<p dir=3D"ltr">Let me think about this and cook up a test case. I&#39;ll su=
bmit a v2 with a better description.</p>
<p dir=3D"ltr">Peter<br>
</p>

--bcaec5186b0a5f97750503d771ff--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
