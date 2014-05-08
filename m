Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5946B0111
	for <linux-mm@kvack.org>; Thu,  8 May 2014 14:14:24 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id e51so1978195eek.10
        for <linux-mm@kvack.org>; Thu, 08 May 2014 11:14:23 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id v2si2210522eel.256.2014.05.08.11.14.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 May 2014 11:14:23 -0700 (PDT)
Date: Thu, 8 May 2014 14:14:16 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, thp: close race between mremap() and
 split_huge_page()
Message-ID: <20140508181416.GN19914@cmpxchg.org>
References: <1399328011-15317-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20140506130655.GE19914@cmpxchg.org>
 <CANN689GqmdRpOOHV7uYCLgu+xKcYQ5_ESw7+-djNpVGo=D-+WQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689GqmdRpOOHV7uYCLgu+xKcYQ5_ESw7+-djNpVGo=D-+WQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, stable@vger.kernel.org

On Wed, May 07, 2014 at 05:13:32PM -0700, Michel Lespinasse wrote:
> On Tue, May 6, 2014 at 6:06 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > Fixes: 108d6642ad81 ("mm anon rmap: remove anon_vma_moveto_tail")
> 
> I think 108d6642ad81 on its own was OK (as it always took the locks);
> but the attempt to not take them in the common case in 38a76013ad80 is
> where I forgot to consider the THP case.

108d6642ad81 replaced the chain ordering with an explicit lock, but I
see the unconditional locking only in move_ptes(), which isn't called
for THP pmds.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
