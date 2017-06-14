Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E44FF6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:58:19 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k26so1808394iti.5
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:58:19 -0700 (PDT)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id n14si1411957iti.100.2017.06.14.15.58.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 15:58:19 -0700 (PDT)
Received: by mail-io0-x235.google.com with SMTP id y77so1364331ioe.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:58:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxzXmg3Kkk+NaXYFy4JsQpbUcZ+CGTgTqAdOsOGqA_E_Q@mail.gmail.com>
References: <cover.1497415951.git.luto@kernel.org> <6da4aea9-ef52-694d-9a03-285c32018326@intel.com>
 <CALCETrXT28SpE1SnYJNVOLadTaOKRYyQ2887BAU5S7X8YxS4ig@mail.gmail.com>
 <CA+55aFw_PYteXjaFZw0vkn4XgOomaqN3JWN-NDh_HdaN8Jb0ZA@mail.gmail.com> <CA+55aFxzXmg3Kkk+NaXYFy4JsQpbUcZ+CGTgTqAdOsOGqA_E_Q@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 15 Jun 2017 07:58:18 +0900
Message-ID: <CA+55aFyN_iA4CwVdEvwv4bWu1Y-ihsYcskcCD93=DGahown7sQ@mail.gmail.com>
Subject: Re: [PATCH v2 00/10] PCID and improved laziness
Content-Type: multipart/alternative; boundary="001a11405e5af719e50551f37c55"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>

--001a11405e5af719e50551f37c55
Content-Type: text/plain; charset="UTF-8"

On Jun 15, 2017 7:48 AM, "Andy Lutomirski" <luto@kernel.org> wrote:


Then throw EPT into the mix for extra fun.  I wonder if we should try
to allocate page tables from nearby physical addresses if we think we
might be running as a guest.


They are already dense in the cache in the last level, and upper levels are
already fairly dense if you are just *reasonably* dense in your virtual
mapping.

Yes, for virtualization, the "virtual mapping" ends up being those page
tables, but physical memory itself is already fairly 'reasonably dense' to
begin with. One single cache line of any upper level page table will cover
quite a bit of memory.

You're likely better off just trying to use large pages for the virtual
machine memory layout, which helps in other ways too. But when that fails,I
doubt it helps a lot to try to do fancy page table layout.

All gut feelings, but i seriously doubt any extra complexity would be a win
big enough to make up for the complexity costs..

     Linus

--001a11405e5af719e50551f37c55
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><div class=3D"gmail_extra"><br><div class=3D"gma=
il_quote">On Jun 15, 2017 7:48 AM, &quot;Andy Lutomirski&quot; &lt;<a href=
=3D"mailto:luto@kernel.org">luto@kernel.org</a>&gt; wrote:<blockquote class=
=3D"quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-le=
ft:1ex"><div class=3D"elided-text">
<br>
</div>Then throw EPT into the mix for extra fun.=C2=A0 I wonder if we shoul=
d try<br>
to allocate page tables from nearby physical addresses if we think we<br>
might be running as a guest.<br>
</blockquote></div><br></div></div><div class=3D"gmail_extra" dir=3D"auto">=
They are already dense in the cache in the last level, and upper levels are=
 already fairly dense if you are just *reasonably* dense in your virtual ma=
pping.</div><div class=3D"gmail_extra" dir=3D"auto"><br></div><div class=3D=
"gmail_extra" dir=3D"auto">Yes, for virtualization, the &quot;virtual mappi=
ng&quot; ends up being those page tables, but physical memory itself is alr=
eady fairly &#39;reasonably dense&#39; to begin with. One single cache line=
 of any upper level page table will cover quite a bit of memory.</div><div =
class=3D"gmail_extra" dir=3D"auto"><br></div><div class=3D"gmail_extra" dir=
=3D"auto">You&#39;re likely better off just trying to use large pages for t=
he virtual machine memory layout, which helps in other ways too. But when t=
hat fails,I doubt it helps a lot to try to do fancy page table layout.</div=
><div class=3D"gmail_extra" dir=3D"auto"><br></div><div class=3D"gmail_extr=
a" dir=3D"auto">All gut feelings, but i seriously doubt any extra complexit=
y would be a win big enough to make up for the complexity costs..</div><div=
 class=3D"gmail_extra" dir=3D"auto"><br></div><div class=3D"gmail_extra" di=
r=3D"auto">=C2=A0 =C2=A0 =C2=A0Linus</div></div>

--001a11405e5af719e50551f37c55--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
