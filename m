Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 28EAB6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 20:11:00 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h18so5581407igc.8
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 17:11:00 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id u5si3911182igk.27.2014.09.23.17.10.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 17:10:59 -0700 (PDT)
Received: by mail-ig0-f180.google.com with SMTP id a13so5584911igq.13
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 17:10:59 -0700 (PDT)
Date: Tue, 23 Sep 2014 17:10:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, slab: initialize object alignment on cache
 creation
In-Reply-To: <alpine.DEB.2.11.1409231821050.32451@gentwo.org>
Message-ID: <alpine.DEB.2.02.1409231710430.8339@chino.kir.corp.google.com>
References: <20140923141940.e2d3840f31d0f8850b925cf6@linux-foundation.org> <alpine.DEB.2.02.1409231439190.22630@chino.kir.corp.google.com> <alpine.DEB.2.11.1409231821050.32451@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, a.elovikov@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 23 Sep 2014, Christoph Lameter wrote:

> > The proper alignment defaults to BYTES_PER_WORD and can be overridden by
> > SLAB_RED_ZONE or the alignment specified by the caller.
> 
> Where does it default to BYTES_PER_WORD in __kmem_cache_create?
> 

Previous to commit 4590685546a3 ("mm/sl[aou]b: Common alignment code") 
which introduced this issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
