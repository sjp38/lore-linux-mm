Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 013DF6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 23:38:44 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id q63so113737515pfb.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 20:38:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b14si6684133pfd.63.2016.01.26.20.38.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 20:38:43 -0800 (PST)
Date: Tue, 26 Jan 2016 20:40:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/16] mm/slab: introduce new freed objects management
 way, OBJFREELIST_SLAB
Message-Id: <20160126204013.a065301b.akpm@linux-foundation.org>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 14 Jan 2016 14:24:13 +0900 Joonsoo Kim <js1304@gmail.com> wrote:

> This patchset implements new freed object management way, that is,
> OBJFREELIST_SLAB. Purpose of it is to reduce memory overhead in SLAB.
> 
> SLAB needs a array to manage freed objects in a slab. If there is
> leftover after objects are packed into a slab, we can use it as
> a management array, and, in this case, there is no memory waste.
> But, in the other cases, we need to allocate extra memory for
> a management array or utilize dedicated internal memory in a slab for it.
> Both cases causes memory waste so it's not good.
> 
> With this patchset, freed object itself can be used for a management
> array. So, memory waste could be reduced. Detailed idea and numbers
> are described in last patch's commit description. Please refer it.
> 
> In fact, I tested another idea implementing OBJFREELIST_SLAB with
> extendable linked array through another freed object. It can remove
> memory waste completely but it causes more computational overhead
> in critical lock path and it seems that overhead outweigh benefit.
> So, this patchset doesn't include it. I will attach prototype just for
> a reference.

It appears that this patchset is perhaps due a couple of touchups from
Christoph's comments.  I'll grab it as-is as I want to get an mmotm
into linux-next tomorrow then vanish for a few days.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
