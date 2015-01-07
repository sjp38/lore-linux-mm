Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8492D6B0038
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 02:32:33 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so3033602pdi.2
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 23:32:33 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id ny4si1234428pbb.247.2015.01.06.23.32.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 23:32:31 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so3172495pab.2
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 23:32:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1501062114240.5674@gentwo.org>
References: <CAC2pzGe9Q+19LpyFPwr8+TZ02XfCqwrQzsEsJA8WWB6XhuJyeQ@mail.gmail.com>
	<alpine.DEB.2.11.1501062114240.5674@gentwo.org>
Date: Wed, 7 Jan 2015 15:32:30 +0800
Message-ID: <CAC2pzGd_p37Pi53ZEQShMj9BAECPXZCsxQwm=kKLACwmSBB99w@mail.gmail.com>
Subject: Re: [PATCH] mm: move MACRO SLAB_NEVER_MERGE and SLAB_MERGE_SAME to
 file linux/slab.h
From: Bryton Lee <brytonlee01@gmail.com>
Content-Type: multipart/alternative; boundary=e89a8ffbaaab1df4cc050c0aed56
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: iamjoonsoo.kim@lge.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "vger.linux-kernel.cn" <kernel@vger.linux-kernel.cn>

--e89a8ffbaaab1df4cc050c0aed56
Content-Type: text/plain; charset=UTF-8

thanks for review my patch.

I want to move these macros to linux/slab.h cause I don't want perform
merge in slab level.   for example. ss read /proc/slabinfo to finger out
how many requests pending in the TCP listern queue.  it  use slabe name
"tcp_timewait_sock_ops" search in /proc/slabinfo, although the name is
obsolete. so I committed other patch  to iproute2, replaced
tcp_timewait_sock_ops by request_sock_TCP, but it still not work, because
slab request_sock_TCP  merge into kmalloc-256.

how could I prevent this merge happen.  I'm new to kernel, this is my first
time submit a kernel patch, thanks!


On Wed, Jan 7, 2015 at 11:16 AM, Christoph Lameter <cl@linux.com> wrote:

> On Wed, 7 Jan 2015, Bryton Lee wrote:
>
> > move MACRO SLAB_NEVER_MERGE and SLAB_MERGE_SAME from file
> mm/slab_common.c
> > to file linux/slab.h.
> > let other kernel code create slab can use these flags.
>
> This does not make sense. The fact that a slab has been merged is
> available from a field in the kmem_cache structure (aliases).
>
>
> These two macros are criteria for the slab allocators to perform merges.
> The merge decision is the slab allocators decision and not the decision of
> other kernel code.
>
>
>


-- 
Best Regards

Bryton.Lee

--e89a8ffbaaab1df4cc050c0aed56
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div>thanks for review my patch. <br><br></div>I want=
 to move these macros to linux/slab.h cause I don&#39;t want perform merge =
in slab level.=C2=A0=C2=A0 for example. ss read /proc/slabinfo to finger ou=
t how many requests pending in the TCP listern queue.=C2=A0 it=C2=A0 use sl=
abe name &quot;tcp_timewait_sock_ops&quot; search in /proc/slabinfo, althou=
gh the name is obsolete. so I committed other patch=C2=A0 to iproute2, repl=
aced tcp_timewait_sock_ops by request_sock_TCP, but it still not work, beca=
use=C2=A0 slab request_sock_TCP=C2=A0 merge into kmalloc-256. <br><br></div=
>how could I prevent this merge happen.=C2=A0 I&#39;m new to kernel, this i=
s my first time submit a kernel patch, thanks!<br><br></div><div class=3D"g=
mail_extra"><br><div class=3D"gmail_quote">On Wed, Jan 7, 2015 at 11:16 AM,=
 Christoph Lameter <span dir=3D"ltr">&lt;<a href=3D"mailto:cl@linux.com" ta=
rget=3D"_blank">cl@linux.com</a>&gt;</span> wrote:<br><blockquote class=3D"=
gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-=
left:1ex"><span class=3D"">On Wed, 7 Jan 2015, Bryton Lee wrote:<br>
<br>
&gt; move MACRO SLAB_NEVER_MERGE and SLAB_MERGE_SAME from file mm/slab_comm=
on.c<br>
&gt; to file linux/slab.h.<br>
&gt; let other kernel code create slab can use these flags.<br>
<br>
</span>This does not make sense. The fact that a slab has been merged is<br=
>
available from a field in the kmem_cache structure (aliases).<br>
<br>
<br>
These two macros are criteria for the slab allocators to perform merges.<br=
>
The merge decision is the slab allocators decision and not the decision of<=
br>
other kernel code.<br>
<br>
<br>
</blockquote></div><br><br clear=3D"all"><br>-- <br><div class=3D"gmail_sig=
nature">Best Regards<br><br>Bryton.Lee<br><br></div>
</div>

--e89a8ffbaaab1df4cc050c0aed56--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
