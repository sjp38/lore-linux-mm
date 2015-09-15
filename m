Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id DB4D16B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 14:31:45 -0400 (EDT)
Received: by iofb144 with SMTP id b144so209010780iof.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 11:31:45 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id e193si14550005ioe.131.2015.09.15.11.31.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 15 Sep 2015 11:31:45 -0700 (PDT)
Date: Tue, 15 Sep 2015 13:31:43 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCHv6 2/7] slab, slub: use page->rcu_head instead of page->lru
 plus cast
In-Reply-To: <1442312895-124384-3-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.11.1509151331260.14278@east.gentwo.org>
References: <1442312895-124384-1-git-send-email-kirill.shutemov@linux.intel.com> <1442312895-124384-3-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 15 Sep 2015, Kirill A. Shutemov wrote:

> We have properly typed page->rcu_head, no need to cast page->lru.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
