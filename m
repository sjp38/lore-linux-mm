Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B85846B02AA
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:08:33 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id f4so161542810qte.1
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 10:08:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e23si13690551qtc.222.2017.01.24.10.08.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 10:08:32 -0800 (PST)
Message-ID: <1485281310.15964.34.camel@redhat.com>
Subject: Re: [PATCH 01/12] uprobes: split THPs before trying replace them
From: Rik van Riel <riel@redhat.com>
Date: Tue, 24 Jan 2017 13:08:30 -0500
In-Reply-To: <20170124162824.91275-2-kirill.shutemov@linux.intel.com>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
	 <20170124162824.91275-2-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 2017-01-24 at 19:28 +0300, Kirill A. Shutemov wrote:
> For THPs page_check_address() always fails. It's better to split them
> first before trying to replace.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Peter Zijlstra <peterz@infradead.org>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
