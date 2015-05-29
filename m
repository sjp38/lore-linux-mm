Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1A02A6B00A1
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:22:45 -0400 (EDT)
Received: by pdea3 with SMTP id a3so55810377pde.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:22:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.9])
        by mx.google.com with ESMTPS id xi9si8820448pbc.158.2015.05.29.08.22.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:22:43 -0700 (PDT)
Date: Fri, 29 May 2015 08:22:41 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] zpool: add EXPORT_SYMBOL for functions
Message-ID: <20150529152241.GA22726@infradead.org>
References: <1432912172-16591-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432912172-16591-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 29, 2015 at 11:09:32AM -0400, Dan Streetman wrote:
> Export the zpool functions that should be exported.

Why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
