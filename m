Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBAE6B0044
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 15:47:51 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so3258058pad.28
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 12:47:51 -0700 (PDT)
Date: Thu, 10 Oct 2013 21:47:44 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 00/34] dynamically allocate split ptl if it cannot be
 embedded to struct page
Message-ID: <20131010194744.GU13848@laptop.programming.kicks-ass.net>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Thu, Oct 10, 2013 at 09:05:25PM +0300, Kirill A. Shutemov wrote:
> Any comments?

Reviewed-by: Peter Zijlstra <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
