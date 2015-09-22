Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 903496B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:54:26 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so16733418pac.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:54:26 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id pq4si4534302pac.95.2015.09.22.11.54.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 11:54:25 -0700 (PDT)
Received: by pablk4 with SMTP id lk4so1046439pab.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:54:25 -0700 (PDT)
Date: Tue, 22 Sep 2015 11:54:17 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Multiple potential races on vma->vm_flags
In-Reply-To: <CAAeHK+wABeppPQCsTmUk6cMswJosgkaXkHO5QTFBh=1ZTi+-3w@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1509221151370.11653@eggly.anvils>
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com> <55EC9221.4040603@oracle.com> <20150907114048.GA5016@node.dhcp.inet.fi> <55F0D5B2.2090205@oracle.com> <20150910083605.GB9526@node.dhcp.inet.fi>
 <CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com> <20150911103959.GA7976@node.dhcp.inet.fi> <alpine.LSU.2.11.1509111734480.7660@eggly.anvils> <55F8572D.8010409@oracle.com> <20150915190143.GA18670@node.dhcp.inet.fi>
 <CAAeHK+wABeppPQCsTmUk6cMswJosgkaXkHO5QTFBh=1ZTi+-3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Tue, 22 Sep 2015, Andrey Konovalov wrote:
> If anybody comes up with a patch to fix the original issue I easily
> can test it, since I'm hitting "BUG: Bad page state" in a second when
> fuzzing with KTSAN and Trinity.

This "BUG: Bad page state" sounds more serious, but I cannot track down
your report of it: please repost - thanks - though on seeing it, I may
well end up with no ideas.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
