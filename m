Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5EA6B063F
	for <linux-mm@kvack.org>; Thu, 10 May 2018 16:06:31 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f10-v6so1757490pln.21
        for <linux-mm@kvack.org>; Thu, 10 May 2018 13:06:31 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id v6-v6si1243911pgs.399.2018.05.10.13.06.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 13:06:29 -0700 (PDT)
Date: Thu, 10 May 2018 14:06:24 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH -mm] mm, THP, doc: Add document for
 thp_swpout/thp_swpout_fallback
Message-ID: <20180510140624.6de120e8@lwn.net>
In-Reply-To: <20180509082341.13953-1-ying.huang@intel.com>
References: <20180509082341.13953-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed,  9 May 2018 16:23:41 +0800
"Huang, Ying" <ying.huang@intel.com> wrote:

> From: Huang Ying <ying.huang@intel.com>
> 
> Add document for newly added thp_swpout, thp_swpout_fallback fields in
> /proc/vmstat.
> 
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Applied, thanks.

jon
