Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE7A6B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 12:18:33 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p63so37006345wmp.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 09:18:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pi3si9661919wjb.134.2016.01.27.09.18.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 09:18:32 -0800 (PST)
Subject: Re: [PATCH 16/16] mm/slab: introduce new slab management type,
 OBJFREELIST_SLAB
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1452749069-15334-17-git-send-email-iamjoonsoo.kim@lge.com>
 <56A8C788.9000004@suse.cz>
 <alpine.DEB.2.20.1601271047480.14468@east.gentwo.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56A8FBE4.1060806@suse.cz>
Date: Wed, 27 Jan 2016 18:18:28 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601271047480.14468@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/27/2016 05:48 PM, Christoph Lameter wrote:
> On Wed, 27 Jan 2016, Vlastimil Babka wrote:
> 
>>
>> Can you elaborate? Do we actually need an extendable linked array? Why not just
>> store the pointer to the next free object into the object, NULL for the last
>> one? I.e. a singly-linked list. We should never need to actually traverse it?
>>
>> freeing object obj:
>> *obj = page->freelist;
>> page->freelist = obj;
>>
>> allocating object:
>> obj = page->freelist;
>> page->freelist = *obj;
>> *obj = NULL;
> 
> Well the single linked lists are a concept of another slab allocator. At
> what point do we rename SLAB to SLUB2?

OK. Perhaps a LSF/MM topic then to discuss whether we need both? What are the
remaining cases where SLAB is better choice, and can there be something done
about them in SLUB?

(I can imagine there were such discussions in the past, and I came to kernel
development only in 2013. In that case maybe enough time passed to revisit this?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
