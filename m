Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2F36B02B4
	for <linux-mm@kvack.org>; Tue, 23 May 2017 04:40:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l73so156332571pfj.8
        for <linux-mm@kvack.org>; Tue, 23 May 2017 01:40:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u22si20823338plk.91.2017.05.23.01.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 01:40:08 -0700 (PDT)
Date: Tue, 23 May 2017 01:40:07 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: Define KB, MB, GB, TB in core VM
Message-ID: <20170523084007.GA10308@infradead.org>
References: <20170522111742.29433-1-khandual@linux.vnet.ibm.com>
 <20170522141149.9ef84bb0713769f4af0383f0@linux-foundation.org>
 <20170523070227.GA27864@infradead.org>
 <09a6bafa-5743-425e-8def-bd9219cd756c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <09a6bafa-5743-425e-8def-bd9219cd756c@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 23, 2017 at 10:38:17AM +0200, Vlastimil Babka wrote:
> Those defined in the patch are binary, not decimal. Do we even need
> decimal ones?

Oh, good point.  In which case the names should change to avoid the
confusion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
