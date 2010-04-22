Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0CD9F6B01F1
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 06:15:18 -0400 (EDT)
Received: by gwj15 with SMTP id 15so1827900gwj.14
        for <linux-mm@kvack.org>; Thu, 22 Apr 2010 03:15:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BCED815.90704@kernel.org>
References: <4BC6CB30.7030308@kernel.org>
	 <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com>
	 <4BC6FBC8.9090204@kernel.org>
	 <w2h28c262361004150449qdea5cde9y687c1fce30e665d@mail.gmail.com>
	 <alpine.DEB.2.00.1004161105120.7710@router.home>
	 <1271606079.2100.159.camel@barrios-desktop>
	 <alpine.DEB.2.00.1004191235160.9855@router.home>
	 <4BCCD8BD.1020307@kernel.org> <20100420150522.GG19264@csn.ul.ie>
	 <4BCED815.90704@kernel.org>
Date: Thu, 22 Apr 2010 19:15:14 +0900
Message-ID: <x2h28c262361004220315v9b8fbf3ei86fe0ebba92169f1@mail.gmail.com>
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 21, 2010 at 7:48 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On 04/20/2010 05:05 PM, Mel Gorman wrote:
>> alloc_pages_exact_node() avoids a branch in a hot path that is checking =
for
>> something the caller already knows. That's the reason it exists.
>
> Yeah sure but Minchan is trying to tidy up the API by converting
> alloc_pages_node() users to use alloc_pages_exact_node(), at which
> point, the distinction becomes pretty useless. =C2=A0Wouldn't just making
> alloc_pages_node() do what alloc_pages_exact_node() does now and
> converting all its users be simpler? =C2=A0IIRC, the currently planned
> transformation looks like the following.
>
> =C2=A0alloc_pages() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0-> alloc_pages_any_node()
> =C2=A0alloc_pages_node() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -> bas=
ically gonna be obsoleted by _exact_node
> =C2=A0alloc_pages_exact_node() =C2=A0 =C2=A0 =C2=A0 -> gonna be used by m=
ost NUMA aware allocs
>
> So, let's just make sure no one calls alloc_pages_node() w/ -1 nid,
> kill alloc_pages_node() and rename alloc_pages_exact_node() to
> alloc_pages_node().

Yes. It was a stupid idea. I hope Mel agree this suggestion.
Thanks for careful review, Tejun.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
