Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 50CBB6B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:21:34 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id 128so57259546wmz.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 07:21:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qr6si22711056wjc.206.2016.01.29.07.21.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Jan 2016 07:21:33 -0800 (PST)
Subject: Re: [PATCH 16/16] mm/slab: introduce new slab management type,
 OBJFREELIST_SLAB
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1452749069-15334-17-git-send-email-iamjoonsoo.kim@lge.com>
 <56A8C788.9000004@suse.cz> <20160128045128.GC14467@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56AB837A.5090702@suse.cz>
Date: Fri, 29 Jan 2016 16:21:30 +0100
MIME-Version: 1.0
In-Reply-To: <20160128045128.GC14467@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/28/2016 05:51 AM, Joonsoo Kim wrote:
> On Wed, Jan 27, 2016 at 02:35:04PM +0100, Vlastimil Babka wrote:
>> On 01/14/2016 06:24 AM, Joonsoo Kim wrote:
>> > In fact, I tested another idea implementing OBJFREELIST_SLAB with
>> > extendable linked array through another freed object. It can remove
>> > memory waste completely but it causes more computational overhead
>> > in critical lock path and it seems that overhead outweigh benefit.
>> > So, this patch doesn't include it.
>> 
>> Can you elaborate? Do we actually need an extendable linked array? Why not just
>> store the pointer to the next free object into the object, NULL for the last
>> one? I.e. a singly-linked list. We should never need to actually traverse it?
> 
> As Christoph explained, it's the way SLUB manages freed objects. In SLAB
> case, it doesn't want to touch object itself. It's one of main difference
> between SLAB and SLUB. These objects are cache-cold now so touching object itself
> could cause more cache footprint.

Hm I see. Although I wouldn't bet on whether the now-freed object is more or
less cold than the freelist array itself (regardless of its placement) :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
