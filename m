Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 724DB6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 17:51:11 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z2-v6so6302683plk.3
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 14:51:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g3-v6si8960284plb.536.2018.04.05.14.51.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 14:51:10 -0700 (PDT)
Date: Thu, 5 Apr 2018 14:51:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 23/25] slub: make struct kmem_cache_order_objects::x
 unsigned int
Message-Id: <20180405145108.e1a9f788bea329653505cadc@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.20.1803061248540.29393@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com>
	<20180305200730.15812-23-adobriyan@gmail.com>
	<alpine.DEB.2.20.1803061248540.29393@nuc-kabylake>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Tue, 6 Mar 2018 12:51:47 -0600 (CST) Christopher Lameter <cl@linux.com> wrote:

> On Mon, 5 Mar 2018, Alexey Dobriyan wrote:
> 
> > struct kmem_cache_order_objects is for mixing order and number of objects,
> > and orders aren't bit enough to warrant 64-bit width.
> >
> > Propagate unsignedness down so that everything fits.
> >
> > !!! Patch assumes that "PAGE_SIZE << order" doesn't overflow. !!!
> 
> PAGE_SIZE could be a couple of megs on some platforms (256 or so on
> Itanium/PowerPC???) . So what are the worst case scenarios here?
> 
> I think both order and # object should fit in a 32 bit number.
> 
> A page with 256M size and 4 byte objects would have 64M objects.

Another dangling review comment.  Alexey, please respond?
