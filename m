Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C77476B025E
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 13:06:13 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l19so3296702pgo.4
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 10:06:13 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u86si3439861pfg.173.2017.11.17.10.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 10:06:12 -0800 (PST)
Date: Fri, 17 Nov 2017 10:06:10 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: filemap: remove include of hardirq.h
Message-ID: <20171117180610.GA24610@bombadil.infradead.org>
References: <1509985319-38633-1-git-send-email-yang.s@alibaba-inc.com>
 <43348133-9c30-4c4f-8bc9-498841a01bd6@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43348133-9c30-4c4f-8bc9-498841a01bd6@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Nov 18, 2017 at 01:58:15AM +0800, Yang Shi wrote:
> Hi folks,
> 
> Any comment on this patch? The quick build test passed on the latest Linus's
> tree.

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
