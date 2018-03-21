Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1106B0006
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 01:59:18 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id e19-v6so2310174otf.9
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 22:59:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b189sor1142041oia.287.2018.03.20.22.59.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 22:59:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180321045353.GC28705@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com> <20180320085452.24641-3-aaron.lu@intel.com>
 <CAF7GXvovKsabDw88icK5c5xBqg6g0TomQdspfi4ikjtbg=XzGQ@mail.gmail.com>
 <20180321015944.GB28705@intel.com> <CAF7GXvrQG0+iPu8h13coo2QW7WxNhjHA1JAaOYoEBBB9-obRSQ@mail.gmail.com>
 <20180321045353.GC28705@intel.com>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Tue, 20 Mar 2018 22:59:16 -0700
Message-ID: <CAF7GXvpzZassTEebX7nS0u_xynns=mxEF28rPBhXX9Yp4xQ3hw@mail.gmail.com>
Subject: Re: [RFC PATCH v2 2/4] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Content-Type: multipart/alternative; boundary="001a113d24a831f16c0567e5e4be"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

--001a113d24a831f16c0567e5e4be
Content-Type: text/plain; charset="UTF-8"

2018-03-20 21:53 GMT-07:00 Aaron Lu <aaron.lu@intel.com>:

> On Tue, Mar 20, 2018 at 09:21:33PM -0700, Figo.zhang wrote:
> > suppose that in free_one_page() will try to merge to high order anytime ,
> > but now in your patch,
> > those merge has postponed when system in low memory status, it is very
> easy
> > let system trigger
> > low memory state and get poor performance.
>
> Merge or not merge, the size of free memory is not affected.
>

yes, the total free memory is not impact, but will influence the higher
order allocation.

--001a113d24a831f16c0567e5e4be
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2018-03-20 21:53 GMT-07:00 Aaron Lu <span dir=3D"ltr">&lt;<a href=3D"ma=
ilto:aaron.lu@intel.com" target=3D"_blank">aaron.lu@intel.com</a>&gt;</span=
>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-l=
eft:1px #ccc solid;padding-left:1ex"><span class=3D"">On Tue, Mar 20, 2018 =
at 09:21:33PM -0700, Figo.zhang wrote:<br>
&gt; suppose that in free_one_page() will try to merge to high order anytim=
e ,<br>
&gt; but now in your patch,<br>
&gt; those merge has postponed when system in low memory status, it is very=
 easy<br>
&gt; let system trigger<br>
&gt; low memory state and get poor performance.<br>
<br>
</span>Merge or not merge, the size of free memory is not affected.<br></bl=
ockquote><div><br></div><div>yes, the total free memory is not impact, but =
will influence the higher order allocation.=C2=A0</div></div><br></div></di=
v>

--001a113d24a831f16c0567e5e4be--
