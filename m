Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8526B0044
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 15:50:35 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so3130624pdj.16
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 12:50:35 -0700 (PDT)
Message-ID: <52570507.9080704@tilera.com>
Date: Thu, 10 Oct 2013 15:50:31 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH 28/34] tile: handle pgtable_page_ctor() fail
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com> <1381428359-14843-29-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-29-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On 10/10/2013 2:05 PM, Kirill A. Shutemov wrote:
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Chris Metcalf <cmetcalf@tilera.com>
> ---
>  arch/tile/mm/pgtable.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
