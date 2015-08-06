Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 97C3C6B0253
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 22:07:54 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so25966417pdr.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 19:07:54 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id i2si8626966pdc.102.2015.08.05.19.07.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 19:07:53 -0700 (PDT)
Received: by pdco4 with SMTP id o4so25743307pdc.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 19:07:53 -0700 (PDT)
Date: Wed, 5 Aug 2015 19:07:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: vm_flags, vm_flags_t and __nocast
In-Reply-To: <20150803155155.7F8546E@black.fi.intel.com>
Message-ID: <alpine.DEB.2.10.1508051907320.4843@chino.kir.corp.google.com>
References: <201507241628.EnDEXbaF%fengguang.wu@intel.com> <20150724100940.GB22732@node.dhcp.inet.fi> <alpine.DEB.2.10.1507241314300.5215@chino.kir.corp.google.com> <20150803155155.7F8546E@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, Oleg Nesterov <oleg@redhat.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, 3 Aug 2015, Kirill A. Shutemov wrote:

> From f690ec43103e55d0ed533fc977f9ac3cfa29d8f6 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 3 Aug 2015 18:49:18 +0300
> Subject: [PATCH] mm: drop __nocast from vm_flags_t definition
> 
> __nocast does no good for vm_flags_t. It only produces useless sparse
> warnings.
> 
> Let's drop it.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
