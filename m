Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 92A1E6B0036
	for <linux-mm@kvack.org>; Fri,  9 May 2014 04:44:45 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id q108so4025372qgd.41
        for <linux-mm@kvack.org>; Fri, 09 May 2014 01:44:45 -0700 (PDT)
Received: from mail-qa0-x230.google.com (mail-qa0-x230.google.com [2607:f8b0:400d:c00::230])
        by mx.google.com with ESMTPS id l110si1740556qgf.59.2014.05.09.01.44.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 May 2014 01:44:45 -0700 (PDT)
Received: by mail-qa0-f48.google.com with SMTP id i13so3732022qae.21
        for <linux-mm@kvack.org>; Fri, 09 May 2014 01:44:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140508181416.GN19914@cmpxchg.org>
References: <1399328011-15317-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20140506130655.GE19914@cmpxchg.org>
	<CANN689GqmdRpOOHV7uYCLgu+xKcYQ5_ESw7+-djNpVGo=D-+WQ@mail.gmail.com>
	<20140508181416.GN19914@cmpxchg.org>
Date: Fri, 9 May 2014 01:44:43 -0700
Message-ID: <CANN689Hy+4YV6y0mhLQNBO_4GwAABtNQjFF5B4mDrwtTZGs8aQ@mail.gmail.com>
Subject: Re: [PATCH] mm, thp: close race between mremap() and split_huge_page()
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, stable@vger.kernel.org

On Thu, May 8, 2014 at 11:14 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Wed, May 07, 2014 at 05:13:32PM -0700, Michel Lespinasse wrote:
>> On Tue, May 6, 2014 at 6:06 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>> > Fixes: 108d6642ad81 ("mm anon rmap: remove anon_vma_moveto_tail")
>>
>> I think 108d6642ad81 on its own was OK (as it always took the locks);
>> but the attempt to not take them in the common case in 38a76013ad80 is
>> where I forgot to consider the THP case.
>
> 108d6642ad81 replaced the chain ordering with an explicit lock, but I
> see the unconditional locking only in move_ptes(), which isn't called
> for THP pmds.

Ah yes, you are right.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
