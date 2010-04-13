Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3B4456B01EF
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 12:01:34 -0400 (EDT)
Received: by iwn14 with SMTP id 14so5040326iwn.22
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 09:01:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100413155253.GD25756@csn.ul.ie>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com>
	 <20100413155253.GD25756@csn.ul.ie>
Date: Wed, 14 Apr 2010 01:01:31 +0900
Message-ID: <i2x28c262361004130901p9c34b49cu9c7ebd1a24de5ed9@mail.gmail.com>
Subject: Re: [PATCH 3/6] change alloc function in alloc_slab_page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 12:52 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Wed, Apr 14, 2010 at 12:25:00AM +0900, Minchan Kim wrote:
>> alloc_slab_page never calls alloc_pages_node with -1.
>
> Are you certain? What about
>
> __kmalloc
> =C2=A0-> slab_alloc (passed -1 as a node from __kmalloc)
> =C2=A0 =C2=A0-> __slab_alloc
> =C2=A0 =C2=A0 =C2=A0-> new_slab
> =C2=A0 =C2=A0 =C2=A0 =C2=A0-> allocate_slab
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-> alloc_slab_page
>

Sorry for writing confusing changelog.

I means if node =3D=3D -1 alloc_slab_page always calls alloc_pages.
So we don't need redundant check.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
