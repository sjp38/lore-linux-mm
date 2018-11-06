Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE4B6B02F8
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 04:45:41 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id m1-v6so12823497plb.13
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 01:45:41 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id a3-v6si16787233plp.323.2018.11.06.01.45.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 01:45:40 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] slab.h: Avoid using & for logical and of booleans
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
Date: Tue, 6 Nov 2018 02:45:28 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <210D9DA6-67F2-4CF3-94FC-883AA890F53A@oracle.com>
References: <20181105204000.129023-1-bvanassche@acm.org> <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Bart Van Assche <bvanassche@acm.org>, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, Roman Gushchin <guro@fb.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org



> On Nov 5, 2018, at 14:13, Andrew Morton <akpm@linux-foundation.org> wrote:=

>=20
>> On Mon,  5 Nov 2018 12:40:00 -0800 Bart Van Assche <bvanassche@acm.org> w=
rote:
>> -    return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
>> +    return type_dma + is_reclaimable * !is_dma * KMALLOC_RECLAIM;
>> }
>>=20
>> /*
>=20
> I suppose so.
>=20
> That function seems too clever for its own good :(.  I wonder if these
> branch-avoiding tricks are really worthwhile.

At the very least I'd like to see some comments added as to why that approac=
h was taken for the sake of future maintainers.

William Kucharski
