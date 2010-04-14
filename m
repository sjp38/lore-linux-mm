Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A86E36B01F5
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 20:02:05 -0400 (EDT)
Received: by gwb15 with SMTP id 15so3780786gwb.14
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:02:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1004131654340.8116@chino.kir.corp.google.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com>
	 <alpine.DEB.2.00.1004131437140.8617@chino.kir.corp.google.com>
	 <u2o28c262361004131640zd034a692s4b46ee77c08e1ccd@mail.gmail.com>
	 <alpine.DEB.2.00.1004131654340.8116@chino.kir.corp.google.com>
Date: Wed, 14 Apr 2010 09:02:04 +0900
Message-ID: <l2p28c262361004131702m49921d78qde6b51bd5b34247c@mail.gmail.com>
Subject: Re: [PATCH 3/6] change alloc function in alloc_slab_page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 8:55 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Wed, 14 Apr 2010, Minchan Kim wrote:
>
>> This changlog is bad.
>> I will change it with following as when I send v2.
>>
>> "alloc_slab_page always checks nid =3D=3D -1, so alloc_page_node can't b=
e
>> called with -1.
>> =C2=A0It means node's validity check in alloc_pages_node is unnecessary.
>> =C2=A0So we can use alloc_pages_exact_node instead of alloc_pages_node.
>> =C2=A0It could avoid comparison and branch as 6484eb3e2a81807722 tried."
>>
>
> Each patch in this series seems to be independent and can be applied
> seperately, so it's probably not necessary to make them incremental.

Surely.
Without considering, I used git-formant-patch -n --thread.
I will keep it in mind.

Thanks, David.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
