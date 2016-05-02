Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9A56B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 11:17:35 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id x189so196035630ywe.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:17:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 134si14955898qkh.103.2016.05.02.08.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 08:17:34 -0700 (PDT)
Date: Mon, 2 May 2016 16:15:38 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: GUP guarantees wrt to userspace mappings redesign
Message-ID: <20160502141538.GA5961@redhat.com>
References: <20160428181726.GA2847@node.shutemov.name> <20160428125808.29ad59e5@t450s.home> <20160428232127.GL11700@redhat.com> <20160429005106.GB2847@node.shutemov.name> <20160428204542.5f2053f7@ul30vt.home> <20160429070611.GA4990@node.shutemov.name> <20160429163444.GM11700@redhat.com> <20160502104119.GA23305@node.shutemov.name> <20160502111513.GA4079@gmail.com> <20160502121402.GB23305@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160502121402.GB23305@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jerome Glisse <j.glisse@gmail.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

I am sure I missed the problem, but...

On 05/02, Kirill A. Shutemov wrote:
>
> Quick look around:
>
>  - I don't see any check page_count() around __replace_page() in uprobes,
>    so it can easily replace pinned page.

Why it should? even if it races with get_user_pages_fast()... this doesn't
differ from the case when an application writes to MAP_PRIVATE non-anonymous
region, no?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
