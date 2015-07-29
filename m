Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 056DE6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 11:34:54 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so10791509ykd.2
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:34:53 -0700 (PDT)
Received: from mail-yk0-x22c.google.com (mail-yk0-x22c.google.com. [2607:f8b0:4002:c07::22c])
        by mx.google.com with ESMTPS id z188si18867815ywa.99.2015.07.29.08.34.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 08:34:53 -0700 (PDT)
Received: by ykay190 with SMTP id y190so10774462yka.3
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:34:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150729153135.GW8100@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
	<20150729123629.GI15801@dhcp22.suse.cz>
	<20150729135907.GT8100@esperanza>
	<CANN689HJX2ZL891uOd8TW9ct4PNH9d5odQZm86WMxkpkCWhA-w@mail.gmail.com>
	<20150729144539.GU8100@esperanza>
	<CANN689Euq3Y-CHQo8q88vzFAYZX4S6rK+rZRfbuSKfS74u=gcg@mail.gmail.com>
	<20150729153135.GW8100@esperanza>
Date: Wed, 29 Jul 2015 08:34:52 -0700
Message-ID: <CANN689GNzwjc5AsAfSGRWM=Tr=ouHSgJ76fSvvPvA_hmiGjFSA@mail.gmail.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
From: Michel Lespinasse <walken@google.com>
Content-Type: multipart/alternative; boundary=94eb2c0335d0f2164a051c055333
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

--94eb2c0335d0f2164a051c055333
Content-Type: text/plain; charset=UTF-8

On Wed, Jul 29, 2015 at 8:31 AM, Vladimir Davydov <vdavydov@parallels.com>
wrote:

> On Wed, Jul 29, 2015 at 08:08:22AM -0700, Michel Lespinasse wrote:
> > On Wed, Jul 29, 2015 at 7:45 AM, Vladimir Davydov <
> vdavydov@parallels.com>
> > wrote:
> > > Page table scan approach has the inherent problem - it ignores unmapped
> > > page cache. If a workload does a lot of read/write or map-access-unmap
> > > operations, we won't be able to even roughly estimate its wss.
> >
> > You can catch that in mark_page_accessed on those paths, though.
>
> Actually, the problem here is how to find an unmapped page cache page
> *to mark it idle*, not to mark it accessed.
>

Ah, yes.

When I tried that I was still scanning memory by address at the end just to
compute such totals - but I did not have to do rmap at that point anymore.

It did look incredibly lame, though.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--94eb2c0335d0f2164a051c055333
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div class=3D"gmail_quote">On Wed, Jul 29, 2015 at 8:31 AM, Vladimir Davydo=
v <span dir=3D"ltr">&lt;<a href=3D"mailto:vdavydov@parallels.com" target=3D=
"_blank">vdavydov@parallels.com</a>&gt;</span> wrote:<br><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">On Wed, Jul 29, 2015 at 08:08:22AM -0700, Michel Lespinasse w=
rote:<br>
&gt; On Wed, Jul 29, 2015 at 7:45 AM, Vladimir Davydov &lt;<a href=3D"mailt=
o:vdavydov@parallels.com">vdavydov@parallels.com</a>&gt;<br>
<span class=3D"">&gt; wrote:<br>
&gt; &gt; Page table scan approach has the inherent problem - it ignores un=
mapped<br>
&gt; &gt; page cache. If a workload does a lot of read/write or map-access-=
unmap<br>
&gt; &gt; operations, we won&#39;t be able to even roughly estimate its wss=
.<br>
&gt;<br>
&gt; You can catch that in mark_page_accessed on those paths, though.<br>
<br>
</span>Actually, the problem here is how to find an unmapped page cache pag=
e<br>
*to mark it idle*, not to mark it accessed.<br></blockquote><div><br>Ah, ye=
s.<br><br>When I tried that I was still scanning memory by address at the e=
nd just to compute such totals - but I did not have to do rmap at that poin=
t anymore.<br><br>It did look incredibly lame, though.<br clear=3D"all"></d=
iv></div><br>-- <br><div class=3D"gmail_signature">Michel &quot;Walken&quot=
; Lespinasse<br>A program is never fully debugged until the last user dies.=
</div>

--94eb2c0335d0f2164a051c055333--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
