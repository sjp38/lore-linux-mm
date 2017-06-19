Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBBE46B03BD
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 09:25:14 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 95so23173123lfq.5
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 06:25:14 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id v24si4572258ljd.217.2017.06.19.06.25.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 06:25:13 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id m77so55972595lfe.0
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 06:25:13 -0700 (PDT)
Date: Mon, 19 Jun 2017 16:25:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Fix THP handling in invalidate_mapping_pages()
Message-ID: <20170619132510.4uzwyww43g5jt5si@node.shutemov.name>
References: <20170619124723.21656-1-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170619124723.21656-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, Jun 19, 2017 at 02:47:23PM +0200, Jan Kara wrote:
> The condition checking for THP straddling end of invalidated range is
> wrong - it checks 'index' against 'end' but 'index' has been already
> advanced to point to the end of THP and thus the condition can never be
> true. As a result THP straddling 'end' has been fully invalidated. Given
> the nature of invalidate_mapping_pages(), this could be only performance
> issue. In fact, we are lucky the condition is wrong because if it was
> ever true, we'd leave locked page behind.
> 
> Fix the condition checking for THP straddling 'end' and also properly
> unlock the page. Also update the comment before the condition to explain
> why we decide not to invalidate the page as it was not clear to me and I
> had to ask Kirill.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Thanks a lot for the fix.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
