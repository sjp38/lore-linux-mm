Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 89C146B0254
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 16:03:43 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id p65so7038747wmp.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:03:43 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id j83si22081262wmj.84.2016.02.29.13.03.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 13:03:42 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id l68so6938249wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:03:42 -0800 (PST)
Date: Tue, 1 Mar 2016 00:03:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: readahead: do not cap readahead() and MADV_WILLNEED
Message-ID: <20160229210339.GA15095@node.shutemov.name>
References: <1456277927-12044-1-git-send-email-hannes@cmpxchg.org>
 <CA+55aFzQr-8fOfzA97nZd07L8EFRgXSLSorrw1xVm_KMYinfdA@mail.gmail.com>
 <20160229194159.GB29896@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160229194159.GB29896@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Mon, Feb 29, 2016 at 02:41:59PM -0500, Johannes Weiner wrote:
> That, or switch to read() from a separate thread for cache priming.

mmap(MAP_POPULATE) would save you some copy_to_user() overhead, comparing
to read().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
