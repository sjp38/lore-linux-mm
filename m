Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id A7C6F6B0038
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 18:03:24 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id uq10so4793919igb.6
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 15:03:24 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id j1si13543357igx.5.2014.06.30.15.03.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 15:03:24 -0700 (PDT)
Received: by mail-ie0-f179.google.com with SMTP id tr6so7484170ieb.38
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 15:03:23 -0700 (PDT)
Date: Mon, 30 Jun 2014 15:03:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: mm: slub: invalid memory access in setup_object
In-Reply-To: <alpine.DEB.2.11.1406251228130.29216@gentwo.org>
Message-ID: <alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com>
References: <53AAFDF7.2010607@oracle.com> <alpine.DEB.2.11.1406251228130.29216@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>, Sasha Levin <sasha.levin@oracle.com>, Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Wed, 25 Jun 2014, Christoph Lameter wrote:

> On Wed, 25 Jun 2014, Sasha Levin wrote:
> 
> > [  791.669480] ? init_object (mm/slub.c:665)
> > [  791.669480] setup_object.isra.34 (mm/slub.c:1008 mm/slub.c:1373)
> > [  791.669480] new_slab (mm/slub.c:278 mm/slub.c:1412)
> 
> So we just got a new page from the page allocator but somehow cannot
> write to it. This is the first write access to the page.
> 

I'd be inclined to think that this was a result of "slub: reduce duplicate 
creation on the first object" from -mm[*] that was added the day before 
Sasha reported the problem.

It's not at all clear to me that that patch is correct.  Wei?

Sasha, with a revert of that patch, does this reproduce?

 [*] http://ozlabs.org/~akpm/mmotm/broken-out/slub-reduce-duplicate-creation-on-the-first-object.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
