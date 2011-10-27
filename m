Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B80D86B002D
	for <linux-mm@kvack.org>; Thu, 27 Oct 2011 05:10:48 -0400 (EDT)
Received: by wwf5 with SMTP id 5so3181948wwf.26
        for <linux-mm@kvack.org>; Thu, 27 Oct 2011 02:10:46 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 4/9] mm: MIGRATE_CMA migration type added
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <1317909290-29832-5-git-send-email-m.szyprowski@samsung.com>
 <20111018130826.GD6660@csn.ul.ie> <op.v3ve8vbl3l0zgt@mpn-glaptop>
Date: Thu, 27 Oct 2011 11:10:42 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v3z6f4173l0zgt@mpn-glaptop>
In-Reply-To: <op.v3ve8vbl3l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse
 Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq
 Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

> On Tue, 18 Oct 2011 06:08:26 -0700, Mel Gorman <mel@csn.ul.ie> wrote:
>> This does mean that MIGRATE_CMA also does not have a per-cpu list.
>> I don't know if that matters to you but all allocations using
>> MIGRATE_CMA will take the zone lock.

On Mon, 24 Oct 2011 21:32:45 +0200, Michal Nazarewicz <mina86@mina86.com=
> wrote:
> This is sort of an artefact of my misunderstanding of pcp lists in the=

> past.  I'll have to re-evaluate the decision not to include CMA on pcp=

> list.

Actually sorry.  My comment above is somehow invalid.

The CMA does not need to be on pcp list because CMA pages are never allo=
cated
via standard kmalloc() and friends.  Because of the fallbacks in rmqueue=
_bulk()
the CMA pages end up being added to a pcp list of the MOVABLE type and s=
o when
kmallec() allocates an MOVABLE page it can end up grabbing a CMA page.

So it's quite OK that CMA does not have its own pcp list as the list wou=
ld
not be used anyway.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
