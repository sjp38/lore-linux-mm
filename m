Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f52.google.com (mail-vk0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6416B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 06:20:33 -0400 (EDT)
Received: by vkbf67 with SMTP id f67so52151896vkb.3
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 03:20:33 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id v6si3448513vdh.34.2015.08.17.03.20.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Aug 2015 03:20:32 -0700 (PDT)
Message-ID: <1439805499.2416.14.camel@kernel.crashing.org>
Subject: Re: [RFC PATCH kernel vfio] mm: vfio: Move pages out of CMA before
 pinning
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 17 Aug 2015 19:58:19 +1000
In-Reply-To: <55D1AF06.5090703@suse.cz>
References: <1438762094-17747-1-git-send-email-aik@ozlabs.ru>
	 <55D1910C.7070006@suse.cz> <55D1A525.5090706@ozlabs.ru>
	 <55D1AF06.5090703@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Alexey Kardashevskiy <aik@ozlabs.ru>, linux-mm@kvack.org
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Gibson <david@gibson.dropbear.id.au>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Alexander Graf <agraf@suse.de>, Paolo Bonzini <pbonzini@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>

On Mon, 2015-08-17 at 11:53 +0200, Vlastimil Babka wrote:
> I meant why the kernel used for QEMU has also CMA enabled and used 
> (for 
> something else)? CMA is mostly used on mobile devices and they don't 
> run 
> QEMU?

I explained in a separeate reply but yes, we do use a CMA for KVM for
our MMU hash tables.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
