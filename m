Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 531376B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 23:46:14 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so113847410pfb.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 20:46:14 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id r6si6650841pap.212.2016.01.26.20.46.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 20:46:13 -0800 (PST)
Date: Wed, 27 Jan 2016 13:46:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 00/16] mm/slab: introduce new freed objects management
 way, OBJFREELIST_SLAB
Message-ID: <20160127044614.GA8326@js1304-P5Q-DELUXE>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160126204013.a065301b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160126204013.a065301b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 26, 2016 at 08:40:13PM -0800, Andrew Morton wrote:
> On Thu, 14 Jan 2016 14:24:13 +0900 Joonsoo Kim <js1304@gmail.com> wrote:
> 
> > This patchset implements new freed object management way, that is,
> > OBJFREELIST_SLAB. Purpose of it is to reduce memory overhead in SLAB.
> > 
> > SLAB needs a array to manage freed objects in a slab. If there is
> > leftover after objects are packed into a slab, we can use it as
> > a management array, and, in this case, there is no memory waste.
> > But, in the other cases, we need to allocate extra memory for
> > a management array or utilize dedicated internal memory in a slab for it.
> > Both cases causes memory waste so it's not good.
> > 
> > With this patchset, freed object itself can be used for a management
> > array. So, memory waste could be reduced. Detailed idea and numbers
> > are described in last patch's commit description. Please refer it.
> > 
> > In fact, I tested another idea implementing OBJFREELIST_SLAB with
> > extendable linked array through another freed object. It can remove
> > memory waste completely but it causes more computational overhead
> > in critical lock path and it seems that overhead outweigh benefit.
> > So, this patchset doesn't include it. I will attach prototype just for
> > a reference.
> 
> It appears that this patchset is perhaps due a couple of touchups from
> Christoph's comments.  I'll grab it as-is as I want to get an mmotm
> into linux-next tomorrow then vanish for a few days.

Hello, Andrew.

Could you add just one small fix below to 16/16 "mm/slab: introduce
new slab management type, OBJFREELIST_SLAB"?

Thanks.


------------>8-------------
