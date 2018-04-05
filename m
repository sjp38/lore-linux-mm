Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E85E6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 17:48:36 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o3-v6so18573221pls.11
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 14:48:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t3-v6si8665940ply.344.2018.04.05.14.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 14:48:34 -0700 (PDT)
Date: Thu, 5 Apr 2018 14:48:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 06/25] slab: make kmem_cache_create() work with 32-bit
 sizes
Message-Id: <20180405144833.41d16216c8c010294664e8ce@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.20.1803061235260.29393@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com>
	<20180305200730.15812-6-adobriyan@gmail.com>
	<alpine.DEB.2.20.1803061235260.29393@nuc-kabylake>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Tue, 6 Mar 2018 12:37:49 -0600 (CST) Christopher Lameter <cl@linux.com> wrote:

> On Mon, 5 Mar 2018, Alexey Dobriyan wrote:
> 
> > struct kmem_cache::size and ::align were always 32-bit.
> >
> > Out of curiosity I created 4GB kmem_cache, it oopsed with division by 0.
> > kmem_cache_create(1UL<<32+1) created 1-byte cache as expected.
> 
> Could you add a check to avoid that in the future?
> 
> > size_t doesn't work and never did.
> 
> Its not so simple. Please verify that the edge cases of all object size /
> alignment etc calculations are doable with 32 bit entities first.
> 
> And size_t makes sense as a parameter.

Alexey, please don't let this stuff dangle on.

I think I'll merge this as-is but some fixups might be needed as a
result of Christoph's suggestion?
