Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id CC77E6B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 03:58:44 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id g10so417435pdj.35
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 00:58:44 -0700 (PDT)
Message-ID: <525E4669.7090005@synopsys.com>
Date: Wed, 16 Oct 2013 13:25:21 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/34] arc: handle pgtable_page_ctor() fail
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com> <1381428359-14843-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-11-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo
 Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On 10/10/2013 11:35 PM, Kirill A. Shutemov wrote:
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Vineet Gupta <vgupta@synopsys.com> [for arch/arc bits]

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
