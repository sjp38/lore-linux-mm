Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8C6B6B0005
	for <linux-mm@kvack.org>; Mon,  2 May 2016 15:14:07 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id c103so306533180qge.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 12:14:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z65si15681025qhc.47.2016.05.02.12.14.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 12:14:07 -0700 (PDT)
Date: Mon, 2 May 2016 21:14:04 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: GUP guarantees wrt to userspace mappings
Message-ID: <20160502191404.GF12310@redhat.com>
References: <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502111513.GA4079@gmail.com>
 <20160502121402.GB23305@node.shutemov.name>
 <20160502133919.GB4079@gmail.com>
 <20160502150013.GA24419@node.shutemov.name>
 <20160502152249.GA5827@gmail.com>
 <20160502161252.GE24419@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160502161252.GE24419@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jerome Glisse <j.glisse@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 02, 2016 at 07:12:52PM +0300, Kirill A. Shutemov wrote:
> Any reason why mmu_notifier is not an option?

No way to trigger an hardware re-tried secondary MMU fault as result
of PCI DMA memory access, and expensive to do an MMU notifier
invalidate if it requires waiting for the DMA to complete (but since
MMU notifier is now sleepable the latter is a secondary concern).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
