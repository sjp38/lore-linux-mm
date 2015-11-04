Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 96C076B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 03:46:37 -0500 (EST)
Received: by padhx2 with SMTP id hx2so38965287pad.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 00:46:37 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id ba4si621658pbb.20.2015.11.04.00.46.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 00:46:36 -0800 (PST)
Received: by padda3 with SMTP id da3so5661489pad.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 00:46:36 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH] mm: change tlb_finish_mmu() to be more simple
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151104083610.GA403@swordfish>
Date: Wed, 4 Nov 2015 16:46:25 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <58D5B463-D8C3-40E2-A0B0-458DB1117338@gmail.com>
References: <1446622531-316-1-git-send-email-yalin.wang2010@gmail.com> <20151104083610.GA403@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, riel@redhat.com, raindel@mellanox.com, willy@linux.intel.com, boaz@plexistor.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Nov 4, 2015, at 16:36, Sergey Senozhatsky =
<sergey.senozhatsky.work@gmail.com> wrote:
>=20
> On (11/04/15 15:35), yalin wang wrote:
> [..]
>>=20
>> -	for (batch =3D tlb->local.next; batch; batch =3D next) {
>> -		next =3D batch->next;
>> +	for (batch =3D tlb->local.next; batch; batch =3D batch->next)
>> 		free_pages((unsigned long)batch, 0);
>=20
> accessing `batch->next' after calling free_pages() on `batch'?
>=20
> 		-ss
oh,  my mistake, my code is buggy here .

Thanks=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
