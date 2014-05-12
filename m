Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 600F96B0037
	for <linux-mm@kvack.org>; Sun, 11 May 2014 23:36:34 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so7391239pab.17
        for <linux-mm@kvack.org>; Sun, 11 May 2014 20:36:34 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fm5si5665532pbc.206.2014.05.11.20.36.32
        for <linux-mm@kvack.org>;
        Sun, 11 May 2014 20:36:33 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCHv2 0/2] remap_file_pages() decommission
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com>
Date: Sun, 11 May 2014 20:36:32 -0700
In-Reply-To: <CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com>
	(Armin Rigo's message of "Thu, 8 May 2014 17:44:46 +0200")
Message-ID: <87tx8v4qin.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Armin Rigo <arigo@tunes.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

Armin Rigo <arigo@tunes.org> writes:

> Here is a note from the PyPy project (mentioned earlier in this
> thread, and at https://lwn.net/Articles/587923/ ).

Your use is completely bogus. remap_file_pages() pins everything 
and disables any swapping for the area.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
